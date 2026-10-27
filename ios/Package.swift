// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "PairingCore", platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "PairingCore", targets: ["PairingCore"])],
    targets: [
        .target(name: "PairingCore", path: "VirtualCamera",
            exclude: ["CameraModel.swift", "ContentView.swift", "VirtualCameraApp.swift", "SavedComputer.swift", "HomeView.swift", "LiveCameraView.swift", "Info.plist", "Info-Debug.plist", "Assets.xcassets"],
            sources: ["PairingEndpoint.swift", "CompositionGuide.swift", "TrackingOrientation.swift"]),
        .testTarget(name: "PairingCoreTests", dependencies: ["PairingCore"], path: "Tests")
    ])
