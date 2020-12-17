//
//  File.swift
//  
//
//  Created by Nour on 17.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

internal class SVGCurveTo: SVGPath {

    override internal init(pathStr: String) throws {
        try! super.init(pathStr: pathStr)
        let split =  pathStr.dropFirst().replacingOccurrences(of: " ", with: ",").split(separator: ",")
        let points = split.map { Float($0) }.compactMap {$0}
        guard points.count == 6 else {
            throw SVGError.fatalError("could not constrcut CurveTo path, less than 6 points found")
        }

        self.points = self.makeCGPoints(coordinates: points)
    }

    override func draw(path: inout Path, rect: CGRect) {
        guard points.count == 3 else {
            return
        }
        let toPoint = CGPoint(x: points.last!.x * rect.width, y: points.last!.y * rect.height)
        let controlPoint1 = CGPoint(x: points.first!.x * rect.width, y: points.first!.y * rect.height)
        let controlPoint2 = CGPoint(x: points[1].x * rect.width, y: points[1].y * rect.height)

        path.addCurve(to: toPoint, control1: controlPoint1, control2: controlPoint2 )
    }

}
