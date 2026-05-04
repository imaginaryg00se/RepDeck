//
//  SetCard.swift
//  continuum
//
//  Created by William Huang on 4/21/26.
//

import SwiftUI

struct SetCard: View {
    let exerciseName : String
    let weight: Int
    let reps: Int
    let onCompleted: () -> Void
    
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 12) {
            Text(exerciseName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text("\(weight) LBS")
                .font(.title)
                .foregroundColor(.black)
            Text("x\(reps)")
                .font(.title)
                .foregroundColor(.black)
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 8)
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = CGSize(width: 0, height: min(value.translation.height, 0))
                }
                .onEnded { value in
                    if value.translation.height < -175 {
                        let feedback = UIImpactFeedbackGenerator(style: .heavy)
                        feedback.impactOccurred()
                        onCompleted()
                    } else {
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                        offset = .zero
                    }
                }
        )
    }
}

#Preview {
    // SetCard()
}
