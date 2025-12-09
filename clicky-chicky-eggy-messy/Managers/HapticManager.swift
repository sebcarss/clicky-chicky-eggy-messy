//
//  HapticManager.swift
//  clicky-chicky-eggy-messy
//
//  Handles haptic feedback for game events
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private var lightImpact: UIImpactFeedbackGenerator?
    private var mediumImpact: UIImpactFeedbackGenerator?
    private var heavyImpact: UIImpactFeedbackGenerator?
    private var notificationFeedback: UINotificationFeedbackGenerator?
    
    private var isHapticsEnabled: Bool = true
    
    private init() {
        prepareGenerators()
    }
    
    private func prepareGenerators() {
        lightImpact = UIImpactFeedbackGenerator(style: .light)
        mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        notificationFeedback = UINotificationFeedbackGenerator()
        
        // Prepare generators for immediate response
        lightImpact?.prepare()
        mediumImpact?.prepare()
        heavyImpact?.prepare()
        notificationFeedback?.prepare()
    }
    
    // MARK: - Public Properties
    
    var hapticsEnabled: Bool {
        get { isHapticsEnabled }
        set { isHapticsEnabled = newValue }
    }
    
    // MARK: - Haptic Methods
    
    /// Light tap - used for regular egg taps
    func playEggTap() {
        guard isHapticsEnabled else { return }
        lightImpact?.impactOccurred()
        lightImpact?.prepare()
    }
    
    /// Medium impact - used for combos
    func playCombo() {
        guard isHapticsEnabled else { return }
        mediumImpact?.impactOccurred()
        mediumImpact?.prepare()
    }
    
    /// Heavy impact with intensity - used for big combos
    func playBigCombo(intensity: CGFloat = 1.0) {
        guard isHapticsEnabled else { return }
        heavyImpact?.impactOccurred(intensity: intensity)
        heavyImpact?.prepare()
    }
    
    /// Warning notification - used when life is lost
    func playLifeLost() {
        guard isHapticsEnabled else { return }
        notificationFeedback?.notificationOccurred(.warning)
        notificationFeedback?.prepare()
    }
    
    /// Error notification - used for game over
    func playGameOver() {
        guard isHapticsEnabled else { return }
        notificationFeedback?.notificationOccurred(.error)
        notificationFeedback?.prepare()
    }
    
    /// Success notification - used for special eggs, achievements
    func playSuccess() {
        guard isHapticsEnabled else { return }
        notificationFeedback?.notificationOccurred(.success)
        notificationFeedback?.prepare()
    }
    
    /// Soft impact - used for UI interactions
    func playSoftImpact() {
        guard isHapticsEnabled else { return }
        let soft = UIImpactFeedbackGenerator(style: .soft)
        soft.impactOccurred()
    }
    
    /// Rigid impact - used for important events
    func playRigidImpact() {
        guard isHapticsEnabled else { return }
        let rigid = UIImpactFeedbackGenerator(style: .rigid)
        rigid.impactOccurred()
    }
}
