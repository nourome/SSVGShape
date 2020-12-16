//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//

import Foundation

import XCTest
@testable import SSVGShape

final class SVGPathTests: XCTestCase {

    func testMoveToSVGPath() {
        let moveToPoint = try! SVGMoveTo(pathStr: "M1.0,0.0")
        XCTAssertNotNil(moveToPoint)
        XCTAssertEqual(moveToPoint.points.count, 1)
        XCTAssertEqual(moveToPoint.points.first, CGPoint(x: 1.0, y: 0.0))
        XCTAssertThrowsError(try SVGMoveTo(pathStr: "0.0"))
    }
    
    func testLineToSVGPath() {
        let lineToPoint = try! SVGMoveTo(pathStr: "L0.0,0.0")
        XCTAssertNotNil(lineToPoint)
        XCTAssertEqual(lineToPoint.points.count, 1)
        XCTAssertEqual(lineToPoint.points.first, CGPoint(x: 0.0, y: 0.0))
        XCTAssertThrowsError(try SVGLineTo(pathStr: "L0.0"))
    }
    
    func testCurveToSVGPath() {
        let curveToPoint = try! SVGCurveTo(pathStr: "C1.0,0.0 1.0,0.0 3.0,4.0")
        XCTAssertNotNil(curveToPoint)
        XCTAssertEqual(curveToPoint.points.count, 3)
        XCTAssertEqual(curveToPoint.points.first, CGPoint(x: 1.0, y: 0.0))
        XCTAssertThrowsError(try SVGCurveTo(pathStr: "C0.0"))
    }
    
    func testClosedSVGPath() {
        let closedPoint = try! SVGClose(pathStr: "")
        XCTAssertNotNil(closedPoint)
        XCTAssertEqual(closedPoint.points.count, 0)
    }
}
