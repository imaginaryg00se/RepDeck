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
    }
}

#Preview {
    // SetCard()
}
