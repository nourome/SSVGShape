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
            let values =  viewBoxRect.split(separator: " ").map {Float($0)}.compactMap {$0}
            guard values.count == 4 else {
                return .failure(.contentNotFound("svg viewBox Rectangle (x y width height) not found!"))
            }
            var updatedModel = model
            let vCGFloat = values.map {CGFloat($0)}
            updatedModel.rect =  CGRect(x: vCGFloat[0], y: vCGFloat[1], width: vCGFloat[2], height: vCGFloat[3])
            return .success(updatedModel)
        }

        return .failure(.contentNotFound("svg viewBox tag not found!"))
    }

    func buildSVGTree(model: SVGModel) -> Result<SVGModel, SVGError> {

        var previousChar = ""
        var transforms: [String] = []
        var updatedModel = model

        guard let content = stripHeaderTags(for: model.content) else {
            return .failure(.contentNotFound("failed to build svg tree, make sure it is valid svg file"))
        }

        for (offset, char) in content.enumerated() {

            if let transformMatrix = getTransformMatrixTag(for: char, with: previousChar, from: content, by: offset) {
                transforms.append(String(transformMatrix))
            }

            if let path = getPathTag(for: char, with: previousChar, from: content, by: offset) {
                updatedModel.svgTree.append(SVGElement(pathStr: "p" + String(path), transformStr: transforms))
            }

            if isEndOfGroupTag(char: char, previousChar: previousChar) {
                transforms.removeLast()
            }

            previousChar = char.lowercased()
        }

        return .success(updatedModel)

    }

    func stripHeaderTags(for content: String) -> String? {
        
        guard let stripped = content.firstSubstring(between: "<g", and: "</svg>") else {
            guard let pathToSVg = content.firstSubstring(between: "<path", and: "</svg>") else{
                return nil
            }
            return "<path" + String(pathToSVg)
        }

        return "<g " + String(stripped)
    }

    func getTransformMatrixTag(for char: Character, with previousChar: String,
                               from content: String, by offset: Int) -> Substring? {

        if char.lowercased() == "g" &&  previousChar == "<" {
            let subStr = content[content.index(content.startIndex, offsetBy: offset)..<content.endIndex]
            return subStr.firstSubstring(between: "g", and: ">")
        }

        return nil

    }

    func getPathTag(for char: Character, with previousChar: String,
                    from content: String, by offset: Int) -> Substring? {

        if char.lowercased() == "p" &&  previousChar == "<" {
            let subStr = content[content.index(content.startIndex, offsetBy: offset)..<content.endIndex]
            return subStr.firstSubstring(between: "p", and: "/>")
        }

        return nil
    }

    func isEndOfGroupTag(char: Character, previousChar: String) -> Bool {
        return char.lowercased() == "g" &&  previousChar == "/"
    }

    func getSVGPaths(model: SVGModel) ->  Result<SVGModel, SVGError> {

        guard !model.svgTree.isEmpty else {
            return .failure(.contentNotFound("failed to get svg path, make sure it is valid svg file"))
        }

        var updatedModel = model
        updatedModel.paths  = model.svgTree.map { element -> [SVGPath] in
            guard let transform = element.transforms else {return element.path}
            return element.path.map { path in
                transform.apply(svgPath: path, rect: model.rect)
            }
        }.compactMap {$0}

        return .success(updatedModel)

    }

}
