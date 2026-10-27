import Foundation

struct RecordedTake: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    let start: Int
    let end: Int
    let fps: Double
    var duration: Double { Double(max(0, end - start)) / max(1, fps) }
}
