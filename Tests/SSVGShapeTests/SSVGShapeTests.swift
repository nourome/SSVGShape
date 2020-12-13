import XCTest
@testable import SSVGShape

final class SSVGShapeTests: XCTestCase {
    let svgReader = SVGReader()
    
    func testParseSvgFile() {
        XCTAssertEqual(SSVGShape().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
