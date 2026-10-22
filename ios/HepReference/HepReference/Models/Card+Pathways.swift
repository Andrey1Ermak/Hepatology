import Foundation

extension Card {
    /// Every pathway the card can show — `pathway` blocks and each
    /// `age_switch` branch — in reading order, each id once. Shared by
    /// `LinkIndex` and the integrity gate so neither misses a branch.
    var pathIds: [String] {
        var seen = Set<String>()
        return blocks.flatMap { block -> [String] in
            switch block {
            case .pathway(let b): [b.pathId]
            case .ageSwitch(let b): b.options.map(\.pathId)
            default: []
            }
        }
        .filter { seen.insert($0).inserted }
    }
}
