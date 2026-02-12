import Foundation

enum SessionAnalyzer {
    /// Detect 5-hour session blocks from sorted usage entries
    static func detectBlocks(from entries: [UsageEntry]) -> [SessionBlock] {
        guard !entries.isEmpty else { return [] }

        var blocks: [SessionBlock] = []
        var currentBlock: SessionBlock?

        for entry in entries {
            if let block = currentBlock {
                if entry.timestamp < block.endTime {
                    currentBlock?.entries.append(entry)
                } else {
                    blocks.append(block)
                    let start = floorToHour(entry.timestamp)
                    currentBlock = SessionBlock(startTime: start, entries: [entry])
                }
            } else {
                let start = floorToHour(entry.timestamp)
                currentBlock = SessionBlock(startTime: start, entries: [entry])
            }
        }

        if let block = currentBlock {
            blocks.append(block)
        }

        return blocks
    }

    /// Find the current active block (or the most recent one)
    static func currentBlock(from blocks: [SessionBlock]) -> SessionBlock? {
        // First try to find an active block
        if let active = blocks.last(where: { $0.isActive }) {
            return active
        }
        // Otherwise return the most recent block
        return blocks.last
    }

    /// Floor a date to the start of its hour
    private static func floorToHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: components) ?? date
    }
}
