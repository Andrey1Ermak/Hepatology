import SwiftUI

/// `c_vitamins`: starting doses of vitamins A, D, E and K in cholestasis for
/// a weight (Mouzaki 2019, Table 3), the bilirubin trigger for separate
/// dosing (Shneider 2012), what to measure, and the ChiLDReN escalation steps.
struct VitaminsCalcView: View {
    @Environment(Registry.self) private var registry: Registry?
    @State private var weightText = ""
    @State private var bilirubinText = ""

    private var bilirubin: Double? { bilirubinText.parsedDouble }

    private var weightValid: Bool {
        weightText.parsedDouble.map(VitaminsCalc.weightRange.contains) ?? false
    }

    /// Empty is fine (optional); typed must parse and sit in range, so an
    /// unreadable bilirubin never silently drops the separate-dosing flag.
    private var bilirubinValid: Bool {
        bilirubinText.isEmpty || (bilirubin.map(VitaminsCalc.bilirubinRange.contains) ?? false)
    }

    private var result: VitaminsCalc.Result? {
        guard let weight = weightText.parsedDouble, bilirubinValid else { return nil }
        return VitaminsCalc.compute(weightKg: weight, totalBilirubin: bilirubin)
    }

    private var inputHint: String? {
        if !weightText.isEmpty, !weightValid { return "Enter a weight between 0.5 and 150 kg." }
        if !bilirubinValid { return "Enter total bilirubin in mg/dL, 0 to 50." }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    CalcNumberField(label: "Weight (kg)", text: $weightText)
                    CalcNumberField(label: "Total bilirubin (mg/dL), optional", text: $bilirubinText)
                }
            }
            CalcCaution(text: "Starting doses only. Measure each vitamin and adjust: a fixed dose is rarely enough in a jaundiced infant, and too much vitamin A causes liver fibrosis.")
            if let result {
                if result.belowTermWeight {
                    // No dose is shown: Table 3 was not written for preterm infants.
                    CalcCaution(text: "Under 2.5 kg: no published starting doses for preterm or low-birth-weight infants. Dose with neonatal pharmacy and nutrition.")
                } else {
                    doses(result)
                }
                if let separate = result.separateDosing {
                    bilirubinCard(separate: separate)
                }
            }
            if let inputHint {
                Text(inputHint).font(.hepCaption).foregroundStyle(Color.hepMuted)
            }
            monitoring
            escalation
            footer
            CalculatorResetButton {
                weightText = ""; bilirubinText = ""
            }
        }
    }

    // MARK: Doses

    private func doses(_ r: VitaminsCalc.Result) -> some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text("Starting doses (NASPGHAN/ESPGHAN 2019)").font(.hepTag).foregroundStyle(Color.hepMuted)
                    .accessibilityAddTraits(.isHeader)
                doseRow("Vitamin A", value: VitaminsCalc.formatIU(r.vitaminAIU), unit: "IU/day",
                        note: "By mouth. 5,000 IU/day up to 10 kg; 10,000 IU/day above 10 kg.")
                doseRow("Vitamin D", value: VitaminsCalc.formatRange(VitaminsCalc.vitaminDRangeIU), unit: "IU/day",
                        note: "Cholecalciferol (D3) by mouth. Weekly 50,000 IU is used in some centers; too few data to recommend it.")
                doseRow("Vitamin E", value: VitaminsCalc.formatRange(r.tpgsLowIU...r.tpgsHighIU), unit: "IU/day",
                        note: "As TPGS, 15–25 IU/kg/day by mouth. TPGS forms its own micelles without bile and helps absorb vitamin D: give the vitamins together.")
                doseRow("Vitamin K", value: VitaminsCalc.formatRange(VitaminsCalc.vitaminKRangeMg), unit: "mg/day",
                        note: "By mouth. If the INR stays high, 1–10 mg IV may be needed; anaphylaxis with IV vitamin K has been reported. Confirm the infant dose with pharmacy. Prolonged INR: see the Prolonged INR card.")
            }
        }
    }

    private func doseRow(_ label: String, value: String, unit: String, note: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            CalcMetricRow(label: label, value: value, unit: unit)
            Text(note).font(.hepCaption).foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func bilirubinCard(separate: Bool) -> some View {
        if separate {
            CalcCaution(text: "Total bilirubin 2 mg/dL or more: a combined multivitamin is not enough. In ChiLDReN (infants after Kasai), 0 of 23 such infants were sufficient in all four vitamins at 6 months. Give each vitamin separately, measure each, and check levels monthly if cholestasis is severe.")
        } else {
            Text("Total bilirubin below 2 mg/dL: in ChiLDReN (infants after Kasai), levels were mostly sufficient on a multivitamin. Still measure every 3–6 months.")
                .font(.hepBody).foregroundStyle(Color.hepInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Static reference

    private var monitoring: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("What to measure").font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                    .accessibilityAddTraits(.isHeader)
                CalcBullet(text: "When: every 3–6 months; monthly in severely cholestatic infants. Adjust doses to the levels.")
                CalcBullet(text: "A: serum retinol and retinol-binding protein (RBP). Retinol below 20 µg/dL → confirm with a modified relative dose response. ChiLDReN target: retinol 19–77 µg/dL and retinol:RBP molar ratio above 0.8. RBP is unreliable in advanced liver disease.")
                CalcBullet(text: "D: 25-OH vitamin D. ChiLDReN target 15–45 ng/mL; below 15 was called insufficient (a conservative cut-off; others use 20). With low D, check calcium, phosphate and PTH.")
                CalcBullet(text: "E: vitamin E to total lipid ratio, not serum E alone (high lipids hide deficiency). Deficient below 0.6 mg/g at 1–12 years, below 0.8 mg/g if older. ChiLDReN infants: target above 0.6 mg/g.")
                CalcBullet(text: "K: INR (ChiLDReN target 1.2 or less). A normal INR does not prove enough vitamin K for bone; PIVKA-II helps where available.")
                CalcBullet(text: "Essential fatty acids every 3–6 months: red-cell fatty acid profile. A triene:tetraene ratio alone is not enough.")
            }
        }
    }

    private var escalation: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("If a level stays low (ChiLDReN protocol)").font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                    .accessibilityAddTraits(.isHeader)
                CalcBullet(text: "A: raise by 5,000 IU/day, up to 25,000–50,000 IU/day by mouth. Keep retinol within 19–77 µg/dL: too much causes liver fibrosis.")
                CalcBullet(text: "D: raise cholecalciferol in steps of 1,200–8,000 IU/day, or switch to calcitriol 0.05–0.20 µg/kg/day.")
                CalcBullet(text: "E: raise TPGS by 25 IU/kg/day, up to 100 IU/kg/day.")
                CalcBullet(text: "K: INR above 1.2 to 1.5 → 2.5 mg/day by mouth. Above 1.5 to 1.8 → a parenteral dose of 2–5 mg plus 2.5 mg/day by mouth. Above 1.8 → a parenteral dose of 2–5 mg plus 5 mg/day by mouth. Give it IV or subcutaneously, not IM, in a coagulopathic infant (Prolonged INR card).")
                Text("A research protocol in infants after Kasai (the trial gave parenteral doses IM), not a guideline.")
                    .font(.hepCaption).foregroundStyle(Color.hepMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Vitamin A = 5,000 IU/day up to 10 kg, 10,000 IU/day above; vitamin E (TPGS) = weight × 15 to weight × 25 IU/day; D and K are fixed ranges (Mouzaki 2019, Table 3). Bilirubin trigger and escalation: Shneider 2012 (ChiLDReN, 92 infants after Kasai on a TPGS multivitamin). No maximum is published for the TPGS starting dose, and no separate dose for preterm infants.")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
            CitationFooter(citations: VitaminsCalc.sourceIds.compactMap { registry?.guideline($0)?.citation })
        }
    }
}
