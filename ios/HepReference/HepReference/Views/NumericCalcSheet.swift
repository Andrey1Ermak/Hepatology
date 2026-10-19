import SwiftUI

/// Shared app-wide state for which `numeric_calc` calculator (if any) is on
/// screen. A plain `.fullScreenCover`/`.sheet` always slides in from an edge
/// with no way to override that transition, so presentation is done by hand
/// instead: `ContentView` overlays `NumericCalcSheet` above the whole
/// `TabView` when `active` is set, using a scale-from-center transition, and
/// any nested view (a `numeric_calc` block, a chip row's linked calculator)
/// reaches this via `@EnvironmentObject` instead of owning its own
/// `@State`/cover.
final class CalculatorPresenter: ObservableObject {
    struct Active: Identifiable, Equatable {
        let calcId: String
        let title: String
        var id: String { calcId }
    }

    @Published var active: Active?

    func present(calcId: String, title: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            active = Active(calcId: calcId, title: title)
        }
    }

    func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            active = nil
        }
    }
}

/// A tappable row shown inline in a card for a `numeric_calc` block; tapping
/// presents the matching calculator via `CalculatorPresenter` (never inline —
/// unlike `score_calc`, these need room for multiple input fields).
struct NumericCalcRowView: View {
    let calcId: String
    let label: String
    @EnvironmentObject private var presenter: CalculatorPresenter

    var body: some View {
        Button {
            presenter.present(calcId: calcId, title: label)
        } label: {
            SectionCard {
                HStack(alignment: .top) {
                    CalculatorHeader(label: label)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.hepNavy)
                        .padding(.top, 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// A centered modal card (not a bottom-rising system sheet) wrapping
/// whichever concrete calculator view matches `calcId` — overlaid above the
/// whole app by `ContentView` and grown in from a point at screen-center
/// (see `CalculatorPresenter`) rather than sliding up. Title styled like a
/// card's own block heading (`CollapsibleSection`'s header: uppercase,
/// `hepSectionHeading`, accent-colored) so it reads as the same kind of
/// title, not a generic navigation bar.
struct NumericCalcSheet: View {
    let calcId: String
    let title: String
    @EnvironmentObject private var presenter: CalculatorPresenter

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Explicit .tint: this sheet is a sibling `.overlay` on top
                // of ContentView's `.tint(Color.hepNavy)`-scoped
                // TabView, not a true descendant of it, so anything reading
                // the ambient `Color.accentColor`/bordered-button tint here
                // (SelectableChip's selected state, CalculatorResetButton,
                // the TextField cursor) would otherwise fall back to the
                // system default blue instead of the app's navy.
                Color.hepScrim
                    .ignoresSafeArea()
                    .onTapGesture { presenter.dismiss() }

                VStack(alignment: .leading, spacing: Spacing.m) {
                    HStack(alignment: .top, spacing: Spacing.s) {
                        Text(title.uppercased())
                            .font(.hepSectionHeading)
                            .foregroundStyle(Color.hepNavy)
                        Spacer()
                        Button {
                            presenter.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.hepNavy)
                        }
                        .buttonStyle(.plain)
                    }
                    ScrollView {
                        content
                    }
                }
                .padding(Spacing.l)
                .frame(maxHeight: geo.size.height * 0.75)
                // A raised card with SectionCard's navy top stripe — the
                // same "basic block" surface every card block uses.
                .background(Color.hepCard)
                .overlay(alignment: .top) {
                    Color.hepNavy.frame(height: SectionCard<EmptyView>.stripeHeight)
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                .hepElevated()
                .padding(.horizontal, Spacing.xl)
            }
        }
        .tint(Color.hepNavy)
    }

    @ViewBuilder
    private var content: some View {
        if let view = NumericCalcRegistry.view(for: calcId) {
            view
        } else {
            // Any other calc_id is a chip_screen (a checklist, not a
            // dedicated numeric_calc view) linked from a pathway row or
            // `out`. `bare: true` skips ChipBoardView's own
            // CollapsibleSection, since this sheet already has a title.
            if let screen = ChipScreen.load(calcId: calcId) {
                ChipBoardView(screen: screen, bare: true)
            } else {
                Text("Calculator not available yet")
                    .foregroundStyle(Color.hepMuted)
            }
        }
    }
}
