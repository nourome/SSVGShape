//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import Sweep
import CoreGraphics
import simd

public struct SVGReader11: SVGReader {
    
    public var filePath: String
    private let viewBoxTag: Identifier = "viewBox=\""
    private let pathTag: Identifier = "<path d=\""
    private let transformTag: Identifier = "transform=\""
    private let matrixTag: Identifier = "matrix("
    
    public init(filePath: String) {
        self.filePath = filePath
    }
    
    public func parse() -> Result<[[SVGPath]], SVGError> {
        let svgPaths = read()
            .flatMap(self.getViewBoxRect)
            .flatMap(self.buildSVGTree).flatMap(self.getSVGPaths)
    
        switch svgPaths {
        case .success(let svgModel):
            return .success(svgModel.paths)
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    func read() -> Result<SVGModel, SVGError> {
        do {
            var model = SVGModel()
            model.content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            return .success(model)
        } catch {
            return .failure(.readingFileError("svg file not found in bundle"))
        }
    }
    
    func getViewBoxRect(model: SVGModel) -> Result<SVGModel, SVGError> {
        
        if let viewBoxRect = model.content.firstSubstring(between: viewBoxTag, and: "\"") {
            let values =  viewBoxRect.split(separator: " ").map {Float($0)}.compactMap{$0}
            guard values.count == 4 else {
                return .failure(.contentNotFound("svg viewBox Rectangle (x y width height) not found!"))
            }
            var updatedModel = model
            updatedModel.rect =  CGRect(x: CGFloat(values[0]), y: CGFloat(values[1]), width: CGFloat(values[2]), height: CGFloat(values[3]))
            return .success(updatedModel)
        }
        
        return .failure(.contentNotFound("svg viewBox tag not found!"))
    }
    
    func buildSVGTree(model: SVGModel) -> Result<SVGModel, SVGError> {
        
        var previousChar = ""
        var treeStr: [String] = []
        var transforms: [String] = []
        var updatedModel = model
        let removeHeaderTags =  model.content.firstSubstring(between: "<g", and: "</svg>")
        guard var content = removeHeaderTags else {
            return .failure(.contentNotFound("failed to build svg tree, make sure it is valid svg file"))
        }
        
        content = "<g " + String( content)
        for (offset, c) in content.enumerated() {
            
            if c.lowercased() == "g" &&  previousChar == "<"   {
                let subStr = content[content.index(content.startIndex, offsetBy: offset-1)..<content.endIndex]
                if let transformMatrix = subStr.firstSubstring(between: "g", and: ">") {
                    transforms.append(String(transformMatrix))
                }
            } else if c.lowercased() == "p" &&  previousChar == "<"  {
                let subStr = content[content.index(content.startIndex, offsetBy: offset)..<content.endIndex]
            
                if let path = subStr.firstSubstring(between: "p", and: "/>") {
                    treeStr.append("p" + String(path))
                    updatedModel.svgTree.append(SVGElement(pathStr: "p" + String(path), transformStr: transforms))
                    
                }
               
                
            } else if c.lowercased() == "g" &&  previousChar == "/"  {
                treeStr.append("close group")
                transforms.removeLast()
            }
            
            previousChar = c.lowercased()
        }
        
        guard !treeStr.isEmpty else {
            return .failure(.contentNotFound("failed to build svg tree, make sure it is valid svg file"))
        }
        
        return .success(updatedModel)
        
    }
    
    func getSVGPaths(model:SVGModel) ->  Result<SVGModel, SVGError> {
        
        guard !model.svgTree.isEmpty else {
            return .failure(.contentNotFound("failed to get svg path, make sure it is valid svg file"))
        }
        
        var updatedModel = model
        updatedModel.paths  = model.svgTree.map { element -> [SVGPath] in
            return element.path.map { path in
                var transformedPath = path
                for trans in element.transforms {
                    transformedPath =  trans.apply(svgPath: transformedPath, rect: model.rect)
                }
                
                return transformedPath
            }
        }
        return .success(updatedModel)
       
    }

    
}
