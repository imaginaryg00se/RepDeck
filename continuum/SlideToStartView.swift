//
//  SlideToStartView.swift
//  continuum
//
//  Created by William Huang on 5/3/26.
//

import SwiftUI

struct SlideToStartView: View {
    @Binding var isWorkoutActive: Bool
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let threshold = geometry.size.width - 60
            
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.gray.opacity(0.3))
                
                // Label
                Text("Slide to begin")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 4)
                    .frame(width: 52, height: 52)
                    .padding(.leading, 4)
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = min(max(0, value.translation.width), threshold)
                            }
                            .onEnded { _ in
                                if offset >= threshold {
                                    let feedback = UIImpactFeedbackGenerator(style: .heavy)
                                    feedback.impactOccurred()
                                    isWorkoutActive = true
                                } else {
                                    withAnimation(.spring()) {
                                        offset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 60)
        .padding(.horizontal)
    }
}
