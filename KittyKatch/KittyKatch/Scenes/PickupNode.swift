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
    private let node: SKNode!
    private let positioner: Positioner!
    private let coordinates: Coordinates!
    private let resolver: CollisionResolver!
    
    init(data: Pickup, node: SKNode,
         positioner: Positioner,
         coordinates: Coordinates,
         resolver: CollisionResolver) {
        self.data = data
        self.node = node
        self.positioner = positioner
        self.coordinates = coordinates
        self.resolver = resolver
    }
    
    func activate() {
        let top = self.coordinates.lanePoint(lane: self.data.lane, y: -1)
        let bottom = self.coordinates.lanePoint(lane: self.data.lane, y: 1)
        
        self.node.position = top
        
        let move = getMoveAction(destination: bottom, duration: 1.0)
        let collision = getCollisionAction()
        let delete = getDeleteAction()
        let wait = SKAction.wait(forDuration: TimeInterval(0.1))
        
        let group = SKAction.group([
            SKAction.sequence([move, delete]),
            SKAction.repeatForever(SKAction.sequence([collision, wait]))])
        
        self.node.run(group)
    }
}

extension PickupNode {
    private func getMoveAction(destination: CGPoint, duration: CGFloat) -> SKAction {
        let time = TimeInterval(duration)
        
        return SKAction.move(to: destination, duration: time)
    }
    
    private func getDeleteAction() -> SKAction {
        let fadeOut = SKAction.fadeOut(withDuration: TimeInterval(0.2))
        let shrink = SKAction.scale(by: -1, duration: TimeInterval(0.2))
        let remove = SKAction.removeFromParent()
        
        return SKAction.sequence([SKAction.group([fadeOut, shrink]), remove])
    }
    
    private func getCollisionAction() -> SKAction {
        return SKAction.run {
            if self.didCollide(lane: self.data.lane, type: self.data.type) {
                self.node.removeAllActions()
                self.node.run(self.getDeleteAction())
            }
        }
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
