//
//  Egg.swift
//  clicky-chicky-eggy-messy
//
//  Egg model with different egg types
//

import SpriteKit

enum EggType: CaseIterable {
    case normal
    case golden    // Worth 5x points
    case speed     // Slows down all eggs temporarily
    case heart     // Restores one life
    case bomb      // Loses a life if tapped
    
    var spawnWeight: Int {
        switch self {
        case .normal: return 100
        case .golden: return 8
        case .speed: return 5
        case .heart: return 3
        case .bomb: return 6
        }
    }
    
    var pointMultiplier: Int {
        switch self {
        case .normal: return 1
        case .golden: return 5
        case .speed: return 2
        case .heart: return 0
        case .bomb: return 0
        }
    }
    
    var fillColor: SKColor {
        switch self {
        case .normal:
            return SKColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 1.0)
        case .golden:
            return SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        case .speed:
            return SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        case .heart:
            return SKColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)
        case .bomb:
            return SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        }
    }
    
    var strokeColor: SKColor {
        switch self {
        case .normal:
            return SKColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
        case .golden:
            return SKColor(red: 0.8, green: 0.6, blue: 0.0, alpha: 1.0)
        case .speed:
            return SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0)
        case .heart:
            return SKColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1.0)
        case .bomb:
            return SKColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
    static func randomType() -> EggType {
        let totalWeight = EggType.allCases.reduce(0) { $0 + $1.spawnWeight }
        let random = Int.random(in: 0..<totalWeight)
        
        var cumulative = 0
        for type in EggType.allCases {
            cumulative += type.spawnWeight
            if random < cumulative {
                return type
            }
        }
        
        return .normal
    }
}

// Egg structure to track individual eggs
struct EggData {
    let id: UUID
    let node: SKNode
    let type: EggType
    var hatchTime: TimeInterval
    var spawnTime: TimeInterval
    var isTapped: Bool = false
    var isHatched: Bool = false
    var visualNode: SKNode
}
