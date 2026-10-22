import Foundation

struct CompletedRound: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let duration: TimeInterval
}

