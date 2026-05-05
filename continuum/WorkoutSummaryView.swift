//
//  WorkoutSummaryView.swift
//  continuum
//
//  Created by William Huang on 5/4/26.
//

import SwiftUI
import SwiftData

struct WorkoutSummaryView: View {
    let workoutLog: WorkoutLog
    
    var body: some View {
        // Unwrap the optional using if let
        VStack(spacing: 4) {
            // Header
            Text("Workout Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(workoutLog.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(workoutLog.exerciseLogs.reduce(0) { $0 + $1.setsCompleted })/\(workoutLog.exerciseLogs.reduce(0) { $0 + $1.targetSets }) sets")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // List of exercises
            List(workoutLog.exerciseLogs) { exerciseLog in
                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseLog.exerciseName)
                        .font(.headline)
                    Text("\(exerciseLog.setsCompleted)/\(exerciseLog.targetSets) sets × \(exerciseLog.targetReps) reps @ \(exerciseLog.targetWeight) lbs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !exerciseLog.notes.isEmpty {
                        Text(exerciseLog.notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
            }
        }
        .padding(.top, 32)
    }
}
