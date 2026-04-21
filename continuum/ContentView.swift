//
//  ContentView.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack {
            SetCard(exerciseName: "Dumbbell RDLs", weight: 140, reps: 10)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            offset = value.translation
                        })
                        .onEnded({ value in
                            if value.translation.height < -100 {
                                print("Set Completed!")
                            } else {
                                offset = .zero
                            }
                        })
                )
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
