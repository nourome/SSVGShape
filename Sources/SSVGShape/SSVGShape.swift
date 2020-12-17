import SwiftUI

public struct SSVGShape<R: SVGReader>: Shape {

    private let paths: [[SVGPath]]
    let reader: R

    public init(reader: R) {
        self.reader = reader
        let result = reader.parse()

        switch result {
        case .success(let path):
            paths = path
        case .failure(let error):
            print(error)
            fatalError("SVG file parsing failed")
        }
    }

    public func path(in rect: CGRect) -> Path {
        Path { path in
            for onePath in paths {
                for apath in onePath {
                    apath.draw(path: &path, rect: rect)
                }
            }
        }
    }
}
