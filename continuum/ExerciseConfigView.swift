//
//  ExerciseConfigView.swift
//  continuum
//
//  Created by William Huang on 5/3/26.
//

import SwiftUI
import SwiftData

struct ExerciseConfigView: View {
    let exercise: ScheduledExercise
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var workingSets: Int
    @State private var targetReps: Int
    @State private var targetWeight: Int
    @State private var notes: String
    
    init(exercise: ScheduledExercise) {
        self.exercise = exercise
        _workingSets = State(initialValue: exercise.workingSets)
        _targetReps = State(initialValue: exercise.targetReps)
        _targetWeight = State(initialValue: exercise.targetWeight)
        _notes = State(initialValue: exercise.notes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    Text(exercise.exerciseTemplate?.displayName ?? "Unknown Exercise")
                        .font(.headline)
                }
                
                Section("Targets") {
                    Stepper("Sets: \(workingSets)", value: $workingSets, in: 1...10)
                    Stepper("Reps: \(targetReps)", value: $targetReps, in: 1...30)
                    Stepper("Weight: \(targetWeight) lbs", value: $targetWeight, in: 0...1000, step: 5)
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    func saveChanges() {
        exercise.workingSets = workingSets
        exercise.targetReps = targetReps
        exercise.targetWeight = targetWeight
        exercise.notes = notes
        try? modelContext.save()
        dismiss()
    }
}
