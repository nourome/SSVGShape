//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import Sweep

struct SVGReader {
    let fileName: String
    private let viewBoxTag: Identifier = "viewBox"
    private let pathTag: Identifier = "<path d"
    private let transformTag: Identifier = "transform"
    
    func parse() -> Result<String, SVGError> {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "svg") else {
            return .failure(.parsingError("svg file not found in bundle"))
        }

        do {
            return .success(try String(contentsOfFile: filePath, encoding: String.Encoding.utf8))
        } catch {
            return .failure(.readingFileError("svg file not found in bundle"))
        }
    }
    
    func getViewBoxRect(content: String) -> Result<CGRect, SVGError> {
        
        if let viewBoxRect = content.firstSubstring(between: viewBoxTag, and: "\"") {
            let values =  viewBoxRect.split(separator: " ").map {Float($0)}.compactMap{$0}
            guard values.count == 4 else {
                return .failure(.contentNotFound("svg viewBox Rectangle (x y width height) not found!"))
            }
            return .success(CGRect(x: CGFloat(values[0]), y: CGFloat(values[1]), width: CGFloat(values[2]), height: CGFloat(values[3])))
        }
           
        return .failure(.contentNotFound("svg viewBox tag not found!"))
    }
    
    func getPath(content: String) -> Result<String, SVGError> {
        
        if let pathValues = content.firstSubstring(between: pathTag, and: "\"") {
            return .success(String(pathValues))
        }
        return .failure(.contentNotFound("svg Path tag not found!"))
    }
    
    func getTransform(content: String) -> Result<String, SVGError> {
        
        if let pathValues = content.firstSubstring(between: pathTag, and: "\"") {
            return .success(String(pathValues))
        }
        return .failure(.contentNotFound("svg Transform tag not found!"))
    }
    
}
