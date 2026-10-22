import Foundation

enum HistoryFilter: String, CaseIterable, Identifiable {
    case twelve = "last12Hours", fifteen = "last15Hours", tenDays = "last10Days", month = "currentMonth"
    var title: String {
        switch self {
        case .twelve: return L10n.last12Hours
        case .fifteen: return L10n.last15Hours
        case .tenDays: return L10n.last10Days
        case .month: return L10n.currentMonth
        }
    }
    static func restore(_ value: String?) -> HistoryFilter {
        if let value, let filter = Self(rawValue: value) { return filter }
        // Önceki sürüm Türkçe başlıkları kimlik olarak saklıyordu.
        switch value {
        case "Son 15 saat": return .fifteen
        case "Son 10 gün": return .tenDays
        case "Bu ay": return .month
        default: return .twelve
        }
    }
    var id: String { rawValue }
    func start(at now: Date) -> Date {
        switch self {
        case .twelve: return now.addingTimeInterval(-12 * 3600)
        case .fifteen: return now.addingTimeInterval(-15 * 3600)
        case .tenDays: return now.addingTimeInterval(-10 * 86400)
        case .month: return Calendar.current.dateInterval(of: .month, for: now)!.start
        }
    }
}

