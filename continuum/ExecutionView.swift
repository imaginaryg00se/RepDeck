//
//  ExecutionView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI
import SwiftData

struct ExecutionView: View {
    @Binding var isWorkoutActive: Bool
    @Binding var selectedTab: Int
    @Binding var workoutJustCompleted: Bool
    
    @Query var plans: [Plan]
    
    @State private var completedSets: [UUID: Int] = [:]
    @State private var cardWidth: CGFloat = 300
    
    // Abandon-gesture state
    @State private var abandonOffset: CGFloat = 0      // thumb position, 0…maxOffset
    @State private var abandonArmed = false            // overlay visible?
    @State private var abandonCommitted = false        // crossed commit threshold? (haptic latch)

    // Abandon-gesture constants
    private let thumbWidth: CGFloat = 56
    private let commitFraction: CGFloat = 0.88         // slide this far → commit
    
    @Environment(\.modelContext) private var modelContext
    
    // Save state of execution engine
    @AppStorage("completedSetsData") private var completedSetsData: Data = Data()
    @AppStorage("currentPage") private var currentPage = 0
    
    var todayExercises: [ScheduledExercise] {
        let today = Calendar.current.component(.weekday, from: Date())
        return plans.first?.planDays
            .first(where: { $0.dayOfWeek == today })?
            .scheduledExercises
            .sorted { $0.orderIndex < $1.orderIndex } ?? []
    }
    
    var totalSets: Int {
        todayExercises.reduce(0) { $0 + $1.workingSets }
    }
    
    var totalCompletedSets: Int {
        completedSets.values.reduce(0, +)
    }
    
    private var progressHeader: some View {
        VStack(spacing: 4) {
            Text("Workout Progress")
                .font(.headline)
            Text("\(totalCompletedSets)/\(totalSets)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            ProgressView(value: Double(totalCompletedSets), total: Double(totalSets))
                .tint(.blue)
                .padding(.horizontal)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
    }
    
    private var headerZone: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width
            let maxOffset = trackWidth - thumbWidth

            ZStack {
                progressHeader
                    .opacity(abandonArmed ? 0 : 1)

                if abandonArmed {
                    abandonTrack(maxOffset: maxOffset)
                        .transition(.opacity)
                }
            }
            .contentShape(Rectangle())              // whole zone hit-testable, incl. empty space
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { v in
                        if !abandonArmed {
                            withAnimation(.easeOut(duration: 0.15)) { abandonArmed = true }
                        }
                        abandonOffset = min(max(0, v.translation.width), maxOffset)
                    }
                    .onEnded { _ in
                        if abandonOffset >= maxOffset * commitFraction {
                            endWorkout()
                        } else {
                            withAnimation(.spring()) {
                                abandonOffset = 0
                                abandonArmed = false
                            }
                        }
                    }
            )
        }
        .frame(height: 60)                          // reserve the header's vertical space
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            headerZone
                .padding(.horizontal)
                .padding(.top)
            
            // Carousel
            TabView(selection: $currentPage) {
                ForEach(Array(todayExercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                    VStack(spacing: 3) {
                        ZStack {
                            // Ghost base card
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 300, height: 200)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray.opacity(0.4))
                                )
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                cardWidth = geometry.size.width
                                            }
                                    }
                                )
                            
                            // Active cards
                            let remaining = exercise.workingSets - (completedSets[exercise.id] ?? 0)
                            ForEach(0..<max(remaining, 0), id: \.self) { setIndex in
                                SetCard(
                                    exerciseName: exercise.exerciseTemplate?.displayName ?? "Unknown",
                                    weight: exercise.targetWeight,
                                    reps: exercise.targetReps,
                                    onCompleted: {
                                        completeSet(exercise: exercise, exerciseIndex: exerciseIndex)
                                    }
                                )
                                .offset(x: 0, y: CGFloat(setIndex) * -8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .disabled(setIndex != remaining - 1)
                            }
                            .animation(.easeOut(duration: 0.3), value: completedSets[exercise.id])
                        }
                        
                        // Exercise-level segmented progress bar
                        HStack(spacing: 3) {
                            ForEach(0..<exercise.workingSets, id: \.self) { segmentIndex in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(segmentIndex < (completedSets[exercise.id] ?? 0)
                                          ? Color.green
                                          : Color.gray.opacity(0.3))
                                    .frame(height: 6)
                            }
                        }
                        .padding(.horizontal)
                        .animation(.easeOut(duration: 0.3), value: completedSets[exercise.id])
                        .frame(width: cardWidth)
                    }
                    .tag(exerciseIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentPage) {
                let feedback = UISelectionFeedbackGenerator()
                feedback.selectionChanged()
            }
            
            // Custom dot navigation
            HStack(spacing: 20) {
                ForEach(todayExercises.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 20 : 15,
                                   height: index == currentPage ? 20 : 15)
                        Text("\(index + 1)")
                            .font(.system(size: 9))
                            .foregroundColor(index == currentPage ? .white : .white.opacity(0.3))
                    }
                    .onTapGesture {
                        withAnimation {
                            currentPage = index
                        }
                    }
                }
            }
            .padding()
        }
        
        // On the root view of ExecutionView's body
        .onChange(of: completedSets) { _, _ in
            persistCompletedSets()
        }
        .onAppear {
            loadCompletedSets()
        }
        
    }
    
    // Helper function handling set completion behavior
    func completeSet(exercise: ScheduledExercise, exerciseIndex: Int) {
            withAnimation(.easeOut(duration: 0.3)) {
            completedSets[exercise.id, default: 0] += 1
        }
        
        let completed = completedSets[exercise.id] ?? 0
        let isExhausted = completed >= exercise.workingSets
        
        if isExhausted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                // Once a stack is exhausted, move to next available stack
                let nextIndex = todayExercises.indices
                    .filter { idx in
                        let ex = todayExercises[idx]
                        let done = completedSets[ex.id] ?? 0
                        return idx != exerciseIndex && done < ex.workingSets
                    }
                    .first(where: { $0 > exerciseIndex })
                    ?? todayExercises.indices.first(where: { idx in
                        let ex = todayExercises[idx]
                        let done = completedSets[ex.id] ?? 0
                        return done < ex.workingSets
                    })
                
                if let next = nextIndex {
                    withAnimation {
                        currentPage = next
                    }
                } else {
                    // Workout complete
                    completeWorkout()
                }
            }
        }
    }
    // Helper function hanlding record keeping
    func saveWorkoutLog() {
        let workoutLog = WorkoutLog(date: Date(), duration: 0)
        modelContext.insert(workoutLog)
        
        // include ALL exercises, even if setsCompleted = 0
        for exercise in todayExercises {
            // find the number of completedSets for a given exercise
            let setsCompleted = completedSets[exercise.id] ?? 0
            
            let exerciseLog = ExerciseLog(
                exerciseName: exercise.exerciseTemplate?.displayName ?? "Unknown",
                targetSets: exercise.workingSets,
                setsCompleted: setsCompleted,
                targetReps: exercise.targetReps,
                targetWeight: exercise.targetWeight,
                notes: exercise.notes
            )
            modelContext.insert(exerciseLog)
            // Add exerciseLog to workoutLog
            workoutLog.exerciseLogs.append(exerciseLog)
        }
        
        try? modelContext.save()
    }
    
    @ViewBuilder
    private func abandonTrack(maxOffset: CGFloat) -> some View {
        // 0…1 progress along the track, for color + label fade
        let progress = maxOffset > 0 ? abandonOffset / maxOffset : 0
        let committed = progress >= commitFraction

        ZStack(alignment: .leading) {
            // Track background — ramps neutral → red as you slide
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.12 + 0.33 * progress))

            // Filled trail behind the thumb
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.25 + 0.45 * progress))
                .frame(width: abandonOffset + thumbWidth)

            // Label — fades out as the thumb advances over it
            Text(committed ? "Release to end" : "Slide to end workout")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundColor(.white.opacity(committed ? 1 : 0.7 - 0.4 * progress))
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)

            // Thumb
            ZStack {
                Circle().fill(.white)
                Image(systemName: committed ? "checkmark" : "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
            }
            .frame(width: thumbWidth, height: thumbWidth)
            .offset(x: abandonOffset)
            .shadow(radius: 2, y: 1)
        }
        .frame(height: thumbWidth)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func endWorkout() {
        // 1. Clear the durable buffer FIRST — explicitly, not via the .onChange mirror.
        completedSetsData = Data()

        // 2. Reset in-memory execution state
        completedSets = [:]
        currentPage = 0

        // 3. Reset gesture state so a re-entered workout starts clean
        abandonOffset = 0
        abandonArmed = false
        abandonCommitted = false

        // 4. Flip the flag last — this dismisses the fullScreenCover and tears down this view
        isWorkoutActive = false
    }
    
    private func completeWorkout() {
        saveWorkoutLog()            // Writes to history
        workoutJustCompleted = true // Pulls up summary
        selectedTab = 2             // Navigates to history tab
        endWorkout()                // Reset
    }

    private func persistCompletedSets() {
        let encodable = completedSets.reduce(into: [String: Int]()) { $0[$1.key.uuidString] = $1.value }
        completedSetsData = (try? JSONEncoder().encode(encodable)) ?? Data()
    }

    private func loadCompletedSets() {
        guard !completedSetsData.isEmpty,
              let decoded = try? JSONDecoder().decode([String: Int].self, from: completedSetsData)
        else { return }
        completedSets = decoded.reduce(into: [UUID: Int]()) { dict, pair in
            if let id = UUID(uuidString: pair.key) { dict[id] = pair.value }
        }
    }
    
}
