//
//  File.swift
//  
//
//  Created by Nour on 17.12.2020.
//

import Foundation
import CoreGraphics
import SwiftUI

internal class SVGClose: SVGPath {
    
    override init(pathStr: String) throws {
        try super.init(pathStr: pathStr)
    }
    override func draw(p: inout Path, rect: CGRect) {
        p.closeSubpath()
    }
    
}
