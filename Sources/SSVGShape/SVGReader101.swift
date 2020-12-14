//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import Sweep


struct SVGReader101: SVGReader {
   
    var filePath: String
    private let viewBoxTag: Identifier = "viewBox=\""
    private let pathTag: Identifier = "<path d=\""
    private let transformTag: Identifier = "transform=\""
    private let matrixTag: Identifier = "matrix("
       
    func parse() -> Result<[SVGPath], SVGError> {
        let svgPaths = read()
            .flatMap(self.getViewBoxRect)
            .flatMap(self.getPath)
            .flatMap(self.getTransform)
            .flatMap(self.pathStringToSVGPath).map(self.convertToLocalCorrdinates)
            
        
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
            updatedModel.rect = CGRect(x: CGFloat(values[0]), y: CGFloat(values[1]), width: CGFloat(values[2]), height: CGFloat(values[3]))
            return .success(updatedModel)
        }
           
        return .failure(.contentNotFound("svg viewBox tag not found!"))
    }
    
    func getPath(model: SVGModel) -> Result<SVGModel, SVGError> {
        
        if let pathValues = model.content.firstSubstring(between: pathTag, and: "\"") {
            var updatedModel = model
            updatedModel.pathPointsString = String(pathValues)
            return .success(updatedModel)
        }
        return .failure(.contentNotFound("svg Path tag not found!"))
    }
    
    func getTransform(model: SVGModel) -> Result<SVGModel, SVGError> {
        
        if let transformValues = model.content.firstSubstring(between: transformTag, and: "\"") {
            var updatedModel = model
            updatedModel.transformString = String(transformValues)
            return .success(updatedModel)
        }
        
        print("svg Transform tag not found!")
        return .success(model)
       
        //return .failure(.contentNotFound("svg Transform tag not found!"))
    }
    
    func pathStringToSVGPath(model: SVGModel) ->  Result<SVGModel, SVGError> {
        let svgPaths = splitPathString(model: model).map(convertPathStringToSVGPaths).flatMap{$0}
            
        switch svgPaths {
        case .success(let paths):
            var updatedModel = model
            updatedModel.paths = paths
        return .success(updatedModel)
        case.failure(let error):
            return .failure(error)
        }
        
        //return .failure(.convertFailed("failed to parse path string to points"))
    }
    
    func splitPathString(model: SVGModel) ->  Result<[String], SVGError> {
        let endOfContent = "~"
        var lastIndex: String.Index = model.content.startIndex
        let content = model.pathPointsString + endOfContent
        var lastSymbol = ""
        var svgs: [String] = []
        
        guard content.first?.uppercased() == "M" else {
            return .failure(.convertFailed("Path string dose not start with M or m!!"))
        }
        
        for (offset , c) in content.enumerated() {
            if String(c).uppercased() == "M" {
                lastSymbol = String(c)
            }
            
            else if String(c).uppercased() == "C" || String(c).uppercased() == "L" || String(c).uppercased() == "Z" || String(c) == endOfContent {
                let offsetIndex = content.index(model.content.startIndex, offsetBy: offset)
                let svgSub = String(content[lastIndex..<offsetIndex]).trimmingCharacters(in: .whitespaces)
                
                let svgPoints = !svgSub.contains(lastSymbol) ?  lastSymbol + svgSub : svgSub
                svgs.append(svgPoints)
                lastIndex = offsetIndex
                lastSymbol = String(c)
            }
        }
        
        return .success(svgs)
        
    }
    
    func convertPathStringToSVGPaths(points: [String]) -> Result<[SVGPath], SVGError> {
        
        var offset = 0
        var paths: [SVGPath] = []
        
        for p in points {
            let first = p.first ?? " "
        
            if String(first).uppercased() == "M" {
                guard let movePoint = getMoveToSVGPath(using: p) else {
                    return .failure(.convertFailed("MoveTo point missing X or Y corrdinates or values are not float!!"))
                }
                paths.append(movePoint)
            }
            
            if String(first).uppercased() == "C" {
                
                guard let curvePoint = getCurveToSVGPath(using: p) else {
                    return .failure(.convertFailed("CurveTo points are smaller than 6 points or values are not float!!"))
                }
                
                paths.append(curvePoint)
            }
            
            if String(first).uppercased() == "L" {
                
                guard let linePoint = getLineToSVGPath(using: p) else {
                    return .failure(.convertFailed("LineTo point missing X or Y corrdinates or values are not float!!"))
                }
                paths.append(linePoint)
                }
            
            offset += 1
        }
        
        return .success(paths)
        
        
    }
    
    func getMoveToSVGPath(using p: String) -> SVGPath? {
        
        let split = p.dropFirst().split(separator: ",")
        guard split.count == 2 else {
            return nil
        }
        
        guard let x = Float(split[0]), let y = Float(split[1]) else {
            return nil
        }
        
        return SVGMoveTo(points: [x,y])
    }
    
    func getCurveToSVGPath(using p: String) -> SVGPath? {
        
        let split =  p.dropFirst().replacingOccurrences(of: " ", with: ",").split(separator: ",")
        let points = split.map { Float($0) }.compactMap{$0}
        guard points.count == 6 else {
            return nil
        }
        
        return SVGCurveTo(points: points)
    }
    
    func getLineToSVGPath(using p: String) -> SVGPath? {
        
        let split = p.dropFirst().split(separator: ",")
        guard split.count == 2 else {
            return nil
        }
        
        guard let x = Float(split[0]), let y = Float(split[1]) else {
            return nil
        }
        
        return SVGLineTo(points: [x,y])
    }
    
    func convertToLocalCorrdinates(model: SVGModel) -> SVGModel {
        
        guard !model.transformString.isEmpty else {
            return model
        }
        
        if let matrix = getTransformationMatrix(model: model) {
            let svgMatrix = SVGMatrix(translateX: matrix[4], translateY: matrix[5], rotateX: matrix[0], rotateY: matrix[1], scaleX: matrix[2], scaleY: matrix[3])
            var updatedModel = model
            updatedModel.matrix = svgMatrix
            return applyTransformation(for: updatedModel)
        }
        
        
        return model
        
    }
    
    func getTransformationMatrix(model: SVGModel) -> [Float]? {
        
        if model.transformString.contains("matrix") {
            if let transformMatrix = model.content.firstSubstring(between: matrixTag, and: ")") {
                let points = transformMatrix.split(separator: ",").compactMap{Float($0)}
                
                if points.count == 6 {
                    return points
                }
            }
        }
        
        return nil
    }
    
    func applyTransformation(for model: SVGModel) -> SVGModel {
        
        guard let matrix = model.matrix else {
            return model
        }
        
        let transformedPaths = model.paths
        var alternateX = true
        for n in 0..<transformedPaths.count {
            for z in 0..<transformedPaths[n].points.count {
                let transformed = (alternateX) ? (transformedPaths[n].points[z] +  matrix.translateX) / Float(model.rect.width) : (transformedPaths[n].points[z] + matrix.translateY) / Float(model.rect.height)
                alternateX = !alternateX
                transformedPaths[n].points[z] = transformed
            }
        }
        
        var updatedModel = model
        updatedModel.paths = transformedPaths
        
        return updatedModel
    }

}
