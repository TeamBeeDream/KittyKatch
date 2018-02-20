//
//  GameScene.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene {
    
    // DIFFICULTY SETTINGS
    private let toleranceX = 35.0
    private let toleranceY = 35.0
    private let spawnRate = 0.3
    
    // stuff
    private let offset : CGFloat = 75.0
    private var collected : Int = 0
    private var pickupCount : Int = 100
    
    // UI
    private var label : SKLabelNode!
    
    // KITTY
    private var kitty : SKShapeNode!
    
    // TOUCHES
    private var positioner: DefaultPositioner!
    private var debugPositionMarker: SKShapeNode!
    
    // PICKUPS
    private var pickup : SKShapeNode!
    private var badObj : SKShapeNode!
    
    // TIMING
    private var previousTime: TimeInterval = 0
    
    private var sequencer: PatternSequencer!
    private var pattern: Pattern!
    private var rowIndex: Int = 0
    
    override func didMove(to view: SKView) {
        self.setup()
        
        backgroundColor = SKColor.black
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Kitty Katch"
        label.position = CGPoint(x: frame.midX, y: frame.maxY * 0.9)
        label.color = SKColor.white
        label.fontSize = 35
        addChild(label)
        self.label = label
        
        let kitty = SKShapeNode(rectOf: CGSize(width: 100, height: 100), cornerRadius: 5)
        kitty.position = CGPoint(x: frame.midX, y: frame.maxX * 0.2)
        kitty.fillColor = SKColor.blue
        kitty.strokeColor = SKColor.clear
        addChild(kitty)
        self.kitty = kitty
        
        let pickup = SKShapeNode(circleOfRadius: 20)
        pickup.strokeColor = SKColor.clear
        pickup.fillColor = SKColor.green
        self.pickup = pickup
        
        let badObj = SKShapeNode(circleOfRadius: 20)
        badObj.strokeColor = SKColor.clear
        badObj.fillColor = SKColor.red
        self.badObj = badObj
        
        let debugPositionMarker = SKShapeNode(circleOfRadius: 10)
        debugPositionMarker.strokeColor = SKColor.white
        debugPositionMarker.fillColor = SKColor.clear
        self.debugPositionMarker = debugPositionMarker
        addChild(debugPositionMarker)
        
        let key = "spawnLoop"
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: self.spawnRate),
                SKAction.run({
                    if self.pickupCount <= 0 {
                        self.removeAction(forKey: key)
                    } else {
                        // temp
                        self.spawnRow(row: self.pattern.rows[self.rowIndex])
                        self.rowIndex = (self.rowIndex + 1) % self.pattern.rows.count
                    }
                })])),
            withKey: key)
    }
    
    private func setup() {
        self.positioner = DefaultPositioner(frame: self.frame, timeToMove: 0.07, tolerance: 0.4)
        self.sequencer = PatternSequencer()
        self.sequencer.load()
        self.pattern = self.sequencer.getPattern()
        self.rowIndex = 0
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    private func spawnRow(row: Row) {
        for (_, pickup) in row.pickups.enumerated() {
            let type = pickup.pickup // @FIXME: gross
            if type == .none { continue }
            
            let node = getNode(fromType: type)
            node.position.y = frame.maxY
            node.position.x = self.laneToPosition(lane: pickup.lane)
            
            let timeStep = CGFloat(0.1)
            let totalDistance = frame.maxY
            let totalTime = CGFloat(2.0)
            let vecStep = totalDistance / (totalTime / timeStep)
            
            let moveVector = CGVector(dx: 0, dy: -vecStep)
            
            // actions
            node.run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.move(by: moveVector, duration: TimeInterval(timeStep)),
                    SKAction.run { self.checkCollision(pickup: node, good: type == .good) }])))
            
            addChild(node)
            
            if type == .good {
                self.pickupCount -= 1
            }
        }
    }
    
    private func getNode(fromType: Pickup) -> SKNode {
        switch fromType {
        case .none:
            assert(false) // @FIXME
        case .good:
            return self.pickup.copy() as! SKNode   // @HARDCODED
        case .bad:
            return self.badObj.copy() as! SKNode   // @HARDCODED
        }
    }
    
    private func laneToPosition(lane: Lane) -> CGFloat {
        let laneIntValue = CGFloat(lane.rawValue)
        return frame.midX + (offset * laneIntValue)
    }
    
    func checkCollision(pickup: SKNode, good: Bool) {
        let diffX = fabs(self.kitty.position.x - pickup.position.x)
        let diffY = fabs(self.kitty.position.y - pickup.position.y)
        let tolerance : CGFloat = 35.0
        if pickup.position.y < self.frame.minY {
            pickup.removeAllActions()
            pickup.run(SKAction.removeFromParent())
        } else if diffX < tolerance && diffY < tolerance {
            pickup.removeAllActions()
            pickup.run(SKAction.sequence([
                SKAction.scale(by: CGFloat(2.0), duration: 0.2),
                SKAction.removeFromParent()]))
            
            if good {
                self.collected += 1
            } else {
                self.collected = Int(round(Double(self.collected) * 0.85))
            }
            self.updateUI()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // calculate timestep
        var delta = currentTime - self.previousTime
        self.previousTime = currentTime
        if delta > 1.0 { delta = 0.016 }
        
        // update values
        self.positioner.update(dt: delta)
        
        // reposition kitty
        let position = self.positioner.getPosition()
        self.kitty.position.x = frame.midX + (offset * position.offset)
        
        // debug
        let positionMarker = self.debugPositionMarker!
        switch position.state {
        case .inPosition(let positionOffset):
            positionMarker.alpha = 1.0
            positionMarker.position.x = frame.midX + (offset * CGFloat(positionOffset.rawValue))
            positionMarker.position.y = self.kitty.position.y
        case .outOfPosition:
            positionMarker.alpha = 0.0
        }
    }
    
    func updateUI() {
        self.label.text = String(format: "%d", self.collected)
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.positioner?.touchPress(point: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches { self.positioner?.touchRelease() }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches { self.positioner?.touchRelease() }
    }
}
