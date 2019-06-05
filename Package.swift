// swift-tools-version:5.1

import PackageDescription

// Is this going to be required for anyone using swift-syntax? (Also, I
// tried to use linkerSettings, but that caused the flags to be passed
// *both* with *and* without -Xlinker prefixes to swiftc. SwiftPM bug?
let rpathSettings = [SwiftSetting.unsafeFlags([
  "-Xlinker",
  "-rpath",
  "-Xlinker",
  "/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx",
])]

let package = Package(
  name: "SwiftSyntaxRepros",
  products: [
    .executable(name: "BrokenVisitor", targets: ["BrokenVisitor"]),
    .executable(name: "RewritePipeline", targets: ["RewritePipeline"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-syntax.git",
      .revision("xcode11-beta1")
    )
  ],
  targets: [
    .target(
      name: "BrokenVisitor",
      dependencies: ["SwiftSyntax"],
      swiftSettings: rpathSettings
    ),
    .target(
      name: "RewritePipeline",
      dependencies: ["SwiftSyntax"],
      swiftSettings: rpathSettings
    ),
  ]
)
