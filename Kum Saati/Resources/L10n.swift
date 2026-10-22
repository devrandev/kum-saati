import Foundation

enum L10n {
    static var appName: String { String(localized: "app.name", defaultValue: "Kum Saati") }
    static var ready: String { String(localized: "timer.ready", defaultValue: "Hazır") }
    static var completed: String { String(localized: "timer.completed", defaultValue: "Tamamlandı") }
    static var running: String { String(localized: "timer.running", defaultValue: "Çalışıyor") }
    static var paused: String { String(localized: "timer.paused", defaultValue: "Duraklatıldı") }
    static var duration: String { String(localized: "timer.duration", defaultValue: "Tur süresi") }
    static var minutes: String { String(localized: "timer.minutes", defaultValue: "Dakika") }
    static var minuteUnit: String { String(localized: "timer.minuteUnit", defaultValue: "dk") }
    static var apply: String { String(localized: "action.apply", defaultValue: "Uygula") }
    static var durationHint: String { String(localized: "timer.durationHint", defaultValue: "Süreyi uygulamak mevcut turu sıfırlar.") }
    static var pause: String { String(localized: "action.pause", defaultValue: "Duraklat") }
    static var newRound: String { String(localized: "action.newRound", defaultValue: "Yeni tur") }
    static var start: String { String(localized: "action.start", defaultValue: "Başlat") }
    static var reset: String { String(localized: "action.reset", defaultValue: "Sıfırla") }
    static var statistics: String { String(localized: "history.title", defaultValue: "İstatistik") }
    static var completedRounds: String { String(localized: "history.completedRounds", defaultValue: "tamamlanan tur") }
    static var historyHint: String { String(localized: "history.retentionHint", defaultValue: "Geçmiş 60 gün saklanır. Süresi elle değiştirilen turlar sayılmaz.") }
    static var controlsHint: String { String(localized: "circle.controlsHint", defaultValue: "Merkez: taşı • Kenar: süreyi sar\nSağ alt tutamaç: boyutlandır\nÇift tık: başlat / duraklat / yeni tur") }
    static var showCircle: String { String(localized: "action.showCircle", defaultValue: "Daireyi göster") }
    static var quit: String { String(localized: "action.quit", defaultValue: "Çıkış") }
    static var circleAccessibility: String { String(localized: "circle.accessibility", defaultValue: "Kum Saati. Çift tıklayarak başlat veya duraklat.") }
    static var last12Hours: String { String(localized: "history.last12Hours", defaultValue: "Son 12 saat") }
    static var last15Hours: String { String(localized: "history.last15Hours", defaultValue: "Son 15 saat") }
    static var last10Days: String { String(localized: "history.last10Days", defaultValue: "Son 10 gün") }
    static var currentMonth: String { String(localized: "history.currentMonth", defaultValue: "Bu ay") }

    static func roundCount(_ count: Int) -> String {
        String(format: String(localized: "history.roundCount", defaultValue: "%lld tur"), locale: Locale.current, Int64(count))
    }
    static func historyReadError(_ detail: String) -> String {
        String(format: String(localized: "history.readError", defaultValue: "Geçmiş okunamadı: %@"), detail)
    }
    static func historyWriteError(_ detail: String) -> String {
        String(format: String(localized: "history.writeError", defaultValue: "Geçmiş kaydedilemedi: %@"), detail)
    }
}
