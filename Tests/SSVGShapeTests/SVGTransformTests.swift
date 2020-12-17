//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//

import Foundation
import simd
import XCTest
@testable import SSVGShape

final class SVGTransformTests: XCTestCase {

    func testParseMatrix() {
        let translate = SVGTranslate(matrix: "matrix(1,0,0,1,-178.831,-143.889)")
        var matrix = matrix_identity_float3x3
        matrix[2,0] = Float(-178.831)
        matrix[2,1] = Float(-143.889)
        XCTAssertNotNil(translate)
        XCTAssertEqual(translate.parseMatrix(str: "matrix(1,0,0,1,-178.831,-143.889)"), matrix)
    }
    
    
}
