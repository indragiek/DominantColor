// swift-tools-version:5.0

/**
 *  DominantColor
 *  Copyright (c) Indragie Karunaratne 2021
 *  See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "DominantColor",
    platforms: [
       .macOS(.v10_13),
       .iOS(.v11),
       .tvOS(.v11)
    ],
    products: [
        .library(name: "DominantColor", targets: ["DominantColor"]),
        .library(name: "DominantColor_Dynamic", type: .dynamic, targets: ["DominantColor"]),
    ],
    targets: [
        .target(
            name: "DominantColor",
            path: "DominantColor/Shared"
        ),
    ]
)
