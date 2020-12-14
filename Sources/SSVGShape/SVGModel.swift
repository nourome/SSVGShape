//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics

struct SVGModel {
    var content: String = ""
    var rect: CGRect = .zero
    var transformString: String = ""
    var matrix: SVGMatrix? = nil
    var pathPointsString: String = ""
    var paths: [SVGPath] = []
}

struct SVGMatrix {
    let translateX: Float
    let translateY: Float
    let rotateX: Float
    let rotateY: Float
    let scaleX: Float
    let scaleY: Float
}
