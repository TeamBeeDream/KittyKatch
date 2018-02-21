//
//  PositionerTests.swift
//  KittyKatchUnitTests
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import XCTest
@testable import KittyKatch

class PositionerTests: XCTestCase {
    private var positioner: DefaultPositioner!
    
    private let left: CGFloat   = -1.0
    private let right: CGFloat  = +1.0
    private let center: CGFloat =  0.0
    
    private let leftState = LaneState.inLane(.left)
    
    private let leftTouch  = CGPoint(x: 0.25, y: 0.5)
    private let rightTouch = CGPoint(x: 0.75, y: 0.5)
    
    private let fullTimeStep    = 1.0
    private let halfTimeStep    = 0.5
    private let almostFullStep  = 0.9
    
    private let tolerance = 0.15
    
    override func setUp() {
        super.setUp()
        
        let timeToMove = CGFloat(self.fullTimeStep)
        let tolerance = CGFloat(self.tolerance)
        self.positioner = DefaultPositioner(timeToMove: timeToMove,
                                            tolerance: tolerance)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.positioner = nil
    }
    
    func testTouchLeft() {
        self.positioner.addInput(.left)
        self.positioner.update(dt: self.fullTimeStep)
        XCTAssert(isInLane(.left))
    }
    
    func testTouchRight() {
        self.positioner.addInput(.right)
        self.positioner.update(dt: self.fullTimeStep)
        XCTAssert(isInLane(.right))
    }
    
    func testTouchLeftRelease() {
        self.positioner.addInput(.left)
        self.positioner.removeInput()
        self.positioner.update(dt: self.fullTimeStep)
        XCTAssert(isInLane(.center))
    }
    
    func testTouchRightRelease() {
        self.positioner.addInput(.right)
        self.positioner.removeInput()
        self.positioner.update(dt: self.fullTimeStep)
        XCTAssert(isInLane(.center))
    }
    
    func testTouchLeftRight() {
        self.positioner.addInput(.left)
        self.positioner.addInput(.right)
        self.positioner.update(dt: self.fullTimeStep)
        XCTAssert(isInLane(.right))
    }
    
    func testTouchRightLeft() {
        self.positioner.addInput(.right)
        self.positioner.addInput(.left)
        self.positioner.update(dt: self.fullTimeStep)
        XCTAssert(isInLane(.left))
    }
    
    func testWithinTolerance() {
        self.positioner.addInput(.left)
        self.positioner.update(dt: self.almostFullStep)
        XCTAssert(isInLane(.left))
    }
    
    func testOutOfPosition() {
        self.positioner.addInput(.left)
        self.positioner.update(dt: self.halfTimeStep)
        XCTAssert(isOutOfPosition())
    }
}

// MARK: - Helpers
extension PositionerTests {
    
    /**
     Determine if positioner is in the given lane.
     */
    private func isInLane(_ lane: Lane) -> Bool {
        let position = self.positioner.getPosition()
        switch position.state {
        case .inLane(let l):
            return lane == l
        case .outOfPosition:
            return false
        }
    }
    
    /**
     Determine if positioner is out of position.
     */
    private func isOutOfPosition() -> Bool {
        let position = self.positioner.getPosition()
        switch position.state {
        case .outOfPosition:
            return true
        default:
            return false
        }
    }
}
