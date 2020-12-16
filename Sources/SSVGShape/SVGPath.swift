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
    var points: [CGPoint] = []
    func draw(p: inout Path, rect: CGRect) {}
    
    init(pathStr: String) throws {}
    
    fileprivate func makeCGPoints(coordinates: [Float]) -> [CGPoint] {
        let split = coordinates.chunked(into: 2).map { coord in
            CGPoint(x: CGFloat(coord[0]), y: CGFloat(coord[1]))
            
        }
        return split
    }
    
    
}

public class SVGMoveTo:SVGPath {
    
    override init(pathStr: String) throws {
        try! super.init(pathStr: pathStr)
        
        let split = pathStr.dropFirst().split(separator: ",")
        guard split.count == 2 else {
            throw SVGError.fatalError("could not construct LineTo path")
        }
        guard let x = Float(split[0]), let y = Float(split[1]) else {
            throw SVGError.fatalError("could not construct LineTo path")
            //fatalError("could not construct MoveTo point, x or y are not float")
        }
        self.points = self.makeCGPoints(coordinates: [x,y])
    }
    
    override func draw( p: inout Path, rect: CGRect) {
        if let point = points.first {
            p.move(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
        }
    }
}

public class SVGLineTo: SVGPath {
    
    override init(pathStr: String) throws {
        try! super.init(pathStr: pathStr)
        
        let split = pathStr.dropFirst().split(separator: ",")
        guard split.count == 2 else {
            throw SVGError.fatalError("could not constrcut LineTo path")
        }
        
        guard let x = Float(split[0]), let y = Float(split[1]) else {
            throw SVGError.fatalError("could not constrcut LineTo point, x or y are not float")
        }
        
        self.points = self.makeCGPoints(coordinates: [x,y])
    }
    
    override func draw(p: inout Path, rect: CGRect) {
        if let point = points.first {
            p.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
        }
    }
}

public class SVGCurveTo: SVGPath {
    
    override init(pathStr: String) throws {
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

public class SVGClose: SVGPath {
    override func draw(p: inout Path, rect: CGRect) {
        p.closeSubpath()
    }
    
}

