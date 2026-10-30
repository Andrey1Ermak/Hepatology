import SwiftUI

struct NACCalcView: View {
    @State private var weightText = ""

    private var result: NACResult? {
        weightText.parsedDouble.flatMap(NACCalc.compute)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                CalcNumberField(label: "Weight (kg)", text: $weightText)
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
                        CalcMetricRow(label: "Total 21-h NAC", value: "\(result.totalMg)", unit: "mg")
                    }
                }
            }
            CalculatorResetButton { weightText = "" }
        }
    }

    private func doseText(_ mg: Int, ml: Double? = nil, unit: String = "mg", capped: Bool, sub: String? = nil) -> String {
        var text = "\(mg) \(unit)"
        if let ml { text += " (≈ \(String(format: "%.1f", ml)) mL)" }
        if capped { text += " · max" }
        if let sub { text += " · \(sub)" }
        return text
    }
}
