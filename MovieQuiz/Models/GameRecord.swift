//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Артур  Арсланов on 22.12.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        self.correct > another.correct
    }
}

//extension GameRecord: Comparable {
//    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
//        lhs.accuracy < rhs.accuracy
//    }
//    
//    
//    private var accuracy: Double {
//        guard total != 0 else {
//            return 0
//        }
//        return Double(correct / total)
//    }
//    
//}
