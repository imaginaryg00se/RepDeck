//
//  WorkoutSet.swift
//  continuum
//
//  Created by William Huang on 4/22/26.
//

import Foundation

struct WorkoutSet: Identifiable {
    let id = UUID()
    let weight: Int
    let reps: Int
}
