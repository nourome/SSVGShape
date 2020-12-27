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
    private let svgPathSymbols = [SVGPathType.lineTo.rawValue,
                                  SVGPathType.curveTo.rawValue,
                                  SVGPathType.close.rawValue,
                                  "~"]

    init(pathStr: String, transformStr: [String]) {

        let result = split(path: pathStr).map(self.convertPathStringToSVGPaths).flatMap {$0}

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
        return String(str.first ?? "0") == SVGPathType.moveTo.rawValue
    }

    func isClosedPath(pathString: String) -> Bool {
        return String(pathString.last ?? "0") == SVGPathType.close.rawValue
    }

    func split(pathString: String) -> [String] {
        var lastIndex: String.Index = pathString.startIndex
        var lastSymbol = ""
        var svgs: [String] = []
        let pathContent = splitByClosedPaths(content: pathString)
        
        for closedPath in pathContent {
            lastIndex = closedPath.startIndex
            lastSymbol = ""
            for (offset, char) in closedPath.enumerated() {
                lastSymbol = isFirstLetterM(str: String(char).uppercased()) ? String(char) : lastSymbol
                let offsetIndex = closedPath.index(closedPath.startIndex, offsetBy: offset)

                if let nextPath = getNextPathString(for: char, from: closedPath,
                                                    by: offset, lastIndex: lastIndex,
                                                    symbol: lastSymbol) {
                    svgs.append(nextPath)
                    lastIndex = offsetIndex
                    lastSymbol = String(char)
                }
            }
        }

        return svgs
    }

    func splitByClosedPaths(content: String) -> [String] {
        if content.contains(Character(SVGPathType.close.rawValue)) {
            return content.split(separator: Character(SVGPathType.close.rawValue)).map { String($0) + SVGPathType.close.rawValue + endOfContent
            }
        }
        return [content + endOfContent]
    }
    
    func getNextPathString(for char: Character, from content: String,
                           by offset: Int, lastIndex: String.Index, symbol: String) -> String? {

        let offsetIndex = content.index(content.startIndex, offsetBy: offset)
        if svgPathSymbols.contains(String(char)) {
            let subPath =  String(content[lastIndex..<offsetIndex]).trimmingCharacters(in: .whitespaces)
            return !subPath.contains(symbol) ?  symbol + subPath : subPath
        }

        return nil
    }

    func convertPathStringToSVGPaths(points: [String]) -> Result<[SVGPath], SVGError> {

        var offset = 0
        var paths: [SVGPath] = []

        for point in points {
            do {
                if let path =  try SVGPath.make(pathStr: point, for: String(point.first ?? " ")) {
                    paths.append(path)
                }
            } catch {
                return .failure(SVGError.fatalError("something wrong with Path format!!"))
            }
            offset += 1
        }

        return .success(paths)
    }

}
