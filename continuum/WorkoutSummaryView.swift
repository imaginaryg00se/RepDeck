//
//  WorkoutSummaryView.swift
//  continuum
//
//  Created by William Huang on 5/4/26.
//

import SwiftUI
import SwiftData

struct WorkoutSummaryView: View {
    // Query the database for WorkoutLog objects and sorter them in descending order
    @Query(sort: \WorkoutLog.date, order: .reverse) var workoutLogs: [WorkoutLog]
    
    // Find the most recent log — conditional since a return is not guaranteed
    var mostRecentLog: WorkoutLog? { workoutLogs.first }
    
    var body: some View {
        // Unwrap the optional using if let
        if let log = mostRecentLog {
            VStack(spacing: 4) {
                // Header
                Text("Workout Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(log.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(log.exerciseLogs.reduce(0) { $0 + $1.setsCompleted })/\(log.exerciseLogs.reduce(0) { $0 + $1.targetSets }) sets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // List of exercises
                List(log.exerciseLogs) { exerciseLog in
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

        } else {
            Text("No workout found")
        }
    }
}
