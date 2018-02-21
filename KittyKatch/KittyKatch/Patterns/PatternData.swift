//
//  PatternData.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation

struct Pickup {
    let type: PickupType
    let lane: Lane
}

struct Row {
    var pickups: [Pickup]
}

struct Pattern {
    var rows: [Row]
    var difficulty: Difficulty
    var pickupCount: Int
}

enum LineType {
    case header(Difficulty)
    case row(Row)
    case blank
    case invalid
}
