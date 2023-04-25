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
                "ShareFeature",
                "MakePromise",
                "PromiseManagement",
                "LoginFeature",
                "SwiftUIHelper",
                "Entity",
                "PromiseTimeDetailFeature"
            ]
        ),
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "CalendarFeature",
            targets: ["CalendarFeature"]
        ),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(
            name: "CommonView",
            targets: ["CommonView"]
        ),
        .library(
            name: "HomeContainerFeature",
            targets: ["HomeContainerFeature"]
        ),
        .library(
            name: "HomeFeature",
            targets: ["HomeFeature"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            branch: "navigation-beta"
        ),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.1.4"),
        .package(url: "https://github.com/devxoul/Then.git", from: "3.0.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.14.0"),
        .package(url: "https://github.com/Team-Planz/Planz-iOS-Secrets.git", branch: "main"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "8.10.0")
    ],
    targets: [
        .target(
            name: "APIClient",
            dependencies: [
                "Entity",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "APIClientLive",
            dependencies: [
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "KakaoSDK", package: "kakao-ios-sdk"),
                .product(name: "Planz-iOS-Secrets", package: "Planz-iOS-Secrets")
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "DesignSystem",
                "HomeContainerFeature",
                "LoginFeature",
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
            name: "DesignSystem",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CommonView",
            dependencies: [
                "DesignSystem",
                "SwiftUIHelper",
                "SharedModel",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "CalendarFeature",
            dependencies: [
                "DesignSystem",
                "Entity",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Introspect", package: "SwiftUI-Introspect")
            ]
        ),
        .target(
            name: "ShareFeature",
            dependencies: [
                "DesignSystem",
                "Repository",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "APIClient",
                .product(name: "Planz-iOS-Secrets", package: "Planz-iOS-Secrets")
            ]
        ),
        .target(
            name: "MakePromise",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "CalendarFeature",
                "TimeTableFeature"
            ]
        ),
        .target(
            name: "PromiseManagement",
            dependencies: [
                "DesignSystem",
                "CommonView",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "APIClient",
                "APIClientLive",
                "SharedModel"
            ]
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "APIClient",
                "APIClientLive"
            ]
        ),
        .target(
            name: "HomeContainerFeature",
            dependencies: [
                "DesignSystem",
                "MakePromise",
                "HomeFeature",
                "CalendarFeature",
                "TimeTableFeature",
                "SwiftUIHelper",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "DesignSystem",
                "CalendarFeature",
                "CommonView",
                "SharedModel",
                "APIClient",
                "APIClientLive",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Introspect", package: "SwiftUI-Introspect")
            ]
        ),
        .target(name: "SwiftUIHelper"),
        .target(name: "Entity"),
        .target(
            name: "PromiseTimeDetailFeature",
            dependencies: [
                "DesignSystem",
                "TimeTableFeature",
                "SwiftUIHelper",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "SharedModel",
            dependencies: [
                "Entity"
            ]
        ),
        .target(
            name: "Repository",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
                .product(name: "KakaoSDK", package: "kakao-ios-sdk"),
                .product(name: "Planz-iOS-Secrets", package: "Planz-iOS-Secrets")
            ]
        )
    ]
)
