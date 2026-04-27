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
        TabView (selection: $currentPage){
            ForEach(Array(exercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                ZStack {
                    Color.gray.opacity(0.15)
                        .ignoresSafeArea()
                    VStack {
                        ProgressView(value: Double(exercise.totalSets - exercise.sets.count),
                                     total: Double(exercise.totalSets))
                        .padding(.horizontal)
                        .tint(.green)
                        Text("\(exercise.totalSets - exercise.sets.count)/\(exercise.totalSets)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 300, height: 200)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.4))
                        )
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                        SetCard(exerciseName: exercise.name, weight: set.weight, reps: set.reps, onCompleted: {
                            _ = withAnimation(.easeOut(duration: 0.3)) {
                                exercises[exerciseIndex].sets.removeLast()
                            } // We might care about the return value later when we implement "undo"
                            if exercises[exerciseIndex].sets.isEmpty {
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
                        })
                        .offset(x: 0, y: CGFloat(setIndex) * -8)
                    }.transition(.move(edge: .top).combined(with: .opacity))
                }.tag(exerciseIndex)
            }
        }
        .padding()
        .onChange(of: currentPage) {
            let feedback = UISelectionFeedbackGenerator()
            feedback.selectionChanged()
        }
        //.tabViewStyle(.page(indexDisplayMode: .always))
    }
}
#Preview {
    ExecutionView(isWorkoutActive: .constant(true), selectedTab: .constant(0))
}
