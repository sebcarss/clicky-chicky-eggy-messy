//
//  SoundManager.swift
//  clicky-chicky-eggy-messy
//
//  Handles all game audio using synthesized sounds
//

import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var mixerFormat: AVAudioFormat?
    private var isSoundEnabled: Bool = true
    
    private init() {
        setupAudioSession()
        setupAudioEngine()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = playerNode else { return }
        
        engine.attach(player)
        
        // Get the mixer's format and use it for connection
        let mixer = engine.mainMixerNode
        mixerFormat = mixer.outputFormat(forBus: 0)
        
        // Connect player to mixer using the mixer's format
        engine.connect(player, to: mixer, format: mixerFormat)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    var soundEnabled: Bool {
        get { isSoundEnabled }
        set { isSoundEnabled = newValue }
    }
    
    func playEggTap() {
        guard isSoundEnabled else { return }
        playTone(frequency: 880, duration: 0.1, type: .pop)
    }
    
    func playEggHatch() {
        guard isSoundEnabled else { return }
        playTone(frequency: 440, duration: 0.2, type: .crack)
    }
    
    func playLifeLost() {
        guard isSoundEnabled else { return }
        playTone(frequency: 220, duration: 0.3, type: .negative)
    }
    
    func playGameOver() {
        guard isSoundEnabled else { return }
        playGameOverSequence()
    }
    
    func playCombo() {
        guard isSoundEnabled else { return }
        playTone(frequency: 1200, duration: 0.15, type: .chime)
    }
    
    func playSpecialEgg() {
        guard isSoundEnabled else { return }
        playTone(frequency: 1500, duration: 0.2, type: .sparkle)
    }
    
    func playHeartGained() {
        guard isSoundEnabled else { return }
        playTone(frequency: 660, duration: 0.25, type: .powerup)
    }
    
    // MARK: - Sound Synthesis
    
    private enum SoundType {
        case pop, crack, negative, chime, sparkle, powerup
    }
    
    private func playTone(frequency: Double, duration: Double, type: SoundType) {
        guard let engine = audioEngine, let player = playerNode, let format = mixerFormat else { return }
        
        // Use the mixer's sample rate and channel count
        let sampleRate = format.sampleRate
        let channelCount = format.channelCount
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        
        // Fill all channels with the same data
        for channel in 0..<Int(channelCount) {
            guard let channelData = buffer.floatChannelData?[channel] else { continue }
            
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                let envelope = calculateEnvelope(time: time, duration: duration, type: type)
                let sample = calculateSample(time: time, frequency: frequency, type: type)
                channelData[frame] = Float(sample * envelope * 0.3)
            }
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        if !player.isPlaying {
            player.play()
        }
    }
    
    private func calculateEnvelope(time: Double, duration: Double, type: SoundType) -> Double {
        let progress = time / duration
        
        switch type {
        case .pop:
            // Quick attack, quick decay
            if progress < 0.1 {
                return progress / 0.1
            } else {
                return pow(1 - (progress - 0.1) / 0.9, 2)
            }
        case .crack:
            // Sharp attack, medium decay with noise
            return pow(1 - progress, 1.5)
        case .negative:
            // Slow attack, slow decay
            if progress < 0.2 {
                return progress / 0.2
            } else {
                return 1 - (progress - 0.2) / 0.8
            }
        case .chime:
            // Bell-like envelope
            return pow(1 - progress, 0.5)
        case .sparkle:
            // Bright, quick
            return pow(1 - progress, 2)
        case .powerup:
            // Rising and fading
            if progress < 0.3 {
                return progress / 0.3
            } else {
                return pow(1 - (progress - 0.3) / 0.7, 0.8)
            }
        }
    }
    
    private func calculateSample(time: Double, frequency: Double, type: SoundType) -> Double {
        switch type {
        case .pop:
            // Sine wave with slight frequency drop
            let freq = frequency * (1 - time * 2)
            return sin(2 * .pi * freq * time)
        case .crack:
            // Noise + low frequency
            let noise = Double.random(in: -1...1) * 0.3
            let tone = sin(2 * .pi * frequency * time)
            return noise + tone * 0.7
        case .negative:
            // Descending tone
            let freq = frequency * (1 - time * 0.5)
            return sin(2 * .pi * freq * time)
        case .chime:
            // Harmonics for bell-like sound
            let fundamental = sin(2 * .pi * frequency * time)
            let harmonic1 = sin(2 * .pi * frequency * 2 * time) * 0.5
            let harmonic2 = sin(2 * .pi * frequency * 3 * time) * 0.25
            return fundamental + harmonic1 + harmonic2
        case .sparkle:
            // High frequency with harmonics
            let fundamental = sin(2 * .pi * frequency * time)
            let harmonic = sin(2 * .pi * frequency * 2.5 * time) * 0.3
            return fundamental + harmonic
        case .powerup:
            // Rising frequency
            let freq = frequency * (1 + time * 0.5)
            return sin(2 * .pi * freq * time)
        }
    }
    
    private func playGameOverSequence() {
        // Play a descending sequence of notes
        let notes: [(Double, Double)] = [
            (440, 0.15),
            (392, 0.15),
            (349, 0.15),
            (330, 0.3)
        ]
        
        var delay: Double = 0
        for (frequency, duration) in notes {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.playTone(frequency: frequency, duration: duration, type: .negative)
            }
            delay += duration * 0.8
        }
    }
}
