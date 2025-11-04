// swift-tools-version: 6.2

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackageDescription

let package = Package(
  name: "Versionator",
  platforms: [
    .macOS(.v26),
    .custom("Ubuntu", versionString: "22.04"),  // uncommenting this causes ActionBuilder to create a Linux job
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
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.2.1")
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
        .product(name: "Subprocess", package: "swift-subprocess"),
      ]
    ),

    .testTarget(
      name: "VersionatorTests",
      dependencies: [
        "VersionatorTool",
        "VersionatorUtils",
        .product(name: "Subprocess", package: "swift-subprocess"),
      ],
      resources: [
        .copy("Resources/Example.git"),
        .copy("Resources/Example.out"),
      ]
    ),

  ]
)
