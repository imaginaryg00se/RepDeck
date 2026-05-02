//
//  PlannerView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI
import SwiftData

struct PlannerView: View {
    @Query var plans: [Plan]
    
    var body: some View {
        NavigationStack {
            // Update logic when more than one Plan exists
            if let activePlan = plans.first {
                PlanDayTabView(plan: activePlan)
            } else {
                Text("No program found")
            }
        }
    }
}

#Preview {
    PlannerView()
}
