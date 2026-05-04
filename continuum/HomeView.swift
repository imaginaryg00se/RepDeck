//
//  HomeView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var isWorkoutActive: Bool
    @Query var plans: [Plan]
    
    // Find the PlanDay object that corresponds to the current day
    var todayPlanDay: PlanDay? {
            let today = Calendar.current.component(.weekday, from: Date())
            return plans.first?.planDays.first(where: { $0.dayOfWeek == today })
        }
    
    // Sort the PlanDay object's children by order
    var todayExercises: [ScheduledExercise] {
            todayPlanDay?.scheduledExercises.sorted { $0.orderIndex < $1.orderIndex } ?? []
        }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(todayExercises.isEmpty ? "Rest Day" : "Today's Workout")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.top)
            
            // Exercise preview
            if todayExercises.isEmpty {
                Spacer()
                Text("No exercises scheduled today.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(todayExercises) { exercise in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.exerciseTemplate?.displayName ?? "Unknown")
                                        .font(.headline)
                                    Text("\(exercise.workingSets) sets × \(exercise.targetReps) reps @ \(exercise.targetWeight) lbs")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                // Slide to start
                SlideToStartView(isWorkoutActive: $isWorkoutActive)
                    .padding(.bottom)
            }
        }
    }
    var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: Date())
        }
}

#Preview {
    HomeView(isWorkoutActive: .constant(false))
}
