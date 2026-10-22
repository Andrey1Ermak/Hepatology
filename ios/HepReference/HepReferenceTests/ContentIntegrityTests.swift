import XCTest
@testable import HepReference

/// The release gate for bundled content. Every file under Content/ must
/// decode, and every reference between files must resolve — a broken link
/// fails the build instead of silently rendering a placeholder. Extend this
/// file (never weaken it) as new link types are added.
final class ContentIntegrityTests: XCTestCase {
    private let bundle = Bundle(for: ContentIntegrityTests.self)

    private func jsonFiles(_ folder: String) -> [URL] {
        guard let dir = bundle.url(forResource: folder, withExtension: nil, subdirectory: "Content"),
              let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        else { return [] }
        return urls.filter { $0.pathExtension == "json" }.sorted { $0.path < $1.path }
    }

    private func decode<T: Decodable>(_ type: T.Type, _ url: URL) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        } catch {
            XCTFail("\(url.lastPathComponent) failed to decode as \(T.self): \(error)")
            throw error
        }
    }

    private func allCards() throws -> [Card] {
        try jsonFiles("Cards").map { try decode(Card.self, $0) }
    }

    // MARK: Decoding

    func testEveryFileDecodesAndIdMatchesFilename() throws {
        for url in jsonFiles("Cards") {
            XCTAssertEqual(try decode(Card.self, url).id, url.deletingPathExtension().lastPathComponent)
        }
        for url in jsonFiles("Pathways") {
            XCTAssertEqual(try decode(Pathway.self, url).id, url.deletingPathExtension().lastPathComponent)
        }
        for url in jsonFiles("Calculators") {
            let screen = try decode(ChipScreen.self, url)
            XCTAssertEqual(screen.id, url.deletingPathExtension().lastPathComponent)
            _ = screen.verdictRule // traps on an unregistered named rule_id
        }
        for url in jsonFiles("ScoreCalcs") {
            XCTAssertEqual(try decode(ScoreCalcSchema.self, url).id, url.deletingPathExtension().lastPathComponent)
        }
    }

    // MARK: Manifest

    func testManifestAndCardFilesMatchOneToOne() throws {
        let url = try XCTUnwrap(bundle.url(forResource: "manifest", withExtension: "json", subdirectory: "Content"))
        let entries = try Manifest.decode(from: Data(contentsOf: url))
        let manifestIDs = entries.map(\.id)
        XCTAssertEqual(Set(manifestIDs).count, manifestIDs.count, "duplicate id in manifest.json")

        let cards = Dictionary(uniqueKeysWithValues: try allCards().map { ($0.id, $0) })
        XCTAssertEqual(Set(manifestIDs), Set(cards.keys), "manifest.json and Content/Cards must list the same ids")
        for entry in entries {
            XCTAssertEqual(cards[entry.id]?.cat, entry.cat, "\(entry.id): manifest cat differs from card cat")
        }
    }

    // MARK: Card metadata (§5.1)

    /// Legacy `done`/`reviewed` booleans were replaced by `status`; a card
    /// still carrying them would decode silently and lose its badge.
    func testNoCardUsesLegacyStatusKeys() throws {
        for url in jsonFiles("Cards") {
            let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
            for key in ["done", "reviewed"] {
                XCTAssertNil(object[key], "\(url.lastPathComponent): legacy key '\(key)' — use \"status\"")
            }
        }
    }

    func testCardMetadataIsWellFormed() throws {
        let cards = try allCards()
        let ids = Set(cards.map(\.id))
        for card in cards {
            if let related = card.related {
                XCTAssertEqual(Set(related).count, related.count, "\(card.id): duplicate related id")
            }
            if let plan = card.plan {
                XCTAssertEqual(Set(plan.map(\.block)).count, plan.count, "\(card.id): plan block listed twice")
            }
            for id in card.related ?? [] {
                XCTAssertTrue(ids.contains(id), "\(card.id): related card '\(id)' missing")
                XCTAssertNotEqual(id, card.id, "\(card.id): lists itself as related")
            }
            for ref in card.plan ?? [] {
                XCTAssertTrue((1...26).contains(ref.block), "\(card.id): plan block \(ref.block) outside 1–26")
                XCTAssertEqual(Set(ref.days).count, ref.days.count, "\(card.id): duplicate day in plan block \(ref.block)")
                XCTAssertFalse(ref.days.isEmpty, "\(card.id): plan block \(ref.block) lists no days")
                for day in ref.days {
                    XCTAssertTrue((1...14).contains(day), "\(card.id): plan day \(day) outside 1–14")
                }
            }
            if let ages = card.ages {
                XCTAssertFalse(ages.isEmpty, "\(card.id): empty ages — omit the field instead")
            }
        }
    }

    // MARK: Registries (§5.5)

    private func registry<T: Decodable>(_ name: String, as type: T.Type) throws -> T {
        let url = try XCTUnwrap(
            bundle.url(forResource: name, withExtension: "json", subdirectory: "Content/Registry"),
            "Content/Registry/\(name).json missing"
        )
        return try decode(T.self, url)
    }

    func testEveryRegistryDecodes() throws {
        _ = try registry("guidelines", as: [Guideline].self)
        _ = try registry("labs", as: [LabTest].self)
        _ = try registry("plan", as: [PlanBlock].self)
        _ = try registry("cases", as: [ClinicalCase].self)
        _ = try registry("synonyms", as: [String: [String]].self)
    }

    /// 26 blocks × 14 days, each block starting the day after the previous one ends.
    func testPlanCoversTheYearWithoutGaps() throws {
        let plan = try registry("plan", as: [PlanBlock].self)
        XCTAssertEqual(plan.map(\.block), Array(1...26))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "UTC"))
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        var expectedStart: Date?
        for block in plan {
            XCTAssertEqual(block.days.map(\.day), Array(1...14), "block \(block.block): days must be 1–14")
            XCTAssertFalse(block.title.isEmpty, "block \(block.block): empty title")
            for day in block.days {
                XCTAssertFalse(day.topic.isEmpty, "block \(block.block) day \(day.day): empty topic")
            }
            let start = try XCTUnwrap(formatter.date(from: block.start), "block \(block.block): bad start '\(block.start)'")
            if let expectedStart {
                XCTAssertEqual(start, expectedStart, "block \(block.block): starts \(block.start), expected the day after block \(block.block - 1)")
            }
            expectedStart = calendar.date(byAdding: .day, value: 14, to: start)
        }
    }

    // TODO(day 5): once plan.json lists cards, also require that each listed
    // card names that block/day in its own `plan`, and the reverse.
    func testRegistryLinksResolve() throws {
        let cardIDs = Set(try allCards().map(\.id))
        let guidelines = try registry("guidelines", as: [Guideline].self)
        let guidelineIDs = Set(guidelines.map(\.id))
        XCTAssertEqual(guidelineIDs.count, guidelines.count, "duplicate id in guidelines.json")
        for g in guidelines {
            if let old = g.supersedes {
                XCTAssertTrue(guidelineIDs.contains(old), "\(g.id): supersedes unknown '\(old)'")
            }
            XCTAssertNotNil(g.checked.range(of: #"^\d{4}-(0[1-9]|1[0-2])$"#, options: .regularExpression), "\(g.id): checked must be YYYY-MM")
        }

        let labs = try registry("labs", as: [LabTest].self)
        XCTAssertEqual(Set(labs.map(\.id)).count, labs.count, "duplicate id in labs.json")
        for lab in labs {
            for band in lab.bands {
                XCTAssertTrue(guidelineIDs.contains(band.source), "\(lab.id): source '\(band.source)' not in guidelines.json")
                XCTAssertTrue(band.low != nil || band.high != nil, "\(lab.id) \(band.age): band without a limit")
                if let low = band.low, let high = band.high {
                    XCTAssertLessThanOrEqual(low, high, "\(lab.id) \(band.age): low above high")
                }
            }
        }

        let cases = try registry("cases", as: [ClinicalCase].self)
        XCTAssertEqual(Set(cases.map(\.id)).count, cases.count, "duplicate id in cases.json")
        for c in cases {
            XCTAssertTrue(cardIDs.contains(c.card), "\(c.id): card '\(c.card)' missing")
        }

        let plan = try registry("plan", as: [PlanBlock].self)
        for block in plan {
            for day in block.days {
                for id in day.cards {
                    XCTAssertTrue(cardIDs.contains(id), "plan \(block.block)-\(day.day): card '\(id)' missing")
                }
            }
        }

        for card in try allCards() {
            for id in card.guidelines ?? [] {
                XCTAssertTrue(guidelineIDs.contains(id), "\(card.id): guideline '\(id)' not in guidelines.json")
            }
            for ref in card.plan ?? [] {
                let days = Set(plan.first { $0.block == ref.block }?.days.map(\.day) ?? [])
                for day in ref.days {
                    XCTAssertTrue(days.contains(day), "\(card.id): plan \(ref.block)-\(day) not in plan.json")
                }
            }
        }
    }

    // MARK: Links

    func testEveryBlockReferenceResolves() throws {
        for card in try allCards() {
            for block in card.blocks {
                switch block {
                case .pathway(let b):
                    XCTAssertNotNil(Pathway.load(pathId: b.pathId, bundle: bundle), "\(card.id): pathway '\(b.pathId)' missing")
                case .chipScreen(let b):
                    XCTAssertNotNil(ChipScreen.load(calcId: b.calcId, bundle: bundle), "\(card.id): chip_screen '\(b.calcId)' missing")
                case .scoreCalc(let b):
                    XCTAssertNotNil(ScoreCalcSchema.load(calcId: b.calcId, bundle: bundle), "\(card.id): score_calc '\(b.calcId)' missing")
                case .numericCalc(let b):
                    XCTAssertTrue(NumericCalcRegistry.ids.contains(b.calcId), "\(card.id): numeric_calc '\(b.calcId)' not in NumericCalcRegistry")
                case .ageSwitch(let b):
                    for option in b.options {
                        XCTAssertNotNil(Pathway.load(pathId: option.pathId, bundle: bundle), "\(card.id): age_switch '\(option.age.rawValue)' pathway '\(option.pathId)' missing")
                    }
                default:
                    break
                }
            }
        }
    }

    func testEveryPathwayCalculatorLinkResolves() throws {
        for url in jsonFiles("Pathways") {
            let pathway = try decode(Pathway.self, url)
            for id in pathway.calcLinks {
                XCTAssertTrue(
                    NumericCalcRegistry.ids.contains(id) || ChipScreen.load(calcId: id, bundle: bundle) != nil,
                    "\(pathway.id): link_calc_id '\(id)' resolves to no calculator"
                )
            }
        }
    }

    /// A `link_card_id` must open a bundled card listed in the manifest —
    /// a link to a card that isn't written yet is added on the day the
    /// target card ships (§4.5), never ahead of it. A pathway must not link
    /// back to the card that shows it: that button would go nowhere new.
    func testEveryPathwayCardLinkResolves() throws {
        let cards = try allCards()
        // Manifest ↔ Cards is already one-to-one (testManifestAndCardFilesMatchOneToOne).
        let cardIDs = Set(cards.map(\.id))
        var ownersByPathway: [String: Set<String>] = [:]
        for card in cards {
            for id in card.pathIds {
                ownersByPathway[id, default: []].insert(card.id)
            }
        }
        for url in jsonFiles("Pathways") {
            let pathway = try decode(Pathway.self, url)
            for id in pathway.cardLinks {
                XCTAssertTrue(cardIDs.contains(id), "\(pathway.id): link_card_id '\(id)' resolves to no bundled card")
                XCTAssertFalse(ownersByPathway[pathway.id, default: []].contains(id), "\(pathway.id): link_card_id '\(id)' points back to its own card")
            }
        }
    }

    /// An age switch offers a real choice: at least two branches, one chip
    /// per age, each age one the card says it covers, each branch its own
    /// pathway.
    func testEveryAgeSwitchIsAWellFormedChoice() throws {
        for card in try allCards() {
            for block in card.blocks {
                guard case .ageSwitch(let b) = block else { continue }
                let ages = b.options.map(\.age)
                XCTAssertGreaterThanOrEqual(b.options.count, 2, "\(card.id): age_switch needs at least two options")
                XCTAssertEqual(Set(ages).count, ages.count, "\(card.id): age_switch repeats an age")
                XCTAssertEqual(Set(b.options.map(\.pathId)).count, b.options.count, "\(card.id): age_switch repeats a path_id")
                for option in b.options {
                    XCTAssertFalse(option.label.trimmingCharacters(in: .whitespaces).isEmpty, "\(card.id): age_switch '\(option.age.rawValue)' has no label")
                }
                XCTAssertNotNil(card.ages, "\(card.id): age_switch requires card ages")
                for age in ages {
                    XCTAssertTrue((card.ages ?? []).contains(age), "\(card.id): age_switch age '\(age.rawValue)' not in card ages")
                }
            }
        }
    }

    // MARK: Presentation

    func testEveryGridTitleFitsTheBrowseTile() throws {
        for card in try allCards() {
            XCTAssertLessThanOrEqual(card.gridTitle.count, 25, "\(card.id): add a gridTitleOverrides entry")
        }
    }
}
