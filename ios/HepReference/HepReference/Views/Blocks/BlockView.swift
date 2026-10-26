import SwiftUI

/// Dispatches a `Block` to its renderer. chip_screen renders inline
/// (ChipBoardView) when its calc_id resolves to a bundled
/// Content/Calculators/<id>.json,
/// pathway renders inline (PathwayBlockView) when its path_id resolves to a
/// bundled Content/Pathways/<id>.json, score_calc renders inline
/// (ScoreCalcView) when its calc_id resolves to a bundled
/// Content/ScoreCalcs/<id>.json, and numeric_calc renders a tappable row
/// (NumericCalcRowView) that opens a sheet for any calculator registered in
/// `NumericCalcRegistry` — otherwise each falls back to a placeholder.
/// age_switch renders its chips and the selected branch's pathway
/// (AgeSwitchBlockView), with the same placeholder for a missing path_id;
/// workup renders tickable orders with a Copy button (WorkupBlockView);
/// lab_norms renders each analyte's limits from labs.json (LabNormsBlockView);
/// pearls and guideline_compare render collapsed Learn-layer sections
/// (PearlsBlockView, GuidelineCompareBlockView); case renders the
/// "Test yourself" cases from cases.json, answers hidden until tapped
/// (CaseBlockView).
struct BlockView: View {
    let block: Block

    var body: some View {
        switch block {
        case .note(let b): NoteBlockView(block: b)
        case .list(let b): ListBlockView(block: b)
        case .dose(let b): DoseBlockView(block: b)
        case .branch(let b): BranchBlockView(block: b)
        case .kv(let b): KVBlockView(block: b)
        case .table(let b): TableBlockView(block: b)
        case .text(let b): TextBlockView(block: b)
        case .chipScreen(let b):
            if let screen = ChipScreen.load(calcId: b.calcId) {
                ChipBoardView(screen: screen, label: b.label)
            } else {
                PlaceholderBlockView(kind: "Chip screen", label: b.label ?? b.calcId)
            }
        case .pathway(let b):
            if let pathway = Pathway.load(pathId: b.pathId) {
                PathwayBlockView(pathway: pathway)
            } else {
                PlaceholderBlockView(kind: "Pathway", label: b.pathId)
            }
        case .scoreCalc(let b):
            if let schema = ScoreCalcSchema.load(calcId: b.calcId) {
                ScoreCalcView(schema: schema, label: b.label)
            } else {
                PlaceholderBlockView(kind: "Score calculator", label: b.label ?? b.calcId)
            }
        case .numericCalc(let b):
            if NumericCalcRegistry.ids.contains(b.calcId) {
                NumericCalcRowView(calcId: b.calcId, label: b.label ?? b.calcId)
            } else {
                PlaceholderBlockView(kind: "Calculator", label: b.label ?? b.calcId)
            }
        case .ageSwitch(let b): AgeSwitchBlockView(block: b)
        case .workup(let b): WorkupBlockView(block: b)
        case .labNorms(let b): LabNormsBlockView(block: b)
        case .pearls(let b): PearlsBlockView(block: b)
        case .guidelineCompare(let b): GuidelineCompareBlockView(block: b)
        case .cases(let b): CaseBlockView(block: b)
        }
    }
}
