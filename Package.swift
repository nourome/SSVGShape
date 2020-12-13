// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSVGShape",
    platforms: [
            .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SSVGShape",
            targets: ["SSVGShape"]),
    ],
    dependencies: [
        .package(
                   url: "https://github.com/JohnSundell/Sweep",
                   from: "0.4.0"
               )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SSVGShape",
            dependencies: ["Sweep"]),
        .testTarget(
            name: "SSVGShapeTests",
            dependencies: ["SSVGShape"],
            resources: [
                .copy("Resources/test.svg")
            ]),
    ]
)
