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

public struct SVGReader1dot1: SVGReader {
    
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
            updatedModel.rect =  CGRect(x: CGFloat(values[0]), y: CGFloat(values[1]), width: CGFloat(values[2]), height: CGFloat(values[3]))
            return .success(updatedModel)
        }
        
        return .failure(.contentNotFound("svg viewBox tag not found!"))
    }
    
    func getPath(model: SVGModel) -> Result<SVGModel, SVGError> {
        
        let pathValues = model.content.substrings(between: pathTag, and: "\"")
        guard !pathValues.isEmpty else {
            return .failure(.contentNotFound("svg Path tag not found!"))
        }
        
        var updatedModel = model
        updatedModel.pathPointsString = pathValues.map{String($0)}
        return .success(updatedModel)
        
    }
    
    func getTransform(model: SVGModel) -> Result<SVGModel, SVGError> {
        
        if let transformValues = model.content.firstSubstring(between: transformTag, and: "\"") {
            var updatedModel = model
            updatedModel.transMatrixString = String(transformValues)
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
    
    func splitPathString(model: SVGModel) ->  Result<[[String]], SVGError> {
        var splits: [[String]] = []
        
        for pathString in model.pathPointsString {
            guard model.isFirstLetterM(pathString: pathString) else {
                return .failure(.convertFailed("Path string dose not start with M or m!!"))
            }
            splits.append(model.split(pathString: pathString))
        }
        
        return .success(splits)
        
    }
    
    func convertPathStringToSVGPaths(points: [[String]]) -> Result<[[SVGPath]], SVGError> {
        
        var offset = 0
        var paths: [[SVGPath]] = []
        
        
        for pp in points  {
            var onePath: [SVGPath] = []
            for p in pp {
                
                let first = p.first ?? " "
                
                if String(first).uppercased() == "M" {
                    guard let movePoint = getMoveToSVGPath(using: p) else {
                        return .failure(.convertFailed("MoveTo point missing X or Y corrdinates or values are not float!!"))
                    }
                    onePath.append(movePoint)
                }
                
                if String(first).uppercased() == "C" {
                    
                    guard let curvePoint = getCurveToSVGPath(using: p) else {
                        return .failure(.convertFailed("CurveTo points are smaller than 6 points or values are not float!!"))
                    }
                    
                    onePath.append(curvePoint)
                }
                
                if String(first).uppercased() == "L" {
                    
                    guard let linePoint = getLineToSVGPath(using: p) else {
                        return .failure(.convertFailed("LineTo point missing X or Y corrdinates or values are not float!!"))
                    }
                    onePath.append(linePoint)
                }
                
                offset += 1
            }
            paths.append(onePath)
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
        
        return SVGMoveTo(coordinates: [x,y])
    }
    
    func getCurveToSVGPath(using p: String) -> SVGPath? {
        
        let split =  p.dropFirst().replacingOccurrences(of: " ", with: ",").split(separator: ",")
        let points = split.map { Float($0) }.compactMap{$0}
        guard points.count == 6 else {
            return nil
        }
        
        return SVGCurveTo(coordinates: points)
    }
    
    func getLineToSVGPath(using p: String) -> SVGPath? {
        
        let split = p.dropFirst().split(separator: ",")
        guard split.count == 2 else {
            return nil
        }
        
        guard let x = Float(split[0]), let y = Float(split[1]) else {
            return nil
        }
        
        return SVGLineTo(coordinates: [x,y])
    }
    
    func convertToLocalCorrdinates(model: SVGModel) -> SVGModel {
        
        guard !model.transMatrixString.isEmpty else {
            return model
        }
        
        if let matrix = getTranslateMatrix(model: model) {
            var updatedModel = model
            updatedModel.translateMatrix = matrix
            return applyTranslation(for: updatedModel)
        }
        
        return model
        
    }
    
    func getTranslateMatrix(model: SVGModel) -> simd_float3x3? {
        
        if model.transMatrixString.contains("matrix") {
            if let transformMatrix = model.content.firstSubstring(between: matrixTag, and: ")") {
                let points = transformMatrix.split(separator: ",").compactMap{Float($0)}
                
                if points.count == 6 {
                    var matrix3x3 = matrix_identity_float3x3
                    matrix3x3[2,0] = points[4]
                    matrix3x3[2,1] = points[5]
                    return matrix3x3
                }
            }
        }
        
        return nil
    }
    
    func applyTranslation(for model: SVGModel) -> SVGModel {
        
        guard let matrix = model.translateMatrix else {
            return model
        }
        
        
       // var transformedPathsx = model.paths
        var updatedModel = model
        
        updatedModel.paths =  model.paths.map { paths  in
            return paths.map { svgPath in
                svgPath.points = svgPath.points.map { point in
                    let newPositionVector = matrix * simd_float3(Float(point.x), Float(point.y), 1)
                    return CGPoint(x: CGFloat(newPositionVector[0]) / model.rect.width, y: CGFloat(newPositionVector[1]) / model.rect.height)
                }
                return svgPath
            }
        }
        
        /*for path in model.paths {
            for n in 0..<path.count {
                for z in 0..<path[n].points.count {
                    let newPositionVector = matrix * simd_float3(Float(path[n].points[z].x), Float(path[n].points[z].y), 1)
                    
                    path[n].points[z] = CGPoint(x: CGFloat(newPositionVector[0]) / model.rect.width, y: CGFloat(newPositionVector[1]) / model.rect.height)
                }
            }
        }*/
        
        //var updatedModel = model
        //updatedModel.paths = transformedPathsx
        
        return updatedModel
    }
    
    
    
    
    
}
