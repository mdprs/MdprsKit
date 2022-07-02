// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "mdprsKit",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "mdprsKit",
      targets: ["mdprsKit"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/JohnSundell/Ink", from: "0.5.1"),
    .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
    .package(url: "https://github.com/JohnSundell/Sweep", from: "0.4.0"),
    .package(url: "https://github.com/stencilproject/Stencil", from: "0.14.2"),
    .package(url: "https://github.com/httpswift/swifter", from: "1.5.0"),

    // -- Testing --
    .package(url: "https://github.com/Quick/Quick", from: "5.0.0"),
    .package(url: "https://github.com/Quick/Nimble", from: "10.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "mdprsKit",
      dependencies: [
        "Files",
        "Ink",
        "Stencil",
        "Sweep",
        .product(name: "Swifter", package: "swifter"),
      ],
      resources: [
        .copy("reveal.js")
      ]),
    .testTarget(
      name: "mdprsKitTests",
      dependencies: [
        "Quick",
        "Nimble",
        "Sweep",
        "mdprsKit",
      ],
      resources: [
        .copy("testdata")
      ]),
  ]
)
