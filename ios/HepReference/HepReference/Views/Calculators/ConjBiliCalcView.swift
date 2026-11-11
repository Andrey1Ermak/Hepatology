import SwiftUI

/// `c_conj_bili`: direct or conjugated bilirubin → cholestasis or not.
/// Absolute threshold, never a fraction of the total; stool colour overrides
/// the number. Logic in `ConjBiliCalc`.
struct ConjBiliCalcView: View {
    @Environment(Registry.self) private var registry: Registry?
    @State private var unit: ConjBiliCalc.Unit = .mgdl
    @State private var age: ConjBiliCalc.Age?
    @State private var directText = ""
    @State private var totalText = ""
    @State private var labULNText = ""
    @State private var paleStool = false

    private var result: ConjBiliCalc.Result? {
        ConjBiliCalc.compute(direct: directText.parsedDouble, unit: unit, total: totalText.parsedDouble,
                             labULN: labULNText.parsedDouble, age: age, paleStool: paleStool)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    chipRow("Unit") {
                        ForEach(ConjBiliCalc.Unit.allCases, id: \.self) { option in
                            SelectableChip(label: option.rawValue, isOn: unit == option) {
                                // A number typed in one unit is not a number in the other.
                                if option != unit { directText = ""; totalText = ""; labULNText = "" }
                                unit = option
                            }
                        }
                    }
                    chipRow("Age") {
                        ForEach(ConjBiliCalc.Age.allCases, id: \.self) { option in
                            SelectableChip(label: option.label, isOn: age == option) { age = option }
                        }
                    }
                    chipRow("Stool and urine") {
                        SelectableChip(label: "Pale stool or dark urine", isOn: paleStool) { paleStool.toggle() }
                    }
                    CalcNumberField(label: "Direct or conjugated (\(unit.rawValue))", text: $directText)
                    CalcNumberField(label: "Lab upper limit, same assay (\(unit.rawValue), optional)", text: $labULNText)
                    CalcNumberField(label: "Total bilirubin (\(unit.rawValue), optional)", text: $totalText)
                }
            }
            if let result {
                resultCard(result)
            }
            reference
            footer
            CalculatorResetButton {
                directText = ""; totalText = ""; labULNText = ""; paleStool = false; age = nil
            }
        }
    }

    private func chipRow<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title.uppercased()).font(.hepTag).foregroundStyle(Color.hepMuted)
                .accessibilityAddTraits(.isHeader)
            FlowLayout { content() }
        }
    }

    // MARK: Result

    private func resultCard(_ result: ConjBiliCalc.Result) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            VerdictBanner(verdict: verdict(result.verdict), headline: headline(result.verdict))
            if result.directExceedsTotal {
                CalcCaution(text: "Direct is higher than total: check the entry.")
            }
            if result.labULNSuspect {
                CalcCaution(text: "A lab upper limit of \(unit.thresholdLabel) or more is unusual: check that it is in \(unit.rawValue) and for the same assay.")
            }
            if let fraction = result.fraction, !result.directExceedsTotal {
                Text("Direct is \(ConjBiliCalc.formatPercent(fraction)) of total: not used. In Harpavat 2011, 79% of newborns with biliary atresia had a ratio of 0.2 or less.")
                    .font(.hepCaption).foregroundStyle(Color.hepMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func headline(_ v: ConjBiliCalc.Verdict) -> String {
        switch v {
        case .paleStool: "Same day"
        case .cholestasis: "Cholestasis"
        case .aboveLabRangeNewborn, .aboveLabRangeOlder: "Above lab range"
        case .withinLabRange: "Within lab range"
        case .belowThresholdNoULN: "Below threshold"
        }
    }

    private func verdict(_ v: ConjBiliCalc.Verdict) -> Verdict {
        let t = unit.thresholdLabel
        return switch v {
        case .paleStool:
            Verdict(band: .hi, text: "Pale stool or dark urine overrides the number. Fractionated bilirubin, INR and pediatric hepatology today: biliary atresia until proven otherwise.")
        case .cholestasis:
            Verdict(band: .hi, text: "Abnormal at any total bilirubin. Call pediatric GI or hepatology today. Do not wait for an ultrasound or other tests. Check INR now; if prolonged, give vitamin K. Sick or poorly feeding infant: sepsis workup with urine culture, and glucose. Look at the stool yourself.")
        case .aboveLabRangeNewborn:
            Verdict(band: .mid, text: "Not normal, even if only slightly above the range: early biliary atresia can look like this. Repeat by the 2-week visit and ask about stool color. Higher than the first value, or \(t) or more → hepatology today (expert opinion).")
        case .aboveLabRangeOlder:
            Verdict(band: .hi, text: "Above the lab's range in an infant 2 weeks or older: not normal. Discuss with pediatric hepatology today (expert opinion), check INR, and look at the stool yourself.")
        case .withinLabRange:
            Verdict(band: .lo, text: "Not cholestasis on this value. Still jaundiced, pale stool or dark urine → repeat the fractionated bilirubin.")
        case .belowThresholdNoULN:
            Verdict(band: .mid, text: "Below \(t). Any value above the lab's own range is not normal: enter the lab's upper limit to check.")
        }
    }

    // MARK: Static reference

    private var reference: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("How to read it").font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                    .accessibilityAddTraits(.isHeader)
                CalcBullet(text: "Fractionate when jaundice lasts beyond 2 weeks, or at any age with pale stool or dark urine.")
                CalcBullet(text: "Direct (diazo) and conjugated (enzymatic) bilirubin are different assays: compare with the upper limit of the same assay. Use a non-hemolyzed sample.")
                CalcBullet(text: "No 20% rule: the threshold is absolute, whatever the total.")
                CalcBullet(text: "UK (NICE CG98): conjugated above 25 µmol/L → follow expert advice. The North American threshold is lower.")
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Cholestasis: direct or conjugated bilirubin of 1.0 mg/dL (17 µmol/L) or more at any total (NASPGHAN/ESPGHAN 2017: above 1.0; the line itself is counted as abnormal). 1 mg/dL = 17.1 µmol/L. Values above the lab's range: in Harpavat 2011 every newborn with biliary atresia who was tested had one.")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
            CitationFooter(citations: ConjBiliCalc.sourceIds.compactMap { registry?.guideline($0)?.citation })
        }
    }
}
