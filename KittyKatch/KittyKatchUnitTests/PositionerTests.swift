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
    
    private let leftTouch  = CGPoint(x: 0.25, y: 0.5)
    private let rightTouch = CGPoint(x: 0.75, y: 0.5)
    
    override func setUp() {
        super.setUp()
        
        self.positioner = DefaultPositioner(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.positioner = nil
    }
    
    func testTouchLeft() {
        self.positioner.touchPress(point: self.leftTouch)
        XCTAssert(self.positioner.getPosition() == self.left)
    }
    
    func testTouchRight() {
        self.positioner.touchPress(point: self.rightTouch)
        XCTAssert(self.positioner.getPosition() == self.right)
    }
    
    func testTouchLeftThenRight() {
        self.positioner.touchPress(point: self.leftTouch)
        self.positioner.touchPress(point: self.rightTouch)
        XCTAssert(self.positioner.getPosition() == self.right)
    }
    
    func testTouchRightThenLeft() {
        self.positioner.touchPress(point: self.rightTouch)
        self.positioner.touchPress(point: self.leftTouch)
        XCTAssert(self.positioner.getPosition() == self.left)
    }
    
    func testTouchLeftThenRelease() {
        self.positioner.touchPress(point: self.leftTouch)
        self.positioner.touchRelease()
        XCTAssert(self.positioner.getPosition() == self.center)
    }
    
    func testTouchRightThenRelease() {
        self.positioner.touchPress(point: self.rightTouch)
        self.positioner.touchRelease()
        XCTAssert(self.positioner.getPosition() == self.center)
    }
}
