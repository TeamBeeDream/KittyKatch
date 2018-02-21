//
//  Enums.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/20/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation

enum Result {
    case success
    case failure
}

enum PickupType {
    case good
    case bad
    case none
}

enum Difficulty: Int {
    case starter    = 0
    case easy       = 1
    case medium     = 2
    case hard       = 3
    case veryHard   = 4
}

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
