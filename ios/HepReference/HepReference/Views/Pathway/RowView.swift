import SwiftUI

/// A single fact line: a labeled fact or a plain
/// line ("row") when `label` is nil — both get the same leading dot, so a
/// run of plain rows reads as a bulleted list instead of unmarked paragraph
/// text. `label` is no longer bolded — on-device review found bold weight
/// used too widely across pathway text to read as a meaningful emphasis
/// signal; it's now just the row's own leading word, same weight as the rest.
struct RowView: View {
    let label: String?
    let text: String
    var bullet: Bool = true
    /// A trailing "Calculate" button on this same bulleted line (e.g.
    /// "Assess risk" → a score) — same mechanism as `OutView`'s own
    /// `linkCalcId`/`linkLabel`, for a plain fact row that needs a
    /// calculator link without being promoted into an `out`'s boxed
    /// condition badge.
    var linkCalcId: String? = nil
    var linkLabel: String? = nil
    @EnvironmentObject private var calculatorPresenter: CalculatorPresenter

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            if bullet {
                Circle()
                    .fill(Color.hepNavy)
                    .frame(width: Spacing.xs, height: Spacing.xs)
                    .padding(.top, 5)
            }
            Group {
                if let label {
                    Text(label) + Text(" ") + Text(CardMarkup.attributedString(text))
                } else {
                    Text(CardMarkup.attributedString(text))
                }
            }
            // Every row is the same size regardless of nesting depth —
            // a depth-based step-down (tried briefly) made a single arm's
            // rows read as inconsistent sizes whenever it mixed top-level
            // and nested rows; indentation alone signals depth now.
            .font(.hepCaption)
            // Matches Badge's own `.fixedSize` — without it, a long row deep
            // inside a nest (tree-connector's Color.clear spacer eating into
            // the row's proposed width) can get an ambiguous height proposal
            // and silently truncate with a trailing ellipsis instead of
            // wrapping to as many lines as the text actually needs.
            .fixedSize(horizontal: false, vertical: true)
            if let linkCalcId {
                Spacer(minLength: Spacing.s)
                Button {
                    calculatorPresenter.present(calcId: linkCalcId, title: linkLabel ?? text)
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
        }
    }
}
