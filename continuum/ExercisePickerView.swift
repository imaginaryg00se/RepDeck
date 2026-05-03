//
//  ExercisePickerView.swift
//  continuum
//
//  Created by William Huang on 5/2/26.
//

import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    let planDay: PlanDay
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseTemplate.movementName) var exerciseTemplates: [ExerciseTemplate]
    @State private var searchText = ""
    
    var filteredTemplates: [ExerciseTemplate] {
            if searchText.isEmpty {
                return exerciseTemplates
            }
            return exerciseTemplates.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    
    var body: some View {
        NavigationStack {
            List(filteredTemplates) { template in
                Button(action: {addExercise(template: template) }) {
                    Text(template.displayName)
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
    
    func addExercise(template: ExerciseTemplate) {
        let orderIndex = planDay.scheduledExercises.count
        let newExercise = ScheduledExercise(
            orderIndex: orderIndex,
            // Smart defaults
            workingSets: 3,
            targetReps: 10,
            targetWeight: 0,
            
            exerciseTemplate: template
        )
        modelContext.insert(newExercise)
        planDay.scheduledExercises.append(newExercise)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    //ExercisePickerView()
}
