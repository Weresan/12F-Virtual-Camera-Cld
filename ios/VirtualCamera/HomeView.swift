import SwiftUI
import VisionKit

enum Theme {
    static let background = Color(red: 23/255, green: 36/255, blue: 59/255) // INK #17243B
    static let card = Color(red: 29/255, green: 46/255, blue: 73/255)
    static let accent = Color(red: 0.22, green: 0.57, blue: 1.0)
}

/// Launch screen: previously paired computers plus Scan QR / paste-link actions.
struct HomeView: View {
    @ObservedObject var model: CameraModel
    let scan: () -> Void
    let manual: () -> Void

    var body: some View {
        GeometryReader { geo in
            let landscape = geo.size.width > geo.size.height
            ZStack {
                Theme.background.ignoresSafeArea()
                if landscape {
                    HStack(spacing: 48) {
                        brand.frame(maxWidth: .infinity)
                        panel.frame(maxWidth: .infinity)
                    }.padding(.horizontal, 32).padding(.vertical, 16)
                } else {
                    VStack(spacing: 28) {
                        brand
                        panel
                    }.padding(24)
                }
            }
        }
    }

    private var brand: some View {
        VStack(spacing: 10) {
            Image(systemName: "camera.aperture")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Theme.accent)
            Text("12F Virtual Camera").font(.title2.weight(.semibold))
            Text("12FRAMES STUDIO").font(.caption2).tracking(4).foregroundStyle(.secondary)
        }
    }

    private var panel: some View {
        VStack(spacing: 14) {
            computerList
            if shouldShowStatus {
                Text(model.status)
                    .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            HStack {
                Button(action: scan) { Label("Scan QR Code", systemImage: "qrcode.viewfinder") }
                    .disabled(!DataScannerViewController.isSupported)
                Spacer()
                Button(action: manual) { Label("Enter Link", systemImage: "link") }
            }
            .font(.subheadline.weight(.semibold))
            .tint(Theme.accent)
            .padding(.horizontal, 6)
        }
    }

    private var shouldShowStatus: Bool {
        !["Disconnected", "Paired"].contains(model.status)
    }

    private var computerList: some View {
        ScrollView {
            VStack(spacing: 4) {
                if model.computers.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "desktopcomputer").font(.title).foregroundStyle(.secondary)
                        Text("No computers yet").font(.headline)
                        Text("In Blender, open the 12F panel and scan its QR code.")
                            .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }.padding(.vertical, 36).frame(maxWidth: .infinity)
                } else {
                    ForEach(model.computers) { computer in
                        ComputerRow(computer: computer,
                                    connecting: model.isConnecting && model.address == computer.address) {
                            model.connect(to: computer)
                        }
                        .contextMenu {
                            Button("Forget", role: .destructive) { model.forget(computer) }
                        }
                    }
                }
            }.padding(10)
        }
        .frame(minHeight: 150, maxHeight: 230)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct ComputerRow: View {
    let computer: SavedComputer
    let connecting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "cube.transparent").font(.title2).frame(width: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(computer.name).font(.headline)
                    Text("\(computer.host) · \(computer.lastUsed.formatted(.relative(presentation: .named)))")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if connecting { ProgressView() }
                else { Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary) }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Fallback for devices without the scanner, or for pasting a link from Blender.
struct ManualEntrySheet: View {
    @ObservedObject var model: CameraModel
    @Environment(\.dismiss) private var dismiss
    let connect: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Pairing link from Blender") {
                    TextField("https://192.168.1.10:8765/#token=…", text: $model.address)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .keyboardType(.URL)
                }
                #if DEBUG
                Section {
                    Toggle("Allow unencrypted LAN development connection", isOn: $model.allowInsecureLAN)
                } footer: {
                    Text("Use only on trusted Wi-Fi. Release builds require HTTPS.")
                }
                #endif
            }
            .navigationTitle("Enter Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") { dismiss(); connect() }
                        .disabled(model.address.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
