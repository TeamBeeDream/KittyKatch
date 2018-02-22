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
    
    // State
    private var collected : Int = 0
    private var pickupCount : Int = 100
    
    // UI
    private var scoreText : SKLabelNode!
    
    // KITTY
    private var kitty : SKNode!
    
    // DEBUG
    private var debugPositionMarker: SKShapeNode!
    
    // PICKUPS
    private var pickup : SKNode!
    private var badObj : SKNode!
    
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
        
        self.coordinates = Coordinates(frame: frame, laneOffsetX: 0.50, laneOffsetY: 0.66) // @FIXME: this should probably be configured outside of this class
        
        super.init(size: frame.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.gray
        
        let scoreText = SKLabelNode(fontNamed: "Chalkduster")
        scoreText.text = "0"
        scoreText.position = CGPoint(x: frame.midX, y: frame.maxY * 0.9)
        scoreText.color = SKColor.white
        scoreText.fontSize = 35
        addChild(scoreText)
        self.scoreText = scoreText
        
        // background
        let shader = SKShader(fileNamed: "shadertest.fsh")
        let background = SKShapeNode(rect: frame)
        background.fillShader = shader
        background.zPosition = -100
        addChild(background)
        
        // kitty
        let kittyWidth = self.coordinates.getSize().width * 0.3
        let kitty = SKSpriteNode(imageNamed: "Kitty")
        kitty.size = CGSize(width: kittyWidth, height: kittyWidth)
        kitty.position = self.coordinates.laneToPoint(.center)
        kitty.zPosition = -10
        addChild(kitty)
        self.kitty = kitty
        
        // fish
        let pickupWidth = self.coordinates.getSize().width * 0.175
        let pickup = SKSpriteNode(imageNamed: "Fish")
        pickup.size = CGSize(width: pickupWidth, height: pickupWidth)
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
        self.drawDebugLine(a: self.coordinates.laneToPoint(.left), b: self.coordinates.laneToPoint(.right))
        self.drawDebugLine(a: self.coordinates.pointOnLane(lane: .left, y: -1), b: self.coordinates.pointOnLane(lane: .left, y: 1))
        self.drawDebugLine(a: self.coordinates.pointOnLane(lane: .center, y: -1), b: self.coordinates.pointOnLane(lane: .center, y: 1))
        self.drawDebugLine(a: self.coordinates.pointOnLane(lane: .right, y: -1), b: self.coordinates.pointOnLane(lane: .right, y: 1))
        //
        
        self.rows = self.sequencer.getSequence(difficulty: .medium, pickupCount: 100)
        self.rowIndex = 0
        
        // @TODO: Delay before spawning first wave.
        let key = "spawnLoop"
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: self.spawnRate),
                SKAction.run({
                    if self.pickupCount <= 0 { // done
                        self.removeAction(forKey: key)
                        self.run(SKAction.sequence([
                            SKAction.wait(forDuration: 3),
                            SKAction.run{ self.roundOver() }]))
                    } else {
                        // temp
                        self.spawnRow(row: self.rows[self.rowIndex])
                        self.rowIndex = (self.rowIndex + 1) % self.rows.count
                    }
                })])),
            withKey: key)
    }
    
    private func roundOver() {
        print("DONE") // @TODO: actually do something when game is over
    }
    
    func handleCollect(data: Pickup) {
        switch data.type {
        case .good:
            self.collected += 1
        case .bad:
            self.collected = Int(round(Double(self.collected) * 0.85)) // @FIXME: gross
        case .none:
            break // shouldn't happen
        }
        
        self.updateScoreText()
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
                travelTime: 1.75,    // @HARDCODED
                positioner: self.positioner,
                coordinates: self.coordinates,
                resolver: self.resolver)
            let _ = pickupNode.collectEvent.addHandler(target: self, handler: GameScene.handleCollect) // @FIXME: figure out how to handle return value
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
            positionMarker.position = self.coordinates.laneToPoint(lane)
        case .outOfPosition:
            positionMarker.alpha = 0.0
        }
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

// MARK: - UI
extension GameScene {
    private func updateScoreText() {
        self.scoreText.text = String(format: "%d", self.collected)
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
