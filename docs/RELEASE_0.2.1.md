# 12F Virtual Camera 0.2.1

## Pair inside Blender

Connect opens a QR dialog inside Blender, with a second QR in the sidebar. No browser is launched and no pairing HTML is generated. Show Pairing QR reopens the dialog. Copy Pairing Link is an explicit manual fallback for the phone's Enter Link screen. Stop/restart rotates the credential; rescan when reconnecting after a restart. Session-owned pairing PNG is removed on clean shutdown.

## No source repository required

Artists install the add-on ZIP and connect. No .12f-project marker or source checkout is needed. The old Project repository field is hidden and ignored; it was a development restriction, not a production dependency.

Default storage:

- Saved blend: a sibling `<blend-name>.12f` folder, e.g. `MyShot.blend` uses `MyShot.12f/recordings/`.
- Unsaved blend: Blender's per-version user data under `12F Virtual Camera/Unsaved/<scene-id>/recordings/`. This is persistent user data, not an automatically cleared temporary folder.
- Connection and storage options exposes an optional Recording folder override. A selected folder does not need a marker. The storage location is shown while the server runs. Folder changes take effect on reconnect.

Storage is pinned for a connection and separately captured when a recording begins. Saving/Save As or changing a folder during a take does not move its journal or split its final JSON into another location. Take cameras retain the absolute JSON path. No existing takes are moved or deleted. To move unsaved recordings alongside a newly saved blend, stop/disconnect first, copy the data deliberately if needed, and reconnect for future takes. Read-only folders report a filesystem error; choose a writable optional override.

## 60 FPS targets

Blender Target preview FPS now supports 1–60; the default is 30 to balance responsiveness and load. Set it to 60 to request a faster monitor stream. The main-thread timer and transport polling are no longer capped at 50 FPS. Actual GPU draw/JPEG encode/network speed can be lower; the phone displays measured received FPS. This is not a claim of 60 FPS sustained performance on hardware.

The native app sends tracking at a target of 60 Hz by default. Enter Link → Tracking offers 30 or 60 Hz; apply it before connecting. ARKit selects a supported camera format at or above the requested rate when available. Actual samples remain limited by supported device formats, scheduling and tracking quality. Tracking and preview rates are independent.

Install the updated 0.2.1 Blender ZIP for the QR/storage/preview changes. Update the Debug IPA through the existing sideload workflow for the 60 Hz native option. The earlier app still pairs and previews with this add-on at its existing tracking rate.

Validation: storage resolver unit tests and Blender smoke tests cover automatic unsaved paths, marker-free overrides, 60 FPS configuration, animation/take preservation and optics. Native CI covers both configurations and the simulator launch. Physical QR scanning and sustained 60 FPS still require device acceptance. No artist scene was opened or modified during tests.
