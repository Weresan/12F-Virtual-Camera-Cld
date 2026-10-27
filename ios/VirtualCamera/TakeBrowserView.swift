import SwiftUI

struct TakeBrowserView: View {
    @ObservedObject var model: CameraModel
    @Environment(\.dismiss) private var dismiss
    @State private var renaming: RecordedTake?
    @State private var label = ""

    var body: some View {
        NavigationStack {
            List {
                if !model.supportsTakeBrowser {
                    Text("Update the Blender add-on to 0.2.3 to browse takes.")
                } else if model.takes.isEmpty {
                    Text("No recorded takes in this Blender scene yet. Record and stop a take to add it here.")
                }
                ForEach(model.takes) { take in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(take.label).font(.headline)
                            Text(String(format: "%.1f s · %.2f fps · frames %d–%d", take.duration, take.fps, take.start, take.end))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Review") { model.takeCommand("select", id: take.id); dismiss() }
                            .buttonStyle(.borderedProminent)
                        Button { label = take.label; renaming = take } label: { Image(systemName: "pencil") }
                            .buttonStyle(.bordered).accessibilityLabel("Rename take")
                    }.disabled(model.isRecording)
                }
            }
            .scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle("Recorded takes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button("Live camera") { model.takeCommand("live"); dismiss() }.disabled(model.isRecording)
                }
            }
            .alert("Rename take", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
                TextField("Take name", text: $label)
                Button("Save") {
                    if let take = renaming { model.takeCommand("rename", id: take.id, extra: ["label": String(label.prefix(80))]) }
                    renaming = nil
                }.disabled(label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Cancel", role: .cancel) { renaming = nil }
            }
        }.tint(Theme.accent).preferredColorScheme(.dark)
    }
}

struct TakePlaybackBar: View {
    @ObservedObject var model: CameraModel
    var body: some View {
        if let take = model.takes.first(where: { $0.id == model.selectedTake }) {
            HStack {
                Button { model.takeCommand("live") } label: { Image(systemName: "video.fill") }
                    .accessibilityLabel("Return to live camera")
                Button { model.takeCommand(model.reviewPlaying ? "pause" : "play", id: take.id) } label: {
                    Image(systemName: model.reviewPlaying ? "pause.fill" : "play.fill")
                }.accessibilityLabel(model.reviewPlaying ? "Pause take" : "Play take")
                Text(take.label).font(.caption).lineLimit(1).frame(maxWidth: 130)
                Slider(value: Binding(get: { Double(max(take.start,min(take.end,model.reviewFrame))) },
                    set: { model.takeCommand("scrub", id: take.id, extra: ["frame": Int($0.rounded())]) }),
                       in: Double(take.start)...Double(max(take.start + 1,take.end)), step: 1)
                    .frame(minWidth: 100, maxWidth: 250).disabled(take.start == take.end)
                Text("\(model.reviewFrame)").font(.caption.monospacedDigit())
            }.padding(12).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
