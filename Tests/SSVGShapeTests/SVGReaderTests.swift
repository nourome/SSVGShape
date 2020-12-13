//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import XCTest
@testable import SSVGShape

final class SVGReaderTests: XCTestCase {
    let reader = SVGReader(filePath: Bundle.module.path(forResource: "test", ofType: "svg")!)
    
    
    func testParseSvgFile() {
        let contents = try? reader.parse().get()
        XCTAssertNotNil(contents)
    }
    
    func testGetViewBoxRect() {
        let contents = try! reader.parse().get()
        let viewBoxRectResult =  reader.getViewBoxRect(content: contents)
        
        switch viewBoxRectResult {
        case .success(let rect):
            XCTAssertNotNil(rect)
        case .failure(_):
            XCTFail()
        }
        
    }
    
    func testGetPath() {
        let contents = try! reader.parse().get()
        let pathResult =  reader.getPath(content: contents)
        
        switch pathResult {
        case .success(let path):
            XCTAssertEqual(path.first!.uppercased(), "M")
        case .failure(_):
            XCTFail()
        }
        
    }

    static var allTests = [
        ("testParseSvgFile", testParseSvgFile),
    ]
}
