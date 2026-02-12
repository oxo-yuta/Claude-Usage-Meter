import Foundation

enum JSONLReader {
    /// Read usage entries from all recent JSONL files
    static func readEntries(since cutoff: Date) -> [UsageEntry] {
        let projectsDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/projects")

        guard FileManager.default.fileExists(atPath: projectsDir.path) else {
            return []
        }

        let cutoffInterval = cutoff.timeIntervalSinceReferenceDate
        var seenIDs = Set<String>()
        var entries: [UsageEntry] = []

        let jsonlFiles = findJSONLFiles(in: projectsDir, modifiedAfter: cutoffInterval)

        let decoder = JSONDecoder()
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoFormatterNoFrac = ISO8601DateFormatter()
        isoFormatterNoFrac.formatOptions = [.withInternetDateTime]

        for fileURL in jsonlFiles {
            guard let data = try? Data(contentsOf: fileURL) else { continue }
            guard let content = String(data: data, encoding: .utf8) else { continue }

            for line in content.components(separatedBy: .newlines) {
                guard !line.isEmpty else { continue }
                guard let lineData = line.data(using: .utf8) else { continue }

                guard let record = try? decoder.decode(JSONLRecord.self, from: lineData) else {
                    continue
                }

                guard record.type == "assistant",
                      let message = record.message,
                      let messageID = message.id,
                      let model = message.model,
                      let usage = message.usage,
                      usage.outputTokens > 0,
                      let timestampStr = record.timestamp else {
                    continue
                }

                // Deduplicate by message ID
                guard !seenIDs.contains(messageID) else { continue }
                seenIDs.insert(messageID)

                // Parse timestamp
                guard let date = isoFormatter.date(from: timestampStr)
                        ?? isoFormatterNoFrac.date(from: timestampStr) else {
                    continue
                }

                // Only include entries since cutoff
                guard date >= cutoff else { continue }

                let entry = UsageEntry(
                    id: messageID,
                    timestamp: date,
                    model: model,
                    usage: usage
                )
                entries.append(entry)
            }
        }

        return entries.sorted { $0.timestamp < $1.timestamp }
    }

    /// Find all .jsonl files modified after the given date
    private static func findJSONLFiles(in directory: URL, modifiedAfter cutoff: TimeInterval) -> [URL] {
        var result: [URL] = []
        let fm = FileManager.default

        guard let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return result
        }

        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "jsonl" else { continue }

            guard let resourceValues = try? fileURL.resourceValues(
                forKeys: [.contentModificationDateKey, .isRegularFileKey]
            ) else { continue }

            guard resourceValues.isRegularFile == true else { continue }

            if let modDate = resourceValues.contentModificationDate,
               modDate.timeIntervalSinceReferenceDate >= cutoff {
                result.append(fileURL)
            }
        }

        return result
    }
}
