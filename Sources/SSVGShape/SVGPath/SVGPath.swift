//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

enum SVGPathType: String, CaseIterable {
    case moveTo = "M"
    case lineTo = "L"
    case curveTo = "C"
    case close = "Z"

    func getSVGPath(str: String) throws -> SVGPath {
        switch self {
        case .moveTo:
            return try SVGMoveTo(pathStr: str)
        case .lineTo:
            return try SVGLineTo(pathStr: str)
        case .curveTo:
            return try SVGCurveTo(pathStr: str)
        case .close:
            return try SVGClose(pathStr: str)
        }
    }
}

public class SVGPath {

    var points: [CGPoint] = []
    func draw(path: inout Path, rect: CGRect) {}

    internal init(pathStr: String) throws {}

    static func make(pathStr: String, for char: String) throws -> SVGPath? {
        for type in SVGPathType.allCases {
            if type.rawValue == char {
                return try type.getSVGPath(str: pathStr)
            }
        }

        return nil
    }

    internal func makeCGPoints(coordinates: [Float]) -> [CGPoint] {
        let split = coordinates.chunked(into: 2).map { coord in
            CGPoint(x: CGFloat(coord[0]), y: CGFloat(coord[1]))

        }
        return split
    }
}
