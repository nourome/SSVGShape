//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import XCTest
@testable import SSVGShape

final class SVGReaderTests: XCTestCase {
    let reader = SVGReader11(filePath: Bundle.module.path(forResource: "test", ofType: "svg")!)
    
    
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
    
    func testGetSVGPath() {
        let model = try! reader.read().get()
        let treeModel =  try! reader.buildSVGTree(model: model).get()
        let pathResult =  reader.getSVGPaths(model: treeModel)

        
        switch pathResult {
        case .success(let model):
            XCTAssertEqual(model.paths.count, 4)
            XCTAssertNotNil(model.paths.first?.first as? SVGMoveTo )
        case .failure(_):
            XCTFail()
        }
        
    }
    
    func testParse() {
        let model = reader.parse()
       
        switch model {
        case .success(let paths):
            print(paths.first!)
            XCTAssertEqual(paths.first!.count, 4)
            XCTAssertEqual(paths.first?.first?.points.first, CGPoint(x: 0.0016778523489932886, y: 0.9955464756621747))
        case .failure(let error):
            print(error)
            XCTFail()
        }
        
    }
    
    func testParseInvalid() {
        let reader = SVGReader11(filePath: Bundle.module.path(forResource: "invalid", ofType: "svg")!)
        let model = reader.parse()
       
        switch model {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, SVGError.contentNotFound("failed to get svg path, make sure it is valid svg file"))
        }
        
    }
    
    func testParseInvalid2() {
        let reader = SVGReader11(filePath: Bundle.module.path(forResource: "invalid2", ofType: "svg")!)
        let model = reader.parse()
       
        switch model {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, SVGError.contentNotFound("svg viewBox tag not found!"))
        }
        
    }
    
    func testBuildSVGTree() {
        let reader = SVGReader11(filePath: Bundle.module.path(forResource: "noro", ofType: "svg")!)
        let model = try! reader.read().get()
        let treeResult =  reader.buildSVGTree(model: model)
        
        switch treeResult {
        case .success(let model):
            print(model.svgTree)
            XCTAssertEqual(model.svgTree.count, 4)
        case .failure(let error):
            print(error)
            XCTFail()
        }
        
    }
    
    func testGetTransform() {
       /* let model = try! reader.read().get()
        let transformResult =  reader.getTransform(model: model)
        
        switch transformResult {
        case .success(let model):
            XCTAssertTrue(model.matrixString.contains("matrix"))
        case .failure(_):
            XCTFail()
        }*/
        
    }
    
    func testPathStringToSVGPath() {
       /* let model = try! reader.read().get()
        let modelWithPathString =  try! reader.getPath(model: model).get()
        let svgPathsResult =  reader.pathStringToSVGPath(model: modelWithPathString)
        
        switch svgPathsResult {
        case .success(let model):
            XCTAssertEqual(model.paths.first!.count, 4)
        case .failure(let error):
            print("error \(error)")
            XCTFail()
        }*/
        
    }
    
    func testMoveToSVGPath() {
        
        /*let moveToPoint = reader.getMoveToSVGPath(using: "M1.0,0.0")
        XCTAssertNotNil(moveToPoint)
        XCTAssertEqual(moveToPoint?.points.count, 1)
        XCTAssertEqual(moveToPoint?.points.first, CGPoint(x: 1.0, y: 0.0))
        
        let moveToPointNil = reader.getMoveToSVGPath(using: "0.0")
        XCTAssertNil(moveToPointNil)*/
       
    }
    
    func testLineToSVGPath() {
        
       /* let lineToPoint = reader.getMoveToSVGPath(using: "L2.0,3.0")
        XCTAssertNotNil(lineToPoint)
        XCTAssertEqual(lineToPoint?.points.count, 1)
        XCTAssertEqual(lineToPoint?.points.first, CGPoint(x: 2.0, y: 3.0))
        
        let lineToPointNil = reader.getMoveToSVGPath(using: "1.0,1.0f")
        XCTAssertNil(lineToPointNil)*/
    }
    
    func testCurveToSVGPath() {
        
       /* let curveToPoint = reader.getCurveToSVGPath(using: "C2.0,3.0 3.0,4.0 5.0, 6.0")
        XCTAssertNotNil(curveToPoint)
        XCTAssertEqual(curveToPoint?.points.count, 3)
        XCTAssertEqual(curveToPoint?.points.last!.x,  5.0)
        XCTAssertEqual(curveToPoint!.points.last!.y,  6.0)
        
        let curveToPointNil = reader.getMoveToSVGPath(using: "C1.0,1.0 1.0,1.0")
        XCTAssertNil(curveToPointNil)*/
    }

    
    func testGetTransformMatrix() {
        /*let model = try! reader.read().get()
        let modelWithPathString =  try! reader.getPath(model: model).get()
        let modelWithSvgPaths =  try! reader.pathStringToSVGPath(model: modelWithPathString).get()
        let modelWithTransformMatrix =  try! reader.getTransform(model: modelWithSvgPaths).get()
        
        let svgTranslate = SVGTranslate(model: modelWithTransformMatrix)
        let result  = svgTranslate.matrix
        XCTAssertEqual(result?[0,0], 1.0)
        XCTAssertEqual(result?[2,1], -143.889)*/
    }
    
    func testConvertToLocalCorrdinates() {
        /*let model = try! reader.read().get()
        let modelWithViewRect =  try! reader.getViewBoxRect(model: model).get()
        let modelWithPathString =  try! reader.getPath(model: modelWithViewRect).get()
        let modelWithSvgPaths =  try! reader.pathStringToSVGPath(model: modelWithPathString).get()
        let modelWithTransformMatrix =  try! reader.getTransform(model: modelWithSvgPaths).get()
        
        let result  = reader.convertToLocalCorrdinates(model: modelWithTransformMatrix)
        let firstPoint = result.paths.first
        XCTAssertEqual(firstPoint?.first?.points.first, CGPoint(x: 0.0016778523489932886, y: 0.9955464756621747))*/
        
    }
    
   
    
   
    
   
    
    
    
    func testGetMultiPath() {
        /*let reader = SVGReader11(filePath: Bundle.module.path(forResource: "multi", ofType: "svg")!)
        let model = try! reader.read().get()
        let pathResult =  reader.getPath(model: model)
        
        switch pathResult {
        case .success(let model):
            print(model.pathPointsString.count)
            XCTAssertEqual(model.pathPointsString.first!.first!.uppercased(), "M")
            XCTAssertEqual(model.pathPointsString.count, 2)
        case .failure(_):
            XCTFail()
        }*/
        
    }
    
    func testGetClosedPath() {
        /*let reader = SVGReader11(filePath: Bundle.module.path(forResource: "closed", ofType: "svg")!)
        let model = try! reader.read().get()
        let pathResult =  reader.getPath(model: model)
        
        switch pathResult {
        case .success(let model):
            print(model.pathPointsString.count)
            XCTAssertEqual(model.pathPointsString.first!.last!.uppercased(), "Z")
            XCTAssertEqual(model.pathPointsString.count, 1)
        case .failure(_):
            XCTFail()
        }
        
        let svgPathsResult =  reader.pathStringToSVGPath(model: try! pathResult.get())
        
        switch svgPathsResult {
        case .success(let model):
            XCTAssertNotNil(model.paths.first!.last! as? SVGClose)
        case .failure(let error):
            print("error \(error)")
            XCTFail()
        }*/
    }
    
   
    
    static var allTests = [
        ("testParseSvgFile", testParseSvgFile),
    ]
}
