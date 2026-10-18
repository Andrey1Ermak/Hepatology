import SwiftUI

/// Generic segment-selector score (ADS/BDS/GECDS), driven entirely by a
/// `ScoreCalcSchema`. Renders inline in `CardDetailView` — unlike
/// `numeric_calc`, `score_calc` never opens a sheet.
struct ScoreCalcView: View {
    let schema: ScoreCalcSchema
    var label: String?
    @State private var selections: [String: String]

    init(schema: ScoreCalcSchema, label: String?) {
        self.schema = schema
        self.label = label
        _selections = State(initialValue: Self.defaultSelections(schema))
    }

    private static func defaultSelections(_ schema: ScoreCalcSchema) -> [String: String] {
        var initial: [String: String] = [:]
        for dim in schema.dimensions {
            if let def = dim.defaultValue { initial[dim.key] = def }
        }
        return initial
    }

    private var scoredDimensions: [ScoreDimension] { schema.dimensions.filter(\.scored) }
    private var doneCount: Int { scoredDimensions.filter { selections[$0.key] != nil }.count }
    private var total: Int { scoredDimensions.reduce(0) { $0 + (Int(selections[$1.key] ?? "") ?? 0) } }
    private var isComplete: Bool { doneCount == scoredDimensions.count }

    var body: some View {
        CollapsibleSection(title: label ?? "") {
            VStack(alignment: .leading, spacing: Spacing.m) {
                ForEach(schema.dimensions, id: \.key) { dimension in
                    ScoreDimensionRow(dimension: dimension, allDimensions: schema.dimensions, selections: $selections)
                }
                output
                CalculatorResetButton { selections = Self.defaultSelections(schema) }
            }
        }
    }

    @ViewBuilder
    private var output: some View {
        if isComplete, let band = schema.band(for: total) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                if schema.showScore {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text(schema.id.uppercased()).font(.hepCaption).foregroundStyle(Color.hepMuted)
                        Text("\(total)").font(.hepMetric)
                        Text("/\(schema.maxScore)").font(.hepCaption).foregroundStyle(Color.hepMuted)
                    }
                }
                VerdictBanner(verdict: Verdict(band: band.band, text: band.label.verdictText(count: total)))
                if !band.tier.isEmpty {
                    Text(band.tier)
                        .font(.hepCaption)
                        .foregroundStyle(Color.hepMuted)
                }
            }
        } else {
            Text("Select all \(scoredDimensions.count) factors — \(doneCount)/\(scoredDimensions.count)")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
        }
    }
}

private struct ScoreDimensionRow: View {
    let dimension: ScoreDimension
    let allDimensions: [ScoreDimension]
    @Binding var selections: [String: String]

    var body: some View {
        let options = dimension.resolvedOptions(selections: selections)
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(dimension.label)
                .font(.hepRowLabel)
                .foregroundStyle(Color.hepInk)
            // `fillWidth` + a grid (not `FlowLayout`) — matches the
            // symmetric option layout chip_screen calculators use, so a dimension's options read as evenly-sized
            // panels instead of ragged, left-hugging pills. 3 columns for a
            // 3-option dimension (most dimensions have
            // exactly 3 options) — 2 columns would otherwise wrap the
            // 3rd option alone onto its own half-empty row.
            LazyVGrid(columns: options.count == 3 ? GridLayout.threeColumns : GridLayout.twoColumns, spacing: Spacing.s) {
                ForEach(options, id: \.value) { option in
                    SelectableChip(label: option.label, isOn: selections[dimension.key] == option.value, fillWidth: true) {
                        select(option.value)
                    }
                }
            }
        }
    }

    /// Selecting a value that other dimensions gate on (e.g. ADS's "age")
    /// clears those dimensions' selections, since their option set just changed.
    private func select(_ value: String) {
        selections[dimension.key] = value
        for other in allDimensions where other.conditionalOptions?.contains(where: { $0.whenKey == dimension.key }) == true {
            selections[other.key] = nil
        }
    }
}
