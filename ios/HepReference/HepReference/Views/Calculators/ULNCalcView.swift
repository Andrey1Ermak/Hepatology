import SwiftUI

/// `c_uln`: an enzyme as a multiple of the ULN. The health-based ULN comes
/// from `labs.json` when the app holds one for the chosen age and sex (today:
/// ALT, 11–18 y); otherwise the fellow enters the laboratory's ULN.
struct ULNCalcView: View {
    @Environment(Registry.self) private var registry: Registry?
    @State private var enzyme: LiverEnzyme = .alt
    @State private var age: AgeBand?
    @State private var sex: Sex?
    @State private var valueText = ""
    @State private var labULNText = ""

    private var reference: LabBand? {
        ULNCalc.reference(in: registry?.labs ?? [], enzyme: enzyme, age: age, sex: sex)
    }

    private var value: Double? { valueText.parsedDouble }

    private func multiple(over uln: Double?) -> Double? {
        guard let value, let uln else { return nil }
        return ULNCalc.multiple(value: value, uln: uln)
    }

    private var labMultiple: Double? { multiple(over: labULNText.parsedDouble) }
    private var referenceMultiple: Double? { multiple(over: reference?.high) }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    chipRow("Test", options: LiverEnzyme.allCases, selected: enzyme, label: \.name) {
                        // A value typed for one test is not a value for another.
                        if $0 != enzyme { valueText = "" }
                        enzyme = $0
                    }
                    chipRow("Age", options: AgeBand.allCases, selected: age, label: \.label) { age = $0 }
                    chipRow("Sex", options: [Sex.F, Sex.M], selected: sex, label: \.name) { sex = $0 }
                    CalcNumberField(label: "\(enzyme.name) (U/L)", text: $valueText)
                    CalcNumberField(label: "Lab ULN (U/L)", text: $labULNText)
                    referenceLine
                }
            }
            if labMultiple != nil || referenceMultiple != nil {
                result
            }
            if let caution {
                CalcCaution(text: caution)
            }
            footer
            CalculatorResetButton {
                valueText = ""
                labULNText = ""
            }
        }
    }

    private func chipRow<T: Equatable>(_ title: String, options: [T], selected: T?, label: KeyPath<T, String>, select: @escaping (T) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title.uppercased()).font(.hepTag).foregroundStyle(Color.hepMuted)
                .accessibilityAddTraits(.isHeader)
            FlowLayout {
                ForEach(options.indices, id: \.self) { i in
                    SelectableChip(label: options[i][keyPath: label], isOn: options[i] == selected) {
                        select(options[i])
                    }
                }
            }
        }
    }

    private var referenceLine: some View {
        referenceText
            .font(.hepCaption)
            .foregroundStyle(Color.hepMuted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var referenceText: Text {
        if let reference, let high = reference.high {
            return Text("Health-based ULN for this age and sex: \(LabBand.format(high)) U/L (\(sourceName(reference.source))). Use it even when the laboratory prints a higher limit.")
        } else if enzyme == .alt, age == .teen, sex == nil {
            return Text("Select sex to use the health-based ULN for 11–18 y.")
        } else {
            return Text("No validated pediatric ULN for this test, age and sex in the app — use your laboratory's age- and sex-specific ULN.")
        }
    }

    private var result: some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                if let referenceMultiple {
                    CalcMetricRow(label: "× health-based ULN", value: ULNCalc.format(referenceMultiple))
                }
                if let labMultiple {
                    CalcMetricRow(label: "× lab ULN", value: ULNCalc.format(labMultiple))
                }
                if let value, let grade = ULNCalc.grade(enzyme: enzyme, value: value, multiple: referenceMultiple ?? labMultiple ?? 0) {
                    Divider()
                    Text("ACG grade").font(.hepTag).foregroundStyle(Color.hepMuted)
                    Text(grade.label).font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                    if referenceMultiple != nil && labMultiple != nil {
                        Text("Graded against the health-based ULN; against the lab ULN the grade may be lower.")
                            .font(.hepCaption)
                            .foregroundStyle(Color.hepMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var caution: String? {
        switch enzyme {
        case .alp: "ALP follows bone growth: a growing child's ULN can be up to about 4 times the adult one. Use your laboratory's ULN for this age and sex."
        case .ggt: "GGT is much higher in newborns and young infants than later. Use an age-specific ULN."
        case .ast: "AST is also in muscle and red cells. A high AST with a lower ALT: check CK and look for hemolysis."
        case .alt: nil
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("× ULN = value ÷ upper limit of normal. ACG grades ALT and AST in adults; the grade sorts causes but does not predict prognosis (BSG).")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
            CitationFooter(citations: citations)
        }
    }

    private var citations: [String] {
        var ids = ULNCalc.sourceIds
        if let source = reference?.source { ids.append(source) }
        return ids.compactMap { registry?.guideline($0)?.citation }
    }

    private func sourceName(_ id: String) -> String {
        guard let guideline = registry?.guideline(id) else { return id }
        return "\(guideline.society) \(guideline.year)"
    }
}

private extension Sex {
    /// Chip label — VoiceOver reads "Female", not "F".
    var name: String {
        switch self {
        case .F: "Female"
        case .M: "Male"
        }
    }
}
