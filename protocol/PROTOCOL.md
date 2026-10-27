# 12F protocol v1

0.2.0 additions: `paired.capabilities` advertises `live-preview`, `preview-control`, and `camera-state`. When `preview-control` is present, command names `preview_start` and `preview_stop` toggle preview. State may include `preview_status`, `preview_fps`, `preview_enabled`, `monitor_source` (LIVE/TAKE), `camera`, `lens`, `focus`, `aperture`, and `needs_recenter`. JPEG binary messages now carry successive live frames. Old clients may ignore these optional state fields. New clients must not send preview commands to a server that lacks the capability. Optics settings remain the existing v1 message and are sampled alongside recorded poses.

Local TCP port 8765; HTTP(S) `/` serves the controller, WebSocket `/ws` carries control. Use TLS for secure sessions. All JSON is UTF-8, max 8192 bytes. Client first sends `{"token":"<QR bearer token>"}` within five seconds. Server returns `{"v":1,"type":"paired"}` or closes with 1008. Only one authenticated controller is allowed. Stop/restart rotates the token.

Every client message thereafter:

```json
{"v":1,"type":"pose","session":"UUID-or-opaque-id","seq":1,"t":100.033,"payload":{"position":[0,0,0],"rotation":[0,0,0,1],"quality":"normal"}}
```

`session`: 1–128 characters, fixed for socket. `seq`: nonnegative integer, strictly increasing. `t`: finite nonnegative monotonic seconds, nondecreasing, same client clock for all messages (AR frame capture time should be close to send time). Pose times must be strictly increasing for recording. Do not compare sender time directly to Blender's clock. Reconnect uses a fresh session and begins with `hello`; raw sample epochs never span reconnects. Unknown major versions/types, invalid payloads, NaNs/infinities and replay close the stream. JSON key order is irrelevant.

| Type | Payload |
|---|---|
| hello | First message; optional `client` and informational `capabilities` |
| pose | `position`: 3 finite meter values; `rotation`: xyzw quaternion normalized by receiver; `quality`: normal/limited/lost/manual |
| settings | One or more: lens 8–300 mm; focus .01–10000 m; aperture .7–64; scale .01–100 |
| command | `name`: recenter, record, stop |
| heartbeat | Empty object; send about every 2 s |

Manual quality explicitly identifies browser/manual input; it is not a positional tracking quality claim. Limited/lost freezes camera and ends a take. `recenter` ends any active take before changing the origin. Source ARKit transform is camera-local → Y-up world, no UI screen rotation; see architecture for the canonical conversion.

Server messages:

* `{"type":"heartbeat","echo":100}` echoes client time; estimate RTT from the same client monotonic clock.
* `{"type":"state","payload":{"status":"Recording","recording":true,"quality":"normal"}}` reflects consumer state, asynchronously. A command is not proof it succeeded; use state. This version has no command correlation ID or exactly-once reconnect retry; commands are not automatically replayed.
* Binary messages are individual complete JPEG preview frames. No preview is sent until a producer supplies a snapshot. Only latest preview retained; slow clients must not block Blender.

WebSocket ping every 5 s, timeout 10 s. Consumer pose timeout 500 ms; jitter/gaps over 250 ms reject animation generation but preserve journal/JSON samples. A saturated inbound queue closes with 1013; consumers stop on timeout. Current implementation uses TCP order and offline resampling, not a live interpolated jitter buffer.

Future protocol revisions: capture timestamps separate from send timestamps; clock sync measurements, command acknowledgements/IDs, stream capability negotiation, persistent paired identity, rig and lens curves, preview frame metadata, and tracking epoch changes. Increment `v` for incompatible changes; optional new fields must not silently acquire mandatory semantics in v1.


## Capability extension: take-browser (0.2.3)

See [take and monitor extension](../docs/RELEASE_0.2.3.md#protocol-extension). The v1 envelope is retained. Take operations resolve opaque IDs only within active-scene recorded cameras. Viewer authentication uses a distinct read-only credential and does not enter the main-thread command queue. Up to four viewers share the operator-selected feed; they cannot change review or camera state.


## Independent review and activation (0.2.4)

See [0.2.4 protocol and access](../docs/RELEASE_0.2.4.md#protocol-and-access). Viewer-local review requests and mode changes never enter the operator control queue. Generated JPEG review frames require the separate monitor bearer token. Native pose rotation uses the screen-aligned ARCamera basis latched at explicit activation; UI rotation does not swap that basis during a take. The v1 envelope and xyzw order remain unchanged.
