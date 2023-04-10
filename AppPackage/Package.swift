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
                "Entity"
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
        .package(url: "https://github.com/Team-Planz/Planz-iOS-APIClient.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.6.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "8.10.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.14.0"),
        .package(url: "https://github.com/Team-Planz/Planz-iOS-Secrets", branch: "main")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "DesignSystem",
                "HomeContainerFeature",
                "LoginFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation")
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
                .product(name: "APIClient", package: "Planz-iOS-APIClient"),
                .product(name: "Planz-iOS-Secrets", package: "Planz-iOS-Secrets")
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
            name: "PromiseManagement",
            dependencies: [
                "DesignSystem",
                "CommonView",
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "DesignSystem",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "APIClient", package: "Planz-iOS-APIClient")
            ]
        ),
        .target(
            name: "HomeContainerFeature",
            dependencies: [
                "DesignSystem",
                "MakePromise",
                "HomeFeature",
                "CalendarFeature",
                "SwiftUIHelper",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation")
            ]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "DesignSystem",
                "CalendarFeature",
                "CommonView",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                .product(name: "Introspect", package: "SwiftUI-Introspect")
            ]
        ),
        .target(name: "SwiftUIHelper"),
        .target(name: "Entity"),
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
