# 0.2.3 validation

Native source commit: `39ca77229401ceb8178c6151fdd06acf3dfa83df`.

[Native build](https://github.com/Weresan/12F-Virtual-Camera-Cld/actions/runs/40561386367): completed successfully: eight Swift tests passed per configuration; Debug/Release iPhone builds and simulator compilation/install/launch/screenshot passed. Downloaded Debug IPA archive integrity, version 0.2.3 build 5 and embedded icon assets verified.

- 29 local Python tests passed, including take-operation validation and concurrent operator/viewer transport.
- Blender 4.4.3 and 5.2.0 isolated animation/review smoke checks passed. Reviewed catalog/rename/scrub/play/end/live-return and existing animation preservation.
- Isolated Blender 5.2 GUI test delivered three changing GPU JPEGs to a real read-only WebSocket viewer without an operator. Source camera matrix and render settings remained unchanged.
- Chrome UI fixture check verified monitor authentication, take list and stale-frame indication. IP-only page plus pasted link successfully connected. Screenshot: `12F-0.2.3-browser-monitor.png` (static test fixture, not a hardware throughput demonstration).
- Browser monitor JS syntax check passed.
- Earlier 0.2.2 build also passed tests, Debug/Release builds and simulator launch; its orientation guard/icon are included in 0.2.3.

Physical iPhone orientation handoff, installed home-screen icon, multi-device Wi-Fi monitoring and sustained 60 FPS are acceptance tasks. Shared viewers follow the operator-selected feed. Native take browser lists recorded camera objects present in the current Blender scene; it does not import orphaned disk takes. Raw recordings and generated Actions are not overwritten by review or label edits.

Next: sideload the new IPA, update the Blender ZIP, scan in portrait then hold landscape, record a take, review it on the phone and watch from a second device using Copy Browser Monitor Link.
