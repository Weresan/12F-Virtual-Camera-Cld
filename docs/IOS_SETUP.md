# Native iPhone app and QR pairing

## What is ready

Source code for SwiftUI controls, VisionKit QR scanning, ARKit 6DoF poses, Core Motion diagnostics, authenticated WebSocket pairing and tracking/interruption handling. Blender 0.1.2 generates an additional local PNG and displays the QR in its sidebar as well as the desktop pairing page. The native app automatically accepts a detected QR, closes the scanner to release the camera, connects, requests tracking permission and recenters the first normal tracking pose. Later tracking loss still requires Recenter.

Native scanning requires a VisionKit-supported physical device. Paste the full pairing URL on devices without the scanner. The standard iPhone Camera opens the current URL in Safari; it does **not** launch this app. Universal links/deep links are not implemented. Open **12F Virtual Camera → Scan QR** inside the installed app instead. The app scans a code displayed by Blender; Blender does not scan the phone.

## Windows-only development

This repository contains an Xcode project, not an installable IPA. Apple-platform compilation and signing require a Mac environment. You can keep working from Windows and use a remote Mac build, but a source ZIP or unsigned app bundle cannot be installed directly on your iPhone.

The included `.github/workflows/ios-build.yml` is manually triggered on a macOS runner. Once this repository is hosted in your own GitHub repository, run **Actions → iOS compile and pairing tests → Run workflow**. It runs Swift pairing tests in Debug/Release and compiles both app configurations without signing. No workflow was uploaded or run from this environment. GitHub Actions availability and usage depend on your account. The resulting artifacts are **unsigned app bundles for validation, not installable apps**.

The next distribution milestone needs an Apple signing identity, a matching bundle ID/provisioning profile, and either registered test-device distribution or TestFlight. TestFlight distribution requires Apple Developer Program access and an App Store Connect app. Credentials should be configured through the build service's secrets UI, never committed. No signing credentials, paid service, account enrollment or external repository was created here.

## On a Mac or remote Mac

1. Open `ios/VirtualCamera.xcodeproj`, select scheme **VirtualCamera**, choose a unique bundle identifier if necessary, and set your signing team in Signing & Capabilities. The project targets iPhone/iPad, iOS 16+.
2. For local development with the existing HTTP Blender server, build **Debug**. In the app explicitly enable **Allow unencrypted LAN development connection**. This accepts only private numeric LAN IPv4 hosts (10/8, 172.16/12, 192.168/16). This is unencrypted development transport. The broader ATS exception exists only in the Debug plist. Release builds reject HTTP even if the setting is enabled in code.
3. For production **Release**, configure a trusted HTTPS certificate in Blender and on the device, then scan its HTTPS QR. The app retains system certificate verification; no trust bypass is implemented.
4. Build/install a signed app on the physical phone using the chosen distribution method. Grant camera and local-network permissions, and motion permission if requested. Keep both devices on the same Wi-Fi.
5. Close any browser controller occupying the operator slot. Start Blender's server, open the iPhone app, tap **Scan QR**, and point it at Blender's sidebar QR or the desktop QR page. The app connects after dismissing the scanner. Move in a well-lit room with visual detail. Once tracking is normal, test physical movement, Recenter, Record and Stop. Monitoring remains snapshot-based.
6. If local-network permission rejects the first connection while the permission dialog is shown, allow access and tap Connect again. On backgrounding, the app stops its tracking session; reconnect explicitly.

Pure Swift parser tests: `cd ios`, then `swift test` and `swift test -c release`. These tests are supplied but not run on this Windows host. Complete app compilation and physical ARKit acceptance are also pending.

## Validation in this milestone

Python structural checks cover unique/resolved Xcode object identifiers, all Swift source references, and separation of Debug/Release networking policy. A duplicate-identifier defect in the original generated project was corrected. PNG tests cover QR image pixels, dimensions and checksums. Blender smoke tests load the generated QR PNG through Blender's preview system. None of those checks substitutes for Xcode compilation or a physical scan.
