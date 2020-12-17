//
//  File.swift
//  
//
//  Created by Nour on 16.12.2020.
//

import Foundation
import simd
import Sweep
import CoreGraphics

class SVGTransform {
    var matrices: [simd_float3x3?] = []
    private let matrixTag: Identifier = "matrix("

    init(matrices: [String]) {
        self.matrices = parseMatrix(matricesStr: matrices)
    }

    func parseMatrix(matricesStr: [String]) -> [simd_float3x3?] {

        return matricesStr.filter {$0.contains("matrix")}.map { str -> simd_float3x3? in
            guard  let transformMatrix = str.firstSubstring(between: matrixTag, and: ")") else {
                return nil

            }
                let points = transformMatrix.split(separator: ",").compactMap {Float($0)}
                guard points.count == 6 else {
                    return nil
                }

                var matrix3x3 = matrix_identity_float3x3
                matrix3x3[0, 0] = points[0]
                matrix3x3[0, 1] = points[1]
                matrix3x3[1, 0] = points[2]
                matrix3x3[1, 1] = points[3]
                matrix3x3[2, 0] = points[4]
                matrix3x3[2, 1] = points[5]
                return matrix3x3

        }.compactMap {$0}

    }

    func apply(svgPath: SVGPath, rect: CGRect) -> SVGPath {

        guard !matrices.isEmpty else {
            return svgPath
        }

        svgPath.points = svgPath.points.map { point in
            let newPositionVector = matrices.compactMap {$0}
                .reduce(matrix_identity_float3x3, { result, mats -> simd_float3x3 in
                result * mats
            }) * simd_float3(Float(point.x), Float(point.y), 1)

            return CGPoint(x: CGFloat(newPositionVector[0]) / rect.width,
                           y: CGFloat(newPositionVector[1]) / rect.height)
        }

        return svgPath
    }
}
