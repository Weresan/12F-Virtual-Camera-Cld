"""Create the checked-in minimal iOS project. Run from any OS; build requires macOS."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]/'ios'
folder=ROOT/'VirtualCamera.xcodeproj';folder.mkdir(exist_ok=True)
sources=['VirtualCameraApp.swift','CameraModel.swift','ContentView.swift','PairingEndpoint.swift','SavedComputer.swift','HomeView.swift','LiveCameraView.swift','CompositionGuide.swift','TrackingOrientation.swift']
def ident(n):return f'{n:024X}'
objects=[]
for i,name in enumerate(sources):
    objects.append(f'{ident(100+i)} = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};')
    objects.append(f'{ident(200+i)} = {{isa = PBXBuildFile; fileRef = {ident(100+i)}; }};')
objects.extend([
f'{ident(400)} = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};',
f'{ident(401)} = {{isa = PBXBuildFile; fileRef = {ident(400)}; }};', 
f'{ident(1)} = {{isa = PBXProject; buildConfigurationList = {ident(10)}; compatibilityVersion = "Xcode 14.0"; mainGroup = {ident(2)}; productRefGroup = {ident(4)}; targets = ({ident(5)}); }};',
f'{ident(2)} = {{isa = PBXGroup; children = ({ident(3)}, {ident(4)}); sourceTree = "<group>"; }};',
f'{ident(3)} = {{isa = PBXGroup; path = VirtualCamera; children = ({ident(400)},{",".join(ident(100+i) for i in range(len(sources)))}); sourceTree = "<group>"; }};',
f'{ident(4)} = {{isa = PBXGroup; name = Products; children = ({ident(6)}); sourceTree = "<group>"; }};',
f'{ident(6)} = {{isa = PBXFileReference; explicitFileType = wrapper.application; path = VirtualCamera.app; sourceTree = BUILT_PRODUCTS_DIR; }};',
f'{ident(5)} = {{isa = PBXNativeTarget; name = VirtualCamera; productName = VirtualCamera; productReference = {ident(6)}; productType = "com.apple.product-type.application"; buildConfigurationList = {ident(11)}; buildPhases = ({ident(7)}, {ident(8)}, {ident(9)}); buildRules = (); dependencies = (); }};',
f'{ident(7)} = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({",".join(ident(200+i) for i in range(len(sources)))}); runOnlyForDeploymentPostprocessing = 0; }};',
f'{ident(8)} = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};',
f'{ident(9)} = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({ident(401)}); runOnlyForDeploymentPostprocessing = 0; }};'])
for config in (10,11):
    ids=[config*100,config*100+1]
    objects.append(f'{ident(config)} = {{isa = XCConfigurationList; buildConfigurations = ({ident(ids[0])},{ident(ids[1])}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};')
    for n,name in zip(ids,['Debug','Release']):
        settings='SDKROOT = iphoneos; IPHONEOS_DEPLOYMENT_TARGET = 16.0; SWIFT_VERSION = 5.0; CLANG_ENABLE_MODULES = YES;'
        if config==11:settings+=' ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; PRODUCT_BUNDLE_IDENTIFIER = studio.12frames.virtualcamera; PRODUCT_NAME = "$(TARGET_NAME)"; INFOPLIST_FILE = VirtualCamera/Info.plist; TARGETED_DEVICE_FAMILY = "1,2"; CODE_SIGN_STYLE = Automatic;'
        if name=='Debug':
            settings+=' SWIFT_OPTIMIZATION_LEVEL = "-Onone"; SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;'
            if config==11: settings=settings.replace('INFOPLIST_FILE = VirtualCamera/Info.plist;', 'INFOPLIST_FILE = VirtualCamera/Info-Debug.plist;')
        objects.append(f'{ident(n)} = {{isa = XCBuildConfiguration; name = {name}; buildSettings = {{{settings}}}; }};')
(folder/'project.pbxproj').write_text('// !$*UTF8*$!\n{ archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+'\n'.join(objects)+f'\n}}; rootObject = {ident(1)}; }}\n',encoding='utf-8')
print(folder)
scheme=folder/'xcshareddata'/'xcschemes';scheme.mkdir(parents=True,exist_ok=True)
(scheme/'VirtualCamera.xcscheme').write_text('''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries>
<BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="000000000000000000000005" BuildableName="VirtualCamera.app" BlueprintName="VirtualCamera" ReferencedContainer="container:VirtualCamera.xcodeproj"/>
</BuildActionEntry></BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug"/>
<LaunchAction buildConfiguration="Debug" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
<BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="000000000000000000000005" BuildableName="VirtualCamera.app" BlueprintName="VirtualCamera" ReferencedContainer="container:VirtualCamera.xcodeproj"/></BuildableProductRunnable>
</LaunchAction><ProfileAction buildConfiguration="Release"/><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''',encoding='utf-8')
import plistlib
info=plistlib.loads((ROOT/'VirtualCamera'/'Info.plist').read_bytes())
info['NSAppTransportSecurity']={'NSAllowsArbitraryLoads':True}
(ROOT/'VirtualCamera'/'Info-Debug.plist').write_bytes(plistlib.dumps(info))
