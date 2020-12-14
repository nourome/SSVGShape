

import SwiftUI

struct SSVGShape<R: SVGReader>: Shape {
    
    private let paths: [SVGPath]
    let reader: R
    
    init(reader: R) {
        self.reader = reader
        let result = reader.parse()
        
        switch result {
        case .success(let p):
            paths = p
        case .failure(let error):
            fatalError("Error \(error.localizedDescription)")
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            for path in paths {
                path.draw(p: &p)
            }
        }
    }
    
}
