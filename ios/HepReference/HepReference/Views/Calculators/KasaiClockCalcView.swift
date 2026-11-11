import SwiftUI

/// `c_kasai_clock`: date of birth → age in days and days to 30 / 45 / 60.
/// The clock argues for speed at every age; it never says "too late".
/// Logic in `KasaiClockCalc`.
struct KasaiClockCalcView: View {
    @Environment(Registry.self) private var registry: Registry?
    @State private var birth = Calendar.current.startOfDay(for: .now)
    /// No result until a date is actually chosen: a default "age 0 days"
    /// must never read like an answer.
    @State private var chosen = false

    var body: some View {
        // Redraw every minute so a sheet left open overnight moves to the
        // next day by itself.
        TimelineView(.everyMinute) { context in
            content(today: context.date)
        }
    }

    private func content(today: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    DatePicker("Date of birth", selection: Binding(get: { birth }, set: { birth = $0; chosen = true }), in: ...today, displayedComponents: .date)
                        .font(.hepCaption)
                        .foregroundStyle(Color.hepMuted)
                        .tint(Color.hepNavy)
                    if !chosen {
                        Text("Set the date of birth to start the clock.")
                            .font(.hepCaption).foregroundStyle(Color.hepMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            if chosen, let result = KasaiClockCalc.compute(birth: birth, today: today) {
                resultCard(result)
                message(result.band)
            }
            evidence
            footer
            CalculatorResetButton {
                birth = Calendar.current.startOfDay(for: .now)
                chosen = false
            }
        }
    }

    // MARK: Result

    private func resultCard(_ result: KasaiClockCalc.Result) -> some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                CalcMetricRow(label: "Age", value: "\(result.ageDays)", unit: result.ageDays == 1 ? "day" : "days")
                Text(KasaiClockCalc.formatWeeks(result.ageDays) + " · " + result.band.label)
                    .font(.hepCaption).foregroundStyle(Color.hepMuted)
                Divider()
                ForEach(result.milestones, id: \.day) { m in
                    HStack(alignment: .firstTextBaseline) {
                        Text("Day \(m.day)").font(.hepCaptionBold).foregroundStyle(Color.hepInk)
                        Spacer()
                        Text(KasaiClockCalc.formatMilestone(m))
                            .font(.hepMetric)
                            .foregroundStyle(m.daysLeft < 0 ? Color.hepMuted : Color.hepNavy)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    @ViewBuilder
    private func message(_ band: KasaiClockCalc.Band) -> some View {
        VerdictBanner(verdict: Verdict(band: band.isLate ? .hi : .mid,
                                       text: "Suspected biliary atresia: cholangiogram and Kasai as soon as possible. Outcome falls with every band of age; there is no safe age to wait for."),
                      headline: "Every day counts")
        if band.isLate {
            SectionCard {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Late is not futile").font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                        .accessibilityAddTraits(.isHeader)
                    CalcBullet(text: "Age alone does not rule out a Kasai: in Canada 23% of infants operated after 90 days had their own liver at 4 years (Schreiber 2007).")
                    CalcBullet(text: "Ascites, an INR that does not correct with vitamin K, or cirrhosis → transplant-center assessment first (expert opinion).")
                    CalcBullet(text: "Decide with the surgeon and a transplant center today.")
                }
            }
        }
    }

    // MARK: Static reference

    private var evidence: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Why the days matter").font(.hepSectionHeading).foregroundStyle(Color.hepInk)
                    .accessibilityAddTraits(.isHeader)
                CalcBullet(text: "France, 1,340 Kasai operations: alive with own liver at 25 years — 38% if operated in month 1, 27% month 2, 22% month 3, 19% later (Fanna 2019).")
                CalcBullet(text: "Canada, 349 children with biliary atresia: own liver at 4 years — 49% if Kasai at 30 days or younger, 36% at 31–90 days, 23% after 90 days (Schreiber 2007).")
                CalcBullet(text: "France: a Kasai for every infant before 46 days would spare 5.7% of pediatric liver transplants (Serinet 2009).")
                CalcBullet(text: "Meta-analysis, 9 studies: Kasai at 30 days or younger vs later, risk ratio 1.22 for survival with own liver (Hoshino 2023).")
                CalcBullet(text: "Preterm infant: no source defines a corrected-age clock (limited data). This clock counts days since birth.")
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Age in days = calendar days since birth (day of birth = 0). Days 30, 45 and 60 are reference points from outcome studies, not deadlines; median age at Kasai was 55–59 days in Canada and France.")
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                .fixedSize(horizontal: false, vertical: true)
            CitationFooter(citations: KasaiClockCalc.sourceIds.compactMap { registry?.guideline($0)?.citation })
        }
    }
}
