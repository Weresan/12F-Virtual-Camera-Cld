# 0.2.4 validation

Native source commit: `e05282b3099fdca781b6426ef4ecb0bace1a3101`.

[Native CI run](https://github.com/Weresan/12F-Virtual-Camera-Cld/actions/runs/40568147880) succeeded. Eight Swift tests passed in Debug and eight in Release. Full Debug/Release iPhone builds and simulator compilation/install/launch/screenshot passed. Downloaded Debug IPA integrity, version 0.2.4 build 6 and embedded AppIcon verified.

32 Python tests passed, including proxy sampling limits/full-duration coverage, authenticated frame access, denied operator-token access to monitor frames, independent viewer requests, shared-stream suppression/resume and previous transport/recording tests. Browser JS syntax passed.

Isolated Blender 5.2 GUI test generated two changing JPEG review proxies and served them through authenticated HTTP to separate viewers. Shared camera/frame/subframe and original source Action remained unchanged after preparation. Blender 4.4 passed the same test on rerun, including paused-preparation behavior. One initial 4.4 run closed the viewer connection with code 1008; the cause was not established and the failure did not recur on the diagnostic rerun. Debug exception logging was added; hardware/network acceptance remains necessary.

Chrome UI checks using generated GPU test proxies verified take selection, playback to the final frame, scrubbing, preferred marking across reload, different take selection in a second tab without disturbing the first, and return to the shared feed. Screenshot: `12F-0.2.4-independent-review.png`. These are isolated test takes, not artist recordings or a throughput benchmark.

Files changed: native activation model, portrait layout, orientation tests/plists; Blender review plan/GPU proxy generator, adapter and transport; browser monitor; unit/GPU tests; packaging, release and protocol documentation.

Limitations: independent previews use up to 10 fps/480-pixel width and 600 samples; first-watch preparation costs GPU time and waits during recording/shared playback. Cache snapshots persist and require server restart to refresh after animation edits. Preferred marks are local browser data. Physical portrait/landscape sensor alignment, actual Wi-Fi behavior and sustained live 60 FPS remain unverified by the development agent.

Next acceptance task: sideload 0.2.4, install the updated add-on, pair in portrait and tap to activate, record a move, and review different takes from two devices.
