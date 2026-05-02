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
        }
    }
    
    func deleteExercises(at indexSet: IndexSet) {
        for index in indexSet {
            let exercise = sortedExercises[index]
            modelContext.delete(exercise)
        }
        try? modelContext.save()
    }
}

#Preview {
    //PlanDayView()
}
