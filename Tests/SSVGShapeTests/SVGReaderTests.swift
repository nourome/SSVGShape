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
            XCTAssertEqual(model.paths.first!.count, 4)
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
    
    func testGetMultiPath() {
        let reader = SVGReader11(filePath: Bundle.module.path(forResource: "multi", ofType: "svg")!)
        let model = try! reader.read().get()
        let treeResult =  reader.buildSVGTree(model: model)
        
        switch treeResult {
        case .success(let model):
            print(model.svgTree.count)
            XCTAssertNotNil(model.svgTree.first!.path.first! as? SVGMoveTo)
            XCTAssertEqual(model.svgTree.count, 2)
        case .failure(_):
            XCTFail()
        }
        
    }
    
    func testGetClosedPath() {
        let reader = SVGReader11(filePath: Bundle.module.path(forResource: "closed", ofType: "svg")!)
        let model = try! reader.read().get()
        let treeResult =  reader.buildSVGTree(model: model)
        
        switch treeResult {
        case .success(let model):
            XCTAssertNotNil(model.svgTree.first!.path.last! as? SVGClose)
            XCTAssertEqual(model.svgTree.count, 1)
        case .failure(_):
            XCTFail()
        }
        
    }
    
    static var allTests = [
        ("testParseSvgFile", testParseSvgFile),
    ]
}
