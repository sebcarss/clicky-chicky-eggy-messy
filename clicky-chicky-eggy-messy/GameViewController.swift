//
//  GameViewController.swift
//  clicky-chicky-  y-messy
//
//  Created by Seb Carss on 09/12/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load settings before starting
            GameManager.shared.loadSettings()
            
            // Start with the menu scene
            let menuScene = MenuScene(size: view.bounds.size)
            menuScene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(menuScene)
            
            view.ignoresSiblingOrder = true
            
            // Disable debug info for release
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
