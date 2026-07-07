import Foundation
import Combine

@MainActor
final class PostnapStore: ObservableObject {
    @Published var entries: [PostnapEntry] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Seed data ships with 3 entries, kept well below this
    /// limit so a fresh install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileName = "postnap_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Self.freeLimit
    }

    func add(_ entry: PostnapEntry) {
        guard canAddMore else { return }
        entries.insert(entry, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func update(_ entry: PostnapEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    private func seed() {
        let cal = Calendar.current
        entries = [
            PostnapEntry(date: cal.date(byAdding: .day, value: -2, to: Date()) ?? Date(), note: "Sample entry", value1: "5", value2: "3"),
            PostnapEntry(date: cal.date(byAdding: .day, value: -1, to: Date()) ?? Date(), note: "Sample entry", value1: "6", value2: "2"),
            PostnapEntry(date: Date(), note: "Sample entry", value1: "7", value2: "1"),
        ]
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([PostnapEntry].self, from: data) {
            entries = decoded
        }
    }
}
