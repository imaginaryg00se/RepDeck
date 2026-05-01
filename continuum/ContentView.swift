//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isWorkoutActive = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView (selection: $selectedTab) {
                HomeView(isWorkoutActive: $isWorkoutActive)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                PlannerView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .tag(1)
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("History")
                    }
                    .tag(2)
            }.fullScreenCover(isPresented: $isWorkoutActive) {
                ExecutionView(isWorkoutActive: $isWorkoutActive, selectedTab: $selectedTab)
            }
        }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
