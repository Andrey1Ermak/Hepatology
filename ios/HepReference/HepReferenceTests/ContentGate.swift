import Foundation
@testable import HepReference

/// The release-gate rules from CLAUDE.md §3.2–§3.3 and §5, written as pure
/// functions that return human-readable violations. `ContentIntegrityTests`
/// runs them on the bundled content; `ContentGateTests` runs them on
/// fixtures, so each rule is proven to bite before any card relies on it.
enum ContentGate {
    // MARK: Reachability (§3.2: no more than 3 taps to orders)

    /// Every bundled card must sit on a home tile: Home → tile → card is
    /// two steps. A card whose category never reaches the home screen would
    /// be findable only by search.
    static func unreachableCards(manifestEntries: [ManifestEntry], cardsByID: [String: Card]) -> [String] {
        let onTiles = homeCardIDs(CardLibrary.homeSections(
            from: CardLibrary.groupedSections(manifestEntries: manifestEntries, cardsByID: cardsByID)
        ))
        return cardsByID.keys.sorted().filter { !onTiles.contains($0) }
            .map { "\($0): not reachable from the home screen in two steps" }
    }

    /// Every card on a home tile, Reference included — the same sections
    /// `HomeView` renders.
    static func homeCardIDs(_ home: CardLibrary.HomeSections) -> Set<String> {
        Set((home.problems + [home.reference].compactMap { $0 }).flatMap { $0.cards.map(\.id) })
    }

    // MARK: No dead ends (§3.2)

    /// Every `out` ends in something to do: a pill, a subtext, a card link or
    /// a calculator link. An outcome with only a condition leaves the fellow
    /// with nowhere to go.
    static func deadEnds(in pathway: Pathway) -> [String] {
        var found: [String] = []
        func walk(_ nodes: [PathwayNode]) {
            for node in nodes {
                if case let .out(condition, pills, subtext, linkCalcId, _, _, linkCardId) = node {
                    let hasSubtext = !(subtext ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    let label = condition ?? "(no condition)"
                    if pills.isEmpty, !hasSubtext, linkCalcId == nil, linkCardId == nil {
                        found.append("\(pathway.id): outcome '\(label)' is a dead end — add a pill, subtext, link_card_id or link_calc_id")
                    }
                    if pills.contains(where: { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                        found.append("\(pathway.id): outcome '\(label)' has a pill without text")
                    }
                }
                walk(node.children)
            }
        }
        walk(pathway.children)
        return found
    }

    // MARK: Anatomy (§3.3)

    /// The sections of the card anatomy, in their required order. Blocks
    /// that are not anatomy sections (`lab_norms`, `numeric_calc`, info
    /// notes, tables…) may sit anywhere.
    enum Section: Int, Comparable, CaseIterable {
        case redFlags = 1, age, algorithm, firstContact, dontMiss, why, pearls, guidelines, testYourself

        static func < (a: Section, b: Section) -> Bool { a.rawValue < b.rawValue }

        var name: String {
            switch self {
            case .redFlags: "Red flags"
            case .age: "Age"
            case .algorithm: "Algorithm"
            case .firstContact: "First contact"
            case .dontMiss: "Don't miss"
            case .why: "Why"
            case .pearls: "Pearls & pitfalls"
            case .guidelines: "Guidelines"
            case .testYourself: "Test yourself"
            }
        }
    }

    /// The anatomy section a block fills, if any. `list` and `text` are
    /// generic block types, so only their §3.3 headings count (straight or
    /// curly apostrophe). A crit note or `chip_screen` is the red-flags
    /// section only as the card's first block — further down it is a
    /// warning or a calculator inside another section (e.g. `c_vitk_inr`
    /// after the workup).
    static func section(of block: Block, at index: Int) -> Section? {
        func heading(_ h: String?) -> String {
            (h ?? "").replacingOccurrences(of: "\u{2019}", with: "'").trimmingCharacters(in: .whitespaces)
        }
        return switch block {
        case .note(let b) where b.k == .crit: index == 0 ? .redFlags : nil
        case .chipScreen: index == 0 ? .redFlags : nil
        case .ageSwitch: .age
        case .pathway: .algorithm
        case .workup: .firstContact
        case .list(let b) where heading(b.h) == Section.dontMiss.name: .dontMiss
        case .text(let b) where heading(b.h) == Section.why.name: .why
        case .pearls: .pearls
        case .guidelineCompare: .guidelines
        case .cases: .testYourself
        default: nil
        }
    }

    /// An algorithm card (every card outside `cat: ref`; it must declare
    /// an `entry` other than `reference`) opens with red flags, has an
    /// algorithm, first-contact orders and a don't-miss list, cites at
    /// least one guideline and one plan block, and keeps the anatomy
    /// sections in §3.3 order. Reference cards (`cat: ref`) are free-form,
    /// and `entry: reference` is theirs alone — on any other card it would
    /// switch the whole check off.
    static func anatomyViolations(of card: Card) -> [String] {
        if card.cat == .ref {
            if let entry = card.entry, entry != .reference {
                return ["\(card.id): reference card with entry \"\(entry.rawValue)\" — use \"reference\""]
            }
            return []
        }
        guard let entry = card.entry else { return ["\(card.id): algorithm card without \"entry\""] }
        guard entry != .reference else {
            return ["\(card.id): entry \"reference\" on a \(card.cat.rawValue) card — only cat: ref cards are reference"]
        }

        var found: [String] = []
        let sections = card.blocks.enumerated().map { section(of: $1, at: $0) }
        if sections.first != .redFlags {
            found.append("\(card.id): first block must be red flags (note k: crit or chip_screen)")
        }
        let present = Set(sections.compactMap { $0 })
        if !present.contains(.algorithm), !present.contains(.age) {
            found.append("\(card.id): no algorithm (pathway or age_switch)")
        }
        for required in [Section.firstContact, .dontMiss] where !present.contains(required) {
            found.append("\(card.id): no \(required.name) block")
        }
        if (card.guidelines ?? []).isEmpty {
            found.append("\(card.id): cites no guideline")
        }
        if (card.plan ?? []).isEmpty {
            found.append("\(card.id): no plan block")
        }
        var highest: Section?
        for current in sections.compactMap({ $0 }) {
            if let highest, current < highest {
                found.append("\(card.id): \(current.name) after \(highest.name) — order per §3.3")
            }
            highest = max(highest ?? current, current)
        }
        return found
    }

    // MARK: Freshness (§3.2: "freshness is visible")

    /// Guidelines whose last check (`checked`, "YYYY-MM") is more than
    /// `months` months before `now`. A warning, not a failure: an old check
    /// means "look again", not "the content is wrong".
    static func staleGuidelines(_ guidelines: [Guideline], now: Date, months: Int = 12) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let today = calendar.dateComponents([.year, .month], from: now)
        guard let year = today.year, let month = today.month else { return [] }
        let nowIndex = year * 12 + month
        return guidelines.compactMap { g in
            let parts = g.checked.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 2 else { return nil } // format is checked in testRegistryLinksResolve
            let age = nowIndex - (parts[0] * 12 + parts[1])
            return age > months ? "\(g.id): checked \(g.checked), \(age) months ago — look for a newer version" : nil
        }
    }
}
