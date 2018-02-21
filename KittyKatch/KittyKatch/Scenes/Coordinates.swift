//
//  Coordinates.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

class Coordinates {
    private let frame: CGRect
    private let playerVerticalOffset: CGFloat
    private let laneOffset: CGFloat
    
    init(frame: CGRect, laneOffset: CGFloat, playerVerticalOffset: CGFloat) {
        assert(!frame.isEmpty)
        //assert(laneOffset > 0 && laneOffset <= 1)
        //assert(playerVerticalOffset > 0 && playerVerticalOffset <= 1)
        
        self.frame = frame
        self.laneOffset = laneOffset
        self.playerVerticalOffset = playerVerticalOffset
    }
    
    func laneToPosition(_ lane: Lane) -> CGPoint {
        let laneValue = CGFloat(lane.rawValue)
        
        let laneOffsetScreen = ((self.laneOffset / 2) * self.frame.width)
        
        let x = frame.midX + (laneOffsetScreen * laneValue)
        let y = frame.midY + (self.playerVerticalOffset * self.frame.height / 2)
        
        return CGPoint(x: x, y: y)
    }
    
    func lanePoint(lane: Lane, y: CGFloat) -> CGPoint {
        let y = frame.midY - (y / 2 * self.frame.height)
        return CGPoint(x: laneToPosition(lane).x, y: y)
    }
    
    func relativePointToScreenPoint(_ point: CGPoint) -> CGPoint {
        let x = frame.midX + (point.x * frame.width)
        let y = frame.midY - (point.y * frame.height)
        return CGPoint(x: x, y: y)
    }
    
    func getScreenHeight() -> CGFloat {
        return self.frame.height
    }
    
    func getScreenWidth() -> CGFloat {
        return self.frame.width
    }
    
    func positionToPoint(_ position: Position) -> CGPoint {
        let y = frame.midY + (self.playerVerticalOffset * self.frame.height / 2)
        let laneOffsetScreen = ((self.laneOffset / 2) * self.frame.width)
        let x = frame.midX + (laneOffsetScreen * position.offset)
        return CGPoint(x: x, y: y)
    }
}
