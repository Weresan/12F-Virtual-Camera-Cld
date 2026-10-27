# 0.2.3: take browser and shared browser monitor

Includes 0.2.2 landscape tracking guard and blue aperture app icon.

## iPhone take browser

Tap Takes in the monitor. The list contains up to 100 recorded take cameras present in the active Blender scene, newest IDs first. Select Review to use that camera's animation and optics in the streamed preview. Play/pause and frame scrub controls appear below the monitor. Live camera restores the timeline position captured when review began. Rename changes only a label stored on the take camera; raw JSON and generated Actions are preserved. Save the blend to persist camera labels and scene membership. Takes on disk that have not been restored into this scene are not automatically imported. Recording and review commands cannot run simultaneously. Playback stops at the final frame without looping.

## Read-only shared monitor

In Blender click Copy Browser Monitor Link after starting the server. Share the entire link with a device on the same local Wi-Fi. The URL uses the computer's LAN IP and a separate random credential in its fragment. Opening only the IP at `/monitor` shows a link-entry form. Up to four browser viewers may watch alongside one camera operator. Viewer links cannot authenticate as operators; commands from viewers close their connection and never enter the Blender queue. Stop/restart revokes both credentials. Do not share the operator pairing link with viewers.

Viewers see the single shared live feed or the take selected by the operator, including the take list, current review frame and received FPS. This is not independent playback per viewer. The active Blender scene and a usable open 3D viewport are still required for GPU preview capture. Monitoring works with viewers alone, without a phone operator connected. Local network/firewall access is required. HTTP development mode is unencrypted; TLS settings apply to both operator and monitor endpoints. Each viewer adds network and encoding-delivery load; no sustained multi-viewer 60 FPS claim.

## Protocol extension

Protocol v1 adds the `take-browser` capability. Clients must gate take commands on it. Message `type: take` uses payload `operation` (select, scrub, play, pause, live, rename); all except live require opaque `id`, scrub requires integer frame, rename requires a nonempty label up to 80 characters without control characters. IDs resolve only to recorded camera objects in the active scene. Clients never submit paths.

State adds takes [{id,label,start,end,fps}], selected_take, review_frame and review_playing. Viewer authentication is {role: viewer, token: separate-monitor-token}; viewer application messages accept only heartbeat. Existing operator authentication and pose/control messages are unchanged. Web pages use same-origin scripts and textContent for take labels.

## Validation

29 Python tests passed, including operation bounds, a concurrent operator/viewer, denied viewer control and four-viewer limit. Blender 4.4 and 5.2 isolated smoke checks passed for catalog/review/rename/scrub/play/end/live return and animation preservation. Browser JS syntax passed. Native CI passed eight Swift tests per configuration, Debug/Release iPhone builds and simulator launch. Browser monitor connection, layout, stale-frame handling and IP-only link entry were visually checked with isolated test data. See VALIDATION_0.2.3.md. Physical phone orientation transitions, Wi-Fi throughput and multi-device playback remain hardware acceptance tasks.

Files: core.py, server.py, blender.py, monitor HTML/CSS/JS, RecordedTake.swift, TakeBrowserView.swift, CameraModel/LiveCameraView, Xcode/Swift package configuration, tests and distribution ZIP. Next: hardware acceptance, then adaptive preview and configurable horizon controls.
