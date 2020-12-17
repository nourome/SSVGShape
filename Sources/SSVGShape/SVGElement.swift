//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//

import Foundation

internal struct SVGElement {
    
    private let endOfContent = "~"
    var path: [SVGPath] = []
    var transforms: SVGTransform?
    private let svgPathSymbols = [SVGPathType.lineTo.rawValue, SVGPathType.curveTo.rawValue, SVGPathType.close.rawValue, "~"]
    
    init(pathStr: String, transformStr: [String]) {
        
        let result = split(path: pathStr).map(self.convertPathStringToSVGPaths).flatMap{$0}
        
        switch result {
        case .success(let svgPaths):
            self.path = svgPaths
        case .failure(let error):
            print(error)
            fatalError("could not constrcut SVGPath from path string")
        }
        
        transforms =  SVGTransform(matrices: transformStr)
    }
    
    
    func split(path: String) ->  Result<[String], SVGError> {
        
        let stripPathTag = String(path.firstSubstring(between: "d=\"", and: "\"") ?? "")
        guard isFirstLetterM(str: String(stripPathTag)) else {
            return .failure(.convertFailed("Path string dose not start with <path d="))
            
        }
        return .success(split(pathString: stripPathTag))
        
    }
    
    func isFirstLetterM(str: String) -> Bool {
        return str.first?.uppercased() == SVGPathType.moveTo.rawValue
    }
    
    func isClosedPath(pathString: String) -> Bool {
        return pathString.last?.uppercased() == SVGPathType.close.rawValue
    }
    
    func split(pathString: String) -> [String] {
        var lastIndex: String.Index = pathString.startIndex
        var lastSymbol = ""
        var svgs: [String] = []
        let pathContent = pathString + endOfContent
        
        for (offset , c) in pathContent.enumerated() {
            lastSymbol = isFirstLetterM(str: String(c).uppercased()) ? String(c) : lastSymbol
            let offsetIndex = pathContent.index(pathContent.startIndex, offsetBy: offset)

            if let nextPath = getNextPathString(for: c, from: pathContent, by: offset, offsetIndex: offsetIndex, lastIndex: lastIndex, symbol: lastSymbol) {
                svgs.append(nextPath)
                lastIndex = offsetIndex
                lastSymbol = String(c)
            }
        }
        
        return svgs
    }
    
    func getNextPathString(for c: Character, from content: String, by offset: Int, offsetIndex: String.Index,  lastIndex: String.Index, symbol: String) -> String? {
        
        if svgPathSymbols.contains(String(c).uppercased()) {
            let subPath =  String(content[lastIndex..<offsetIndex]).trimmingCharacters(in: .whitespaces)
            return !subPath.contains(symbol) ?  symbol + subPath : subPath
        }
        
        return nil
    }
    
    func convertPathStringToSVGPaths(points: [String]) -> Result<[SVGPath], SVGError> {
        
        var offset = 0
        var paths: [SVGPath] = []
        
        for p in points {
            do {
                if let path =  try SVGPath.make(pathStr: p, for: String(p.first ?? " ")) {
                    paths.append(path)
                }
            } catch  {
                return .failure(SVGError.fatalError("something wrong with Path format!!"))
            }
            offset += 1
        }
        
        return .success(paths)
    }
    
    
}
