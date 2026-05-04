//
//  Models.swift
//  continuum
//
//  Created by William Huang on 4/30/26.
//

import Foundation
import SwiftData

@Model
class ExerciseTemplate {
    var id: UUID
    var movementName: String
    var equipmentType: String
    
    init(movementName: String, equipmentType: String) {
        self.id = UUID()
        self.movementName = movementName
        self.equipmentType = equipmentType
    }
    
    // Display name combining movement and equipment
    var displayName: String {
        "\(movementName) (\(equipmentType))"
    }
}

@Model
class Plan {
    var id: UUID
    var planName: String
    var recurrenceType: String
    @Relationship(deleteRule: .cascade) var planDays: [PlanDay]
    
    init(planName: String, recurrenceType: String = "weekly") {
        self.id = UUID()
        self.planName = planName
        self.recurrenceType = recurrenceType
        self.planDays = []
    }
}

@Model
class PlanDay {
    var id: UUID
    var dayOfWeek: Int
    @Relationship(deleteRule: .cascade) var scheduledExercises: [ScheduledExercise]
    
    init(dayOfWeek: Int) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.scheduledExercises = []
    }
    
    // Human-readable day name
    var dayName: String {
        let formatter = DateFormatter()
        // dayOfWeek follows Calendar convention: 1=Sunday, 2=Monday...
        return formatter.weekdaySymbols[dayOfWeek - 1]
    }
    
    var shortDayName: String {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols[dayOfWeek - 1]
    }
}

@Model
class ScheduledExercise {
    var id: UUID
    var orderIndex: Int
    var workingSets: Int
    var targetReps: Int
    var targetWeight: Int
    var notes: String
    var exerciseTemplate: ExerciseTemplate?
    
    init(orderIndex: Int, workingSets: Int, targetReps: Int, targetWeight: Int, notes: String = "", exerciseTemplate: ExerciseTemplate) {
        self.id = UUID()
        self.orderIndex = orderIndex
        self.workingSets = workingSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.notes = notes
        self.exerciseTemplate = exerciseTemplate
    }
}

@Model
class WorkoutLog {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    @Relationship(deleteRule: .cascade) var exerciseLogs: [ExerciseLog]
    
    init(date: Date, duration: TimeInterval) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.exerciseLogs = []
    }
}

@Model
class ExerciseLog {
    var id: UUID
    var exerciseName: String
    var targetSets: Int         // intent — what was planned
    var setsCompleted: Int      // actuals — what was done
    var targetReps: Int
    var targetWeight: Int
    var notes: String
    
    init(exerciseName: String, targetSets: Int, setsCompleted: Int, targetReps: Int, targetWeight: Int, notes: String = "") {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.targetSets = targetSets
        self.setsCompleted = setsCompleted
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.notes = notes
    }
}
