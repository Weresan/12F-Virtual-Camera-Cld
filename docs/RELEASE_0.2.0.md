# 12F Virtual Camera 0.2.0

Use the updated iPhone app and Blender add-on together. Updating the app alone does not add a preview producer to older add-ons.

## Install and operate

1. Stop the Blender phone server. Install `12F-Virtual-Camera-0.2.0.zip` and restart Blender to unload old code.
2. In the sidebar choose the project repository. Optionally choose a **Source camera** and click **Use Source Framing**. The live camera copies its framing and optics without changing the source camera or its existing animation.
3. Leave **Live camera monitor** enabled; start the server, then reconnect the updated iPhone app. Keep a 3D View open. Preview uses its current Solid/Material/Rendered shading, through the controlled camera, without overlays. Default target: 640 pixels wide, 12 fps, JPEG quality 65. These are targets, not guaranteed throughput. Adjust them for your scene/computer/Wi-Fi.
4. Operate the camera and tap Record. Change **Zoom / Lens**, focus or aperture while recording. Stop saves a new take camera with a transform Action and a camera-data optics Action. Raw optics are stored separately in the JSON and crash journal. Recording starts at the current Blender frame and uses the scene FPS; it does not automatically play timeline audio.
5. In Blender choose **Recorded camera**, then **Select Recorded Camera for Review**. This explicitly selects it and sets the scene camera. Scrub/play the timeline to review motion and lens changes. Monitor source switches to Recorded camera. Return it to Live camera to operate again. Starting another recording automatically returns the monitor to Live.
6. In the iPhone monitor tap the grid icon for thirds, golden-ratio grid, center cross or 90% action/80% title safe areas. Guides follow the fitted camera image and are not recorded.
7. **Zoom / Lens** changes the actual camera focal length (8–300 mm) and is recorded. The **1×/2×** monitor button and pinch (1–4×) magnify only the phone image for inspecting focus. Drag to inspect details. This magnifier does not change the Blender camera or exported animation; guides hide while magnified. Tap the zoom button to return to 1×.

## Changes

The saved-workstation connection UI from `Weresan/12F-Virtual-Camera-Cld` is preserved. Main background is INK **#17243B** with blue controls. The monitor is landscape, with confirmed recording state, tracking quality, measured received-preview FPS, and stalled-feed reporting. Camera data initializes from Blender state instead of overwriting the artist's lens on pairing. Selecting a take for review disables its phone lens controls; live-camera edits remain independent.

Preview uses `GPUOffScreen.draw_view3d` on Blender's main thread; no background bpy calls or screen capture. JPEG encoding currently uses Blender Image.save_render and one overwritten file under `recordings/preview.jpg`. It can reduce interactive performance on complex scenes. Only the latest completed JPEG is retained by transport; no render backlog is created. A closed/minimized desktop window or no 3D View may stop GPU drawing, depending on the platform. Preview errors appear in the sidebar and phone.

## Validation

Python: 23 unit/integration tests pass, including optics resampling and existing transport/storage checks. Blender 5.2 recording smoke passes with varying lens, focus and aperture, independent camera/optics Actions, original animation preserved, take selection and frame scrubbing. Isolated Blender GUI GPU test captures changing JPEG frames and preserves source render settings. Physical phone visual/gesture/network performance still needs acceptance. Native build and simulator results are recorded after CI.

Known limits: no audio synchronization, automatic Bonjour discovery, final-render-equivalent stream guarantee, or UI for reprocessing saved raw optics. Monitor zoom is for inspection only. Restarting Blender rotates the QR credential; rescan if a saved computer cannot reconnect.
