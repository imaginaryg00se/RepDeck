//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Persistent value across app relaunches
    @AppStorage("isWorkoutActive") private var isWorkoutActive = false
    
    @State private var selectedTab = 0
    @State private var workoutJustCompleted = false
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \WorkoutLog.date, order: .reverse) var workoutLogs: [WorkoutLog]
    
    var body: some View {
        TabView (selection: $selectedTab) {
                HomeView(isWorkoutActive: $isWorkoutActive)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                PlannerView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .tag(1)
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("History")
                    }
                    .tag(2)
        }
        .fullScreenCover(isPresented: $isWorkoutActive) {
            ExecutionView(isWorkoutActive: $isWorkoutActive, selectedTab: $selectedTab, workoutJustCompleted: $workoutJustCompleted)
        }
        .sheet(isPresented: $workoutJustCompleted) {
            if let mostRecentLog = workoutLogs.first {
                WorkoutSummaryView(workoutLog: mostRecentLog)
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            DataSeeder.seedIfNeeded(context: modelContext, force: false)
        }
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
