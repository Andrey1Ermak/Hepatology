#if DEBUG
import SwiftUI

/// Debug-only gallery of every block style, for design screenshots while
/// the bundle holds almost no content: `tools/screenshot.sh` with
/// `HEP_OPEN_CARD=__design_sample` (passed on as `-hepOpenCard`, read by
/// `CardListView`). Placeholder wording only — no clinical
/// thresholds, doses or criteria. Never reachable in a Release build.
struct DesignSampleView: View {
    static let id = "__design_sample"

    private static let blocks: [Block] = decode("""
    [
      {"t": "note", "k": "crit", "h": "Red flags", "text": "Sample red-flag line. Call the on-call team now."},
      {"t": "list", "h": "Don't miss", "items": ["Sample order one", "Sample order two", {"t": "Grouped item", "sub": ["Sub-point A", "Sub-point B"]}]},
      {"t": "table", "h": "Sample table", "head": ["Finding", "Points to", "Next step"], "rows": [["Row one", "Option A", "Action A"], ["Row two", "Option B", "Action B"], ["Row three", "Option C", "Action C"]]},
      {"t": "note", "k": "info", "h": "Definition", "text": "Sample informational note."},
      {"t": "text", "h": "Why", "text": "Sample explanatory paragraph in the Learn layer."}
    ]
    """) ?? []

    private static let pathway: Pathway? = decode("""
    {"id": "design_sample", "children": [
      {"t": "arm", "kind": "sev", "tag": "Severe branch", "children": [
        {"t": "row", "text": "Sample action line"},
        {"t": "out", "cond": "Condition met", "pill": {"kind": "picu", "text": "PICU / transplant center"}}]},
      {"t": "arm", "kind": "mod", "tag": "Moderate branch", "children": [
        {"t": "out", "cond": "Condition met", "pill": {"kind": "step", "text": "Same-day workup"}}]},
      {"t": "arm", "kind": "mild", "tag": "Mild branch", "children": [
        {"t": "out", "pills": [{"kind": "dc", "text": "Outpatient follow-up"}]}]}
    ]}
    """)

    /// Two placeholder branches for the sample `age_switch`.
    private static let ageSwitch: AgeSwitchBlock? = decode("""
    {"t": "age_switch", "h": "Age", "options": [
      {"age": "neo", "label": "Sample band A", "path_id": "design_age_a"},
      {"age": "infant", "label": "Sample band B", "path_id": "design_age_b"}]}
    """)

    private static let agePathways: [String: Pathway] = ([
        "design_age_a": decode("""
        {"id": "design_age_a", "children": [{"t": "section", "h": "Band A algorithm", "children": [
          {"t": "row", "text": "Sample step for band A"},
          {"t": "out", "cond": "Condition met", "pill": {"kind": "floor", "text": "Admit"}}]}]}
        """),
        "design_age_b": decode("""
        {"id": "design_age_b", "children": [{"t": "section", "h": "Band B algorithm", "children": [
          {"t": "row", "text": "Sample step for band B"},
          {"t": "out", "cond": "Condition met", "pill": {"kind": "dc", "text": "Outpatient follow-up"}}]}]}
        """),
    ] as [String: Pathway?]).compactMapValues { $0 }

    /// Placeholder orders for the sample `workup`.
    private static let workup: WorkupBlock? = decode("""
    {"t": "workup", "h": "First contact", "groups": [
      {"label": "Sample group one", "items": ["Sample order A", "Sample order B"]},
      {"label": "Sample group two", "items": ["Sample order C"]}]}
    """)

    /// Placeholder limits for the sample `lab_norms` — not real norms.
    private static let labNorms: LabNormsBlock? = decode("""
    {"t": "lab_norms", "h": "Norms for age", "analytes": ["sample"]}
    """)

    private static let sampleLabs: [LabTest] = decode("""
    [{"id": "sample", "name": "Sample analyte", "unit": "U/L", "bands": [
      {"age": "child", "high": 10, "source": "sample"},
      {"age": "teen", "sex": "F", "low": 1, "high": 20, "source": "sample"},
      {"age": "teen", "sex": "M", "high": 30.5, "source": "sample"}]}]
    """) ?? []

    /// Placeholder pearls — no clinical content.
    private static let pearls: PearlsBlock? = decode("""
    {"t": "pearls", "items": [
      {"k": "pearl", "text": "Sample pearl: a line worth carrying onto the ward."},
      {"k": "pitfall", "text": "Sample pitfall: a reasoning error to avoid."}]}
    """)

    /// Placeholder comparison, one row per verdict — not real positions.
    private static let guidelineCompare: GuidelineCompareBlock? = decode("""
    {"t": "guideline_compare", "h": "Guidelines", "rows": [
      {"topic": "Sample topic one", "positions": {"sample_a": "Position A", "sample_b": "Position B"}, "verdict": "aligned"},
      {"topic": "Sample topic two", "positions": {"sample_a": "Position A", "sample_b": "Different position B"}, "verdict": "differs", "note": "Sample note on why it matters."},
      {"topic": "Sample topic three", "positions": {"sample_a": "Not addressed", "sample_b": "Position B"}, "verdict": "material", "note": "Sample note: changes management."},
      {"topic": "Sample topic four", "positions": {"sample_a": "Not addressed"}, "verdict": "gap"}]}
    """)

    private static let sampleGuidelines: [Guideline] = decode("""
    [{"id": "sample_a", "title": "Sample guideline A", "society": "Society A", "year": 2017,
      "citation": "Sample citation A", "url": null, "checked": "2026-10", "supersedes": null},
     {"id": "sample_b", "title": "Sample guideline B", "society": "Society B", "year": 2025,
      "citation": "Sample citation B", "url": null, "checked": "2026-10", "supersedes": null}]
    """) ?? []

    private static let sampleSession: CardSession = {
        let session = CardSession()
        session.age = .teen
        return session
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                ForEach(Array(Self.blocks.enumerated()), id: \.offset) { index, block in
                    BlockView(block: block)
                    if index == 0, let ageSwitch = Self.ageSwitch {
                        AgeSwitchBlockView(block: ageSwitch, loadPathway: { Self.agePathways[$0] })
                    }
                    // Gallery order, not card anatomy: the norms table and
                    // the workup sit high enough to show in the first
                    // screenshots. The norms get their own session with an
                    // age chosen, so the highlighted row shows.
                    // Learn-layer sections open, so the verdict cells
                    // and pearl markers show in the first screenshot.
                    if index == 0, let guidelineCompare = Self.guidelineCompare {
                        GuidelineCompareBlockView(block: guidelineCompare, guidelines: Self.sampleGuidelines, startsExpanded: true)
                    }
                    if index == 0, let pearls = Self.pearls {
                        PearlsBlockView(block: pearls, startsExpanded: true)
                    }
                    if index == 0, let labNorms = Self.labNorms {
                        LabNormsBlockView(block: labNorms, labs: Self.sampleLabs)
                            .environment(Self.sampleSession)
                    }
                    if index == 0, let workup = Self.workup {
                        WorkupBlockView(block: workup)
                    }
                    if index == 0, let pathway = Self.pathway {
                        PathwayBlockView(pathway: pathway)
                    }
                }
            }
            .padding(Spacing.l)
        }
        .background(Color.hepBackground.ignoresSafeArea())
    }

    private static func decode<T: Decodable>(_ json: String) -> T? {
        try? JSONDecoder().decode(T.self, from: Data(json.utf8))
    }
}
#endif
