# First remote iOS build — 2026-10-27

Private repository: https://github.com/Weresan/12F-Virtual-Camera

Successful run: https://github.com/Weresan/12F-Virtual-Camera/actions/runs/40482870132

Source commit: 59f9faf389daa5792f8ebb27248aacf2fdfa7b23

Environment: GitHub-hosted macOS 15.7.9 arm64; Xcode 16.4; iPhoneOS 18.5 SDK; deployment target iOS 16.

Results:
- Swift XCTest pairing parser: 3 tests passed in Debug, 3 in Release; zero failures.
- Full native app: Debug iPhone arm64 build succeeded without signing.
- Full native app: Release iPhone arm64 build succeeded without signing.
- Two unsigned app ZIPs packaged into artifact 12F-iOS-unsigned-apps (ID 12724081284).

Artifact: https://github.com/Weresan/12F-Virtual-Camera/actions/runs/40482870132/artifacts/12724081284

GitHub artifact retention ends November 3, 2026. The artifact contains unsigned app bundles and cannot be installed directly on an iPhone. Signing and physical-device acceptance remain required. Camera permissions, physical QR scanning, ARKit tracking and phone-to-Blender latency have not been tested by this run. Simulator/UI runtime tests were not run.

The repository initially contains only the iOS app, protocol, workflow and setup instructions; the complete Blender source remains in the local project. No recordings, certificates or pairing credentials were uploaded.

Non-blocking observations: the runner reports deprecated Node runtime targets for the v4 GitHub actions; Xcode reports iPad orientation completeness and no AppIntents dependency. These did not prevent compilation. The build uses Xcode 16.4; a signing/TestFlight milestone must validate current submission SDK requirements separately.

Next: resolve Apple enrollment/signing, configure signed distribution, and validate QR pairing and physical ARKit motion on an iPhone.
