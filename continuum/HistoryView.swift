//
//  HistoryView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \WorkoutLog.date, order: .reverse) var workoutLogs: [WorkoutLog]
    
    @State private var selectedLog: WorkoutLog? = nil
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if workoutLogs.isEmpty {
            Text("No workouts yet")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
        } else {
            // List out WorkoutLog objects
            List {
                ForEach(workoutLogs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(log.date, style: .date)
                            .font(.headline)

                        Text("\(log.exerciseLogs.reduce(0) { $0 + $1.setsCompleted })/\(log.exerciseLogs.reduce(0) { $0 + $1.targetSets }) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .background(
                        Button { selectedLog = log } label: {
                            Color.clear
                        }
                    )
                }
                .onDelete(perform: deleteWorkoutLog)
            }
            .sheet(item: $selectedLog) { log in
                WorkoutSummaryView(workoutLog: log)
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    func deleteWorkoutLog(at indexSet: IndexSet) {
        for index in indexSet {
            let log = workoutLogs[index]
            modelContext.delete(log)
        }
        try? modelContext.save()
    }
}
