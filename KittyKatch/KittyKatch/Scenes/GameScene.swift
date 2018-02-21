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
    
    // PARAMETERS
    private let positioner: Positioner!
    private let sequencer: PatternSequencer!
    private let resolver: CollisionResolver!
    private let coordinates: Coordinates!
    
    // DIFFICULTY SETTINGS
    private let spawnRate = 0.3
    
    // stuff
    private var collected : Int = 0
    private var pickupCount : Int = 100
    
    // UI
    private var label : SKLabelNode!
    
    // KITTY
    private var kitty : SKShapeNode!
    
    // DEBUG
    private var debugPositionMarker: SKShapeNode!
    
    // PICKUPS
    private var pickup : SKShapeNode!
    private var badObj : SKShapeNode!
    
    // TIMING
    private var previousTime: TimeInterval = 0
    
    private var rows: [Row]!
    private var rowIndex: Int = 0
    
    init(frame: CGRect,
         positioner: Positioner,
         sequencer: PatternSequencer,
         resolver: CollisionResolver) {
        
        self.positioner = positioner
        self.sequencer = sequencer
        self.resolver = resolver
        
        self.coordinates = Coordinates(frame: frame, laneOffset: 0.50, playerVerticalOffset: -0.66)
        
        super.init(size: frame.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.gray
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Kitty Katch"
        label.position = CGPoint(x: frame.midX, y: frame.maxY * 0.9)
        label.color = SKColor.white
        label.fontSize = 35
        addChild(label)
        self.label = label
        
        let kittySize = self.resolver.getTolerance()
        let kitty = SKShapeNode(rectOf: CGSize(width: kittySize.x, height: kittySize.y), cornerRadius: 5)
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
        
        // debug marker
        let debugPositionMarker = SKShapeNode(circleOfRadius: 10)
        debugPositionMarker.strokeColor = SKColor.white
        debugPositionMarker.fillColor = SKColor.clear
        self.debugPositionMarker = debugPositionMarker
        addChild(debugPositionMarker)
        
        // debug lines
        self.drawDebugLine(a: self.coordinates.laneToPosition(.left), b: self.coordinates.laneToPosition(.right))
        self.drawDebugLine(a: self.coordinates.lanePoint(lane: .left, y: -1), b: self.coordinates.lanePoint(lane: .left, y: 1))
        self.drawDebugLine(a: self.coordinates.lanePoint(lane: .center, y: -1), b: self.coordinates.lanePoint(lane: .center, y: 1))
        self.drawDebugLine(a: self.coordinates.lanePoint(lane: .right, y: -1), b: self.coordinates.lanePoint(lane: .right, y: 1))
        //
        
        self.rows = self.sequencer.getSequence(difficulty: .medium, pickupCount: 100)
        self.rowIndex = 0
        
        let key = "spawnLoop"
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: self.spawnRate),
                SKAction.run({
                    if self.pickupCount <= 0 {
                        self.removeAction(forKey: key)
                    } else {
                        // temp
                        self.spawnRow(row: self.rows[self.rowIndex])
                        self.rowIndex = (self.rowIndex + 1) % self.rows.count
                    }
                })])),
            withKey: key)
    }
    
    
    
    private func spawnRow(row: Row) {
        for pickup in row.pickups {
            let type = pickup.type
            if type == .none { continue }
            
            let node = getNode(fromType: type)
            addChild(node)
            
            let pickupNode = PickupNode(
                data: pickup,
                node: node,
                travelTime: 1,    // @HARDCODED
                positioner: self.positioner,
                coordinates: self.coordinates,
                resolver: self.resolver)
            pickupNode.activate()
            
            if type == .good {
                self.pickupCount -= 1
            }
        }
    }
    
    private func getNode(fromType: PickupType) -> SKNode {
        switch fromType {
        case .none:
            assert(false) // @FIXME
        case .good:
            return self.pickup.copy() as! SKNode   // @HARDCODED
        case .bad:
            return self.badObj.copy() as! SKNode   // @HARDCODED
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
        self.kitty.position = self.coordinates.positionToPoint(position)
        
        // debug
        let positionMarker = self.debugPositionMarker!
        switch position.state {
        case .inLane(let lane):
            positionMarker.alpha = 1.0
            positionMarker.position = self.coordinates.laneToPosition(lane)
        case .outOfPosition:
            positionMarker.alpha = 0.0
        }
    }
    
    func updateUI() {
        self.label.text = String(format: "%d", self.collected)
    }
}

// MARK: - Input
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let point = t.location(in: self)
            let input = pointToInput(point)
            self.positioner.addInput(input)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches { self.positioner.removeInput() }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches { self.positioner.removeInput() }
    }
    
    private func pointToInput(_ point: CGPoint) -> PositionerInput {
        assert(frame.contains(point))
        
        let x = point.x // ignore y, only care about x
        if x < frame.midX   { return .left }
        else                { return .right }
    }
}

// MARK: - Debug
extension GameScene {
    private func drawDebugLine(a: CGPoint, b: CGPoint) {
        let node = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: a)
        path.addLine(to: b)
        node.path = path.cgPath
        node.strokeColor = SKColor.white
        node.lineWidth = 1
        addChild(node)
    }
}
