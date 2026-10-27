import SwiftUI

/// Landscape monitor: full-screen Blender preview with overlaid controls.
struct LiveCameraView: View {
    @ObservedObject var model: CameraModel
    @State private var showControls = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            preview
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                bottomBar
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
        }
        .overlay(alignment: .trailing) { rail.padding(.trailing, 12) }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onChange(of: model.lens) { model.setting("lens", $0) }
        .onChange(of: model.focus) { model.setting("focus", $0) }
        .onChange(of: model.aperture) { model.setting("aperture", $0) }
    }

    // MARK: Preview

    @ViewBuilder private var preview: some View {
        if let image = model.previewImage {
            Image(uiImage: image).resizable().scaledToFit().ignoresSafeArea()
        } else {
            VStack(spacing: 10) {
                ProgressView().tint(.white)
                Text("Waiting for Blender preview…").font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(alignment: .top) {
            Button { model.suspend() } label: {
                Image(systemName: "xmark").font(.body.weight(.semibold))
                    .frame(width: 40, height: 40).background(.ultraThinMaterial, in: Circle())
            }.tint(.white)

            HStack(spacing: 8) {
                Circle().fill(qualityColor).frame(width: 9, height: 9)
                Text(model.activeComputer?.name ?? "Blender").font(.footnote.weight(.semibold))
                Text(model.status).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
            }
            .padding(.horizontal, 12).frame(height: 40)
            .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            if let start = model.recordingStart { RecordingTimer(start: start) }

            Text("\(Int(model.previewFPS.rounded())) fps · \(model.quality)")
                .font(.caption.monospacedDigit()).foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 10).frame(height: 28)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.trailing, 80) // keep clear of the right-hand rail
        }
    }

    private var qualityColor: Color {
        switch model.quality {
        case "normal": return .green
        case "limited": return .orange
        case "lost": return .red
        default: return .gray
        }
    }

    // MARK: Right rail

    private var rail: some View {
        VStack(spacing: 22) {
            RailButton(symbol: "scope", label: "Recenter") {
                tap(); model.command("recenter")
            }
            Button {
                tap(); model.command(model.isRecording ? "stop" : "record")
            } label: {
                ZStack {
                    Circle().strokeBorder(.white, lineWidth: 4).frame(width: 72, height: 72)
                    RoundedRectangle(cornerRadius: model.isRecording ? 7 : 28, style: .continuous)
                        .fill(.red)
                        .frame(width: model.isRecording ? 28 : 56, height: model.isRecording ? 28 : 56)
                }
                .animation(.easeInOut(duration: 0.2), value: model.isRecording)
            }
            RailButton(symbol: "slider.horizontal.3", label: "Lens") {
                withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() }
            }
        }
    }

    // MARK: Bottom bar

    @ViewBuilder private var bottomBar: some View {
        HStack {
            if showControls {
                controlsPanel
            } else {
                Button { withAnimation(.easeInOut(duration: 0.2)) { showControls = true } } label: {
                    Text(String(format: "%.0f mm  ·  %.1f m  ·  f/%.1f", model.lens, model.focus, model.aperture))
                        .font(.footnote.monospacedDigit().weight(.medium))
                        .padding(.horizontal, 14).frame(height: 36)
                        .background(.ultraThinMaterial, in: Capsule())
                }.tint(.white)
            }
            Spacer()
        }
        .padding(.trailing, 90)
    }

    private var controlsPanel: some View {
        HStack(alignment: .top, spacing: 22) {
            VStack(spacing: 6) {
                ControlSlider(title: "Lens", valueText: String(format: "%.0f mm", model.lens),
                              value: $model.lens, range: 8...200)
                HStack(spacing: 6) {
                    ForEach([24.0, 35, 50, 85, 135], id: \.self) { mm in
                        Button("\(Int(mm))") { model.lens = mm }
                            .font(.caption2.weight(.semibold)).buttonStyle(.bordered)
                            .controlSize(.mini)
                            .tint(model.lens == mm ? Theme.accent : .gray)
                    }
                }
            }
            ControlSlider(title: "Focus", valueText: String(format: "%.1f m", model.focus),
                          value: logBinding($model.focus, min: 0.1, max: 100), range: 0...1)
            ControlSlider(title: "Aperture", valueText: String(format: "f/%.1f", model.aperture),
                          value: $model.aperture, range: 0.7...22)
            Button { withAnimation(.easeInOut(duration: 0.2)) { showControls = false } } label: {
                Image(systemName: "chevron.down").font(.footnote.weight(.bold))
            }.tint(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    /// Focus distance feels natural on a log scale (0.1 m … 100 m).
    private func logBinding(_ value: Binding<Double>, min lo: Double, max hi: Double) -> Binding<Double> {
        Binding(get: { log(value.wrappedValue / lo) / log(hi / lo) },
                set: { value.wrappedValue = lo * pow(hi / lo, $0) })
    }

    private func tap() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
}

private struct RailButton: View {
    let symbol: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: symbol).font(.title3)
                Text(label).font(.system(size: 10, weight: .medium))
            }
            .frame(width: 56, height: 56)
            .background(.ultraThinMaterial, in: Circle())
        }.tint(.white)
    }
}

private struct ControlSlider: View {
    let title: String
    let valueText: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text(valueText).font(.caption.monospacedDigit().weight(.semibold))
            }
            Slider(value: $value, in: range).tint(Theme.accent)
        }
        .frame(width: 170)
    }
}

private struct RecordingTimer: View {
    let start: Date
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(.red).frame(width: 9, height: 9)
            TimelineView(.periodic(from: start, by: 1)) { context in
                let seconds = max(0, Int(context.date.timeIntervalSince(start)))
                Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                    .font(.footnote.monospacedDigit().weight(.semibold))
            }
        }
        .padding(.horizontal, 12).frame(height: 28)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.trailing, 8)
    }
}
