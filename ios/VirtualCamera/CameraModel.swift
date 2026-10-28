import Foundation
import Combine
import ARKit
import CoreMotion
import simd
import AVFoundation
import UIKit
@MainActor
final class CameraModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var status = "Disconnected"
    @Published var quality = "Not tracking"
    @Published var address = ""
    @Published var previewImage: UIImage?
    @Published var previewFPS = 0.0
    @Published var angularSpeed = 0.0
    @Published var allowInsecureLAN = UserDefaults.standard.bool(forKey: "allowInsecureLAN") {
        didSet { UserDefaults.standard.set(allowInsecureLAN, forKey: "allowInsecureLAN") }
    }
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var isRecording = false
    @Published var recordingStart: Date?
    @Published var computers: [SavedComputer] = []
    @Published var activeComputer: SavedComputer?
    @Published var lens = 35.0
    @Published var focus = 5.0
    @Published var aperture = 2.8
    @Published var previewReceivedAt: Date?
    @Published var previewStatus = "Waiting for Blender"
    @Published var supportsPreviewControl = false
    @Published var previewEnabled = true
    @Published var needsRecenter = false
    @Published var monitorSource = "LIVE"
    @Published var cameraName = "12F Camera"
    @Published var trackingFPS = 60.0
    @Published var trackingReady = false
    @Published var supportsTakeBrowser = false
    @Published var takes: [RecordedTake] = []
    @Published var selectedTake = ""
    @Published var reviewFrame = 0
    @Published var reviewPlaying = false
    @Published var lastStopReason = ""
    private var orientationGate = TrackingOrientation()
    private var latestTrackingQuality = "lost"
    @Published var activationPrompt = "Tap to activate camera"
    let ar = ARSession()
    private let motion = CMMotionManager()
    private var socket: URLSessionWebSocketTask?
    private var sequence = 0
    private var sessionID = UUID().uuidString
    private var paired = false
    private var lastFrame = 0.0
    private var initialCalibration = false
    private var heartbeat: Task<Void, Never>?
    private var pendingAddress = ""
    private var lastPreviewTime = 0.0
    override init() {
        super.init()
        computers = ComputerStore.load()
        ar.delegate = self
        ar.delegateQueue = .main
    }
    func connect() {
        disconnect()
        let endpoint: PairingEndpoint
        do { endpoint = try PairingEndpoint(address, allowInsecureLAN: allowInsecureLAN) }
        catch { status = error.localizedDescription; return }
        sessionID = UUID().uuidString; sequence = 0
        pendingAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        isConnecting = true
        let task = URLSession.shared.webSocketTask(with: endpoint.socketURL)
        socket = task; task.resume(); status = "Connecting"
        Task {
            do {
                let auth = try JSONSerialization.data(withJSONObject: ["token": endpoint.token])
                try await task.send(.string(String(decoding: auth, as: UTF8.self)))
                guard task === socket else { return }
                receive(task)
            } catch { if task === socket { fail(error) } }
        }
    }
    private func receive(_ task: URLSessionWebSocketTask) {
        Task {
            do {
                let message = try await task.receive()
                guard task === socket else { return }
                switch message {
                case .data(let bytes):
                    if let image = UIImage(data: bytes) { previewImage = image; tickPreview() }
                case .string(let text):
                    if let bytes = text.data(using: .utf8),
                       let object = try JSONSerialization.jsonObject(with: bytes) as? [String: Any] {
                       if object["type"] as? String == "state",
                          let payload = object["payload"] as? [String: Any] {
                           if let message = payload["status"] as? String { status = message }
                           if let recording = payload["recording"] as? Bool { setRecording(recording) }
                           previewStatus = payload["preview_status"] as? String ?? "Update the Blender add-on to 0.2.0 for live preview"
                           previewEnabled = payload["preview_enabled"] as? Bool ?? false
                           needsRecenter = payload["needs_recenter"] as? Bool ?? false
                           monitorSource = payload["monitor_source"] as? String ?? "LIVE"
                           cameraName = payload["camera"] as? String ?? "12F Camera"
                           if let value = payload["lens"] as? Double { lens = value }
                           if let value = payload["focus"] as? Double { focus = value }
                           if let value = payload["aperture"] as? Double { aperture = value }
                           if let rows = payload["takes"], let data = try? JSONSerialization.data(withJSONObject: rows),
                              let items = try? JSONDecoder().decode([RecordedTake].self, from: data) { takes = items }
                           selectedTake = payload["selected_take"] as? String ?? ""
                           reviewFrame = payload["review_frame"] as? Int ?? 0
                           reviewPlaying = payload["review_playing"] as? Bool ?? false
                           lastStopReason = payload["last_stop_reason"] as? String ?? ""
                       }
                       if object["type"] as? String == "paired" {
                        guard !paired else { return }
                        paired = true; isConnecting = false; isConnected = true; status = "Paired"
                        supportsPreviewControl = (object["capabilities"] as? [String] ?? []).contains("preview-control")
                        supportsTakeBrowser = (object["capabilities"] as? [String] ?? []).contains("take-browser")
                        // Optional: the Blender add-on may send {"type":"paired","payload":{"name":"My PC"}}.
                        let name = (object["payload"] as? [String: Any])?["name"] as? String
                        remember(name: name)
                        send("hello", ["client": "ios", "capabilities": ["arkit6dof", "coremotion"]])
                        // Preserve the artist's current optics; receive them from Blender state.
                        Task { await startTracking() }
                        heartbeat = Task { [weak self] in
                            while !Task.isCancelled {
                                self?.send("heartbeat", [:])
                                do { try await Task.sleep(nanoseconds: 2_000_000_000) } catch { return }
                            }
                        }
                       }
                    }
                @unknown default: break
                }
                receive(task)
            } catch { if task === socket { fail(error) } }
        }
    }
    func send(_ type: String, _ payload: [String: Any]) {
        guard paired, let task = socket else { return }
        let object: [String: Any] = ["v": 1, "type": type, "session": sessionID,
            "seq": sequence, "t": ProcessInfo.processInfo.systemUptime, "payload": payload]
        sequence += 1
        do {
            let bytes = try JSONSerialization.data(withJSONObject: object)
            // Main-queue calls preserve submission order to URLSession.
            task.send(.string(String(decoding: bytes, as: UTF8.self))) { [weak self] error in
                if let error { Task { @MainActor in
                    guard let self, task === self.socket else { return }
                    self.fail(error)
                } }
            }
        } catch { fail(error) }
    }
    private func startTracking() async {
        let currentSocket = socket
        let allowed = await AVCaptureDevice.requestAccess(for: .video)
        guard currentSocket === socket, paired else { return }
        guard allowed else { disconnect(); status = "Camera access is required for ARKit tracking. Enable it in iPhone Settings."; return }
        guard ARWorldTrackingConfiguration.isSupported else {
            disconnect(); status = "World tracking unsupported on this device"; return
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        if let format = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { Double($0.framesPerSecond) >= trackingFPS }) {
            configuration.videoFormat = format
        }
        ar.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        orientationGate = TrackingOrientation(); trackingReady = false
        lastFrame = 0; initialCalibration = false; latestTrackingQuality = "lost"
        if motion.isDeviceMotionAvailable {
            motion.deviceMotionUpdateInterval = 1.0 / 30
            motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let rate = data?.rotationRate else { return }
                Task { @MainActor in self?.angularSpeed = sqrt(rate.x*rate.x + rate.y*rate.y + rate.z*rate.z) }
            }
        }
    }
    // ARSession's delegate queue is explicitly main; immutable values enter the model.
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = frame.camera.transform
        // Inverse view matrices provide screen-aligned camera bases. Latch one on activation.
        let rotations = [1: simd_quatf(frame.camera.viewMatrix(for: .landscapeRight).inverse),
                         2: simd_quatf(frame.camera.viewMatrix(for: .landscapeLeft).inverse),
                         3: simd_quatf(frame.camera.viewMatrix(for: .portrait).inverse),
                         4: simd_quatf(frame.camera.viewMatrix(for: .portraitUpsideDown).inverse)]
        let timestamp = frame.timestamp
        let tracking: String
        switch frame.camera.trackingState {
        case .normal: tracking = "normal"
        case .limited: tracking = "limited"
        case .notAvailable: tracking = "lost"
        }
        let p = [transform.columns.3.x, transform.columns.3.y, transform.columns.3.z]
        Task { @MainActor in
            guard paired else { return }
            guard timestamp - lastFrame >= 1.0/max(1,trackingFPS)-0.001 else { return }
            latestTrackingQuality = tracking
            let hold = orientationGate.update(normal: tracking == "normal", time: timestamp)
            if !hold.ready {
                if hold.expired { send("command", ["name": "stop", "reason": "Tracking unavailable for 1 second"]) }
                if let side = orientationGate.side {
                    let q = rotations[side]!
                    send("pose", ["position": p, "rotation": [q.imag.x,q.imag.y,q.imag.z,q.real], "quality": tracking])
                }
                trackingReady = false
                quality = tracking
                activationPrompt = orientationGate.side != nil ? "Tracking interrupted - holding camera" : (tracking == "normal" ? "Tap to activate camera" : "Waiting for tracking - move phone slowly")
                lastFrame = timestamp
                return
            }
            let q = rotations[orientationGate.side ?? 1]!
            let rotation = [q.imag.x,q.imag.y,q.imag.z,q.real]
            trackingReady = true
            if hold.recalibrate { initialCalibration = false }
            if !initialCalibration {
                send("command", ["name": "recenter"]); initialCalibration = true
            }
            lastFrame = timestamp; quality = tracking
            send("pose", ["position": p, "rotation": rotation, "quality": tracking])
        }
    }
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in command("stop"); orientationGate = TrackingOrientation(); trackingReady = false; latestTrackingQuality = "lost"; quality = "lost"; status = "AR session interrupted" }
    }
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        Task { @MainActor in status = "Reconnect to reset tracking and recenter"; disconnect() }
    }
    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in fail(error) }
    }
    func activateTracking() {
        guard paired, latestTrackingQuality == "normal" else {
            activationPrompt = "Waiting for tracking - move phone slowly"; return
        }
        let device = UIDevice.current.orientation
        let side: Int
        switch device {
        case .landscapeLeft: side = 1
        case .landscapeRight: side = 2
        case .portrait: side = 3
        case .portraitUpsideDown: side = 4
        default:
            let orientation = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.interfaceOrientation
            side = orientation == .landscapeRight ? 1 : (orientation == .landscapeLeft ? 2 : 3)
        }
        send("command", ["name": "stop"])
        _ = orientationGate.activate(side: side)
        initialCalibration = false; trackingReady = false
        activationPrompt = "Activating camera..."
    }
    func command(_ name: String) {
        if name == "recenter" { activateTracking(); return }
        if name == "record" && !trackingReady { return }
        send("command", ["name": name])
    }
    func setting(_ name: String, _ value: Double) { send("settings", [name: value]) }
    func takeCommand(_ operation: String, id: String = "", extra: [String: Any] = [:]) {
        guard supportsTakeBrowser, !isRecording else { return }
        var payload = extra; payload["operation"] = operation; payload["id"] = id
        send("take", payload)
    }
    private func pushSettings() { send("settings", ["lens": lens, "focus": focus, "aperture": aperture]) }
    func connect(to computer: SavedComputer) { address = computer.address; connect() }
    func forget(_ computer: SavedComputer) {
        computers.removeAll { $0.id == computer.id }
        ComputerStore.save(computers)
    }
    private func remember(name: String?) {
        guard let parts = URLComponents(string: pendingAddress), let host = parts.host else { return }
        let id = host + (parts.port.map { ":\($0)" } ?? "")
        let previous = computers.first { $0.id == id }
        let entry = SavedComputer(id: id, name: name ?? previous?.name ?? "Blender", host: host,
                                  address: pendingAddress, lastUsed: Date())
        computers.removeAll { $0.id == id }
        computers.insert(entry, at: 0)
        computers = Array(computers.prefix(5))
        ComputerStore.save(computers)
        activeComputer = entry
    }
    private func setRecording(_ value: Bool) {
        guard value != isRecording else { return }
        isRecording = value; recordingStart = value ? Date() : nil
    }
    private func tickPreview() {
        let now = ProcessInfo.processInfo.systemUptime
        previewReceivedAt = Date()
        if lastPreviewTime > 0 {
            let instant = 1 / max(now - lastPreviewTime, 0.001)
            previewFPS = previewFPS == 0 ? instant : previewFPS * 0.9 + instant * 0.1
        }
        lastPreviewTime = now
    }
    func suspend() { command("stop"); disconnect(); status = "Paused — reconnect when ready" }
    func disconnect() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        trackingReady = false; orientationGate = TrackingOrientation(); latestTrackingQuality = "lost"
        activationPrompt = "Tap to activate camera"
        supportsTakeBrowser = false; takes = []; selectedTake = ""; reviewPlaying = false
        heartbeat?.cancel(); heartbeat = nil
        paired = false; isConnected = false; isConnecting = false; quality = "Not tracking"; ar.pause(); motion.stopDeviceMotionUpdates()
        previewImage = nil; previewFPS = 0; lastPreviewTime = 0; setRecording(false); activeComputer = nil
        previewReceivedAt = nil; supportsPreviewControl = false
        socket?.cancel(with: .goingAway, reason: nil); socket = nil
    }
    private func fail(_ error: Error) { disconnect(); status = error.localizedDescription }
}
