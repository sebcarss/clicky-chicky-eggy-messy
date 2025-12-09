//
//  GameScene.swift
//  clicky-chicky-eggy-messy
//
//  Created by Seb Carss on 09/12/2025.
//

import SpriteKit
import GameplayKit

// Egg structure to track individual eggs
struct Egg {
    let id: UUID
    let node: SKShapeNode
    var hatchTime: TimeInterval
    var spawnTime: TimeInterval
    var isTapped: Bool = false
    var isHatched: Bool = false
}

class GameScene: SKScene {
    
    // Game state
    private var score: Int = 0
    private var lives: Int = 3
    private var gameTime: TimeInterval = 0
    private var lastSpawnTime: TimeInterval = 0
    private var activeEggs: [Egg] = []
    private var isGameOver: Bool = false
    private var lastUpdateTime: TimeInterval = 0
    
    // UI elements
    private var scoreLabel: SKLabelNode!
    private var livesNodes: [SKShapeNode] = []
    private var gameOverLabel: SKLabelNode!
    private var restartLabel: SKLabelNode!
    
    // Chicken node
    private var chickenNode: SKShapeNode!
    
    // Constants
    private let eggRadius: CGFloat = 30
    private let chickenWidth: CGFloat = 60
    private let chickenHeight: CGFloat = 80
    private let edgePadding: CGFloat = 50
    
    override func didMove(to view: SKView) {
        setupScene()
        setupChicken()
        setupUI()
        startGame()
    }
    
    func setupScene() {
        backgroundColor = SKColor(red: 0.9, green: 0.9, blue: 0.85, alpha: 1.0)
    }
    
    func setupChicken() {
        // Create chicken as a simple rounded rectangle
        chickenNode = SKShapeNode(rectOf: CGSize(width: chickenWidth, height: chickenHeight), cornerRadius: 10)
        chickenNode.fillColor = SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        chickenNode.strokeColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        chickenNode.lineWidth = 2
        chickenNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(chickenNode)
        
        // Add a simple head/comb
        let comb = SKShapeNode(circleOfRadius: 8)
        comb.fillColor = SKColor.red
        comb.position = CGPoint(x: 0, y: chickenHeight / 2 + 8)
        chickenNode.addChild(comb)
    }
    
    func setupUI() {
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 100, y: size.height - 50)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        // Lives indicator (hearts)
        updateLivesDisplay()
        
        // Game over label (hidden initially)
        gameOverLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)
        
        // Restart label (hidden initially)
        restartLabel = SKLabelNode(fontNamed: "Arial")
        restartLabel.text = "Tap to restart"
        restartLabel.fontSize = 24
        restartLabel.fontColor = SKColor.darkGray
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        restartLabel.isHidden = true
        addChild(restartLabel)
    }
    
    func updateLivesDisplay() {
        // Remove existing life nodes
        for node in livesNodes {
            node.removeFromParent()
        }
        livesNodes.removeAll()
        
        // Create heart nodes
        let heartSize: CGFloat = 25
        let spacing: CGFloat = 35
        let startX = size.width - 100
        let y = size.height - 50
        
        for i in 0..<3 {
            let heart = SKShapeNode(circleOfRadius: heartSize / 2)
            if i < lives {
                heart.fillColor = SKColor.red
                heart.strokeColor = SKColor.darkGray
            } else {
                heart.fillColor = SKColor.clear
                heart.strokeColor = SKColor.gray
            }
            heart.lineWidth = 2
            heart.position = CGPoint(x: startX - CGFloat(i) * spacing, y: y)
            addChild(heart)
            livesNodes.append(heart)
        }
    }
    
    func startGame() {
        // Remove all existing eggs from the scene before clearing the array
        for egg in activeEggs {
            egg.node.removeAllActions()
            egg.node.removeFromParent()
        }
        
        score = 0
        lives = 3
        gameTime = 0
        lastSpawnTime = 0
        activeEggs.removeAll()
        isGameOver = false
        lastUpdateTime = 0
        
        scoreLabel.text = "Score: 0"
        gameOverLabel.isHidden = true
        restartLabel.isHidden = true
        updateLivesDisplay()
    }
    
    func spawnEgg() {
        guard !isGameOver else { return }
        
        // Calculate random position (avoid edges)
        let minX = edgePadding + eggRadius
        let maxX = size.width - edgePadding - eggRadius
        let minY = edgePadding + eggRadius
        let maxY = size.height - 150 - eggRadius // Leave space for chicken and UI
        
        let x = CGFloat.random(in: minX...maxX)
        let y = CGFloat.random(in: minY...maxY)
        
        // Create egg node
        let eggNode = SKShapeNode(circleOfRadius: eggRadius)
        eggNode.fillColor = SKColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)
        eggNode.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.5, alpha: 1.0)
        eggNode.lineWidth = 2
        eggNode.position = CGPoint(x: x, y: y)
        
        // Calculate hatch time based on difficulty
        // Ensure minHatch is always <= maxHatch by using consistent coefficients
        let baseMinHatch = max(0.5, 3.0 - (gameTime * 0.15))
        let baseMaxHatch = max(1.0, 7.0 - (gameTime * 0.2))
        // Swap if min > max to ensure valid range
        let minHatch = min(baseMinHatch, baseMaxHatch)
        let maxHatch = max(baseMinHatch, baseMaxHatch)
        let hatchTime = Double.random(in: minHatch...maxHatch)
        
        let egg = Egg(
            id: UUID(),
            node: eggNode,
            hatchTime: hatchTime,
            spawnTime: gameTime
        )
        
        activeEggs.append(egg)
        addChild(eggNode)
        
        // Schedule hatch
        scheduleHatch(for: egg)
    }
    
    func scheduleHatch(for egg: Egg) {
        guard let index = activeEggs.firstIndex(where: { $0.id == egg.id }) else { return }
        guard !activeEggs[index].isTapped && !activeEggs[index].isHatched else { return }
        
        let waitAction = SKAction.wait(forDuration: egg.hatchTime)
        let hatchAction = SKAction.run { [weak self] in
            self?.hatchEgg(eggId: egg.id)
        }
        
        activeEggs[index].node.run(SKAction.sequence([waitAction, hatchAction]))
    }
    
    func hatchEgg(eggId: UUID) {
        guard let index = activeEggs.firstIndex(where: { $0.id == eggId }) else { return }
        guard !activeEggs[index].isTapped && !activeEggs[index].isHatched else { return }
        
        activeEggs[index].isHatched = true
        
        // Animate hatch (fade out and scale)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0, duration: 0.3)
        let remove = SKAction.removeFromParent()
        activeEggs[index].node.run(SKAction.group([fadeOut, scaleDown, remove]))
        
        // Lose a life
        loseLife()
        
        // Remove from active eggs
        activeEggs.remove(at: index)
    }
    
    func loseLife() {
        guard !isGameOver else { return }
        
        lives -= 1
        updateLivesDisplay()
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        isGameOver = true
        gameOverLabel.isHidden = false
        restartLabel.isHidden = false
        
        // Stop all egg timers
        for egg in activeEggs {
            egg.node.removeAllActions()
        }
    }
    
    func tapEgg(at location: CGPoint) {
        guard !isGameOver else {
            // If game over, restart on tap
            startGame()
            return
        }
        
        // Check if any egg was tapped
        for index in activeEggs.indices.reversed() {
            let egg = activeEggs[index]
            let distance = sqrt(pow(egg.node.position.x - location.x, 2) + pow(egg.node.position.y - location.y, 2))
            
            if distance <= eggRadius && !egg.isTapped && !egg.isHatched {
                // Egg was tapped
                activeEggs[index].isTapped = true
                
                // Remove egg with animation
                let scaleDown = SKAction.scale(to: 0, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let remove = SKAction.removeFromParent()
                activeEggs[index].node.run(SKAction.sequence([SKAction.group([scaleDown, fadeOut]), remove]))
                
                // Increment score
                score += 1
                scoreLabel.text = "Score: \(score)"
                
                // Animate score update
                let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
                let scaleDownLabel = SKAction.scale(to: 1.0, duration: 0.1)
                scoreLabel.run(SKAction.sequence([scaleUp, scaleDownLabel]))
                
                // Remove from active eggs
                activeEggs.remove(at: index)
                
                return
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            tapEgg(at: location)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize lastUpdateTime on first frame
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard !isGameOver else { return }
        
        gameTime += deltaTime
        
        // Update egg colors based on remaining hatch time
        updateEggVisuals(deltaTime: deltaTime)
        
        // Spawn eggs at decreasing intervals
        let spawnInterval = max(0.5, 3.0 - (gameTime * 0.1))
        if currentTime - lastSpawnTime >= spawnInterval {
            spawnEgg()
            lastSpawnTime = currentTime
        }
    }
    
    func updateEggVisuals(deltaTime: TimeInterval) {
        for index in activeEggs.indices {
            let egg = activeEggs[index]
            if egg.isTapped || egg.isHatched { continue }
            
            let elapsed = gameTime - egg.spawnTime
            let remaining = egg.hatchTime - elapsed
            let progress = max(0, min(1, remaining / egg.hatchTime))
            
            // Change color as egg gets closer to hatching
            // White/beige when fresh, red tint when about to hatch
            if progress < 0.3 {
                // About to hatch - red tint
                activeEggs[index].node.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)
                activeEggs[index].node.strokeColor = SKColor.red
            } else if progress < 0.6 {
                // Getting close - yellow tint
                activeEggs[index].node.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
                activeEggs[index].node.strokeColor = SKColor.orange
            } else {
                // Fresh - white/beige
                activeEggs[index].node.fillColor = SKColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)
                activeEggs[index].node.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.5, alpha: 1.0)
            }
        }
    }
}
