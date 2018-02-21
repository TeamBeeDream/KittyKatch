//
//  Math.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/20/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

class Math {
    static func randInt(min: Int, max: Int) -> Int {
        let range = max - min
        let randValue = Int(arc4random_uniform(UInt32(range)))
        return Int(randValue + min)
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
