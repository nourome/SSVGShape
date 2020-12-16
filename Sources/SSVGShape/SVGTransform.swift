//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//

import Foundation
import simd
import Sweep

class SVGTransform {
    var matrix: simd_float3x3? = nil
    private let matrixTag: Identifier = "matrix("

    init(matrix: String) {
        self.matrix = parseMatrix(str: matrix)
    }
    
    private func parseMatrix(model: SVGModel) -> simd_float3x3? {
            if model.matrixString.contains("matrix") {
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
    
    private func parseMatrix(str: String) -> simd_float3x3? {
            if str.contains("matrix") {
                if let transformMatrix = str.firstSubstring(between: matrixTag, and: ")") {
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
    
    func apply(for model: SVGModel) -> SVGModel {
        return model
    }
    
    func apply(svgPath: SVGPath, rect: CGRect) -> SVGPath {
        return svgPath
    }
}

class SVGTranslate: SVGTransform {
    override func apply(for model: SVGModel) -> SVGModel {
        
        guard let matrix = matrix else {
            return model
        }
        
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
        
        return updatedModel
    }
    
    override func apply(svgPath: SVGPath, rect: CGRect) -> SVGPath {
        
        guard let matrix = matrix else {
            return svgPath
        }
                
        svgPath.points = svgPath.points.map { point in
                    let newPositionVector = matrix * simd_float3(Float(point.x), Float(point.y), 1)
                    return CGPoint(x: CGFloat(newPositionVector[0]) / rect.width, y: CGFloat(newPositionVector[1]) / rect.height)
                }
               
        return svgPath
    }
}
