# 0.2.0 validation — 2026-10-27

Repository: https://github.com/Weresan/12F-Virtual-Camera-Cld

Successful CI: https://github.com/Weresan/12F-Virtual-Camera-Cld/actions/runs/40510032235

Native source commit: ad5b65d41688daee82a10919b3adc5b4a8b1d68d

- Five Swift tests passed in Debug and five in Release (pairing and composition geometry).
- iPhone arm64 app compiled in Debug and Release.
- iPhone Simulator app compiled, installed, launched, captured a screenshot, and terminated successfully.
- Native screenshots visually inspected: INK #17243B background, blue accents, saved-workstation card and scan/link actions.
- Python suite: 23 passed, including optics interpolation, transport authentication, resampling, storage and recovery.
- Blender 4.4.3 and 5.2.0: take creation/review, animated lens/focus/aperture, original animation preservation passed.
- Blender 4.4.3 and 5.2.0 GUI GPU capture tests: three JPEGs per test, changing image with lens changes, original scene render settings preserved.

Unsigned app artifacts: https://github.com/Weresan/12F-Virtual-Camera-Cld/actions/runs/40510032235/artifacts/12736484255

The Debug IPA was downloaded to dist/12F-Virtual-Camera-0.2.0-Debug-unsigned.ipa for signing/installing using the user's existing sideload workflow. The add-on ZIP is available locally and in repository dist/12F-Virtual-Camera-0.2.0.zip.

This validates compilation and simulator home-screen launch, not physical ARKit or monitor gestures. The user previously reported successful phone-to-Blender camera movement on the earlier build. Updated phone live preview, pinch/pan, composition menus and latency still require physical acceptance. macOS Blender GPU capture is not tested.

Files changed: Swift CameraModel/HomeView/LiveCameraView; new CompositionGuide and tests; Xcode project/Info plists; CI simulator stage; Blender preview/core/server/adapter; Python/Blender tests; protocol notes and release guide. Initial CI issues in composition code/type inference and strict floating-point test comparison were corrected before this successful run.

Next acceptance: install both updated artifacts, reconnect via a fresh QR, verify actual scene preview, record a lens sweep, and scrub the selected recorded camera in Blender.
