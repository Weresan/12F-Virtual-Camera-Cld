import SwiftUI

/// Landscape monitor: full-screen Blender preview with overlaid controls.
struct LiveCameraView: View {
    @ObservedObject var model: CameraModel
    @State private var showControls = false
    @State private var showTakes = false
    @AppStorage("compositionGuide") private var guideChoice = GuideMode.thirds.rawValue
    @State private var monitorZoom = 1.0
    @State private var pinchStart = 1.0
    @State private var pan = CGSize.zero
    @State private var panStart = CGSize.zero

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
        .overlay {
            if !model.trackingReady && model.monitorSource == "LIVE" {
                Label("Hold phone in landscape — tracking paused", systemImage: "iphone.gen3.radiowaves.left.and.right")
                    .font(.headline).padding().background(Theme.background.opacity(0.95), in: RoundedRectangle(cornerRadius: 12))
                    .allowsHitTesting(false)
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .tint(Theme.accent)
        .sheet(isPresented: $showTakes) { TakeBrowserView(model: model) }
    }

    // MARK: Preview

    private var preview: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { clock in
            let fresh = model.previewReceivedAt.map { clock.date.timeIntervalSince($0) < 2 } ?? false
            GeometryReader { geometry in
                if let image = model.previewImage {
                    let rect = CompositionGeometry.fittedRect(image:image.size,container:geometry.size)
                    ZStack {
                        Image(uiImage:image).resizable().scaledToFit()
                            .scaleEffect(monitorZoom).offset(pan).opacity(fresh ? 1 : 0.3)
                    }.frame(width:rect.width,height:rect.height).clipped()
                        .position(x:rect.midX,y:rect.midY)
                        .gesture(MagnificationGesture().onChanged { value in
                            monitorZoom = min(4,max(1,pinchStart*value))
                            if monitorZoom == 1 { pan = .zero }
                        }.onEnded { _ in pinchStart = monitorZoom; panStart = pan })
                        .simultaneousGesture(DragGesture().onChanged { value in
                            let x = rect.width*(monitorZoom-1)/2, y = rect.height*(monitorZoom-1)/2
                            pan = CGSize(width:min(x,max(-x,panStart.width+value.translation.width)),
                                         height:min(y,max(-y,panStart.height+value.translation.height)))
                        }.onEnded { _ in panStart = pan })
                    if monitorZoom == 1 {
                        Path { path in
                            for line in CompositionGeometry.lines(GuideMode(rawValue:guideChoice) ?? .none,in:rect) {
                                path.move(to:line.start); path.addLine(to:line.end)
                            }
                        }.stroke(.white.opacity(0.5),lineWidth:0.75).allowsHitTesting(false)
                    }
                }
                if !fresh {
                    VStack(spacing:10) {
                        Image(systemName:"video.slash").font(.title2).foregroundStyle(Theme.accent)
                        Text(model.previewImage == nil ? "Waiting for live preview" : "Preview stalled").font(.headline)
                        Text(model.previewStatus).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }.frame(maxWidth:.infinity,maxHeight:.infinity).padding(50)
                }
            }
        }.ignoresSafeArea()
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
                Text(model.cameraName).font(.footnote.weight(.semibold))
                Text(model.status).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
            }
            .padding(.horizontal, 12).frame(height: 40)
            .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            if let start = model.recordingStart { RecordingTimer(start: start) }

            TimelineView(.periodic(from: .now, by: 0.5)) { clock in
                let fresh = model.previewReceivedAt.map { clock.date.timeIntervalSince($0) < 2 } ?? false
                Text("\(fresh ? Int(model.previewFPS.rounded()) : 0) fps · \(model.quality)")
            }
                .font(.caption.monospacedDigit()).foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 10).frame(height: 28)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.trailing, 80) // keep clear of the right-hand rail
        }
    }

    private var qualityColor: Color {
        switch model.quality {
        case "normal": return Theme.accent
        case "limited": return .orange
        case "lost": return .red
        default: return .gray
        }
    }

    // MARK: Right rail

    private var rail: some View {
        VStack(spacing: 12) {
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
            .disabled(!model.isRecording && (model.needsRecenter || model.quality != "normal"))
            RailButton(symbol: "slider.horizontal.3", label: "Lens") {
                withAnimation(.easeInOut(duration: 0.2)) { showControls.toggle() }
            }
            Menu {
                Picker("Composition",selection:$guideChoice) {
                    ForEach(GuideMode.allCases) { guide in Text(guide.rawValue).tag(guide.rawValue) }
                }
            } label: {
                Image(systemName:"grid").frame(width:44,height:34)
                    .background(Theme.background.opacity(0.9),in:Capsule())
            }.tint(Theme.accent).accessibilityLabel("Composition guides")
            Button {
                monitorZoom = monitorZoom == 1 ? 2 : 1; pinchStart = monitorZoom; pan = .zero; panStart = .zero
            } label: {
                Text(String(format:"%.0f×",monitorZoom)).font(.caption.monospacedDigit().bold())
                    .frame(width:44,height:34).background(Theme.background.opacity(0.9),in:Capsule())
            }.tint(Theme.accent).accessibilityLabel("Monitor magnification, does not affect camera")
            if model.supportsPreviewControl {
                Button { model.command(model.previewEnabled ? "preview_stop" : "preview_start") } label: {
                    Image(systemName:model.previewEnabled ? "video.fill" : "video.slash")
                        .frame(width:44,height:30).background(Theme.background.opacity(0.9),in:Capsule())
                }.tint(Theme.accent).accessibilityLabel("Toggle live preview")
            }
        }
    }

    // MARK: Bottom bar

    @ViewBuilder private var bottomBar: some View {
        HStack {
            Button { showTakes = true } label: {
                Label("Takes",systemImage: "film.stack").font(.footnote.weight(.semibold))
                    .padding(10).background(.ultraThinMaterial,in:Capsule())
            }.tint(Theme.accent)
            if model.monitorSource == "TAKE" {
                TakePlaybackBar(model: model)
            } else if showControls {
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
                ControlSlider(title: "Zoom / Lens", valueText: String(format: "%.0f mm", model.lens),
                              value: settingBinding("lens"), range: 8...300)
                HStack(spacing: 6) {
                    ForEach([24.0, 35, 50, 85, 135], id: \.self) { mm in
                        Button("\(Int(mm))") { settingBinding("lens").wrappedValue = mm }
                            .font(.caption2.weight(.semibold)).buttonStyle(.bordered)
                            .controlSize(.mini)
                            .tint(model.lens == mm ? Theme.accent : .gray)
                    }
                }
            }
            ControlSlider(title: "Focus", valueText: String(format: "%.1f m", model.focus),
                          value: logBinding(settingBinding("focus"), min: 0.1, max: 100), range: 0...1)
            ControlSlider(title: "Aperture", valueText: String(format: "f/%.1f", model.aperture),
                          value: settingBinding("aperture"), range: 0.7...22)
            Button { withAnimation(.easeInOut(duration: 0.2)) { showControls = false } } label: {
                Image(systemName: "chevron.down").font(.footnote.weight(.bold))
            }.tint(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .disabled(model.monitorSource == "TAKE")
    }

    /// Focus distance feels natural on a log scale (0.1 m … 100 m).
    private func logBinding(_ value: Binding<Double>, min lo: Double, max hi: Double) -> Binding<Double> {
        Binding(get: { log(value.wrappedValue / lo) / log(hi / lo) },
                set: { value.wrappedValue = lo * pow(hi / lo, $0) })
    }

    private func tap() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    private func settingBinding(_ name: String) -> Binding<Double> {
        Binding(get: { name == "lens" ? model.lens : name == "focus" ? model.focus : model.aperture },set: { value in
            if name == "lens" { model.lens = value } else if name == "focus" { model.focus = value } else { model.aperture = value }
            model.setting(name,value)
        })
    }
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
