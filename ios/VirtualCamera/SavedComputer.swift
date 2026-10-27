import Foundation

/// A Blender machine the phone has paired with before. `address` is the full pairing URL
/// (including the token), so tapping the card reconnects without rescanning, as long as
/// Blender's server has not been restarted (a restart rotates the token).
struct SavedComputer: Codable, Identifiable, Equatable {
    var id: String          // "host:port"
    var name: String
    var host: String
    var address: String
    var lastUsed: Date
}

enum ComputerStore {
    private static let key = "savedComputers"

    static func load() -> [SavedComputer] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([SavedComputer].self, from: data) else { return [] }
        return list.sorted { $0.lastUsed > $1.lastUsed }
    }

    static func save(_ list: [SavedComputer]) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
