//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var exercises = [
        Exercise(name: "Dumbbell RDLs", sets : [
            WorkoutSet(weight: 140, reps: 10),
            WorkoutSet(weight: 140, reps: 10),
            WorkoutSet(weight: 140, reps: 10),
        ]),
        Exercise(name: "Barbell Squats", sets: [
            WorkoutSet(weight: 285, reps: 6),
            WorkoutSet(weight: 285, reps: 6),
            WorkoutSet(weight: 285, reps: 6),
        ]),
        Exercise(name: "Barbell Shoulder Press", sets: [
            WorkoutSet(weight: 105, reps: 10),
            WorkoutSet(weight: 105, reps: 10),
            WorkoutSet(weight: 105, reps: 10),
        ]),
        Exercise(name: "Weighted Dips", sets: [
            WorkoutSet(weight: 10, reps: 10),
            WorkoutSet(weight: 10, reps: 10),
            WorkoutSet(weight: 10, reps: 10),
        ]),
        Exercise(name: "Barbell Lateral Raise", sets: [
            WorkoutSet(weight: 15, reps: 15),
            WorkoutSet(weight: 15, reps: 15),
            WorkoutSet(weight: 15, reps: 15),
        ]),
    ]
    
    var body: some View {
        TabView {
            ForEach(Array(exercises.enumerated()), id: \.element.id) { exerciseIndex, exercise in
                ZStack {
                    Color.gray.opacity(0.15)
                        .ignoresSafeArea()
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                        SetCard(exerciseName: exercise.name, weight: set.weight, reps: set.reps, onCompleted: {exercises[exerciseIndex].sets.removeLast()})
                            .offset(x: 0, y: CGFloat(setIndex) * -8)
                    }
                }
            }
        }
        .padding()
        //.tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview {
    ContentView()
}
