import SwiftUI
import VisionKit

struct ContentView: View {
    @ObservedObject var model: CameraModel
    @Environment(\.scenePhase) private var phase
    @State private var scanning = false
    @State private var enteringLink = false
    @State private var scannedAddress: String?

    var body: some View {
        ZStack {
            if model.isConnected {
                LiveCameraView(model: model).transition(.opacity)
            } else {
                HomeView(model: model, scan: { scanning = true }, manual: { enteringLink = true })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: model.isConnected)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $scanning, onDismiss: {
            if let value = scannedAddress {
                scannedAddress = nil; model.address = value; model.connect()
            }
        }) {
            NavigationStack {
                QRScanner { value in scannedAddress = value; scanning = false }
                    .navigationTitle("Scan Blender QR")
                    .toolbar { Button("Cancel") { scanning = false } }
            }
        }
        .sheet(isPresented: $enteringLink) {
            ManualEntrySheet(model: model) { model.connect() }
        }
        .onChange(of: phase) { if $0 == .background { model.suspend() } }
        .onChange(of: model.isConnected) { connected in
            OrientationControl.apply(.allButUpsideDown)
            UIApplication.shared.isIdleTimerDisabled = connected
        }
    }
}

struct QRScanner: UIViewControllerRepresentable {
    let found: (String) -> Void
    func makeUIViewController(context: Context) -> ScannerHost { ScannerHost(found: found) }
    func updateUIViewController(_ controller: ScannerHost, context: Context) {}
    static func dismantleUIViewController(_ controller: ScannerHost, coordinator: ()) { controller.stop() }
}

import AVFoundation

final class ScannerHost: UIViewController, DataScannerViewControllerDelegate {
    private let found: (String) -> Void
    private var scanner: DataScannerViewController?
    private var delivered = false
    private var stopped = false
    init(found: @escaping (String) -> Void) { self.found = found; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) is unsupported") }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { @MainActor in
            let allowed = await AVCaptureDevice.requestAccess(for: .video)
            guard !stopped, scanner == nil else { return }
            guard allowed else { showError("Allow camera access in Settings, or cancel and paste the pairing URL."); return }
            guard DataScannerViewController.isSupported, DataScannerViewController.isAvailable else {
                showError("QR scanning unavailable. Cancel and paste the pairing URL."); return
            }
            let child = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.qr])],
                qualityLevel: .balanced, recognizesMultipleItems: false, isHighlightingEnabled: true)
            scanner = child; child.delegate = self
            addChild(child); child.view.frame = view.bounds
            child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(child.view); child.didMove(toParent: self)
            do { try child.startScanning() } catch { showError(error.localizedDescription) }
        }
    }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); stop() }
    func stop() { stopped = true; scanner?.stopScanning() }
    private func showError(_ text: String) {
        let label = UILabel(frame: view.bounds.insetBy(dx: 24, dy: 24))
        label.text = text; label.numberOfLines = 0; label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]; view.addSubview(label)
    }
    private func accept(_ item: RecognizedItem) {
        guard !delivered else { return }
        if case .barcode(let barcode) = item, let value = barcode.payloadStringValue {
            delivered = true; stop(); found(value)
        }
    }
    func dataScanner(_ scanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems { accept(item) }
    }
    func dataScanner(_ scanner: DataScannerViewController, didTapOn item: RecognizedItem) { accept(item) }
}
