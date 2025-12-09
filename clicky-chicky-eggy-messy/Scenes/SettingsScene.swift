//
//  SettingsScene.swift
//  clicky-chicky-eggy-messy
//
//  Settings screen for game options
//

import SpriteKit

class SettingsScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    
    private var soundToggle: SKNode!
    private var hapticsToggle: SKNode!
    private var resetButton: SKShapeNode!
    
    private var soundEnabled: Bool = true
    private var hapticsEnabled: Bool = true
    
    override func didMove(to view: SKView) {
        // Load current settings
        soundEnabled = GameManager.shared.soundEnabled
        hapticsEnabled = GameManager.shared.hapticsEnabled
        
        setupBackground()
        setupTitle()
        setupToggles()
        setupResetButton()
        setupBackButton()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.92, green: 0.90, blue: 0.88, alpha: 1.0)
    }
    
    private func setupTitle() {
        titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.text = "Settings"
        titleLabel.fontSize = 42
        titleLabel.fontColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(titleLabel)
    }
    
    private func setupToggles() {
        let toggleY: CGFloat = size.height * 0.65
        let toggleSpacing: CGFloat = 100
        
        // Sound toggle
        soundToggle = createToggle(
            label: "Sound Effects",
            isOn: soundEnabled,
            position: CGPoint(x: size.width / 2, y: toggleY),
            name: "soundToggle"
        )
        addChild(soundToggle)
        
        // Haptics toggle
        hapticsToggle = createToggle(
            label: "Haptic Feedback",
            isOn: hapticsEnabled,
            position: CGPoint(x: size.width / 2, y: toggleY - toggleSpacing),
            name: "hapticsToggle"
        )
        addChild(hapticsToggle)
    }
    
    private func createToggle(label: String, isOn: Bool, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name
        
        // Label
        let labelNode = SKLabelNode(fontNamed: "Arial")
        labelNode.text = label
        labelNode.fontSize = 24
        labelNode.fontColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        labelNode.horizontalAlignmentMode = .left
        labelNode.position = CGPoint(x: -size.width * 0.35, y: -8)
        container.addChild(labelNode)
        
        // Toggle background
        let toggleBg = SKShapeNode(rectOf: CGSize(width: 60, height: 34), cornerRadius: 17)
        toggleBg.position = CGPoint(x: size.width * 0.25, y: 0)
        toggleBg.fillColor = isOn ? SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0) : SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        toggleBg.strokeColor = .clear
        toggleBg.name = "\(name)Bg"
        container.addChild(toggleBg)
        
        // Toggle knob
        let knob = SKShapeNode(circleOfRadius: 14)
        knob.fillColor = .white
        knob.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        knob.lineWidth = 1
        knob.position = CGPoint(x: isOn ? 12 : -12, y: 0)
        knob.name = "\(name)Knob"
        toggleBg.addChild(knob)
        
        return container
    }
    
    private func setupResetButton() {
        resetButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 12)
        resetButton.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        resetButton.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1.0)
        resetButton.lineWidth = 2
        resetButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        resetButton.name = "resetButton"
        
        let resetLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        resetLabel.text = "Reset High Score"
        resetLabel.fontSize = 18
        resetLabel.fontColor = .white
        resetLabel.verticalAlignmentMode = .center
        resetButton.addChild(resetLabel)
        
        addChild(resetButton)
        
        // Stats info
        let statsInfo = SKLabelNode(fontNamed: "Arial")
        statsInfo.text = "High Score: \(GameManager.shared.highScore) | Best Combo: \(GameManager.shared.bestCombo)x"
        statsInfo.fontSize = 16
        statsInfo.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        statsInfo.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        statsInfo.name = "statsInfo"
        addChild(statsInfo)
    }
    
    private func setupBackButton() {
        backButton = SKShapeNode(rectOf: CGSize(width: 100, height: 44), cornerRadius: 10)
        backButton.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        backButton.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        backButton.lineWidth = 2
        backButton.position = CGPoint(x: 70, y: size.height - 50)
        backButton.name = "backButton"
        
        let backLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        backLabel.text = "← Back"
        backLabel.fontSize = 18
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backButton.addChild(backLabel)
        
        addChild(backButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            // Check for toggle taps
            if let nodeName = node.name {
                if nodeName.contains("soundToggle") || node.parent?.name?.contains("soundToggle") == true || node.parent?.parent?.name?.contains("soundToggle") == true {
                    toggleSound()
                    return
                }
                
                if nodeName.contains("hapticsToggle") || node.parent?.name?.contains("hapticsToggle") == true || node.parent?.parent?.name?.contains("hapticsToggle") == true {
                    toggleHaptics()
                    return
                }
            }
            
            if node.name == "backButton" || node.parent?.name == "backButton" {
                goBack()
                return
            }
            
            if node.name == "resetButton" || node.parent?.name == "resetButton" {
                resetHighScore()
                return
            }
        }
    }
    
    private func toggleSound() {
        soundEnabled.toggle()
        GameManager.shared.soundEnabled = soundEnabled
        
        HapticManager.shared.playSoftImpact()
        
        // Animate toggle
        if let toggle = soundToggle.childNode(withName: "soundToggleBg") as? SKShapeNode,
           let knob = toggle.childNode(withName: "soundToggleKnob") as? SKShapeNode {
            
            let newX: CGFloat = soundEnabled ? 12 : -12
            let newColor = soundEnabled ? SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0) : SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            
            knob.run(SKAction.moveTo(x: newX, duration: 0.15))
            toggle.fillColor = newColor
        }
        
        // Play sound to confirm if enabled
        if soundEnabled {
            SoundManager.shared.playEggTap()
        }
    }
    
    private func toggleHaptics() {
        hapticsEnabled.toggle()
        GameManager.shared.hapticsEnabled = hapticsEnabled
        
        // Animate toggle
        if let toggle = hapticsToggle.childNode(withName: "hapticsToggleBg") as? SKShapeNode,
           let knob = toggle.childNode(withName: "hapticsToggleKnob") as? SKShapeNode {
            
            let newX: CGFloat = hapticsEnabled ? 12 : -12
            let newColor = hapticsEnabled ? SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0) : SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            
            knob.run(SKAction.moveTo(x: newX, duration: 0.15))
            toggle.fillColor = newColor
        }
        
        // Play haptic to confirm if enabled
        if hapticsEnabled {
            HapticManager.shared.playSoftImpact()
        }
    }
    
    private func resetHighScore() {
        HapticManager.shared.playRigidImpact()
        
        GameManager.shared.resetHighScore()
        
        // Update stats display
        if let statsInfo = childNode(withName: "statsInfo") as? SKLabelNode {
            statsInfo.text = "High Score: \(GameManager.shared.highScore) | Best Combo: \(GameManager.shared.bestCombo)x"
        }
        
        // Animate button
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in self?.resetButton.fillColor = SKColor(red: 0.6, green: 0.2, blue: 0.2, alpha: 1.0) },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak self] in self?.resetButton.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0) }
        ])
        resetButton.run(flash)
    }
    
    private func goBack() {
        HapticManager.shared.playSoftImpact()
        
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = scaleMode
        
        let transition = SKTransition.push(with: .right, duration: 0.3)
        view?.presentScene(menuScene, transition: transition)
    }
}
