//
//  continuumApp.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI
import SwiftData

@main
struct continuumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            ExerciseTemplate.self,
            Plan.self,
            PlanDay.self,
            ScheduledExercise.self,
            WorkoutLog.self,
            ExerciseLog.self
        ])
    }
}
