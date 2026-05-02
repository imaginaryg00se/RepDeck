//
//  PlanDayTabView.swift
//  continuum
//
//  Created by William Huang on 5/1/26.
//

import SwiftUI

struct PlanDayTabView: View {
    let plan: Plan
    @State private var selectedDay = Calendar.current.component(.weekday, from: Date())
    
    // Explicitly sort the order of plan via planDays.dayOfWeek
    // This guarantees day selector to render from Sun-Sat
    var sortedDays: [PlanDay] {
        plan.planDays.sorted { $0.dayOfWeek < $1.dayOfWeek }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable day selector
            HStack(spacing: 8) {
                        ForEach(sortedDays) { day in
                            Button(action: {
                                selectedDay = day.dayOfWeek
                            }) {
                                Text(day.shortDayName)
                                    .font(.system(size: 13, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedDay == day.dayOfWeek ? Color.primary : Color.clear)
                                    .foregroundColor(selectedDay == day.dayOfWeek ? Color(UIColor.systemBackground) : .gray)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            
            Divider()
            
            // Content for selected day
            if let currentDay = sortedDays.first(where: { $0.dayOfWeek == selectedDay }) {
                PlanDayView(planDay: currentDay)
            }
        }
    }
}
