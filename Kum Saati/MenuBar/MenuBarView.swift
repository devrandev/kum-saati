import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: TimerModel
    let showCircle: () -> Void
    @State private var minutes: Double = 60
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.appName).font(.title2.bold())
                Spacer()
                Text(model.statusTitle)
                    .font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Text(L10n.duration)
                Spacer()
                TextField(L10n.minutes, value: $minutes, format: .number)
                    .frame(width: 70).textFieldStyle(.roundedBorder)
                Text(L10n.minuteUnit)
                Button(L10n.apply) { model.setDuration(minutes: minutes) }
                    .disabled(!minutes.isFinite || minutes < 1 || minutes > 1440)
            }
            Text(L10n.durationHint).font(.caption).foregroundStyle(.secondary)
            HStack {
                Button(model.running ? L10n.pause : model.finished ? L10n.newRound : L10n.start) { model.toggle() }
                    .buttonStyle(.borderedProminent).tint(.green)
                Button(L10n.reset) { model.reset() }
            }
            Divider()
            Picker(L10n.statistics, selection: $model.filter) {
                ForEach(HistoryFilter.allCases) { Text($0.title).tag($0) }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("\(model.count)").font(.largeTitle.bold())
                Text(L10n.completedRounds).foregroundStyle(.secondary)
            }
            Text(L10n.historyHint)
                .font(.caption).foregroundStyle(.secondary)
            if let error = model.storageError { Text(error).font(.caption).foregroundStyle(.red) }
            Divider()
            Text(L10n.controlsHint)
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Button(L10n.showCircle, action: showCircle)
                Spacer()
                Button(L10n.quit) { NSApp.terminate(nil) }
            }
        }
        .padding(20).frame(width: 350)
        .onAppear { minutes = model.duration / 60; model.pruneAndSave() }
    }
}
