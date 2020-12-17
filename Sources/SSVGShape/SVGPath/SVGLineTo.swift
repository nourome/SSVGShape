//
//  File.swift
//  
//
//  Created by Nour on 17.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

internal class SVGLineTo: SVGPath {
    
    override internal init(pathStr: String) throws {
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
