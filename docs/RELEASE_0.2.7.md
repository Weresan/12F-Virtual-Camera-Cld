# 0.2.7: downloadable preview video and low-bandwidth monitoring

Google Drive integration is deferred at the artist's request. No account connection, upload queue or cloud transfer is added.

## Review and download

Open the browser monitor, choose Watch take and wait for preparation. The browser loads a small H.264 MP4, with Play/Pause, seeking and Download MP4. The downloaded file is a preview video that can be uploaded manually later. Preferred marks remain local browser shortlist data; choose a preferred take and download its video. No raw camera animation or source blend is included in the MP4.

Review images are now 320 pixels wide at lower JPEG quality before conversion to MP4. The default review target remains 30 fps; the existing setting supports up to 60 for new preparations. Long takes remain bounded to 3600 samples, so the actual preview rate may be lower. MP4 timing is derived from that actual rate. A single-frame take produces one frame at the requested rate. Files contain no audio, and duration can differ from the sampled motion interval by one output frame.

MP4 playback downloads the small file once into a browser blob URL rather than issuing an image request for each playback frame. The separate monitor token authorizes the download; tokens are not placed in the MP4 URL. If encoding fails, the UI reports it and retains the existing image-review fallback without a Download MP4 link.

Blender prepares GPU review samples on its main thread, then a single owned factory-startup Blender subprocess encodes only those JPEGs. It never opens the artist's blend. The encoder uses Blender's bundled FFmpeg/H.264 support, so no separate ffmpeg installation is needed on the tested Blender builds. Pending encoding waits while recording/shared playback is active; an encode already in progress completes in the background. The worker uses a single-thread setting and below-normal priority on Windows. Stop/restart closes the owned encoder process. Encoder logs and MP4s live beside the session's review proxy files.

## Live phone/browser preview

Smooth preview is the new default, including in existing scenes that lack this new property. It requests 480-pixel-wide JPEGs at quality 45 and a 30 fps target; recording uses 320 pixels to prioritize camera samples. Custom retains the prior resolution/rate/quality controls. Actual live rate still depends on scene/GPU/network speed; no fixed 30 fps hardware guarantee is made. Phone ARKit tracking, raw motion, lens keys, scene frame rate and recording accuracy are independent of preview resolution and compression.

Install the 0.2.7 add-on ZIP, fully restart Blender and connect again. Scan a fresh app QR and open a fresh Browser Monitor Link. Current iPhone app 0.2.5 remains compatible; no new IPA is required. Previously prepared preview snapshots need a connection restart to rebuild at the new size.

## Validation and next task

37 Python tests pass, plus Node bundle/buffer tests. Isolated Blender 4.4 and 5.2 GUI tests captured changing JPEGs, encoded two MP4s and downloaded them through authenticated HTTP while preserving shared camera/timeline/source Action. Blender decoded the downloaded clip as 320x180, 16 frames at 30 fps. Chrome loaded the MP4 player, played and sought the clip and displayed Download MP4. Screenshot: 12F-0.2.7-mp4-preview.png. Actual downloads were validated through the authenticated endpoint into repository test files; no external Drive upload was performed.

Files: new movie.py/encode_review.py; review generation, Blender preview profile, authenticated movie route, bundled monitor video/download UI and CSS; encoder/download/GPU/package tests and documentation. No native iOS source changes.

Next: verify playback/download on the artist's tablet and Smooth preview on the phone using the real scene. Physical-device sustained frame rate, macOS encoding and browser save dialogs remain acceptance tasks. A standard Blender build with H.264 encoding is required; unsupported builds show an encoding error and image fallback.
