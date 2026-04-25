//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                HomeView()
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
            }
        }
}

#Preview {
    ContentView()
}
