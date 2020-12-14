//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation
import Sweep
import CoreGraphics


public struct SVGReader101: SVGReader {
   
    public var filePath: String
    private let viewBoxTag: Identifier = "viewBox=\""
    private let pathTag: Identifier = "<path d=\""
    private let transformTag: Identifier = "transform=\""
    private let matrixTag: Identifier = "matrix("

    init(filePath: String) {
        self.filePath = filePath
    }
    
    public func parse() -> Result<[SVGPath], SVGError> {
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
    }
    
    func splitPathString(model: SVGModel) ->  Result<[String], SVGError> {
                
        guard model.isFirstLetterM() else {
            return .failure(.convertFailed("Path string dose not start with M or m!!"))
        }
        return .success(model.split())
        
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
        var isCoordX = true
        
        for n in 0..<transformedPaths.count {
            for z in 0..<transformedPaths[n].points.count {
                transformedPaths[n].points[z] = (isCoordX) ? translateX(value: transformedPaths[n].points[z] , by: matrix.translateX, width: model.rect.width) : translateY(value: transformedPaths[n].points[z] , by: matrix.translateY, height: model.rect.height)
                
                isCoordX = !isCoordX
            }
        }
        
        var updatedModel = model
        updatedModel.paths = transformedPaths
        
        return updatedModel
    }
    
    func translateX(value: Float, by tx: Float, width: CGFloat) -> Float {
        return (value +  tx) / Float(width)
    }

    func translateY(value: Float, by ty: Float, height: CGFloat) -> Float {
        return (value +  ty) / Float(height)
    }
  
}
