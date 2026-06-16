//
//  HistoryView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    // Pull all logs from SwiftData, newest first
    @Query(sort: \WorkoutLog.date, order: .reverse) var workoutLogs: [WorkoutLog]
    
    // Which WorkoutSummary to dislay
    @State private var selectedLog: WorkoutLog? = nil
    
    // The time range of entries to display
    @State private var filter: HistoryFilter = .thisWeek
    
    // Enables writing to SwiftData
    @Environment(\.modelContext) private var modelContext
    
    // Filter options
    enum HistoryFilter: String, CaseIterable, Identifiable {
        case thisWeek = "This Week"
        case lastWeek = "Last Week"
        case all = "All"
        var id: String { rawValue }
    }
    
    // A computer property that narrows workoutLogs by date
    private var filteredLogs: [WorkoutLog] {
        let calendar = Calendar.current
        let now = Date()

        switch filter {
        case .all:
            return workoutLogs

        case .thisWeek:
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start
            else { return workoutLogs }
            return workoutLogs.filter { $0.date >= weekStart }

        case .lastWeek:
            guard let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
                  let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)
            else { return workoutLogs }
            return workoutLogs.filter { $0.date >= lastWeekStart && $0.date < thisWeekStart }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter bar
            HStack(spacing: 8) {
                ForEach(HistoryFilter.allCases) { option in
                    Button(action: {
                        // Since filter is @State, this triggers a re-run of 'body'
                        filter = option
                    }) {
                        Text(option.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(filter == option ? Color.primary : Color.clear)
                            .foregroundColor(filter == option ? Color(UIColor.systemBackground) : .gray)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            if filteredLogs.isEmpty {
                Spacer()
                Text(workoutLogs.isEmpty ? "No workouts yet" : "No workouts in this range")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                Spacer()
            } else {
                List {
                    ForEach(filteredLogs) { log in
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
            }
        }
        .sheet(item: $selectedLog) { log in
            WorkoutSummaryView(workoutLog: log)
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    func deleteWorkoutLog(at indexSet: IndexSet) {
        for index in indexSet {
            let log = filteredLogs[index]   // not workoutLogs
            modelContext.delete(log)
        }
        try? modelContext.save()
    }
}
