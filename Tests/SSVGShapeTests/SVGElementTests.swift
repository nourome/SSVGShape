//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//


import XCTest
@testable import SSVGShape

final class SVGElementTests: XCTestCase {
    let reader = SVGReader11(filePath: Bundle.module.path(forResource: "test", ofType: "svg")!)
    let element = SVGElement(pathStr: "path d=\"M100,100L0.0,0.0\"", transformStr: [])
    
    func testStartsWithM() {
       
        XCTAssertTrue(element.isFirstLetterM(pathString: "M100,100L0.0,0,0"))
        XCTAssertFalse(element.isFirstLetterM(pathString: "L100,100L0.0,0,0"))
    }
    
    func testEndsWithZ() {
        let element = SVGElement(pathStr: "path d=\"M100,100L0.0,0.0Z\"", transformStr: [])
        XCTAssertTrue(element.isClosedPath(pathString: "M100,100L0.0,0,0Z"))
        XCTAssertFalse(element.isClosedPath(pathString: "M100,100L0.0,0,0L"))
    }
    
    func testSplitPath() {
        let splits = try! element.split(path: "path d=\"M100,100L0.0,0.0\"").get()
        XCTAssertEqual(splits.count, 2)

    }
    
    func testSplitPathFails() {
        let splits =  element.split(path: "M100,100L0.0,0.0")
        
        switch splits {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, SVGError.convertFailed("Path string dose not start with <path d="))
        }

    }
    
    func testConvertPathStringToSVGPaths() {
        let points =  try! element.split(path: "path d=\"M100,100L0.0,0.0\"").get()
        let svgPaths = element.convertPathStringToSVGPaths(points: points)
        
        switch svgPaths {
        case .success(let svgs):
            XCTAssertEqual(svgs.count, 2)
            XCTAssertNotNil(svgs.first as? SVGMoveTo)
            XCTAssertNotNil(svgs.last as? SVGLineTo)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testConvertTransfromStrToSVGTransform() {
        let transforms = element.convertTransfromStrToSVGTransform(transformArr: ["matrix(1,0,0,1,-178.831,-143.889)"])
        
        XCTAssertEqual(transforms.count, 1)
        XCTAssertNotNil(transforms.first as? SVGTranslate)
    }
}
