// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppPackage",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "AppPackage",
            targets: [
                "AppPackage",
                "TimeTableFeature",
                "Calendar",
                "APIClient"
            ]
        ),
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.50.0"),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.1.4"),
        .package(url: "https://github.com/devxoul/Then.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "AppPackage",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Introspect", package: "SwiftUI-Introspect"),
                .product(name: "Then", package: "Then")
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "TimeTableFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DesignSystem"
        ),
        .target(
            name: "Calendar",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Introspect", package: "SwiftUI-Introspect")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
