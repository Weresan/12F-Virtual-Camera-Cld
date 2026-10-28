# 0.2.5 validation

Native source commit: `fa6188555bb1e8082dfb09df6d82efca4ffba0d4`.

[Native CI run](https://github.com/Weresan/12F-Virtual-Camera-Cld/actions/runs/40656829205) succeeded: nine Swift tests per configuration, Debug/Release iPhone builds, simulator build/install/launch/screenshot. Downloaded IPA archive integrity, version 0.2.5 build 7 and icon verified.

35 Python tests passed. New cases cover brief tracking recovery, sustained tracking loss, delayed queue delivery and derived holds for short network gaps while preserving raw samples. Existing transport, authorization, take review, motion and optical tests pass.

Node buffer tests passed for four-download concurrency limit, decoded-frame prefetch, seek eviction, bounded cache and resource cleanup. Monitor JS syntax passed. Chrome using real generated GPU test proxies loaded the canvas player at 30 fps proxy rate, played and scrubbed. Screenshot: `12F-0.2.5-buffered-review.png`. This verifies the playback path, not sustained throughput on the artist's tablet.

Blender 4.4 and 5.2 factory-startup smoke checks passed. An active take remained recording through a limited sample, held position for that sample, retained raw quality and hold/recovery events, and saved the supplied stop reason. Sustained bad tracking still required recenter. Original source animation was preserved. An isolated Blender 5.2 GUI test generated two complete changing 30 fps JPEG proxies and served them to authenticated viewers while preserving the shared camera and timeline.

Files: native tracking model/state/tests/plists, new health.py, core gap processing, Blender adapter/settings, proxy sampling/generation, new browser review-buffer.js and canvas player, regression tests, packaging and release documentation.

Limits: physical ARKit interruptions and actual tablet Wi-Fi 30/60 fps playback remain unmeasured. Continuing tracking loss, disconnect/background, explicit stop/recenter and unrecoverable filesystem errors can still end a take. Live preview backs off during recording to prioritize samples. Higher-rate proxies need more preparation/storage; long takes remain bounded to 3600 samples. Restart the connection and refresh the browser to rebuild old 10 fps proxies.

Next: install both 0.2.5 packages, rebuild a take proxy, test a longer move and record the displayed stop reason if an unexpected stop recurs.
