import Foundation

extension Card {
    /// The short source line shown under the title in card lists and the card
    /// header, e.g. "NASPGHAN/ESPGHAN 2017 · AAP 2022". Taken from `code`
    /// verbatim; `nil` when `code` is blank so no empty subtitle renders.
    var subtitle: String? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
