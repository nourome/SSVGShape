//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics

internal struct SVGModel {
    var content: String = ""
    var rect: CGRect = .zero
    var svgTree: [SVGElement] = []
    var paths: [[SVGPath]] = []
}


