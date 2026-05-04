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
            // Line 1 — exercise name, most prominent
            Text(exercise.exerciseTemplate?.displayName ?? "Unknown Exercise")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Line 2 — sets, reps, weight
            Text("\(exercise.workingSets) sets × \(exercise.targetReps) reps @ \(exercise.targetWeight) lbs")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Line 3 — notes, only shown if non-empty
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }
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
