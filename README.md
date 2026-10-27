# 12F Virtual Camera — iOS build

12Frames Studio · 12F Development Team

Native iPhone/iPad app build sources for the 12F Virtual Camera Blender integration.

Run Actions → iOS compile and pairing tests → Run workflow. This runs Swift parser tests and builds Debug/Release unsigned app bundles on macOS. Unsigned artifacts cannot be installed on an iPhone. Signing and device acceptance remain separate milestones.

See [setup instructions](docs/IOS_SETUP.md). This initial remote build repository contains the iOS app, protocol and build workflow; the Blender add-on remains in the local project.
