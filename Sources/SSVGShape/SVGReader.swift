//
//  File.swift
//  
//
//  Created by Nour on 14.12.2020.
//

import Foundation

public protocol SVGReader {
    var filePath: String {get set}
    func parse() -> Result<[SVGPath], SVGError>
}
