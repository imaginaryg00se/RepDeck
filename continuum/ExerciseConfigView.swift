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
                    // All Steppers auto save
                    Stepper("Sets: \(exercise.workingSets)", value: Binding(
                        get: { exercise.workingSets },
                        set: {
                            exercise.workingSets = $0
                            try? modelContext.save()
                        }
                    ), in: 1...10)
                    
                    Stepper("Reps: \(exercise.targetReps)", value: Binding(
                        get: { exercise.targetReps },
                        set: {
                            exercise.targetReps = $0
                            try? modelContext.save()
                        }
                    ), in: 1...30)
                    
                    Picker("Weight", selection: Binding(
                        get: { exercise.targetWeight },
                        set: {
                            exercise.targetWeight = $0
                            try? modelContext.save()
                        }
                    )) {
                        ForEach(Array(stride(from: 0, through: 1000, by: 5)), id: \.self) { weight in
                            Text("\(weight) lbs").tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: Binding(
                        get: { exercise.notes },
                        set: {
                            exercise.notes = $0
                            try? modelContext.save()
                        }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
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
