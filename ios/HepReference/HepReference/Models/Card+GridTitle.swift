import Foundation

extension Card {
    /// A shorter display name for the card-list grid's compact two-column
    /// tiles. `title` itself (shown in Card Detail, Search, and everywhere
    /// else) is never touched. Add an override only when a title is longer
    /// than `ContentIntegrityTests` allows (25 characters) — e.g.
    /// "chol_0_3m": "Cholestasis 0–3 mo".
    var gridTitle: String {
        Self.gridTitleOverrides[id] ?? title
    }

    private static let gridTitleOverrides: [String: String] = [:]
}
