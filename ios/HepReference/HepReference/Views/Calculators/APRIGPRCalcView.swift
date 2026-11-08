import SwiftUI

/// `c_apri_gpr`: APRI and GGT-to-platelet ratio, shown against the few
/// published reference points with their populations. No result is called
/// "fibrosis" outright: no pediatric threshold is validated across diseases.
struct APRIGPRCalcView: View {
    @Environment(Registry.self) private var registry: Registry?
    @State private var astText = ""
    @State private var astULNText = ""
    @State private var ggtText = ""
    @State private var ggtULNText = ""
    @State private var plateletText = ""

    private var platelets: Double? { plateletText.parsedDouble }

    private var apri: Double? {
        guard let ast = astText.parsedDouble, let uln = astULNText.parsedDouble, let platelets else { return nil }
        return APRIGPRCalc.index(value: ast, uln: uln, platelets: platelets)
    }

    private var gpr: Double? {
        guard let ggt = ggtText.parsedDouble, let uln = ggtULNText.parsedDouble, let platelets else { return nil }
        return APRIGPRCalc.index(value: ggt, uln: uln, platelets: platelets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    CalcNumberField(label: "Platelets (× 10⁹/L)", text: $plateletText)
                    Text("APRI").font(.hepTag).foregroundStyle(Color.hepMuted)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, Spacing.xs)
                    CalcNumberField(label: "AST (U/L)", text: $astText)
                    CalcNumberField(label: "AST ULN (your lab)", text: $astULNText)
                    Text("GPR").font(.hepTag).foregroundStyle(Color.hepMuted)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, Spacing.xs)
                    CalcNumberField(label: "GGT (U/L)", text: $ggtText)
                    CalcNumberField(label: "GGT ULN (age, sex)", text: $ggtULNText)
                }
            }
            CalcCaution(text: "No pediatric cut-off is validated across diseases. Do not use in MASLD (AASLD 2025, ESPGHAN 2026), during a hepatitis flare, or with muscle injury, hemolysis, sepsis, chemotherapy or ITP. GPR is not interpretable in early infancy, when GGT is physiologically high. At biliary atresia diagnosis, APRI reflects ductular reaction, not fibrosis. Published cut-offs assume the study lab's ULN.")
            if let apri {
                resultCard(title: "APRI", value: apri, references: APRIGPRCalc.apriReferences)
            }
            if let gpr {
                resultCard(title: "GPR", value: gpr, references: APRIGPRCalc.gprReferences)
            }
            footer
            CalculatorResetButton {
                astText = ""; astULNText = ""; ggtText = ""; ggtULNText = ""; plateletText = ""
            }
        }
    }

    private func resultCard(title: String, value: Double, references: [FibrosisIndexReference]) -> some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                CalcMetricRow(label: title, value: APRIGPRCalc.format(value, near: references))
                Text("Published reference points").font(.hepTag).foregroundStyle(Color.hepMuted)
                    .accessibilityAddTraits(.isHeader)
                ForEach(references) { ref in
                    let above = APRIGPRCalc.isAbove(value, ref)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(above ? "Above" : "At or below") \(ref.thresholdText) · \(ref.meaning)")
                            .font(above ? .hepBodyEmphasis : .hepBody)
                            .foregroundStyle(Color.hepInk)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(ref.population).font(.hepCaption).foregroundStyle(Color.hepMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("APRI = (AST ÷ AST ULN) ÷ platelets (10⁹/L) × 100 (Wai 2003). GPR = (GGT ÷ GGT ULN) ÷ platelets (10⁹/L) × 100 (Lemoine 2016). Both were built in adults with viral hepatitis. APRI changes with the lab's AST ULN: ULN 30 instead of 40 raises it by one-third. In 457 European children with MASLD, APRI (AUROC 0.76 for F ≥ 3) did no better than ALT > 50 U/L (Kalveram 2024). Follow the trend in the same child; one value stages nothing.")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
            CitationFooter(citations: APRIGPRCalc.sourceIds.compactMap { registry?.guideline($0)?.citation })
        }
    }
}
