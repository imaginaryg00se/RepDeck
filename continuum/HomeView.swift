//
//  HomeView.swift
//  continuum
//
//  Created by William Huang on 4/25/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var isWorkoutActive: Bool
    
    var body: some View {
        Button("Start Workout") {
            isWorkoutActive = true
        }
    }
}

#Preview {
    HomeView(isWorkoutActive: .constant(false))
}
