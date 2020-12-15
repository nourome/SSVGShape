

import SwiftUI

public struct SSVGShape<R: SVGReader>: Shape {
    
    private let paths: [SVGPath]
    let reader: R
    
    public init(reader: R) {
        self.reader = reader
        let result = reader.parse()
        
        switch result {
        case .success(let p):
            paths = p
        case .failure(let error):
            print(error)
            fatalError("SVG file parsing failed")
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        Path { p in
            for path in paths {
                path.draw(p: &p, rect: rect)
            }
        }
    }
}
