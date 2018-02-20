//
//  Positioner.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import UIKit

enum Lane: Int {
    case left   = -1
    case center =  0
    case right  =  1
    
    static let count = 3
}

enum PositionState {
    case inPosition(Lane)
    case outOfPosition
}

struct Position {
    var state: PositionState
    var offset: CGFloat
}

class DefaultPositioner {
    private let tolerance: CGFloat
    private let timeToMove: CGFloat
    private let frame: CGRect
    
    private var touchCount: Int = 0
    private var targetPosition: CGFloat = 0.0
    private var currentPosition: CGFloat = 0.0
    
    init(frame: CGRect, timeToMove: CGFloat, tolerance: CGFloat) {
        self.frame = frame
        self.tolerance = tolerance
        self.timeToMove = timeToMove
    }
    
    func touchPress(point: CGPoint) {
        // ignore touches outside of frame
        if !frame.contains(point) {
            return
        }
        
        // determine if press is on left or right,
        // override current position
        self.targetPosition = (point.x < frame.midX)
            ? -1.0  // left
            : +1.0  // right
        self.touchCount += 1
    }
    
    func touchRelease() {
        self.touchCount -= 1
        
        // if no more touches, reset to center
        if (self.touchCount == 0) {
            self.targetPosition = 0.0
        }
    }
    
    func update(dt: Double) {
        let delta = CGFloat(dt)
        let diff = self.targetPosition - self.currentPosition
        let step = delta / self.timeToMove // @TODO: assert: [0, 1]
        let deltaX = self.easing(t: step)
        
        self.currentPosition += diff * deltaX
    }
    
    // @TODO: Replace with better smoothing function.
    private func easing(t: CGFloat) -> CGFloat {
        return t
    }
    
    func getPosition() -> Position {
        return Position(state: self.getState(), offset: self.getOffset())
    }
    
    private func getState() -> PositionState {
        let left: Int = -1
        let center: Int = 0
        let right: Int = +1
        
        if fabs(self.currentPosition - CGFloat(left)) < self.tolerance {
            return .inPosition(.left)
        } else if fabs(self.currentPosition - CGFloat(center)) < self.tolerance {
            return .inPosition(.center)
        } else if fabs(self.currentPosition - CGFloat(right)) < self.tolerance {
            return .inPosition(.right)
        }
        
        return .outOfPosition
    }
    
    private func getOffset() -> CGFloat {
        return self.currentPosition
    }
}
