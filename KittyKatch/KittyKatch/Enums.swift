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


