//
//  ExerciseRow.swift
//  continuum
//
//  Created by William Huang on 5/2/26.
//

import SwiftUI

struct ExerciseRow: View {
    let exercise: ScheduledExercise
    @State private var showingConfig = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.exerciseTemplate?.displayName ?? "Unknown Exercise")
                .font(.headline)
            Text("\(exercise.workingSets) sets × \(exercise.targetReps) reps @ \(exercise.targetWeight) lbs")
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(exercise.workingSets) sets × \(exercise.targetReps) reps @ \(exercise.targetWeight) lbs")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .background(
            Button { showingConfig = true } label: {
                Color.clear
            }
        )
        .sheet(isPresented: $showingConfig) {
            ExerciseConfigView(exercise: exercise)
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    //ExerciseRow()
}
