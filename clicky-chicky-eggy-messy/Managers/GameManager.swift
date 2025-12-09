//
//  GameManager.swift
//  clicky-chicky-eggy-messy
//
//  Handles game state persistence and settings
//

import Foundation

class GameManager {
    static let shared = GameManager()
    
    // UserDefaults keys
    private enum Keys {
        static let highScore = "highScore"
        static let totalEggsTapped = "totalEggsTapped"
        static let gamesPlayed = "gamesPlayed"
        static let bestCombo = "bestCombo"
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
        static let hasSeenTutorial = "hasSeenTutorial"
    }
    
    private let defaults = UserDefaults.standard
    
    private init() {
        // Register default values
        defaults.register(defaults: [
            Keys.highScore: 0,
            Keys.totalEggsTapped: 0,
            Keys.gamesPlayed: 0,
            Keys.bestCombo: 0,
            Keys.soundEnabled: true,
            Keys.hapticsEnabled: true,
            Keys.hasSeenTutorial: false
        ])
    }
    
    // MARK: - High Score
    
    var highScore: Int {
        get { defaults.integer(forKey: Keys.highScore) }
        set { defaults.set(newValue, forKey: Keys.highScore) }
    }
    
    /// Updates high score if the new score is higher. Returns true if new high score.
    @discardableResult
    func updateHighScore(_ score: Int) -> Bool {
        if score > highScore {
            highScore = score
            return true
        }
        return false
    }
    
    // MARK: - Statistics
    
    var totalEggsTapped: Int {
        get { defaults.integer(forKey: Keys.totalEggsTapped) }
        set { defaults.set(newValue, forKey: Keys.totalEggsTapped) }
    }
    
    var gamesPlayed: Int {
        get { defaults.integer(forKey: Keys.gamesPlayed) }
        set { defaults.set(newValue, forKey: Keys.gamesPlayed) }
    }
    
    var bestCombo: Int {
        get { defaults.integer(forKey: Keys.bestCombo) }
        set { defaults.set(newValue, forKey: Keys.bestCombo) }
    }
    
    func recordGameEnd(score: Int, eggsTapped: Int, maxCombo: Int) {
        gamesPlayed += 1
        totalEggsTapped += eggsTapped
        
        if maxCombo > bestCombo {
            bestCombo = maxCombo
        }
        
        updateHighScore(score)
    }
    
    // MARK: - Settings
    
    var soundEnabled: Bool {
        get { defaults.bool(forKey: Keys.soundEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.soundEnabled)
            SoundManager.shared.soundEnabled = newValue
        }
    }
    
    var hapticsEnabled: Bool {
        get { defaults.bool(forKey: Keys.hapticsEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.hapticsEnabled)
            HapticManager.shared.hapticsEnabled = newValue
        }
    }
    
    var hasSeenTutorial: Bool {
        get { defaults.bool(forKey: Keys.hasSeenTutorial) }
        set { defaults.set(newValue, forKey: Keys.hasSeenTutorial) }
    }
    
    // MARK: - Reset
    
    func resetHighScore() {
        highScore = 0
    }
    
    func resetAllStats() {
        highScore = 0
        totalEggsTapped = 0
        gamesPlayed = 0
        bestCombo = 0
    }
    
    // MARK: - Load Settings
    
    func loadSettings() {
        // Apply saved settings to managers
        SoundManager.shared.soundEnabled = soundEnabled
        HapticManager.shared.hapticsEnabled = hapticsEnabled
    }
}
