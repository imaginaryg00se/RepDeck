//
//  Exercise.swift
//  continuum
//
//  Created by William Huang on 4/22/26.
//

import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    var sets: [WorkoutSet]
    let totalSets: Int
    
    init(name: String, sets: [WorkoutSet]) {
        self.name = name
        self.sets = sets
        self.totalSets = sets.count
    }
}
