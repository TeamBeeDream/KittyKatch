//
//  PickupNode.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

class PickupNode {
    private let data: Pickup
    private let travelTime: CGFloat
    private let node: SKNode!
    private let positioner: Positioner!
    private let coordinates: Coordinates!
    private let resolver: CollisionResolver!
    
    public let collectEvent = Event<Pickup>()
    private var alreadyHit: Bool = false    // @HACK: prevents event from being called twice
    
    init(data: Pickup, node: SKNode,
         travelTime: CGFloat,
         positioner: Positioner,
         coordinates: Coordinates,
         resolver: CollisionResolver) {
        self.data = data
        self.node = node
        self.travelTime = travelTime
        self.positioner = positioner
        self.coordinates = coordinates
        self.resolver = resolver
    }
    
    func activate() {
        let top = self.coordinates.lanePoint(lane: self.data.lane, y: -1)
        let bottom = self.coordinates.lanePoint(lane: self.data.lane, y: 1)
        
        self.node.position = top
        
        // actions
        let move = getMoveAction(destination: bottom, duration: self.travelTime)
        let collision = getCollisionAction(dt: self.travelTime / 20) // @HARDCODED, 20 steps total
        self.node.run(SKAction.group([move, collision]))
    }
}

extension PickupNode {
    private func getMoveAction(destination: CGPoint, duration: CGFloat) -> SKAction {
        let time = TimeInterval(duration)
        return SKAction.sequence([
            SKAction.move(to: destination, duration: time),
            SKAction.removeFromParent()])
    }
    
    private func getCollisionAction(dt: CGFloat) -> SKAction {
        let collision = SKAction.run {
            if !self.alreadyHit && self.didCollide(lane: self.data.lane, type: self.data.type) {
                self.alreadyHit = true
                self.collectEvent.raise(data: self.data)
                self.node.removeAllActions()
                self.node.run(self.getCollectAndDeleteSequence())
            }
        }
        let wait = SKAction.wait(forDuration: TimeInterval(dt))
        
        return SKAction.repeatForever(SKAction.sequence([collision, wait]))
    }
    
    private func getCollectAndDeleteSequence() -> SKAction {
        let move = SKAction.move(to: self.coordinates.laneToPosition(self.data.lane), duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: TimeInterval(0.2))
        let shrink = SKAction.scale(by: -1, duration: TimeInterval(0.2))
        
        return SKAction.sequence([
            SKAction.group([move, fadeOut, shrink]),
            SKAction.removeFromParent()])
    }
}

extension PickupNode {
    private func didCollide(lane: Lane, type: PickupType) -> Bool {
        let position = self.positioner.getPosition()
        switch position.state {
        case .outOfPosition:
            return false
        case .inLane(let positionerLane):
            if lane != positionerLane { return false }
            
            let origin = self.coordinates.laneToPosition(lane)
            return self.resolver.didCollide(origin: origin, point: self.node.position)
        }
    }
}
