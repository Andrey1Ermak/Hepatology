import SwiftUI

/// An outcome row: an optional condition, then either 1+ disposition pills
/// (colored, e.g. "DC"/"PICU" — two pills render "/"-separated, for a
/// shared-decision either/or outcome) or a plain subtext note — with a
/// subtext-only variant. `condition` is nil when the enclosing
/// arm's own tag already states it — the arrow before the pills is dropped
/// too in that case, since there's no "from" state left to point away from.
/// The condition badge stretches to fill the row (pinning the pill(s) to
/// the trailing edge) whenever there's a pill/subtext beside it, so a run
/// of these reads as full-width, symmetric rows instead of everything
/// clumped at the leading edge with empty space to the right. Each pill
/// also matches the condition's height (`fillHeight`) — a long condition
/// (e.g. "Conjugated bilirubin ≥ 1 mg/dL, or not measured") wrapping to 2 lines next to
/// a 1-line pill otherwise reads as visually lopsided.
struct OutView: View {
    let condition: String?
    let pills: [Pill]
    let subtext: String?
    /// A reference `numeric_calc` tucked behind a "Calculate" link on this
    /// row — same mechanism and rendering as `ChipRowView`'s own
    /// `linkCalcId`/`linkLabel`, for a cond-only flush marker that's really
    /// a pathway step pointing at a calculator (e.g. "AGE ≥ 1 YR →
    /// RUN score") instead of that calculator living in its own
    /// always-visible top-level block.
    var linkCalcId: String? = nil
    var linkLabel: String? = nil
    /// Bolds the condition badge for a sub-branch header inside an arm — see
    /// `PathwayNode.out`'s own doc comment.
    var condBold: Bool = false
    /// Another card this outcome hands off to — see `CardLinkButton`.
    var linkCardId: String? = nil
    @EnvironmentObject private var calculatorPresenter: CalculatorPresenter

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.xs) {
            if let condition {
                Badge(text: condition, style: .neutral, uppercase: false, maxLines: nil, fillHeight: !pills.isEmpty, bold: condBold)
                    .frame(maxWidth: (!pills.isEmpty || subtext != nil || linkCalcId != nil || linkCardId != nil) ? .infinity : nil, alignment: .leading)
            }
            if !pills.isEmpty {
                if condition != nil {
                    DispositionArrow()
                }
                ForEach(Array(pills.enumerated()), id: \.offset) { index, pill in
                    if index > 0 {
                        Text("/")
                            .font(.hepCaption)
                            .foregroundStyle(Color.hepMuted)
                    }
                    Badge(text: pill.text, tier: pill.kind.tier, maxLines: nil, fillHeight: true)
                }
            } else if let subtext {
                Text(CardMarkup.attributedString(subtext))
                    .font(.hepCaption)
                    .foregroundStyle(Color.hepMuted)
            }
            // After the pills, not before — this link is "go compute the
            // number that decides between them," so it reads left-to-right
            // as cond → pill(s) → the way to get there, not interrupting the
            // cond-to-pill arrow.
            if let linkCalcId {
                Button {
                    calculatorPresenter.present(calcId: linkCalcId, title: linkLabel ?? condition ?? "")
                } label: {
                    HStack(spacing: 3) {
                        Text("Calculate")
                        Image(systemName: "chevron.right")
                    }
                    .font(.hepTag)
                    .foregroundStyle(Color.hepOnSolid)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 3)
                    .background(Color.hepNavy, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            // Last: leaving the card is the final step of reading a row.
            if let linkCardId {
                CardLinkButton(cardId: linkCardId)
            }
        }
    }
}
