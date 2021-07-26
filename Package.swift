// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FusionBluetooth",
    platforms: [.macOS(.v10_14), .iOS(.v12)],    
    products: [
        .library(
            name: "FusionBluetooth",
            targets: ["FusionBluetooth"]),
    ],
    dependencies: [
        .package(name: "Android", url: "https://github.com/scade-platform/swift-android.git", .branch("android/24"))        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FusionBluetooth",
            dependencies: [
              .target(name: "FusionBluetooth_Common"),              
              .target(name: "FusionBluetooth_Apple", condition: .when(platforms: [.iOS, .macOS])),
              .target(name: "FusionBluetooth_Android", condition: .when(platforms: [.android])),
            ]
        ),
        .target(
            name: "FusionBluetooth_Common"
        ),  
        .target(
            name: "FusionBluetooth_Apple",
            dependencies: [
              .target(name: "FusionBluetooth_Common"),
            ]                        
        ),
        .target(
            name: "FusionBluetooth_Android",
            dependencies: [
              .target(name: "FusionBluetooth_Common"),
              .product(name: "Android", package: "Android", condition: .when(platforms: [.android])),
              .product(name: "AndroidApp", package: "Android", condition: .when(platforms: [.android])),
              .product(name: "AndroidOS", package: "Android", condition: .when(platforms: [.android])),
              .product(name: "AndroidBluetooth", package: "Android", condition: .when(platforms: [.android]))              
            ],
            resources: [.copy("Generated/BluetoothReceiver.java")]         
        )
    ]
)

