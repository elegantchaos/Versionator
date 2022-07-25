// swift-tools-version: 5.6

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "Versionator",
    platforms: [
        .macOS(.v10_13)
    ],

    products: [
        .plugin(
            name: "VersionatorPlugin",
            targets: [
                "VersionatorPlugin"
            ]
        )
    ],
    
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner.git", from: "1.3.1")
    ], 
    
    targets: [
        .plugin(
            name: "VersionatorPlugin",
            capability: .buildTool(),
            dependencies: [
                "VersionatorTool"
            ]
        ),

        .executableTarget(
            name: "VersionatorTool",
            dependencies: [
                .product(name: "Runner", package: "Runner")
            ]
        ),
        
    ]
)
