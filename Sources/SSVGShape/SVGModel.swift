//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import CoreGraphics
import simd

struct SVGElement {
    private let endOfContent = "~"
    var path: [SVGPath] = []
    var transform: [SVGTransform] = []
    
    init(pathStr: String, transform: [String]) {
        let result = split(path: pathStr).map(self.convertPathStringToSVGPaths).flatMap{$0}
        
        switch result {
        case .success(let svgPaths):
            self.path = svgPaths
        case .failure(let error):
            print(error)
            fatalError("could not constrcut SVGPath from path string")
        }
    }
    
    
    private func split(path: String) ->  Result<[String], SVGError> {
        
            guard isFirstLetterM(pathString: path) else {
                return .failure(.convertFailed("Path string dose not start with M or m!!"))
              
        }
        return .success(split(pathString: path))
        
    }
    
    private func isFirstLetterM(pathString: String) -> Bool {
        return pathString.first?.uppercased() == "M"
    }
    
    private func isClosedPath(pathString: String) -> Bool {
        return pathString.last?.uppercased() == "Z"
    }

    private func split(pathString: String) -> [String] {
        var lastIndex: String.Index = pathString.startIndex
        var lastSymbol = ""
        var svgs: [String] = []
        let pathContent = pathString + endOfContent
        
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
    
    func convertPathStringToSVGPaths(points: [String]) -> Result<[SVGPath], SVGError> {
        
        var offset = 0
        var paths: [SVGPath] = []
        
        
            for p in points {
                
                let first = p.first ?? " "
                
                if String(first).uppercased() == "M" {
                    /*guard let movePoint = getMoveToSVGPath(using: p) else {
                        return .failure(.convertFailed("MoveTo point missing X or Y corrdinates or values are not float!!"))
                    }*/
                    paths.append(SVGMoveTo(pathStr: p))
                }
                
                if String(first).uppercased() == "C" {
                    
                    /*guard let curvePoint = getCurveToSVGPath(using: p) else {
                        return .failure(.convertFailed("CurveTo points are smaller than 6 points or values are not float!!"))
                    }*/
                    
                    paths.append(SVGCurveTo(pathStr: p))
                }
                
                if String(first).uppercased() == "L" {
                    
                    /*guard let linePoint = getLineToSVGPath(using: p) else {
                        return .failure(.convertFailed("LineTo point missing X or Y corrdinates or values are not float!!"))
                    }*/
                    paths.append(SVGLineTo(pathStr: p))
                }
                
                if String(first).uppercased() == "Z" {
                    paths.append(SVGClose(pathStr: p))
                }
                
                offset += 1
            }
           
        return .success(paths)
    }
}

struct SVGModel {
    var content: String = ""
    var rect: CGRect = .zero
    var svgTree: [SVGElement] = []
    var matrixString: String = ""
    var translateMatrix: simd_float3x3? = nil
    var pathPointsString: [String] = []
    var paths: [[SVGPath]] = []

    private let endOfContent = "~"

    
    /*func split(pathString: String) -> [String] {
        var lastIndex: String.Index = pathString.startIndex
        var lastSymbol = ""
        var svgs: [String] = []
        let pathContent = pathString + endOfContent
        
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
    
    func isFirstLetterM(pathString: String) -> Bool {
        return pathString.first?.uppercased() == "M"
    }
    
    func isClosedPath(pathString: String) -> Bool {
        return pathString.last?.uppercased() == "Z"
    }
    */
}


