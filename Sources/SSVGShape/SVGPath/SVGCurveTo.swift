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
        let points = split.map { Float($0) }.compactMap{$0}
        guard points.count == 6 else {
            throw SVGError.fatalError("could not constrcut CurveTo path, less than 6 points found")
        }
        
        self.points = self.makeCGPoints(coordinates: points)
    }
    
    override func draw(p: inout Path, rect: CGRect) {
        guard points.count == 3 else {
            return
        }
        
        p.addCurve(to: CGPoint(x: points.last!.x * rect.width, y: points.last!.y * rect.height), control1: CGPoint(x: points.first!.x * rect.width , y: points.first!.y * rect.height), control2: CGPoint(x: points[1].x * rect.width, y: points[1].y * rect.height))
    }
    
}
