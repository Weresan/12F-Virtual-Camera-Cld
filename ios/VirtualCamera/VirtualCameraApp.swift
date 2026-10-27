import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationMask: UIInterfaceOrientationMask = .allButUpsideDown
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationMask
    }
}

enum OrientationControl {
    /// Restricts the allowed orientations and asks iOS to rotate into them.
    static func apply(_ mask: UIInterfaceOrientationMask) {
        AppDelegate.orientationMask = mask
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else { return }
        scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in }
    }
}

@main
struct VirtualCameraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = CameraModel()
    var body: some Scene {
        WindowGroup { ContentView(model: model) }
    }
}
