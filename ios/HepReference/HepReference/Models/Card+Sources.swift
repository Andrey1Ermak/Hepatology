import Foundation

extension Card {
    /// The card's guidelines resolved from the registry, in the card's own
    /// order; ids the registry doesn't know are skipped (the integrity gate
    /// fails on them before release).
    func sources(in guidelines: [Guideline]) -> [Guideline] {
        let byID = Dictionary(guidelines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return (self.guidelines ?? []).compactMap { byID[$0] }
    }

    /// The header's source line, "NASPGHAN/ESPGHAN 2017 · AAP 2022", built
    /// from `guidelines.json` so society and year live in one place. Falls
    /// back to the hand-written `code` while a card cites no registered
    /// guideline (e.g. About).
    func sourceLine(in guidelines: [Guideline]) -> String? {
        let resolved = sources(in: guidelines)
        guard !resolved.isEmpty else { return subtitle }
        return resolved.map { "\($0.society) \($0.year)" }.uniquedInOrder().joined(separator: " · ")
    }

    /// "Checked 10/2026" — the *oldest* `checked` month among the card's
    /// sources, so the line never claims more freshness than its weakest
    /// source. Nil when no source is resolved or a date is malformed.
    func checkedLabel(in guidelines: [Guideline]) -> String? {
        let months = sources(in: guidelines).map(\.checked)
        guard !months.isEmpty,
              months.allSatisfy(Self.isYearMonth),
              let oldest = months.min()
        else { return nil }
        let parts = oldest.split(separator: "-")
        return "Checked \(parts[1])/\(parts[0])"
    }

    /// "YYYY-MM": string order then equals date order.
    private static func isYearMonth(_ s: String) -> Bool {
        s.range(of: #"^\d{4}-(0[1-9]|1[0-2])$"#, options: .regularExpression) != nil
    }
}

extension AgeBand {
    /// Chip label in the card header (CLAUDE.md §5.1 bands).
    var label: String {
        switch self {
        case .neo: "0–28 d"
        case .infant: "1–12 mo"
        case .child: "1–10 y"
        case .teen: "11–18 y"
        }
    }

    /// What VoiceOver reads instead of the abbreviated chip.
    var spokenLabel: String {
        switch self {
        case .neo: "0 to 28 days"
        case .infant: "1 to 12 months"
        case .child: "1 to 10 years"
        case .teen: "11 to 18 years"
        }
    }
}

extension Card {
    /// One line per year-plan day the card cites, "Block 2 · Day 1 — topic";
    /// the topic is left off when `plan.json` doesn't know the day.
    func studyDays(in plan: [PlanBlock]) -> [String] {
        (self.plan ?? []).flatMap { ref in
            let block = plan.first { $0.block == ref.block }
            return ref.days.map { day in
                let topic = block?.days.first { $0.day == day }?.topic
                return "Block \(ref.block) · Day \(day)" + (topic.map { " — \($0)" } ?? "")
            }
        }
    }
}

extension CardStatus {
    var label: String {
        switch self {
        case .draft: "Draft"
        case .reviewed: "Reviewed"
        case .approved: "Approved"
        }
    }
}

private extension Array where Element == String {
    func uniquedInOrder() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}
