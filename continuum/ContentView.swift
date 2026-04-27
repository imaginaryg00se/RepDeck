//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isWorkoutActive = false
    
    var body: some View {
            TabView {
                HomeView(isWorkoutActive: $isWorkoutActive)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                PlannerView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("History")
                    }
            }.fullScreenCover(isPresented: $isWorkoutActive) {
                ExecutionView()
            }
        }
}

#Preview {
    ContentView()
}
