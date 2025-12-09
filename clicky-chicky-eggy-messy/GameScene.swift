//
//  GameScene.swift
//  clicky-chicky-eggy-messy
//
//  Created by Seb Carss on 09/12/2025.
//

import SpriteKit
import GameplayKit

// Egg type alias for backwards compatibility
typealias Egg = EggData

class GameScene: SKScene {
    
    // Game state
    private var score: Int = 0
    private var lives: Int = 3
    private var gameTime: TimeInterval = 0
    private var lastSpawnTime: TimeInterval = 0
    private var activeEggs: [Egg] = []
    private var isGameOver: Bool = false
    private var lastUpdateTime: TimeInterval = 0
    
    // Combo system
    private var comboCount: Int = 0
    private var lastTapTime: TimeInterval = 0
    private var maxCombo: Int = 0
    private var totalEggsTapped: Int = 0
    private let comboWindow: TimeInterval = 1.5 // seconds to maintain combo
    
    // UI elements
    private var scoreLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var livesNodes: [SKShapeNode] = []
    private var gameOverLabel: SKLabelNode!
    private var restartLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var newHighScoreLabel: SKLabelNode!
    
    // Game over overlay elements
    private var gameOverOverlay: SKNode!
    private var playAgainButton: SKShapeNode!
    private var menuButton: SKShapeNode!
    private var statsLabels: [SKLabelNode] = []
    
    // Chicken node
    private var chickenNode: SKNode!
    private var chickenBody: SKShapeNode!
    private var chickenWing: SKShapeNode!
    
    // Constants
    private let eggRadius: CGFloat = 30
    private let eggWidth: CGFloat = 50
    private let eggHeight: CGFloat = 65
    private let chickenWidth: CGFloat = 60
    private let chickenHeight: CGFloat = 80
    private let edgePadding: CGFloat = 50
    
    override func didMove(to view: SKView) {
        // Load saved settings
        GameManager.shared.loadSettings()
        
        setupScene()
        setupChicken()
        setupUI()
        startGame()
    }
    
    func setupScene() {
        backgroundColor = SKColor(red: 0.9, green: 0.9, blue: 0.85, alpha: 1.0)
    }
    
    func setupChicken() {
        // Create chicken container node
        chickenNode = SKNode()
        chickenNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(chickenNode)
        
        // Create the chicken body (egg-shaped, wider at bottom)
        let bodyPath = createChickenBodyPath()
        chickenBody = SKShapeNode(path: bodyPath)
        chickenBody.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.5, alpha: 1.0) // Golden brown chicken
        chickenBody.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0)
        chickenBody.lineWidth = 2
        chickenNode.addChild(chickenBody)
        
        // Belly (lighter area)
        let bellyPath = createChickenBellyPath()
        let belly = SKShapeNode(path: bellyPath)
        belly.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.75, alpha: 1.0)
        belly.strokeColor = .clear
        belly.position = CGPoint(x: 0, y: -10)
        chickenBody.addChild(belly)
        
        // Wing
        chickenWing = createChickenWing()
        chickenWing.position = CGPoint(x: 20, y: 0)
        chickenBody.addChild(chickenWing)
        
        // Head
        let head = SKShapeNode(circleOfRadius: 18)
        head.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.5, alpha: 1.0)
        head.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0)
        head.lineWidth = 2
        head.position = CGPoint(x: 0, y: chickenHeight / 2 + 5)
        chickenBody.addChild(head)
        
        // Comb (red crown)
        let combPath = createCombPath()
        let comb = SKShapeNode(path: combPath)
        comb.fillColor = SKColor.red
        comb.strokeColor = SKColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0)
        comb.lineWidth = 1
        comb.position = CGPoint(x: 0, y: chickenHeight / 2 + 20)
        chickenBody.addChild(comb)
        
        // Beak
        let beakPath = CGMutablePath()
        beakPath.move(to: CGPoint(x: 0, y: 0))
        beakPath.addLine(to: CGPoint(x: 12, y: -3))
        beakPath.addLine(to: CGPoint(x: 0, y: -6))
        beakPath.closeSubpath()
        
        let beak = SKShapeNode(path: beakPath)
        beak.fillColor = SKColor.orange
        beak.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
        beak.lineWidth = 1
        beak.position = CGPoint(x: 15, y: chickenHeight / 2 + 8)
        chickenBody.addChild(beak)
        
        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 4)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: 6, y: chickenHeight / 2 + 10)
        chickenBody.addChild(leftEye)
        
        // Eye highlight
        let eyeHighlight = SKShapeNode(circleOfRadius: 1.5)
        eyeHighlight.fillColor = .white
        eyeHighlight.strokeColor = .clear
        eyeHighlight.position = CGPoint(x: 1, y: 1)
        leftEye.addChild(eyeHighlight)
        
        // Wattle (red thing under beak)
        let wattle = SKShapeNode(circleOfRadius: 5)
        wattle.fillColor = SKColor.red
        wattle.strokeColor = SKColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0)
        wattle.lineWidth = 1
        wattle.position = CGPoint(x: 8, y: chickenHeight / 2 - 2)
        chickenBody.addChild(wattle)
        
        // Feet
        let leftFoot = createChickenFoot()
        leftFoot.position = CGPoint(x: -12, y: -chickenHeight / 2 - 5)
        chickenBody.addChild(leftFoot)
        
        let rightFoot = createChickenFoot()
        rightFoot.position = CGPoint(x: 12, y: -chickenHeight / 2 - 5)
        chickenBody.addChild(rightFoot)
        
        // Start idle animation
        startChickenIdleAnimation()
    }
    
    func createChickenBodyPath() -> CGPath {
        let path = CGMutablePath()
        let width = chickenWidth
        let height = chickenHeight
        
        // Egg-shaped body
        let a = width / 2
        let b = height / 2
        
        var points: [CGPoint] = []
        let steps = 40
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
            let x = a * cos(t)
            let y = b * sin(t) * (1.1 - 0.15 * cos(t))
            points.append(CGPoint(x: x, y: y))
        }
        
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.closeSubpath()
        
        return path
    }
    
    func createChickenBellyPath() -> CGPath {
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -20, y: -25, width: 40, height: 35))
        return path
    }
    
    func createChickenWing() -> SKShapeNode {
        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: 0, y: 15))
        wingPath.addQuadCurve(to: CGPoint(x: 25, y: 0), control: CGPoint(x: 20, y: 15))
        wingPath.addQuadCurve(to: CGPoint(x: 0, y: -15), control: CGPoint(x: 20, y: -15))
        wingPath.addQuadCurve(to: CGPoint(x: 0, y: 15), control: CGPoint(x: -5, y: 0))
        wingPath.closeSubpath()
        
        let wing = SKShapeNode(path: wingPath)
        wing.fillColor = SKColor(red: 0.85, green: 0.65, blue: 0.4, alpha: 1.0)
        wing.strokeColor = SKColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1.0)
        wing.lineWidth = 1
        wing.zPosition = -1
        
        return wing
    }
    
    func createCombPath() -> CGPath {
        let path = CGMutablePath()
        // Three bumps for the comb
        path.move(to: CGPoint(x: -10, y: 0))
        path.addQuadCurve(to: CGPoint(x: -5, y: 12), control: CGPoint(x: -10, y: 10))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: 0, y: 10))
        path.addQuadCurve(to: CGPoint(x: 5, y: 15), control: CGPoint(x: 5, y: 12))
        path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: 10, y: 10))
        path.closeSubpath()
        return path
    }
    
    func createChickenFoot() -> SKShapeNode {
        let footPath = CGMutablePath()
        // Three toes
        footPath.move(to: CGPoint(x: 0, y: 0))
        footPath.addLine(to: CGPoint(x: -8, y: -10))
        footPath.move(to: CGPoint(x: 0, y: 0))
        footPath.addLine(to: CGPoint(x: 0, y: -12))
        footPath.move(to: CGPoint(x: 0, y: 0))
        footPath.addLine(to: CGPoint(x: 8, y: -10))
        
        let foot = SKShapeNode(path: footPath)
        foot.strokeColor = SKColor.orange
        foot.lineWidth = 3
        foot.lineCap = .round
        
        return foot
    }
    
    func startChickenIdleAnimation() {
        // Gentle bobbing animation
        let bobUp = SKAction.moveBy(x: 0, y: 5, duration: 0.8)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SKAction.moveBy(x: 0, y: -5, duration: 0.8)
        bobDown.timingMode = .easeInEaseOut
        let bobSequence = SKAction.sequence([bobUp, bobDown])
        chickenBody.run(SKAction.repeatForever(bobSequence), withKey: "idleBob")
        
        // Wing flap occasionally
        let wingDown = SKAction.rotate(toAngle: -0.2, duration: 0.15)
        let wingUp = SKAction.rotate(toAngle: 0.1, duration: 0.15)
        let wingRest = SKAction.rotate(toAngle: 0, duration: 0.1)
        let wingWait = SKAction.wait(forDuration: Double.random(in: 2...4))
        let wingSequence = SKAction.sequence([wingDown, wingUp, wingDown, wingUp, wingRest, wingWait])
        chickenWing.run(SKAction.repeatForever(wingSequence), withKey: "wingFlap")
    }
    
    func playChickenLayingAnimation() {
        // Stop idle animation temporarily
        chickenBody.removeAction(forKey: "idleBob")
        
        // Squat down
        let squatDown = SKAction.moveBy(x: 0, y: -10, duration: 0.15)
        let squatUp = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
        
        // Wing flutter
        let wingFlutter = SKAction.run { [weak self] in
            let flutter1 = SKAction.rotate(toAngle: -0.3, duration: 0.05)
            let flutter2 = SKAction.rotate(toAngle: 0.2, duration: 0.05)
            let flutterSequence = SKAction.sequence([flutter1, flutter2])
            self?.chickenWing.run(SKAction.repeat(flutterSequence, count: 3))
        }
        
        // Resume idle
        let resumeIdle = SKAction.run { [weak self] in
            self?.startChickenIdleAnimation()
        }
        
        chickenBody.run(SKAction.sequence([squatDown, wingFlutter, squatUp, resumeIdle]))
    }
    
    func setupUI() {
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 20, y: size.height - 50)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        // High score label
        highScoreLabel = SKLabelNode(fontNamed: "Arial")
        highScoreLabel.text = "Best: \(GameManager.shared.highScore)"
        highScoreLabel.fontSize = 18
        highScoreLabel.fontColor = SKColor.darkGray
        highScoreLabel.position = CGPoint(x: 20, y: size.height - 80)
        highScoreLabel.horizontalAlignmentMode = .left
        addChild(highScoreLabel)
        
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
        
        // Combo label (hidden initially)
        comboLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        comboLabel.text = ""
        comboLabel.fontSize = 36
        comboLabel.fontColor = SKColor.orange
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        comboLabel.isHidden = true
        comboLabel.zPosition = 100
        addChild(comboLabel)
        
        // New high score label (hidden initially)
        newHighScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newHighScoreLabel.text = "NEW HIGH SCORE!"
        newHighScoreLabel.fontSize = 28
        newHighScoreLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        newHighScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        newHighScoreLabel.isHidden = true
        newHighScoreLabel.zPosition = 100
        addChild(newHighScoreLabel)
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
        // Hide game over overlay if visible
        hideGameOverOverlay()
        
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
        
        // Reset combo
        comboCount = 0
        lastTapTime = 0
        maxCombo = 0
        totalEggsTapped = 0
        comboLabel.isHidden = true
        if newHighScoreLabel != nil {
            newHighScoreLabel.isHidden = true
        }
        
        scoreLabel.text = "Score: 0"
        highScoreLabel.text = "Best: \(GameManager.shared.highScore)"
        if gameOverLabel != nil {
            gameOverLabel.isHidden = true
        }
        if restartLabel != nil {
            restartLabel.isHidden = true
        }
        updateLivesDisplay()
    }
    
    func spawnEgg() {
        guard !isGameOver else { return }
        
        // Calculate random position (avoid edges)
        let minX = edgePadding + eggWidth / 2
        let maxX = size.width - edgePadding - eggWidth / 2
        let minY = edgePadding + eggHeight / 2
        let maxY = size.height - 150 - eggHeight / 2 // Leave space for chicken and UI
        
        let x = CGFloat.random(in: minX...maxX)
        let y = CGFloat.random(in: minY...maxY)
        
        // Determine egg type (special eggs only after some game time)
        let eggType: EggType = gameTime > 5 ? EggType.randomType() : .normal
        
        // Create egg container node
        let eggContainer = SKNode()
        eggContainer.position = CGPoint(x: x, y: y)
        
        // Create egg visual based on type
        let visualNode = createYoshiEgg(type: eggType)
        eggContainer.addChild(visualNode)
        
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
            node: eggContainer,
            type: eggType,
            hatchTime: hatchTime,
            spawnTime: gameTime,
            visualNode: visualNode
        )
        
        activeEggs.append(egg)
        addChild(eggContainer)
        
        // Play chicken laying animation
        playChickenLayingAnimation()
        
        // Schedule hatch
        scheduleHatch(for: egg)
    }
    
    func createYoshiEgg(type: EggType = .normal) -> SKNode {
        // Create a Yoshi-style egg programmatically with type-specific colors
        let eggPath = CGMutablePath()
        let width = eggWidth
        let height = eggHeight
        
        // Create egg shape: wider at bottom, narrower at top (like Yoshi eggs)
        let centerX: CGFloat = 0
        let centerY: CGFloat = 0
        let a = width / 2  // Horizontal radius
        let b = height / 2 // Vertical radius
        
        // Use a parametric egg curve
        var points: [CGPoint] = []
        let steps = 60
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
            // Egg curve formula: x = a * cos(t), y = b * sin(t) * (1.2 - 0.3 * cos(t))
            let x = centerX + a * cos(t)
            let y = centerY + b * sin(t) * (1.2 - 0.3 * cos(t))
            points.append(CGPoint(x: x, y: y))
        }
        
        // Build path from points
        eggPath.move(to: points[0])
        for i in 1..<points.count {
            eggPath.addLine(to: points[i])
        }
        eggPath.closeSubpath()
        
        let eggShape = SKShapeNode(path: eggPath)
        
        // Use type-specific colors
        eggShape.fillColor = type.fillColor
        eggShape.strokeColor = type.strokeColor
        eggShape.lineWidth = 2.5
        eggShape.glowWidth = type == .golden ? 2.0 : 0.5
        
        // Add a highlight for 3D effect (like Yoshi eggs)
        let highlight = SKShapeNode(circleOfRadius: width * 0.15)
        highlight.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        highlight.strokeColor = SKColor.clear
        highlight.position = CGPoint(x: -width * 0.15, y: height * 0.2)
        eggShape.addChild(highlight)
        
        // Add subtle shadow at bottom
        let shadow = SKShapeNode(ellipseOf: CGSize(width: width * 0.6, height: height * 0.2))
        shadow.fillColor = SKColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 0.4)
        shadow.strokeColor = SKColor.clear
        shadow.position = CGPoint(x: 0, y: -height * 0.35)
        eggShape.addChild(shadow)
        
        return eggShape
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
        
        // Play hatch sound
        SoundManager.shared.playEggHatch()
        
        // Add hatch particles
        let hatchParticles = ParticleManager.shared.createHatchParticles(at: activeEggs[index].node.position)
        hatchParticles.zPosition = 50
        addChild(hatchParticles)
        
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
        
        // Play life lost sound and haptic
        SoundManager.shared.playLifeLost()
        HapticManager.shared.playLifeLost()
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        isGameOver = true
        
        // Play game over sound and haptic
        SoundManager.shared.playGameOver()
        HapticManager.shared.playGameOver()
        
        // Record game stats and check for new high score
        let isNewHighScore = GameManager.shared.updateHighScore(score)
        GameManager.shared.recordGameEnd(score: score, eggsTapped: totalEggsTapped, maxCombo: maxCombo)
        
        // Update high score display
        highScoreLabel.text = "Best: \(GameManager.shared.highScore)"
        
        // Stop all egg timers
        for egg in activeEggs {
            egg.node.removeAllActions()
        }
        
        // Show enhanced game over overlay
        showGameOverOverlay(isNewHighScore: isNewHighScore)
    }
    
    func showGameOverOverlay(isNewHighScore: Bool) {
        // Create overlay container
        gameOverOverlay = SKNode()
        gameOverOverlay.zPosition = 200
        addChild(gameOverOverlay)
        
        // Semi-transparent background
        let background = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        background.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        background.strokeColor = .clear
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverOverlay.addChild(background)
        
        // Game Over title
        let titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.text = "Game Over!"
        titleLabel.fontSize = 48
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        gameOverOverlay.addChild(titleLabel)
        
        // New high score label
        if isNewHighScore {
            let newHighLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
            newHighLabel.text = "NEW HIGH SCORE!"
            newHighLabel.fontSize = 28
            newHighLabel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            newHighLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
            gameOverOverlay.addChild(newHighLabel)
            
            // Animate it
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            newHighLabel.run(SKAction.repeatForever(pulse))
            
            HapticManager.shared.playSuccess()
        }
        
        // Stats panel
        let statsY = size.height * 0.55
        let statsSpacing: CGFloat = 35
        
        let stats = [
            ("Final Score", "\(score)"),
            ("Eggs Tapped", "\(totalEggsTapped)"),
            ("Best Combo", "\(maxCombo)x"),
            ("Time Survived", String(format: "%.1fs", gameTime))
        ]
        
        for (index, stat) in stats.enumerated() {
            let label = SKLabelNode(fontNamed: "Arial")
            label.text = "\(stat.0): \(stat.1)"
            label.fontSize = 22
            label.fontColor = .white
            label.position = CGPoint(x: size.width / 2, y: statsY - CGFloat(index) * statsSpacing)
            gameOverOverlay.addChild(label)
            statsLabels.append(label)
        }
        
        // Play Again button
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 55
        
        playAgainButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 12)
        playAgainButton.fillColor = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        playAgainButton.strokeColor = SKColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0)
        playAgainButton.lineWidth = 3
        playAgainButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        playAgainButton.name = "playAgainButton"
        
        let playLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        playLabel.text = "Play Again"
        playLabel.fontSize = 24
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playAgainButton.addChild(playLabel)
        
        gameOverOverlay.addChild(playAgainButton)
        
        // Main Menu button
        menuButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 12)
        menuButton.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        menuButton.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        menuButton.lineWidth = 3
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        menuButton.name = "menuButton"
        
        let menuLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        menuLabel.text = "Main Menu"
        menuLabel.fontSize = 22
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        
        gameOverOverlay.addChild(menuButton)
        
        // Animate overlay appearance
        gameOverOverlay.alpha = 0
        gameOverOverlay.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    func hideGameOverOverlay() {
        gameOverOverlay?.removeFromParent()
        gameOverOverlay = nil
        statsLabels.removeAll()
    }
    
    func handleGameOverTap(at location: CGPoint) {
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "playAgainButton" || node.parent?.name == "playAgainButton" {
                HapticManager.shared.playSoftImpact()
                animateButtonPress(playAgainButton) { [weak self] in
                    self?.hideGameOverOverlay()
                    self?.startGame()
                }
                return
            }
            
            if node.name == "menuButton" || node.parent?.name == "menuButton" {
                HapticManager.shared.playSoftImpact()
                animateButtonPress(menuButton) { [weak self] in
                    self?.goToMainMenu()
                }
                return
            }
        }
    }
    
    func animateButtonPress(_ button: SKShapeNode?, completion: @escaping () -> Void) {
        guard let button = button else {
            completion()
            return
        }
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
        let action = SKAction.run(completion)
        
        button.run(SKAction.sequence([scaleDown, scaleUp, action]))
    }
    
    func goToMainMenu() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = scaleMode
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(menuScene, transition: transition)
    }
    
    func tapEgg(at location: CGPoint) {
        guard !isGameOver else {
            // Game over - handle button taps
            handleGameOverTap(at: location)
            return
        }
        
        // Check if any egg was tapped
        for index in activeEggs.indices.reversed() {
            let egg = activeEggs[index]
            // Use egg dimensions for tap detection
            let tapRadius = max(eggWidth, eggHeight) / 2
            let distance = sqrt(pow(egg.node.position.x - location.x, 2) + pow(egg.node.position.y - location.y, 2))
            
            if distance <= tapRadius && !egg.isTapped && !egg.isHatched {
                // Egg was tapped
                activeEggs[index].isTapped = true
                
                // Handle based on egg type
                handleEggTap(egg: egg, at: index)
                
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
        
        // Check combo expiry
        checkComboExpiry()
        
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
            
            // Apply wobble animation when close to hatching
            applyWobbleEffect(to: egg.node, progress: progress)
            
            // Only update colors for normal eggs - special eggs keep their colors
            guard egg.type == .normal else { continue }
            
            // Only update colors if it's a shape node (not a sprite)
            if let eggShape = egg.visualNode as? SKShapeNode {
                // Change color as egg gets closer to hatching
                // White/beige when fresh, red tint when about to hatch
                if progress < 0.3 {
                    // About to hatch - red tint
                    eggShape.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)
                    eggShape.strokeColor = SKColor.red
                } else if progress < 0.6 {
                    // Getting close - yellow tint
                    eggShape.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
                    eggShape.strokeColor = SKColor.orange
                } else {
                    // Fresh - white/beige (Yoshi egg colors)
                    eggShape.fillColor = SKColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 1.0)
                    eggShape.strokeColor = SKColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 1.0)
                }
            } else if let eggSprite = egg.visualNode as? SKSpriteNode {
                // For sprite nodes, adjust color/alpha to indicate hatch status
                if progress < 0.3 {
                    eggSprite.color = SKColor.red
                    eggSprite.colorBlendFactor = 0.3
                } else if progress < 0.6 {
                    eggSprite.color = SKColor.orange
                    eggSprite.colorBlendFactor = 0.2
                } else {
                    eggSprite.color = SKColor.white
                    eggSprite.colorBlendFactor = 0.0
                }
            }
        }
    }
    
    // MARK: - Special Egg Handling
    
    func handleEggTap(egg: Egg, at index: Int) {
        let position = egg.node.position
        
        switch egg.type {
        case .normal, .golden, .speed:
            // Play tap sound and haptic
            if egg.type == .golden {
                SoundManager.shared.playSpecialEgg()
                HapticManager.shared.playSuccess()
                // Golden sparkle particles
                let particles = ParticleManager.shared.createGoldenSparkles(at: position)
                particles.zPosition = 50
                addChild(particles)
            } else if egg.type == .speed {
                SoundManager.shared.playSpecialEgg()
                HapticManager.shared.playCombo()
                applySpeedEffect()
                // Blue particles for speed
                let particles = ParticleManager.shared.createEggTapParticles(at: position, color: SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0))
                particles.zPosition = 50
                addChild(particles)
            } else {
                SoundManager.shared.playEggTap()
                HapticManager.shared.playEggTap()
                // Normal tap particles
                let particles = ParticleManager.shared.createEggTapParticles(at: position, color: SKColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0))
                particles.zPosition = 50
                addChild(particles)
            }
            
            // Remove egg with animation
            let scaleDown = SKAction.scale(to: 0, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let remove = SKAction.removeFromParent()
            activeEggs[index].node.run(SKAction.sequence([SKAction.group([scaleDown, fadeOut]), remove]))
            
            // Update combo
            updateCombo()
            
            // Calculate points based on combo and egg type
            let comboMultiplier = min(comboCount, 5) // Cap at 5x
            let typeMultiplier = egg.type.pointMultiplier
            let points = comboMultiplier * typeMultiplier
            score += points
            totalEggsTapped += 1
            
            // Update max combo
            if comboCount > maxCombo {
                maxCombo = comboCount
            }
            
            scoreLabel.text = "Score: \(score)"
            
            // Show floating points
            if points > 0 {
                showFloatingPoints(points: points, at: position)
            }
            
            // Animate score update
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
            let scaleDownLabel = SKAction.scale(to: 1.0, duration: 0.1)
            scoreLabel.run(SKAction.sequence([scaleUp, scaleDownLabel]))
            
        case .heart:
            // Restore a life
            SoundManager.shared.playHeartGained()
            HapticManager.shared.playSuccess()
            
            // Heart particles
            let heartParticles = ParticleManager.shared.createHeartParticles(at: position)
            heartParticles.zPosition = 50
            addChild(heartParticles)
            
            if lives < 3 {
                lives += 1
                updateLivesDisplay()
                showFloatingText(text: "+1 Life!", at: position, color: .red)
            } else {
                // Already at max lives, give bonus points instead
                score += 10
                scoreLabel.text = "Score: \(score)"
                showFloatingPoints(points: 10, at: position)
            }
            
            // Remove egg with animation
            let heartScaleDown = SKAction.scale(to: 0, duration: 0.2)
            let heartFadeOut = SKAction.fadeOut(withDuration: 0.2)
            let heartRemove = SKAction.removeFromParent()
            activeEggs[index].node.run(SKAction.sequence([SKAction.group([heartScaleDown, heartFadeOut]), heartRemove]))
            
        case .bomb:
            // Bomb egg - lose a life!
            SoundManager.shared.playLifeLost()
            HapticManager.shared.playLifeLost()
            
            // Explosion particles
            let explosionParticles = ParticleManager.shared.createExplosionParticles(at: position)
            explosionParticles.zPosition = 50
            addChild(explosionParticles)
            
            showFloatingText(text: "BOOM!", at: position, color: .red)
            
            // Explosive animation
            let expand = SKAction.scale(to: 1.5, duration: 0.1)
            let shrink = SKAction.scale(to: 0, duration: 0.2)
            let bombRemove = SKAction.removeFromParent()
            activeEggs[index].node.run(SKAction.sequence([expand, shrink, bombRemove]))
            
            // Reset combo
            comboCount = 0
            
            // Lose a life
            loseLife()
        }
        
        // Remove from active eggs
        activeEggs.remove(at: index)
    }
    
    func applySpeedEffect() {
        // Slow down all active eggs by increasing their hatch time
        for index in activeEggs.indices {
            activeEggs[index].hatchTime += 2.0
        }
        
        // Visual indicator
        let slowText = SKLabelNode(fontNamed: "Arial-BoldMT")
        slowText.text = "SLOW DOWN!"
        slowText.fontSize = 32
        slowText.fontColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        slowText.position = CGPoint(x: size.width / 2, y: size.height / 2)
        slowText.zPosition = 200
        addChild(slowText)
        
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
        let wait = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        slowText.run(SKAction.sequence([scaleUp, wait, fadeOut, remove]))
    }
    
    func showFloatingText(text: String, at position: CGPoint, color: SKColor) {
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = text
        label.fontSize = 24
        label.fontColor = color
        label.position = position
        label.zPosition = 100
        addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        
        let group = SKAction.group([moveUp, SKAction.sequence([SKAction.wait(forDuration: 0.2), fadeOut])])
        label.run(SKAction.sequence([group, remove]))
    }
    
    func applyWobbleEffect(to node: SKNode, progress: Double) {
        let wobbleActionKey = "wobble"
        
        if progress < 0.3 {
            // Intense wobble when about to hatch
            if node.action(forKey: wobbleActionKey) == nil {
                let wobbleAngle: CGFloat = 0.15
                let wobbleDuration: TimeInterval = 0.08
                
                let wobbleLeft = SKAction.rotate(toAngle: -wobbleAngle, duration: wobbleDuration)
                let wobbleRight = SKAction.rotate(toAngle: wobbleAngle, duration: wobbleDuration)
                let wobbleSequence = SKAction.sequence([wobbleLeft, wobbleRight])
                let wobbleForever = SKAction.repeatForever(wobbleSequence)
                
                node.run(wobbleForever, withKey: wobbleActionKey)
            }
        } else if progress < 0.5 {
            // Gentle wobble when getting close
            if node.action(forKey: wobbleActionKey) == nil {
                let wobbleAngle: CGFloat = 0.08
                let wobbleDuration: TimeInterval = 0.15
                
                let wobbleLeft = SKAction.rotate(toAngle: -wobbleAngle, duration: wobbleDuration)
                let wobbleRight = SKAction.rotate(toAngle: wobbleAngle, duration: wobbleDuration)
                let wobbleSequence = SKAction.sequence([wobbleLeft, wobbleRight])
                let wobbleForever = SKAction.repeatForever(wobbleSequence)
                
                node.run(wobbleForever, withKey: wobbleActionKey)
            }
        } else {
            // No wobble for fresh eggs - remove any existing wobble
            if node.action(forKey: wobbleActionKey) != nil {
                node.removeAction(forKey: wobbleActionKey)
                node.run(SKAction.rotate(toAngle: 0, duration: 0.1))
            }
        }
    }
    
    // MARK: - Combo System
    
    func updateCombo() {
        let currentTime = gameTime
        
        // Check if within combo window
        if currentTime - lastTapTime <= comboWindow {
            comboCount += 1
        } else {
            comboCount = 1
        }
        
        lastTapTime = currentTime
        
        // Update combo display
        updateComboDisplay()
        
        // Play combo sound and haptic for combos >= 3
        if comboCount >= 3 {
            SoundManager.shared.playCombo()
            if comboCount >= 5 {
                HapticManager.shared.playBigCombo(intensity: 1.0)
                // Add celebration particles for big combos
                let comboParticles = ParticleManager.shared.createComboParticles(at: CGPoint(x: size.width / 2, y: size.height / 2), comboLevel: comboCount)
                comboParticles.zPosition = 50
                addChild(comboParticles)
            } else {
                HapticManager.shared.playCombo()
            }
        }
    }
    
    func updateComboDisplay() {
        if comboCount >= 2 {
            comboLabel.isHidden = false
            comboLabel.text = "\(comboCount)x COMBO!"
            
            // Color based on combo level
            switch comboCount {
            case 2:
                comboLabel.fontColor = SKColor.orange
            case 3:
                comboLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            case 4:
                comboLabel.fontColor = SKColor.red
            default:
                comboLabel.fontColor = SKColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0)
            }
            
            // Animate combo label
            comboLabel.removeAllActions()
            comboLabel.setScale(1.0)
            comboLabel.alpha = 1.0
            
            let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let wait = SKAction.wait(forDuration: 0.8)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let hide = SKAction.run { [weak self] in
                self?.comboLabel.isHidden = true
                self?.comboLabel.alpha = 1.0
            }
            
            comboLabel.run(SKAction.sequence([scaleUp, scaleDown, wait, fadeOut, hide]))
        }
    }
    
    func showFloatingPoints(points: Int, at position: CGPoint) {
        let pointsLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        pointsLabel.text = "+\(points)"
        pointsLabel.fontSize = points >= 3 ? 28 : 22
        pointsLabel.fontColor = points >= 3 ? SKColor.orange : SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        pointsLabel.position = position
        pointsLabel.zPosition = 100
        addChild(pointsLabel)
        
        // Animate floating up and fading
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.4)
        let remove = SKAction.removeFromParent()
        
        let group = SKAction.group([
            moveUp,
            SKAction.sequence([scaleUp, scaleDown]),
            SKAction.sequence([SKAction.wait(forDuration: 0.2), fadeOut])
        ])
        
        pointsLabel.run(SKAction.sequence([group, remove]))
    }
    
    func checkComboExpiry() {
        // Reset combo if window has passed
        if gameTime - lastTapTime > comboWindow && comboCount > 0 {
            comboCount = 0
        }
    }
}
