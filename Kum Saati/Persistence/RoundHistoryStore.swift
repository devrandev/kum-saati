import Foundation

@MainActor
final class RoundHistoryStore {
    static let retention: TimeInterval = 60 * 24 * 60 * 60
    let fileURL: URL
    private(set) var canWrite = true

    init(directory: URL? = nil) {
        let folder = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("KumSaati", isDirectory: true)
        fileURL = folder.appendingPathComponent("rounds.json")
    }
    func load() throws -> [CompletedRound] {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
            return try JSONDecoder().decode([CompletedRound].self, from: Data(contentsOf: fileURL))
        } catch {
            // Okunamayan geçmişi daha sonra boş bir diziyle ezme.
            canWrite = false
            throw error
        }
    }
    func retained(_ rounds: [CompletedRound], at now: Date) -> [CompletedRound] {
        rounds.filter { $0.date >= now.addingTimeInterval(-Self.retention) }
    }
    func save(_ rounds: [CompletedRound]) throws {
        guard canWrite else { return }
        try JSONEncoder().encode(rounds).write(to: fileURL, options: .atomic)
    }
}
