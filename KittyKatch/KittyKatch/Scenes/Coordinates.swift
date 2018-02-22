//
//  Coordinates.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/21/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: - State
class Coordinates {
    private let frame: CGRect
    private let laneOffsetX: CGFloat
    private let laneOffsetY: CGFloat
    
    init(frame: CGRect, laneOffsetX: CGFloat, laneOffsetY: CGFloat) {
        assert(!frame.isEmpty)
        assert(laneOffsetX > -1 && laneOffsetX <= 1)
        assert(laneOffsetY > -1 && laneOffsetY <= 1)
        
        self.frame = frame
        self.laneOffsetX = laneOffsetX
        self.laneOffsetY = laneOffsetY
    }
}

// MARK: - Public Methods
extension Coordinates {
    func laneToPoint(_ lane: Lane) -> CGPoint {
        let laneValue = CGFloat(lane.rawValue)
        
        //let laneOffsetScreen = ((self.laneOffsetX / 2) * self.frame.width)
        
        //let x = frame.midX + (laneOffsetScreen * laneValue)
        //let y = self.convertY(self.laneOffsetY)
        let x = self.convertX(self.laneOffsetX * laneValue)
        let y = self.convertY(self.laneOffsetY)
        
        return CGPoint(x: x, y: y)
    }
    
    func pointOnLane(lane: Lane, y: CGFloat) -> CGPoint {
        let newY = self.convertY(y)
        let newX = self.laneToPoint(lane).x
        return CGPoint(x: newX, y: newY)
    }
    
    func getSize() -> CGSize {
        return self.frame.size
    }
    
    func positionToPoint(_ position: Position) -> CGPoint {
        let x = self.convertX(self.laneOffsetX * position.offset)
        let y = self.convertY(self.laneOffsetY)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Math Helpers
extension Coordinates {
    private func convertX(_ x: CGFloat) -> CGFloat {
        return frame.midX + (x / 2 * frame.width)
    }
    
    private func convertY(_ y: CGFloat) -> CGFloat {
        return frame.midY - (y / 2 * frame.height)
    }
}
