# 0.2.5: smoother review and recording interruption tolerance

## Review

New review proxies default to 30 fps. Blender's Review proxy FPS setting supports 30 through 60 for new preparations. The cap increases from 600 to 3600 samples spanning the full take; long takes can still reduce the proxy rate. The browser displays the actual proxy rate. Width remains 480 pixels. Higher rates require more preparation time and disk space.

Browser playback uses requestAnimationFrame, a bounded decoded-image buffer and up to four parallel frame downloads. This removes the old 50 ms timer's 20 fps ceiling and the serial fetch-per-frame bottleneck. The buffer keeps about 90 frames ahead and a few behind, evicts decoded images as playback advances and closes them on selection changes. If frames cannot arrive in time, playback shows buffering rather than silently claiming full throughput. Independent viewer selection and local preferred marks remain unchanged.

Install the updated add-on and restart Blender's connection, then copy a fresh Browser Monitor Link and open it before selecting the take again. Restarting revokes the previous link and the app QR must be scanned again. Existing session proxies are snapshots; a connection restart rebuilds them with the new rate. Old cache files remain on disk but are not reused by the new session. Set Review proxy FPS before requesting an uncached take; restart the connection to rebuild an already prepared one after changing the rate.

## Recording

The previous client stopped on the first non-normal ARKit frame. The updated client keeps its latched orientation through a brief interruption. Blender freezes the camera while limited/lost tracking samples arrive for less than one second, retains the raw quality-tagged samples and records hold/recovery events. Recovery within that interval resumes the same take without automatic recentering. A full second of continuing bad tracking ends/saves the take and requires activation again.

No-sample timeout increases from 0.5 to 2 seconds. Main-thread queue processing accepts samples delayed up to that bound, rather than ending a take after a half-second preview stall. Short delivery gaps in the generated motion receive explicit held-camera samples; actual raw sensor samples remain unchanged. Gap intervals are included in take metadata. Longer gaps remain invalid for automatic animation generation and the journal remains recoverable.

During recording, live preview is capped at 640 pixels and a 30 fps target. Captures taking over 100 ms back off temporarily to prioritize tracking and recording. This cap applies to the live feed during recording, not the independent proxy setting or native tracking target. Proxy preparation already waits during recording.

Take metadata and Blender state now include the stop reason. The phone displays the last stop reason, including explicit tracking-loss reasons from the client, disconnects and the no-sample timeout. Camera-consumer errors attempt finalization and retain the flushed journal if finalization fails. Intentional Stop, Recenter, backgrounding and sustained tracking loss can still end recording. This is not a guarantee against all device, network or filesystem failures.

## Validation and next task

35 Python tests pass, plus Node buffer checks for concurrency, prefetch, seeking, eviction and cleanup. Blender 4.4/5.2 smoke checks pass for continued recording through a limited sample, held movement, preserved raw quality/events and persisted stop reason. Isolated GPU tests generated two 30 fps proxies. Chrome verified canvas playback and seek using those proxies. Native CI passed nine Swift tests per configuration, Debug/Release device builds and simulator launch. IPA version/icon verified; see VALIDATION_0.2.5.md.

Files: review plan/GPU proxy settings, new health.py, core/adapter/protocol validation, review-buffer.js and monitor UI; native tracking state, stop diagnostics and tests/plists; regression tests, packaging and documentation.

Next: install both packages, rebuild the review proxy and test a longer physical take. Device tracking recovery and sustained 30/60 fps tablet playback have not been measured by the agent. If a take still ends, capture the displayed stop reason so the next fix can target the actual cause.
