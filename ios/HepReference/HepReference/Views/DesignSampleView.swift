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
      {"t": "list", "h": "First contact", "items": ["Sample order one", "Sample order two", {"t": "Grouped item", "sub": ["Sub-point A", "Sub-point B"]}]},
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                ForEach(Array(Self.blocks.enumerated()), id: \.offset) { index, block in
                    BlockView(block: block)
                    if index == 2, let pathway = Self.pathway {
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
