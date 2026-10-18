import SwiftUI

struct NACCalcView: View {
    @State private var weightText = ""

    private var result: NACResult? {
        weightText.parsedDouble.flatMap(NACCalc.compute)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                weightField
            }
            if let result {
                // `RowView` for each dose line — the same bulleted fact-line
                // component pathways use — plus a headline metric for the total.
                SectionCard {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        RowView(label: "Loading · over 1 h", text: doseText(result.loadMg, ml: result.loadML, capped: result.loadCapped))
                        RowView(label: "Maintenance · over 20 h", text: doseText(result.maintMg, ml: result.maintML, capped: result.maintCapped))
                        RowView(label: "Infusion rate", text: doseText(result.rateMgPerHour, unit: "mg/h", capped: result.rateCapped, sub: "15 mg/kg/h"))
                        Divider()
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                            Text("Total 21-h NAC").font(.hepCaption).foregroundStyle(Color.hepMuted)
                            Spacer()
                            Text("\(result.totalMg)").font(.hepMetric)
                            Text("mg").font(.hepCaption).foregroundStyle(Color.hepMuted)
                        }
                    }
                }
            }
            CalculatorResetButton { weightText = "" }
        }
    }

    // Shared compact numeric-input container — every numeric calculator
    // should reuse this look so inputs read as one component.
    private var weightField: some View {
        HStack(spacing: 4) {
            Text("Weight (kg)")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
            TextField("", text: $weightText)
                .keyboardType(.decimalPad)
                .font(.hepCaption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(Color.hepCard, in: RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(RoundedRectangle(cornerRadius: Radius.medium).stroke(Color(.separator).opacity(0.4), lineWidth: 1))
    }

    private func doseText(_ mg: Int, ml: Double? = nil, unit: String = "mg", capped: Bool, sub: String? = nil) -> String {
        var text = "\(mg) \(unit)"
        if let ml { text += " (≈ \(String(format: "%.1f", ml)) mL)" }
        if capped { text += " · max" }
        if let sub { text += " · \(sub)" }
        return text
    }
}
