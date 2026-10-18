import SwiftUI

/// Generic chip grid + verdict banner + reset, driven entirely by a
/// `ChipScreen` (rows of chips + a `VerdictRule`). Used inline in
/// `CardDetailView` for every `chip_screen` block.
struct ChipBoardView: View {
    let screen: ChipScreen
    var label: String?
    // Skips the `CollapsibleSection` wrapper — for a chip_screen embedded via
    // a pathway `out`'s `link_calc_id` (e.g. stroke's tPA contraindication
    // checklist), which opens inside `NumericCalcSheet`'s own title bar;
    // wrapping it in a second, separately-collapsed header would mean
    // tapping twice (Calculate, then expand) to see a checklist that's
    // already the whole point of having opened the sheet.
    var bare: Bool = false
    @State private var selected: Set<String> = []

    private var verdict: Verdict {
        screen.verdictRule.verdict(selected: selected)
    }

    private var rows: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ForEach(Array(screen.rows.enumerated()), id: \.offset) { _, row in
                ChipRowView(row: row, selected: $selected)
            }
            VerdictBanner(verdict: verdict)
            CalculatorResetButton { selected = [] }
        }
    }

    var body: some View {
        if bare {
            rows
        } else {
            CollapsibleSection(title: label ?? "") { rows }
        }
    }
}

struct ChipRowView: View {
    let row: ChipRow
    @Binding var selected: Set<String>
    @EnvironmentObject private var calculatorPresenter: CalculatorPresenter

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            if let tag = row.tag {
                HStack(spacing: Spacing.xs) {
                    Text(tag)
                        .font(.hepRowLabel)
                        .foregroundStyle(Color.hepInk)
                    if let linkCalcId = row.linkCalcId {
                        Button {
                            calculatorPresenter.present(calcId: linkCalcId, title: row.linkLabel ?? tag)
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
            if let columns = row.gridColumns {
                LazyVGrid(columns: columns == 1 ? GridLayout.oneColumn : (columns == 3 ? GridLayout.threeColumns : GridLayout.twoColumns), spacing: Spacing.s) {
                    ForEach(row.items, id: \.key) { item in
                        SelectableChip(label: item.label, isOn: selected.contains(item.key), fillWidth: true) {
                            toggle(item.key)
                        }
                    }
                }
            } else {
                FlowLayout(horizontalSpacing: Spacing.s, verticalSpacing: Spacing.s) {
                    ForEach(row.items, id: \.key) { item in
                        SelectableChip(label: item.label, isOn: selected.contains(item.key)) {
                            toggle(item.key)
                        }
                    }
                }
            }
        }
    }

    private func toggle(_ key: String) {
        if selected.contains(key) {
            selected.remove(key)
        } else {
            if row.exclusive {
                for item in row.items { selected.remove(item.key) }
            }
            selected.insert(key)
        }
    }
}

/// Verdict result banner shared by every calculator (chip, score, numeric) —
/// an icon + short band headline + full verdict text, using the `Tier`
/// tokens instead of ad hoc `.opacity()` colors.
struct VerdictBanner: View {
    let verdict: Verdict
    /// Pass `false` when `verdict.text` would only repeat the band name
    /// already shown by `bandAnnouncement`.
    var showDetail: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: icon)
                .font(.hepIconMedium)
                .foregroundStyle(tier.solid)
            VStack(alignment: .leading, spacing: 2) {
                Text(bandAnnouncement.uppercased())
                    .font(.hepTag)
                    .foregroundStyle(tier.solid)
                if showDetail {
                    Text(CardMarkup.attributedString(verdict.text))
                        .font(.hepCaption)
                }
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tier.tint, in: RoundedRectangle(cornerRadius: Radius.medium))
        .animation(.easeInOut(duration: 0.2), value: verdict.band)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showDetail ? "\(bandAnnouncement): \(CardMarkup.plainText(verdict.text))" : bandAnnouncement)
    }

    private var tier: Tier {
        switch verdict.band {
        case .hi: .crit
        case .mid: .urg
        case .lo: .rt
        }
    }

    private var icon: String {
        switch verdict.band {
        case .hi: "exclamationmark.triangle.fill"
        case .mid: "exclamationmark.circle.fill"
        case .lo: "checkmark.circle.fill"
        }
    }

    private var bandAnnouncement: String {
        switch verdict.band {
        case .hi: "High risk"
        case .mid: "Intermediate"
        case .lo: "Low risk"
        }
    }
}
