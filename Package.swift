// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Bitfield",
    products: [
        .library(
            name: "Bitfield",
            targets: ["Bitfield"]
        ),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit", .upToNextMinor(from: "0.3.1"))
    ],
    targets: [
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "BitfieldMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "Bitfield", dependencies: ["BitfieldMacros"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "BitfieldTests",
            dependencies: [
                "BitfieldMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .executableTarget(
            name: "BitfieldClient",
            dependencies: [
                "Bitfield",
            ]
        ),
    ]
)
