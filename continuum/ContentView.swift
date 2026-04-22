//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var sets = [
        WorkoutSet(exerciseName: "Dumbbell RDLs", weight: 140, reps: 10),
        WorkoutSet(exerciseName: "Dumbbell RDLs", weight: 140, reps: 10),
        WorkoutSet(exerciseName: "Dumbbell RDLs", weight: 140, reps: 10),
    ]
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.15)
                .ignoresSafeArea()
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                SetCard(exerciseName: set.exerciseName, weight: set.weight, reps: set.reps, onCompleted: {sets.removeLast()})
                    .offset(x: 0, y: CGFloat(index) * -8)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
