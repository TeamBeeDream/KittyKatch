//
//  CollisionResolver.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

protocol CollisionResolver {
    func didCollide(origin: CGPoint, point: CGPoint) -> Bool
}

class DefaultCollisionResolver {
    private let toleranceX: CGFloat
    private let toleranceY: CGFloat
    
    init(toleranceX: CGFloat, toleranceY: CGFloat) {
        self.toleranceX = toleranceX
        self.toleranceY = toleranceY
    }
}

extension DefaultCollisionResolver: CollisionResolver {
    func didCollide(origin: CGPoint, point: CGPoint) -> Bool {
        let diffX = fabs(origin.x - point.x)
        let diffY = fabs(origin.y - point.y)
        
        return diffX < self.toleranceX && diffY < self.toleranceY
    }
}
