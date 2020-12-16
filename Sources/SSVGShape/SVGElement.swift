//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//

import Foundation

struct SVGElement {
    private let endOfContent = "~"
    var path: [SVGPath] = []
    var transforms: [SVGTransform] = []
    
    init(pathStr: String, transformStr: [String]) {
        let result = split(path: pathStr).map(self.convertPathStringToSVGPaths).flatMap{$0}
        
        switch result {
        case .success(let svgPaths):
            self.path = svgPaths
        case .failure(let error):
            print(error)
            fatalError("could not constrcut SVGPath from path string")
        }
        
        transforms = convertTransfromStrToSVGTransform(transformArr: transformStr).reversed()
    }
    
    
    private func split(path: String) ->  Result<[String], SVGError> {
       
        let stripPathTag = String(path.firstSubstring(between: "d=\"", and: "\"") ?? "")
            guard isFirstLetterM(pathString: String(stripPathTag)) else {
                return .failure(.convertFailed("Path string dose not start with M or m!!"))
              
        }
        return .success(split(pathString: stripPathTag))
        
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
                    paths.append(SVGMoveTo(pathStr: p))
                }
                
                if String(first).uppercased() == "C" {
                    paths.append(SVGCurveTo(pathStr: p))
                }
                
                if String(first).uppercased() == "L" {
                    paths.append(SVGLineTo(pathStr: p))
                }
                
                if String(first).uppercased() == "Z" {
                    paths.append(SVGClose(pathStr: p))
                }
                
                offset += 1
            }
           
        return .success(paths)
    }
    
    func convertTransfromStrToSVGTransform(transformArr: [String]) -> [SVGTransform] {
        
        return transformArr.map { str -> SVGTransform in
            SVGTranslate(matrix: str)
        }
        
    }
}
