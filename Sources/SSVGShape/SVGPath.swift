//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

public class SVGPath {
    var points: [Float]
    func draw(p: inout Path, rect: CGRect) {}
   init(points: [Float]) {
        self.points = points
    }
}

public class SVGMoveTo:SVGPath {
    override func draw( p: inout Path, rect: CGRect) {
        if let first = points.first, let last = points.last {
            p.move(to: CGPoint(x: CGFloat(first) * rect.width, y: CGFloat(last) * rect.height))
        }
    }
}

public class SVGLineTo: SVGPath {
    override func draw(p: inout Path, rect: CGRect) {
        if let first = points.first, let last = points.last {
            p.addLine(to: CGPoint(x: CGFloat(first) * rect.width, y: CGFloat(last) * rect.height))
        }
        }
}

public class SVGCurveTo: SVGPath {
    override func draw(p: inout Path, rect: CGRect) {
        guard points.count == 6 else {
            return
        }
        p.addCurve(to: CGPoint(x: CGFloat(points[4]) * rect.width, y: CGFloat(points[5]) * rect.height), control1: CGPoint(x: CGFloat(points[0]) * rect.width , y: CGFloat(points[1]) * rect.height), control2: CGPoint(x: CGFloat(points[2]) * rect.width, y: CGFloat(points[3]) * rect.height))
    }
}

