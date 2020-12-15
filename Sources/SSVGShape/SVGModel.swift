//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics
import simd

struct SVGModel {
    var content: String = ""
    var rect: CGRect = .zero
    var transMatrixString: String = ""
    var translateMatrix: simd_float3x3? = nil
    var pathPointsString: String = ""
    var paths: [SVGPath] = []

    private let endOfContent = "~"

    func split() -> [String] {
        var lastIndex: String.Index = pathPointsString.startIndex
        var lastSymbol = ""
        var svgs: [String] = []
        let pathContent = pathPointsString + endOfContent
        
        for (offset , c) in pathContent.enumerated() {
            if String(c).uppercased() == "M" {
                lastSymbol = String(c)
            }
            
            else if String(c).uppercased() == "C" || String(c).uppercased() == "L" || String(c).uppercased() == "Z" || String(c) == endOfContent {
                let offsetIndex = pathContent.index(pathContent.startIndex, offsetBy: offset)
                let svgSub = String(pathContent[lastIndex..<offsetIndex]).trimmingCharacters(in: .whitespaces)
                
                svgs.append(!svgSub.contains(lastSymbol) ?  lastSymbol + svgSub : svgSub)
                lastIndex = offsetIndex
                lastSymbol = String(c)
            }
        }
            
        return svgs
    }
    
    func isFirstLetterM() -> Bool {
        return pathPointsString.first?.uppercased() == "M"
    }
    
}


