//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics

struct SVGModel {
    var content: String
    var size: CGSize = .zero
    var matrix: [Float] = []
    var paths: [SVGPath] = []
    
    init(content: String) {
        self.content = content
    }
}
