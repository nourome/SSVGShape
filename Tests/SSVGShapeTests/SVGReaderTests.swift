//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import XCTest
@testable import SSVGShape

final class SVGReaderTests: XCTestCase {
    let reader = SVGReader1dot1(filePath: Bundle.module.path(forResource: "test", ofType: "svg")!)
    
    
    func testParseSvgFile() {
        let contents = try? reader.read().get()
        XCTAssertNotNil(contents)
    }
    
    func testGetViewBoxRect() {
        let model = try! reader.read().get()
        let viewBoxRectResult =  reader.getViewBoxRect(model: model)
        
        switch viewBoxRectResult {
        case .success(let rect):
            XCTAssertNotNil(rect)
        case .failure(_):
            XCTFail()
        }
        
    }
    
    func testGetPath() {
        let model = try! reader.read().get()
        let pathResult =  reader.getPath(model: model)
        
        switch pathResult {
        case .success(let model):
            XCTAssertEqual(model.pathPointsString.first!.uppercased(), "M")
        case .failure(_):
            XCTFail()
        }
        
    }
    
    func testGetTransform() {
        let model = try! reader.read().get()
        let transformResult =  reader.getTransform(model: model)
        
        switch transformResult {
        case .success(let model):
            XCTAssertTrue(model.transformString.contains("matrix"))
        case .failure(_):
            XCTFail()
        }
        
    }
    
    func testPathStringToSVGPath() {
        let model = try! reader.read().get()
        let modelWithPathString =  try! reader.getPath(model: model).get()
        let svgPathsResult =  reader.pathStringToSVGPath(model: modelWithPathString)
        
        switch svgPathsResult {
        case .success(let model):
            XCTAssertEqual(model.paths.count, 4)
        case .failure(let error):
            print("error \(error)")
            XCTFail()
        }
        
    }
    
    func testMoveToSVGPath() {
        
        let moveToPoint = reader.getMoveToSVGPath(using: "M1.0,0.0")
        XCTAssertNotNil(moveToPoint)
        XCTAssertEqual(moveToPoint?.points.count, 2)
        XCTAssertEqual(moveToPoint?.points.first, 1.0)
        
        let moveToPointNil = reader.getMoveToSVGPath(using: "0.0")
        XCTAssertNil(moveToPointNil)
       
    }
    
    func testLineToSVGPath() {
        
        let lineToPoint = reader.getMoveToSVGPath(using: "L2.0,3.0")
        XCTAssertNotNil(lineToPoint)
        XCTAssertEqual(lineToPoint?.points.count, 2)
        XCTAssertEqual(lineToPoint?.points.first, 2.0)
        
        let lineToPointNil = reader.getMoveToSVGPath(using: "1.0,1.0f")
        XCTAssertNil(lineToPointNil)
    }
    
    func testCurveToSVGPath() {
        
        let curveToPoint = reader.getCurveToSVGPath(using: "C2.0,3.0 3.0,4.0 5.0, 6.6")
        XCTAssertNotNil(curveToPoint)
        XCTAssertEqual(curveToPoint?.points.count, 6)
        XCTAssertEqual(curveToPoint?.points.last, 6.6)
        
        let curveToPointNil = reader.getMoveToSVGPath(using: "C1.0,1.0 1.0,1.0")
        XCTAssertNil(curveToPointNil)
    }

    
    func testGetTransformMatrix() {
        let model = try! reader.read().get()
        let modelWithPathString =  try! reader.getPath(model: model).get()
        let modelWithSvgPaths =  try! reader.pathStringToSVGPath(model: modelWithPathString).get()
        let modelWithTransformMatrix =  try! reader.getTransform(model: modelWithSvgPaths).get()
        
        let result  = reader.getTransformationMatrix(model: modelWithTransformMatrix)
        XCTAssertEqual(result?.first, 1.0)
        XCTAssertEqual(result?.last, -143.889)
    }
    
    func testConvertToLocalCorrdinates() {
        let model = try! reader.read().get()
        let modelWithViewRect =  try! reader.getViewBoxRect(model: model).get()
        let modelWithPathString =  try! reader.getPath(model: modelWithViewRect).get()
        let modelWithSvgPaths =  try! reader.pathStringToSVGPath(model: modelWithPathString).get()
        let modelWithTransformMatrix =  try! reader.getTransform(model: modelWithSvgPaths).get()
        
        let result  = reader.convertToLocalCorrdinates(model: modelWithTransformMatrix)
        let firstPoint = result.paths.first
        XCTAssertEqual(firstPoint?.points, [0.0016778524, 0.99554646])
        
    }
    
    func testParse() {
        let model = reader.parse()
       
        switch model {
        case .success(let paths):
            XCTAssertEqual(paths.count, 4)
            XCTAssertEqual(paths.first?.points, [0.0016778524, 0.99554646])
        case .failure(let error):
            print(error)
            XCTFail()
        }
        
    }
    
   
    
    func testParseInvalid() {
        let reader = SVGReader1dot1(filePath: Bundle.module.path(forResource: "invalid", ofType: "svg")!)
        let model = reader.parse()
       
        switch model {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, SVGError.contentNotFound("svg Path tag not found!"))
        }
        
    }
    
    func testParseInvalid2() {
        let reader = SVGReader1dot1(filePath: Bundle.module.path(forResource: "invalid2", ofType: "svg")!)
        let model = reader.parse()
       
        switch model {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, SVGError.contentNotFound("svg viewBox tag not found!"))
        }
        
    }
    
    static var allTests = [
        ("testParseSvgFile", testParseSvgFile),
    ]
}
