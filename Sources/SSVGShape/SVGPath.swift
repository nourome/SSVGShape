//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

class SVGPath {
    var points: [Float]
    func draw(p: inout Path) {}
    init(points: [Float]) {
        self.points = points
    }
}

class SVGMoveTo:SVGPath {
    override func draw( p: inout Path) {
        if let first = points.first, let last = points.last {
            p.move(to: CGPoint(x: CGFloat(first), y: CGFloat(last)))
        }
    }
}

class SvgLineTo: SVGPath {
    override func draw(p: inout Path) {
        if let first = points.first, let last = points.last {
            p.addLine(to: CGPoint(x: CGFloat(first), y: CGFloat(last)))
        }
        }
}

class SvgCurveTo: SVGPath {
    override func draw(p: inout Path) {
        guard points.count == 6 else {
            return
        }
        //p.addQuadCurve(to: CGPoint(x: CGFloat(points[2]), y: CGFloat(points[3])), control: CGPoint(x: CGFloat(points[4]), y: CGFloat(points[5])))
        p.addCurve(to: CGPoint(x: CGFloat(points[4]), y: CGFloat(points[5])), control1: CGPoint(x: CGFloat(points[0]), y: CGFloat(points[1])), control2: CGPoint(x: CGFloat(points[2]), y: CGFloat(points[3])))
    }
}

