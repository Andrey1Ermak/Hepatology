import SwiftUI

/// The calculator-name label for `NumericCalcRowView`'s tappable summary
/// row (a chevron row that opens a sheet, not a section) — styled
/// identically to a pathway `.section` heading (see `PathwayNodeView`) and
/// to `CollapsibleSection`'s own header, so a calculator's name reads as the
/// same *kind* of text everywhere, whether it's this row, a section
/// heading, or a collapsible card's title. `ChipBoardView`/`ScoreCalcView`
/// don't use this — they pass their label directly
/// to `CollapsibleSection`, which renders its own header.
struct CalculatorHeader: View {
    var label: String?

    var body: some View {
        if let label {
            Text(label.uppercased())
                .font(.hepSectionHeading)
                .foregroundStyle(Color.hepNavy)
        }
    }
}
