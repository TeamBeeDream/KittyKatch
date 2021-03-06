//
//  GameViewController.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // @TODO: connect to config file
        let frame = view.bounds
        let positioner = DefaultPositioner(timeToMove: 0.075, tolerance: 0.35)
        let sequencer = DefaultPatternSequencer(filePath: Bundle.main.path(forResource: "AllPatterns", ofType: "txt")!, padding: 1)
        let resolver = DefaultCollisionResolver(toleranceX: 35.0, toleranceY: 45.0)
        
        let scene = GameScene(frame: frame,
                              positioner: positioner,
                              sequencer: sequencer,
                              resolver: resolver)
        scene.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.isMultipleTouchEnabled = true
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
