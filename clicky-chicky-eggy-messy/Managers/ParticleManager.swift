//
//  ParticleManager.swift
//  clicky-chicky-eggy-messy
//
//  Creates and manages particle effects programmatically
//

import SpriteKit

class ParticleManager {
    static let shared = ParticleManager()
    
    private init() {}
    
    // MARK: - Egg Tap Particles
    
    func createEggTapParticles(at position: CGPoint, color: SKColor = .white) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        
        // Size
        emitter.particleSize = CGSize(width: 8, height: 8)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -1.0
        
        // Speed and direction
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        // Color
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -2.0
        
        // Position
        emitter.position = position
        emitter.particlePositionRange = CGVector(dx: 10, dy: 10)
        
        // Physics
        emitter.yAcceleration = -200
        
        // Create a circular texture
        emitter.particleTexture = createCircleTexture(radius: 4)
        
        // Remove after particles finish
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        return emitter
    }
    
    // MARK: - Egg Hatch Particles (Shell fragments)
    
    func createHatchParticles(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties
        emitter.particleBirthRate = 30
        emitter.numParticlesToEmit = 15
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        
        // Size - irregular for shell fragments
        emitter.particleSize = CGSize(width: 12, height: 10)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.5
        
        // Speed and direction - explode outward
        emitter.particleSpeed = 120
        emitter.particleSpeedRange = 40
        emitter.emissionAngle = .pi / 2 // Upward
        emitter.emissionAngleRange = .pi * 2
        
        // Color - eggshell colors
        emitter.particleColor = SKColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -1.5
        
        // Rotation
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = 5
        
        // Position
        emitter.position = position
        emitter.particlePositionRange = CGVector(dx: 15, dy: 15)
        
        // Physics
        emitter.yAcceleration = -300
        
        // Create shell fragment texture
        emitter.particleTexture = createShellTexture()
        
        // Remove after particles finish
        let wait = SKAction.wait(forDuration: 1.5)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        return emitter
    }
    
    // MARK: - Golden Egg Sparkles
    
    func createGoldenSparkles(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Particle properties
        emitter.particleBirthRate = 80
        emitter.numParticlesToEmit = 40
        emitter.particleLifetime = 0.6
        emitter.particleLifetimeRange = 0.3
        
        // Size
        emitter.particleSize = CGSize(width: 10, height: 10)
        emitter.particleScaleRange = 0.8
        emitter.particleScaleSpeed = -1.5
        
        // Speed and direction
        emitter.particleSpeed = 180
        emitter.particleSpeedRange = 60
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        // Golden color
        emitter.particleColor = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -1.5
        
        // Position
        emitter.position = position
        emitter.particlePositionRange = CGVector(dx: 5, dy: 5)
        
        // Physics
        emitter.yAcceleration = -100
        
        // Star texture
        emitter.particleTexture = createStarTexture()
        
        // Remove after particles finish
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        return emitter
    }
    
    // MARK: - Combo Celebration
    
    func createComboParticles(at position: CGPoint, comboLevel: Int) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // More particles for higher combos
        let particleCount = min(comboLevel * 10, 50)
        
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = particleCount
        emitter.particleLifetime = 0.7
        emitter.particleLifetimeRange = 0.2
        
        emitter.particleSize = CGSize(width: 6, height: 6)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -1.0
        
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 80
        emitter.emissionAngle = .pi / 2 // Upward
        emitter.emissionAngleRange = .pi
        
        // Rainbow colors for combos
        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
        emitter.particleColor = colors[comboLevel % colors.count]
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -1.5
        
        emitter.position = position
        emitter.yAcceleration = -400
        
        emitter.particleTexture = createCircleTexture(radius: 3)
        
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        return emitter
    }
    
    // MARK: - Heart Particles
    
    func createHeartParticles(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 40
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        
        emitter.particleSize = CGSize(width: 15, height: 15)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.8
        
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 40
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi
        
        emitter.particleColor = SKColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSpeed = -1.2
        
        emitter.position = position
        emitter.yAcceleration = -150
        
        emitter.particleTexture = createHeartTexture()
        
        let wait = SKAction.wait(forDuration: 1.2)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        return emitter
    }
    
    // MARK: - Explosion Particles (Bomb)
    
    func createExplosionParticles(at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        emitter.particleBirthRate = 200
        emitter.numParticlesToEmit = 60
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        
        emitter.particleSize = CGSize(width: 12, height: 12)
        emitter.particleScaleRange = 1.0
        emitter.particleScaleSpeed = -2.0
        
        emitter.particleSpeed = 250
        emitter.particleSpeedRange = 100
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        // Orange/red explosion
        emitter.particleColor = SKColor.orange
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorRedRange = 0.3
        emitter.particleAlphaSpeed = -2.0
        
        emitter.position = position
        emitter.particlePositionRange = CGVector(dx: 10, dy: 10)
        emitter.yAcceleration = -200
        
        emitter.particleTexture = createCircleTexture(radius: 6)
        
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
        
        return emitter
    }
    
    // MARK: - Texture Creation
    
    private func createCircleTexture(radius: CGFloat) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createShellTexture() -> SKTexture {
        let size = CGSize(width: 12, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Irregular shell shape
        context.setFillColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: 0, y: 5))
        context.addLine(to: CGPoint(x: 4, y: 0))
        context.addLine(to: CGPoint(x: 10, y: 2))
        context.addLine(to: CGPoint(x: 12, y: 8))
        context.addLine(to: CGPoint(x: 6, y: 10))
        context.closePath()
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createStarTexture() -> SKTexture {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Simple 4-point star
        let center = CGPoint(x: 6, y: 6)
        context.setFillColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: center.x, y: 0))
        context.addLine(to: CGPoint(x: center.x + 2, y: center.y - 2))
        context.addLine(to: CGPoint(x: 12, y: center.y))
        context.addLine(to: CGPoint(x: center.x + 2, y: center.y + 2))
        context.addLine(to: CGPoint(x: center.x, y: 12))
        context.addLine(to: CGPoint(x: center.x - 2, y: center.y + 2))
        context.addLine(to: CGPoint(x: 0, y: center.y))
        context.addLine(to: CGPoint(x: center.x - 2, y: center.y - 2))
        context.closePath()
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createHeartTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Simple heart shape
        context.setFillColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: 8, y: 14))
        context.addCurve(to: CGPoint(x: 1, y: 5), control1: CGPoint(x: 2, y: 10), control2: CGPoint(x: 1, y: 7))
        context.addCurve(to: CGPoint(x: 8, y: 4), control1: CGPoint(x: 1, y: 2), control2: CGPoint(x: 8, y: 4))
        context.addCurve(to: CGPoint(x: 15, y: 5), control1: CGPoint(x: 8, y: 4), control2: CGPoint(x: 15, y: 2))
        context.addCurve(to: CGPoint(x: 8, y: 14), control1: CGPoint(x: 15, y: 7), control2: CGPoint(x: 14, y: 10))
        context.closePath()
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
}
