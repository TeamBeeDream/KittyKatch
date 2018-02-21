//
//  PositionerData.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

enum Lane: Int {
    case left   = -1
    case center =  0
    case right  =  1
    
    static let count = 3
}

enum LaneState {
    case inLane(Lane)
    case outOfPosition
}

enum PositionerInput: Int {
    case left   = -1
    case right  =  1
}

struct Position {
    var state: LaneState
    var offset: CGFloat
}
