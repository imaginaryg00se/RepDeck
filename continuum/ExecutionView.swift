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
    @State private var currentPage = 0
    @State private var cardWidth: CGFloat = 300
    
    @Environment(\.modelContext) private var modelContext
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Workout-level progress bar
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
                    saveWorkoutLog()
                    isWorkoutActive = false
                    selectedTab = 2
                    workoutJustCompleted = true
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
}
