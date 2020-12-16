//
//  File.swift
//  
//
//  Created by Nour on 13.12.2020.
//

import Foundation

public enum SVGError: Error, Equatable {
    case parsingError(String)
    case readingFileError(String)
    case contentNotFound(String)
    case convertFailed(String)
    case fatalError(String)
}
