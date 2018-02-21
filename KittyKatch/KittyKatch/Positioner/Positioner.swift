//
//  Positioner.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation
import SpriteKit

protocol Positioner {
    func addInput(_ input: PositionerInput)
    func removeInput()
    
    func update(dt: Double)
    func getPosition() -> Position
}

// MARK: - State
class DefaultPositioner : Positioner {
    private let tolerance: CGFloat
    private let timeToMove: CGFloat
    
    private var inputCount: Int = 0
    private var targetPosition: CGFloat = 0.0
    private var currentPosition: CGFloat = 0.0
    
    init(timeToMove: CGFloat, tolerance: CGFloat) {
        assert(timeToMove > 0.0)
        assert(tolerance > 0.0)
        
        self.tolerance = tolerance
        self.timeToMove = timeToMove
    }
}

// MARK: - Input
extension DefaultPositioner {
    // @TODO: Fix bug, need better tracking of touch inputs.
    func addInput(_ input: PositionerInput) {
        self.inputCount += 1
        self.targetPosition = CGFloat(input.rawValue)
        
        assert(self.inputCount >= 0)
    }
    
    func removeInput() {
        self.inputCount -= 1
        if (self.inputCount == 0) { self.targetPosition = 0.0 }
        
        assert(self.inputCount >= 0)
    }
}

// MARK: - Update
extension DefaultPositioner {
    func update(dt: Double) {
        let delta = CGFloat(dt)
        let diff = self.targetPosition - self.currentPosition
        let step = delta / self.timeToMove
        let deltaX = self.easing(t: step)
        
        self.currentPosition += diff * deltaX
    }
    
    // @TODO: Replace with better smoothing function.
    private func easing(t: CGFloat) -> CGFloat {
        return t
    }
}

// MARK: - Positioning
extension DefaultPositioner {
    func getPosition() -> Position {
        return Position(state: self.getState(), offset: self.getOffset())
    }
    
    private func getOffset() -> CGFloat {
        return self.currentPosition
    }
    
    private func getState() -> LaneState {
        if isInLane(.left)      { return .inLane(.left) }
        if isInLane(.center)    { return .inLane(.center) }
        if isInLane(.right)     { return .inLane(.right) }
        
        return .outOfPosition
    }
    
    private func isInLane(_ lane: Lane) -> Bool {
        let laneValue = CGFloat(lane.rawValue)
        if laneValue != self.targetPosition { return false }
        return fabs(self.currentPosition - laneValue) < self.tolerance
    }
}
