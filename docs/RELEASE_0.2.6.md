# 0.2.6: self-contained review player and N-panel-only pairing

The reported `ReviewFrameBuffer is not defined` error means the browser player ran without its frame-buffer dependency. The source router included that dependency route, but a previously loaded Blender server module can serve newly replaced web files without recognizing a newly added route. The installed-device cause cannot be proven from the screenshot alone.

The player is now a single dependency-complete `monitor.js`, built from `review-buffer.js` and `monitor-player.js` by `tools/build_monitor.py`. The package builder runs this step automatically. The HTML loads one versioned script URL. The frame-buffer definition is published even if a browser environment exposes a CommonJS-shaped module object. No separate dependency HTTP request is required.

Removed the automatic pairing dialog, its operator and Show Pairing QR button. The N-panel retains the QR image and Copy Pairing Link. Copy Browser Monitor Link remains available. No browser or QR popup opens when starting the connection.

Install the 0.2.6 Blender ZIP, fully restart Blender, start the connection, rescan the app QR and open a fresh Browser Monitor Link. The existing 0.2.5 iPhone app is compatible; no new IPA is needed. Restart rotates credentials and requires fresh links.

Validation: 36 Python tests passed. A regression extracts the actual ZIP web files, serves the page through a router that rejects the old dependency route, downloads its single script and executes its initialization. Node buffer and bundled-player tests passed, including a CommonJS-shaped global environment. An isolated Blender 5.2 GUI startup test passed with the QR preview loaded and no pairing-dialog operator. Chrome loaded and played a 30 fps generated test proxy through to its final frame without the dependency error; screenshot 12F-0.2.6-review-fix.png. Actual tablet playback remains a device acceptance check.

Files: Blender adapter/version, monitor HTML/buffer/bundled player and player source, new bundle builder, packager, packaged-HTTP/Node regression tests, pairing GUI smoke test and documentation.

Next: install the add-on and confirm Watch take/Play on the tablet. Review rate and recording tolerance are unchanged from 0.2.5.
