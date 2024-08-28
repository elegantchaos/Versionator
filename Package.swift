// swift-tools-version: 5.6

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
  name: "Versionator",
  platforms: [
    .macOS(.v12)
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
    .package(url: "https://github.com/elegantchaos/Runner.git", from: "2.0.4")
  ],

  targets: [
    .target(name: "VersionatorUtils"),

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
        "VersionatorUtils",
        .product(name: "Runner", package: "Runner"),
      ]
    ),

    .testTarget(
      name: "VersionatorTests",
      dependencies: [
        "VersionatorTool",
        "VersionatorUtils",
        .product(name: "Runner", package: "Runner"),
      ]
    ),

  ]
)
