import Foundation

/// One row of `manifest.json` — card order plus its section-header grouping,
/// e.g. `{"id":"phones","cat":"ref","section":"REFERENCE"}`. Every entry
/// carries its own explicit `section` (no positional inheritance): the same
/// clinical topic is sometimes appended to the manifest in more than one
/// place, and inferring a card's section from whichever labeled entry
/// preceded it silently mis-groups anything appended out of order.
struct ManifestEntry: Identifiable, Decodable {
    let id: String
    let cat: CardCategory
    let section: String
}

enum Manifest {
    static func decode(from data: Data) throws -> [ManifestEntry] {
        try JSONDecoder().decode([ManifestEntry].self, from: data)
    }

    /// Groups entries by `section`, preserving each section's first-appearance
    /// order and each entry's original order within its section — a stable
    /// partition, not an adjacency run, since entries sharing a section can
    /// be scattered non-contiguously in manifest.json.
    static func grouped(_ entries: [ManifestEntry]) -> [(section: String, entries: [ManifestEntry])] {
        var order: [String] = []
        var bySection: [String: [ManifestEntry]] = [:]
        for entry in entries {
            if bySection[entry.section] == nil {
                order.append(entry.section)
            }
            bySection[entry.section, default: []].append(entry)
        }
        return order.map { (section: $0, entries: bySection[$0]!) }
    }
}
