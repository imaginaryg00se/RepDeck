//
//  ExecutionView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI

struct ExecutionView: View {
    @State private var exercises = [
        Exercise(name: "Barbell Squats", sets: [
            WorkoutSet(weight: 285, reps: 8),
            WorkoutSet(weight: 285, reps: 8),
            WorkoutSet(weight: 285, reps: 8),
        ]),
        Exercise(name: "Weighted Dips", sets: [
            WorkoutSet(weight: 10, reps: 10),
            WorkoutSet(weight: 10, reps: 10),
            WorkoutSet(weight: 10, reps: 10),
        ]),
        Exercise(name: "Barbell Lateral Raise", sets: [
            WorkoutSet(weight: 15, reps: 20),
            WorkoutSet(weight: 15, reps: 20),
            WorkoutSet(weight: 15, reps: 20),
        ]),
        Exercise(name: "Dumbbell RDLs", sets : [
            WorkoutSet(weight: 190, reps: 10),
            WorkoutSet(weight: 190, reps: 10),
            WorkoutSet(weight: 190, reps: 10),
        ]),
        Exercise(name: "Barbell Shoulder Press", sets: [
            WorkoutSet(weight: 105, reps: 10),
            WorkoutSet(weight: 105, reps: 10),
            WorkoutSet(weight: 105, reps: 10),
        ]),
    ]
    @State private var currentPage = 0
    
    @Binding var isWorkoutActive: Bool
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack (spacing: 0) {
            // Workout-level progress bar
            VStack {
                let totalSets = exercises.reduce(0) { $0 + $1.totalSets }
                let completedSets = exercises.reduce(0) { $0 + ($1.totalSets - $1.sets.count) }
                
                Text("Workout Progress")
                    .font(.headline)
                
                Text("\(completedSets)/\(totalSets)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                ProgressView(value: Double(completedSets), total: Double(totalSets))
                    .tint(.blue)
                    .padding(.horizontal)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            } // End of workout-level progress bar
            
            // Conceptual "Page"
            VStack {
                // Navigable tabs
                TabView(selection: $currentPage) {
                    // One Exercise per tab
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                        // Conceptual grouping of a page
                        VStack {
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
                                // Active stack of cards
                                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                                    SetCard(exerciseName: exercise.name, weight: set.weight, reps: set.reps, onCompleted: {
                                        _ = withAnimation(.easeOut(duration: 0.3)) {
                                            exercises[exerciseIndex].sets.removeLast()
                                        } // We might care about the return value later when we implement "undo"
                                        if exercises[exerciseIndex].sets.isEmpty {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                let nextIndex = exercises.indices
                                                    .filter { $0 != exerciseIndex && !exercises[$0].sets.isEmpty }
                                                    .first(where: { $0 > exerciseIndex })
                                                ?? exercises.indices.first(where: { !exercises[$0].sets.isEmpty })
                                                if let next = nextIndex {
                                                    withAnimation {
                                                        currentPage = next
                                                    }
                                                } else {
                                                    // Workout complete
                                                    isWorkoutActive = false
                                                    selectedTab = 2
                                                }
                                            }
                                        }
                                    })
                                    .offset(x: 0, y: CGFloat(setIndex) * -8)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .disabled(setIndex != exercise.sets.count - 1)
                                }
                            }
                            // Exercise-level progress bar
                            VStack {
                                HStack(spacing: 3) {
                                    ForEach(0..<exercise.totalSets, id: \.self) { segmentIndex in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(segmentIndex < (exercise.totalSets - exercise.sets.count)
                                                  ? Color.green
                                                  : Color.gray.opacity(0.3))
                                            .frame(height: 6)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }.tag(exerciseIndex)
                    }
                }
                //.padding()
                .onChange(of: currentPage) {
                    let feedback = UISelectionFeedbackGenerator()
                    feedback.selectionChanged()
                }
                // Remove default dot UI to replace with custom index navigation row
                .tabViewStyle(.page(indexDisplayMode: .never))
                
            } // End of conceptual "Page"
            
            // Custom index navigation row
            HStack(spacing: 20) {
                ForEach(exercises.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 20 : 15,
                                   height: index == currentPage ? 20 : 15)
                        Text("\(index + 1)")
                            .font(.system(size: 15))
                            .foregroundColor(index == currentPage ? .white : .white.opacity(0.3))
                    }
                    .onTapGesture {
                        withAnimation {
                            currentPage = index
                        }
                    }
                }
            } // End of custom index navigation row
            
        } // End of top-level VStack
    }
}
#Preview {
    ExecutionView(isWorkoutActive: .constant(true), selectedTab: .constant(0))
        .preferredColorScheme(.dark)
}
