//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public class SVGPath {
    //var raw: [Float]
    var points: [CGPoint] = []
    func draw(p: inout Path, rect: CGRect) {}
    
   init(coordinates: [Float]) {
        //self.raw = coordinates
        self.points = self.makeCGPoints(coordinates: coordinates)
    }
    
    
    private func makeCGPoints(coordinates: [Float]) -> [CGPoint] {
        let split = coordinates.chunked(into: 2).map { coord in
            CGPoint(x: CGFloat(coord[0]), y: CGFloat(coord[1]))
            
        }
        return split
    }
}

public class SVGMoveTo:SVGPath {
    override func draw( p: inout Path, rect: CGRect) {
        if let point = points.first {
            p.move(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
        }
    }
}

public class SVGLineTo: SVGPath {
    override func draw(p: inout Path, rect: CGRect) {
        if let point = points.first {
            p.addLine(to: CGPoint(x: point.x * rect.width, y: point.x * rect.height))
        }
        }
}

public class SVGCurveTo: SVGPath {
    override func draw(p: inout Path, rect: CGRect) {
        guard points.count == 3 else {
            return
        }
        
        p.addCurve(to: CGPoint(x: points.last!.x * rect.width, y: points.last!.y * rect.height), control1: CGPoint(x: points.first!.x * rect.width , y: points.first!.y * rect.height), control2: CGPoint(x: points[1].x * rect.width, y: points[1].y * rect.height))
    }
}

