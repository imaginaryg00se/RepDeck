//
//  continuumApp.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI
import Sentry

import SwiftData

@main
struct continuumApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://f65bce2d71b2aa058b20657994ca9eec@o4511554286714880.ingest.us.sentry.io/4511554330951680"
            options.environment = "development"
            #if DEBUG
            options.debug = true
            #endif
            options.sendDefaultPii = false   // no IP/PII — keeps the privacy footprint minimal
            options.tracesSampleRate = 0.0   // performance tracing OFF — crashes only
            // profiling / session replay intentionally omitted for the first beta
        }
        // Temporary: confirms the pipeline end-to-end. Remove once it shows in the dashboard.
        SentrySDK.capture(message: "Continuum Sentry test")
    }
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
