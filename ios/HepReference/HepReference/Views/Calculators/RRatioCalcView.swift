import SwiftUI

/// `c_rratio`: injury pattern from R = (ALT ÷ ULN) ÷ (ALP ÷ ULN), with the
/// optional "new R" (higher of ALT or AST). In children the ALP ULN must be
/// the child's own — an adult ULN makes every growing child "cholestatic".
struct RRatioCalcView: View {
    @Environment(Registry.self) private var registry: Registry?
    @State private var altText = ""
    @State private var altULNText = ""
    @State private var alpText = ""
    @State private var alpULNText = ""
    @State private var astText = ""
    @State private var astULNText = ""

    private var result: RRatioResult? {
        guard let alt = altText.parsedDouble, let altULN = altULNText.parsedDouble,
              let alp = alpText.parsedDouble, let alpULN = alpULNText.parsedDouble
        else { return nil }
        return RRatioCalc.compute(alt: alt, altULN: altULN, alp: alp, alpULN: alpULN,
                                  ast: astText.parsedDouble, astULN: astULNText.parsedDouble)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    CalcNumberField(label: "ALT (U/L)", text: $altText)
                    CalcNumberField(label: "ALT ULN", text: $altULNText)
                    CalcNumberField(label: "ALP (U/L)", text: $alpText)
                    CalcNumberField(label: "ALP ULN (age, sex)", text: $alpULNText)
                    Text("Optional, for nR · enter both").font(.hepTag).foregroundStyle(Color.hepMuted)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, Spacing.xs)
                    CalcNumberField(label: "AST (U/L)", text: $astText)
                    CalcNumberField(label: "AST ULN", text: $astULNText)
                }
            }
            CalcCaution(text: "Use the child's own ALP ULN for age and sex. An adult ALP ULN (about 126 U/L) cuts R several-fold and makes a growing child look cholestatic.")
            if let result {
                resultCard(result)
            }
            footer
            CalculatorResetButton {
                altText = ""; altULNText = ""; alpText = ""; alpULNText = ""; astText = ""; astULNText = ""
            }
        }
    }

    private func resultCard(_ result: RRatioResult) -> some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                CalcMetricRow(label: "R", value: RRatioCalc.format(result.r))
                if result.allWithinULN {
                    Text("All tests within ULN — R is not meaningful.")
                        .font(.hepCaption)
                        .foregroundStyle(Color.hepMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(result.pattern.label).font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                    Text("Think of: \(result.pattern.causes)").font(.hepCaption)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !result.allWithinULN, let nR = result.nR, let nRPattern = result.nRPattern {
                    Divider()
                    CalcMetricRow(label: "nR (higher of ALT or AST)", value: RRatioCalc.format(nR))
                    Text(nRPattern.label).font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                }
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("R = (ALT ÷ ULN) ÷ (ALP ÷ ULN), on the first abnormal set of tests. Built for adult drug-induced liver injury; limited pediatric validation. In pediatric DILIN: hepatocellular 78%, mixed 9%, cholestatic 13%. nR uses the higher of ALT or AST; in adult DILI, Hy's law applied with nR was more specific for acute liver failure than with R.")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
            CitationFooter(citations: RRatioCalc.sourceIds.compactMap { registry?.guideline($0)?.citation })
        }
    }
}
