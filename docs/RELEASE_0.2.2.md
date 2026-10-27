# 0.2.2: landscape tracking guard and app icon

The monitor remains a landscape operating interface. Scanning a QR in portrait no longer calibrates the tracking origin immediately. A physical landscape hold must settle for half a second before the first normal ARKit pose triggers recentering. This uses physical device orientation, independently of the interface rotation request.

Portrait, upside-down, flat or unknown device orientation pauses pose application by reporting lost tracking and stops an active take. Returning to either landscape side waits for a stable hold and recalibrates. A take never resumes automatically; start a new recording deliberately. Switching landscape sides also pauses and recalibrates. Intentional portrait shooting and continuous roll through portrait are not supported by this guard; a future explicit portrait operating mode needs its own camera basis and framing policy.

ARKit's raw camera basis remains fixed with respect to device orientation. We preserve its raw transform rather than dynamically swapping quaternion axes with UI rotation. Reference: https://developer.apple.com/documentation/arkit/arcamera/transform

Added the opaque 1024-pixel blue aperture app icon, an Xcode asset catalog resource and AppIcon build setting. Generator is deterministic and uses no added dependencies.

Files: CameraModel.swift, LiveCameraView.swift, TrackingOrientation.swift and tests, Info plists, Package.swift, Xcode project, Assets.xcassets, project/icon generators.

Validation: local Xcode project structure and Debug/Release policy checks pass. Native CI results are recorded separately after completion. Physical portrait-to-landscape handoff and icon installation need iPhone acceptance.

Recommended next work, in priority order: configurable horizon/roll lock with portrait mode; adaptive preview quality and latency diagnostics; take browser with rename/review/retake; separate stabilization controls with preserved raw takes; focus peaking and zebra exposure overlays based on preview image values. These are proposals, not implemented features.

