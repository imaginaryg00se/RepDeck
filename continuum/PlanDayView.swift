//
//  PlanDayView.swift
//  continuum
//
//  Created by William Huang on 5/1/26.
//

import SwiftUI
import SwiftData

struct PlanDayView: View {
    let planDay: PlanDay
    @Environment(\.modelContext) private var modelContext
    @State private var showingExercisePicker = false
    
    // Sort by sequential order
    var sortedExercises: [ScheduledExercise] {
        planDay.scheduledExercises.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var body: some View {
        VStack {
            if planDay.scheduledExercises.isEmpty {
                // Empty state
                Spacer()
                Text("Rest Day")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Tap + to add exercises")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                Spacer()
            } else {
                // Exercise list
                List {
                    ForEach(sortedExercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                    .onDelete {indexSet in
                        deleteExercises(at : indexSet)
                    }
                    .onMove { source, destination in
                        moveExercises(from: source, to: destination)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {showingExercisePicker = true}) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(planDay: planDay)
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    func deleteExercises(at indexSet: IndexSet) {
        for index in indexSet {
            let exercise = sortedExercises[index]
            // Remove object
            planDay.scheduledExercises.removeAll { $0.id == exercise.id }
            // Remove from database
            modelContext.delete(exercise)
        }
        try? modelContext.save()
    }
    
    func moveExercises(from source: IndexSet, to destination: Int) {
        // We get the pass-over tick for free
        // This line gives Haptic on drop
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Reorder in a mutable array, then rewrite orderIndex on all
        var reordered = sortedExercises
        reordered.move(fromOffsets: source, toOffset: destination)
        
        for (index, exercise) in reordered.enumerated() {
            exercise.orderIndex = index
        }
        
        try? modelContext.save()
    }
}
