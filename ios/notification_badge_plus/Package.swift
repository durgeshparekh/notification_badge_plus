// swift-tools-version: 5.0
// Swift Package Manager support for notification_badge_plus
// This Package.swift file enables Swift Package Manager (SPM) support for iOS
// Created to meet pub.dev package scoring requirements for SPM compatibility
import PackageDescription

let package = Package(
    name: "notification_badge_plus",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "notification_badge_plus",
            targets: ["notification_badge_plus"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "notification_badge_plus",
            path: "../Classes",
            exclude: [],
            sources: ["."],
            publicHeadersPath: nil,
            cSettings: [],
            cxxSettings: [],
            swiftSettings: [
                .define("DEFINES_MODULE")
            ],
            linkerSettings: []
        ),
    ]
)

