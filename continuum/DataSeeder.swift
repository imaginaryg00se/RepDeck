//
//  DataSeeder.swift
//  continuum
//
//  Created by William Huang on 4/30/26.
//

import Foundation
import SwiftData

struct DataSeeder {
    static func seedIfNeeded(context: ModelContext, force: Bool = false) {
        let descriptor = FetchDescriptor<ExerciseTemplate>()
        let existingTemplates = try? context.fetch(descriptor)
        guard existingTemplates?.isEmpty == true || force else { return }
        
        // If forcing, delete existing data first
        if force {
            existingTemplates?.forEach { context.delete($0) }
            
            // Also delete existing plans
            let planDescriptor = FetchDescriptor<Plan>()
            let existingPlans = try? context.fetch(planDescriptor)
            existingPlans?.forEach { context.delete($0) }
            
            try? context.save()
        }
        
        // Exercise library
        let exerciseTemplates = [
            // Squat pattern
            ExerciseTemplate(movementName: "Squat", equipmentType: "Barbell"),
            ExerciseTemplate(movementName: "Squat", equipmentType: "Front Barbell"),
            ExerciseTemplate(movementName: "Squat", equipmentType: "Hack"),
            
            // Hinge pattern
            ExerciseTemplate(movementName: "RDL", equipmentType: "Barbell"),
            ExerciseTemplate(movementName: "RDL", equipmentType: "Dumbbell"),
            ExerciseTemplate(movementName: "Deadlift", equipmentType: "Barbell"),
            
            // Horizontal push
            ExerciseTemplate(movementName: "Bench Press", equipmentType: "Barbell"),
            ExerciseTemplate(movementName: "Bench Press", equipmentType: "Dumbbell"),
            ExerciseTemplate(movementName: "Bench Press", equipmentType: "Incline Barbell"),
            
            // Vertical push
            ExerciseTemplate(movementName: "Shoulder Press", equipmentType: "Barbell"),
            ExerciseTemplate(movementName: "Shoulder Press", equipmentType: "Dumbbell"),
            
            // Horizontal pull
            ExerciseTemplate(movementName: "Row", equipmentType: "Barbell"),
            ExerciseTemplate(movementName: "Row", equipmentType: "Dumbbell"),
            ExerciseTemplate(movementName: "Row", equipmentType: "Cable"),
            
            // Vertical pull
            ExerciseTemplate(movementName: "Pull-up", equipmentType: "Weighted"),
            ExerciseTemplate(movementName: "Pull-up", equipmentType: "Bodyweight"),
            ExerciseTemplate(movementName: "Lat Pulldown", equipmentType: "Cable"),
            
            // Isolation
            ExerciseTemplate(movementName: "Lateral Raise", equipmentType: "Dumbbell"),
            ExerciseTemplate(movementName: "Lateral Raise", equipmentType: "Cable"),
            ExerciseTemplate(movementName: "Bicep Curl", equipmentType: "Barbell"),
            ExerciseTemplate(movementName: "Bicep Curl", equipmentType: "Dumbbell"),
            ExerciseTemplate(movementName: "Tricep Extension", equipmentType: "Cable"),
            ExerciseTemplate(movementName: "Dip", equipmentType: "Weighted"),
            ExerciseTemplate(movementName: "Dip", equipmentType: "Bodyweight"),
            ExerciseTemplate(movementName: "Face Pull", equipmentType: "Cable"),
        ]
        
        exerciseTemplates.forEach { context.insert($0) }
        
        // Default plan with all 7 days
        let defaultPlan = Plan(planName: "My Program")
        context.insert(defaultPlan)

        let daysOfWeek = [1, 2, 3, 4, 5, 6, 7] // Sunday through Saturday
        for dayOfWeek in daysOfWeek {
            let planDay = PlanDay(dayOfWeek: dayOfWeek)
            context.insert(planDay)
            defaultPlan.planDays.append(planDay)
        }

        try? context.save()
    }
}
