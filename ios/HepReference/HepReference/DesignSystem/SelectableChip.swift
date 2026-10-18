import SwiftUI

/// The one toggle-able chip component for every calculator in the app
/// (`ChipBoardView`, `ScoreCalcView`, numeric calculator option rows). Sized to its own
/// content, not stretched, so it can sit in a `FlowLayout` alongside other
/// chips — unless `fillWidth` is set, for callers that place it in a
/// `LazyVGrid` column instead (e.g. a short-item checklist), where a
/// uniform column width reads better than flow-wrapped text. An optional
/// `detail` line (e.g. pARC's per-sign point value) renders as a secondary
/// caption below the label — most callers omit it.
struct SelectableChip: View {
    let label: String
    var detail: String? = nil
    let isOn: Bool
    var fillWidth: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 2) {
                Text(CardMarkup.attributedString(label))
                    .font(.hepCaption)
                    .foregroundStyle(isOn ? Color.hepOnSolid : Color.hepInk)
                    .multilineTextAlignment(.center)
                    // Reserves full 2-line height even for a 1-line label —
                    // same reasoning as CardRowView's grid tiles — so a
                    // fillWidth grid of mixed-length chips (e.g. "< 37
                    // wk" next to "Focal bacterial infx") reads as
                    // uniformly-sized panels, not staggered heights. Centered
                    // both axes so a short 1-line label sits in the middle of
                    // the reserved space, not pinned to the top-left corner.
                    .frame(minHeight: fillWidth ? 32 : nil, alignment: .center)
                if let detail {
                    Text(detail)
                        .font(.hepCaption)
                        .foregroundStyle(isOn ? Color.hepOnSolid : Color.hepMuted)
                }
            }
            .frame(maxWidth: fillWidth ? .infinity : nil, alignment: .center)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            // Lesson style (CLAUDE.md §12.3): selected = solid navy with
            // light text, unselected = neutral surface with ink. Explicit
            // `Color.hepNavy`, not the ambient accent — a chip inside
            // NumericCalcSheet's overlay sits outside the TabView's `.tint()`.
            .background(isOn ? Color.hepNavy : Color.hepSurface, in: RoundedRectangle(cornerRadius: Radius.medium))
            .overlay(RoundedRectangle(cornerRadius: Radius.medium).stroke(isOn ? Color.hepNavy : Color.hepMuted.opacity(0.35), lineWidth: 1))
            .animation(.easeOut(duration: 0.15), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(detail.map { "\(CardMarkup.plainText(label)), \($0)" } ?? CardMarkup.plainText(label))
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
        .sensoryFeedback(.selection, trigger: isOn)
    }
}
