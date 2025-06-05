//
//  SeededGenerator.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 6/5/25.
//

import Foundation
import GameplayKit

struct SeededGenerator: RandomNumberGenerator {
    private var generator: GKMersenneTwisterRandomSource

    init(seed: UInt64) {
        self.generator = GKMersenneTwisterRandomSource(seed: seed)
    }

    mutating func next() -> UInt64 {
        return UInt64(bitPattern: Int64(generator.nextInt()))
    }
}

