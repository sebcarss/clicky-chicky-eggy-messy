//
//  MenuScene.swift
//  clicky-chicky-eggy-messy
//
//  Main menu scene with play and settings buttons
//

import SpriteKit

class MenuScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var playButton: SKShapeNode!
    private var settingsButton: SKShapeNode!
    private var highScoreLabel: SKLabelNode!
    private var statsLabel: SKLabelNode!
    
    // Decorative eggs
    private var decorativeEggs: [SKNode] = []
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
        setupStats()
        setupDecorativeEggs()
        animateEntrance()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
        
        // Add subtle gradient overlay
        let gradientNode = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientNode.fillColor = SKColor(red: 0.9, green: 0.85, blue: 0.75, alpha: 0.3)
        gradientNode.strokeColor = .clear
        gradientNode.zPosition = -1
        addChild(gradientNode)
    }
    
    private func setupTitle() {
        // Main title
        titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.text = "Clicky Chicky"
        titleLabel.fontSize = 48
        titleLabel.fontColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        titleLabel.alpha = 0
        addChild(titleLabel)
        
        // Subtitle
        subtitleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        subtitleLabel.text = "Eggy Messy"
        subtitleLabel.fontSize = 36
        subtitleLabel.fontColor = SKColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75 - 50)
        subtitleLabel.alpha = 0
        addChild(subtitleLabel)
    }
    
    private func setupButtons() {
        // Play button
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 60
        
        playButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        playButton.fillColor = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        playButton.strokeColor = SKColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0)
        playButton.lineWidth = 3
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        playButton.name = "playButton"
        playButton.alpha = 0
        
        let playLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        playLabel.text = "PLAY"
        playLabel.fontSize = 28
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playButton.addChild(playLabel)
        
        addChild(playButton)
        
        // Settings button
        settingsButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        settingsButton.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        settingsButton.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        settingsButton.lineWidth = 3
        settingsButton.position = CGPoint(x: size.width / 2, y: size.height * 0.32)
        settingsButton.name = "settingsButton"
        settingsButton.alpha = 0
        
        let settingsLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        settingsLabel.text = "SETTINGS"
        settingsLabel.fontSize = 24
        settingsLabel.fontColor = .white
        settingsLabel.verticalAlignmentMode = .center
        settingsButton.addChild(settingsLabel)
        
        addChild(settingsButton)
    }
    
    private func setupStats() {
        // High score
        highScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        highScoreLabel.text = "High Score: \(GameManager.shared.highScore)"
        highScoreLabel.fontSize = 24
        highScoreLabel.fontColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        highScoreLabel.alpha = 0
        addChild(highScoreLabel)
        
        // Games played stats
        let gamesPlayed = GameManager.shared.gamesPlayed
        let totalEggs = GameManager.shared.totalEggsTapped
        statsLabel = SKLabelNode(fontNamed: "Arial")
        statsLabel.text = "Games: \(gamesPlayed) | Eggs: \(totalEggs)"
        statsLabel.fontSize = 16
        statsLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        statsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        statsLabel.alpha = 0
        addChild(statsLabel)
    }
    
    private func setupDecorativeEggs() {
        // Add some decorative eggs around the screen
        let eggPositions: [CGPoint] = [
            CGPoint(x: size.width * 0.15, y: size.height * 0.85),
            CGPoint(x: size.width * 0.85, y: size.height * 0.80),
            CGPoint(x: size.width * 0.1, y: size.height * 0.35),
            CGPoint(x: size.width * 0.9, y: size.height * 0.40),
            CGPoint(x: size.width * 0.2, y: size.height * 0.08),
            CGPoint(x: size.width * 0.8, y: size.height * 0.05)
        ]
        
        for position in eggPositions {
            let egg = createDecorativeEgg()
            egg.position = position
            egg.alpha = 0
            egg.setScale(0.6 + CGFloat.random(in: 0...0.3))
            egg.zRotation = CGFloat.random(in: -0.3...0.3)
            addChild(egg)
            decorativeEggs.append(egg)
            
            // Add gentle floating animation
            let moveUp = SKAction.moveBy(x: 0, y: 10, duration: Double.random(in: 2...3))
            let moveDown = moveUp.reversed()
            let float = SKAction.sequence([moveUp, moveDown])
            egg.run(SKAction.repeatForever(float))
        }
    }
    
    private func createDecorativeEgg() -> SKNode {
        let eggWidth: CGFloat = 40
        let eggHeight: CGFloat = 52
        
        let eggPath = CGMutablePath()
        let a = eggWidth / 2
        let b = eggHeight / 2
        
        var points: [CGPoint] = []
        let steps = 60
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
            let x = a * cos(t)
            let y = b * sin(t) * (1.2 - 0.3 * cos(t))
            points.append(CGPoint(x: x, y: y))
        }
        
        eggPath.move(to: points[0])
        for i in 1..<points.count {
            eggPath.addLine(to: points[i])
        }
        eggPath.closeSubpath()
        
        let eggShape = SKShapeNode(path: eggPath)
        eggShape.fillColor = SKColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 0.8)
        eggShape.strokeColor = SKColor(red: 0.85, green: 0.75, blue: 0.65, alpha: 0.8)
        eggShape.lineWidth = 2
        
        return eggShape
    }
    
    private func animateEntrance() {
        // Animate title
        titleLabel.run(SKAction.fadeIn(withDuration: 0.5))
        subtitleLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        // Animate buttons
        playButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        
        settingsButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        
        // Animate stats
        highScoreLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        
        statsLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        
        // Animate decorative eggs
        for (index, egg) in decorativeEggs.enumerated() {
            egg.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3 + Double(index) * 0.1),
                SKAction.fadeIn(withDuration: 0.4)
            ]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "playButton" || node.parent?.name == "playButton" {
                animateButtonPress(playButton) { [weak self] in
                    self?.startGame()
                }
            } else if node.name == "settingsButton" || node.parent?.name == "settingsButton" {
                animateButtonPress(settingsButton) { [weak self] in
                    self?.showSettings()
                }
            }
        }
    }
    
    private func animateButtonPress(_ button: SKShapeNode, completion: @escaping () -> Void) {
        HapticManager.shared.playSoftImpact()
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
        let action = SKAction.run(completion)
        
        button.run(SKAction.sequence([scaleDown, scaleUp, action]))
    }
    
    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func showSettings() {
        let settingsScene = SettingsScene(size: size)
        settingsScene.scaleMode = scaleMode
        
        let transition = SKTransition.push(with: .left, duration: 0.3)
        view?.presentScene(settingsScene, transition: transition)
    }
}
