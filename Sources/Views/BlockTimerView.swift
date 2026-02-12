import SwiftUI

struct BlockTimerView: View {
    let block: SessionBlock

    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(L10n.blockTimer)
                    .font(.body.weight(.medium))
                Spacer()
                Text(Formatters.formatDurationShort(seconds: remainingSeconds))
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(remainingSeconds < 600 ? .orange : .primary)
            }

            HStack {
                Text("\(L10n.started):")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(block.startTime, style: .time)
                    .font(.subheadline)
                Spacer()
                Text("\(L10n.ends):")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(block.endTime, style: .time)
                    .font(.subheadline)
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: block.id) { _, _ in startTimer() }
    }

    private func startTimer() {
        updateRemaining()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemaining()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateRemaining() {
        let diff = block.endTime.timeIntervalSince(Date.now)
        remainingSeconds = max(0, Int(diff))
    }
}
