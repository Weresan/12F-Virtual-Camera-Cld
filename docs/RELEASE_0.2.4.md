# 0.2.4: independent review and tap-to-activate tracking

## Activate tracking deliberately

After pairing, hold the phone in portrait or landscape and tap **Tap to activate camera**. ARKit must report normal tracking first. The first pose after activation recenters at the current Blender live-camera transform. No motion is applied before activation. Recenter chooses a fresh basis and ends any active recording. Tracking loss also ends recording and requires another tap after recovery; it does not silently resume a take.

The camera basis is the inverse ARCamera view matrix for the interface orientation corresponding to the physical hold at activation. It stays fixed until reactivation, independently of later screen layout rotation. Rotating the phone after activation is real camera roll, not an automatic axis swap or auto-level operation. To adopt a different hold as neutral, tap Recenter. Phone orientation does not change the Blender shot's render aspect ratio. Portrait controls adapt to the narrower screen.

ARKit reference: https://developer.apple.com/documentation/arkit/arcamera/ (viewMatrix(for:)); https://developer.apple.com/documentation/arkit/arcamera/transform (orientation-independent raw camera basis).

## Independent browser take review

Open Blender's **Copy Browser Monitor Link** on another device on the same Wi-Fi. Click **Watch take** to select a take for that browser alone. Play/pause and scrub controls operate locally. **Shared live monitor** returns to the live/shared feed. Viewer selection does not change the operator's review camera, playback or timeline position. Up to four viewers remain supported alongside one operator.

**Prefer** adds a local preferred-take marker, saved in that browser's storage. It is not a team approval, shared vote or Blender metadata edit. Markers are not synchronized across different devices.

On first request, Blender generates an independent review proxy: 480-pixel-wide JPEG frames, up to 10 fps, maximum 600 samples spanning the entire take. Longer takes lower the proxy rate rather than truncating the duration. The UI displays the actual proxy rate. Raw animation frame rate, motion and lens keyframes are preserved. Playback starts after the requested proxy is ready; preparation status is displayed while waiting. This is visual review without audio or full-resolution export.

Preparation uses one main-thread GPU frame per timer turn and restores the current frame and subframe after each sample. No bpy calls run on network threads. Preparation waits while recording or shared take playback is active. Cached previews can still be played during recording. Keep a 3D View open; capture uses its shading mode. Preparing uncached takes costs GPU time and can reduce live-preview speed. Scene frame-change handlers execute during sampling as they do during normal timeline evaluation.

Proxies are session snapshots, stored under the configured recording root's `recordings/review-proxies/<session>/`. Edits to an already cached take are reflected after a server restart and new preparation. Cache files persist on disk and are distinct from raw take JSON/journals; they are not automatically deleted. Only recorded camera objects present in the active Blender scene appear in the take catalog.

## Protocol and access

Viewer pairing advertises `independent-review`. Viewer messages add `review` with opaque take `id` (a bounded preparation request) and `monitor_mode` with `live` or `review` (per-socket shared-stream delivery). They do not enter the operator command queue. Known IDs resolve to main-thread preparation jobs only; clients never supply paths.

Authenticated GET `/review/<id>/manifest` reports count, available, fps, duration, ready, status and error. `/review/<id>/<index>.jpg` returns a generated frame. Both require `Authorization: Bearer <monitor-token>`. Files are read only from server-published paths, not user-supplied filesystem paths. Restart revokes monitor access. HTTP development mode remains unencrypted; trusted HTTPS is available with the existing certificate settings.

## Milestone validation

Files: native CameraModel/TrackingOrientation/ContentView/LiveCameraView/TakeBrowserView and tests/plists; Blender review.py/review_preview.py, adapter/server, monitor HTML/CSS/JS; protocol tests, GPU review smoke, packaging and docs.

32 Python tests passed. Isolated Blender 5.2 GPU review test prepared two changing take proxies, served them to separate authenticated viewers, and preserved the shared camera, frame/subframe and source Action. Browser checks verified independent selection in two tabs, playback to the end, scrubbing and persistent Preferred marking. Native compile and simulator results are recorded in the validation report after completion. Physical iPhone portrait/landscape activation and separate-device Wi-Fi performance remain acceptance tasks.

Next: install both updated packages, test portrait activation and a recorded move, then review different takes on two devices. Adaptive live-preview quality and configurable horizon controls remain future work.
