// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AppPackage",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "AppPackage",
            targets: [
                "TimeTableFeature",
                "Share",
                "MakePromise",
                "LoginFeature"
            ]
        ),
        .library(
            name: "CalendarFeature",
            targets: ["CalendarFeature"]
        ),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(
            name: "HomeFeature",
            targets: ["HomeFeature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.50.0"),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.1.4"),
        .package(url: "https://github.com/devxoul/Then.git", from: "3.0.0"),
        .package(url: "https://github.com/Team-Planz/Planz-iOS-APIClient.git", branch: "main")
    ],
    targets: [
        .target(
            name: "TimeTableFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "DesignSystem",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CalendarFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Introspect", package: "SwiftUI-Introspect")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "Share",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .target(
            name: "MakePromise",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "APIClient", package: "Planz-iOS-APIClient")
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
