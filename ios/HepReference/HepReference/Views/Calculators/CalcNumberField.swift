import SwiftUI

/// The shared compact numeric input every numeric calculator uses, so
/// inputs read as one component: a muted label and a centered decimal field
/// on a raised card with a thin rule.
struct CalcNumberField: View {
    let label: String
    @Binding var text: String
    /// Grey hint inside an empty field (e.g. a reference ULN).
    var placeholder: String = ""

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(label)
                .font(.hepCaption)
                .foregroundStyle(Color.hepMuted)
                // Wrap a long label instead of truncating it.
                .fixedSize(horizontal: false, vertical: true)
                // The field speaks the label itself; don't read it twice.
                .accessibilityHidden(true)
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .font(.hepCaption)
                .multilineTextAlignment(.center)
                .accessibilityLabel(label)
        }
        .frame(maxWidth: .infinity, minHeight: 32, alignment: .center)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(Color.hepCard, in: RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(RoundedRectangle(cornerRadius: Radius.medium).stroke(Color.hepRule, lineWidth: 1))
    }
}

/// One headline number in a calculator result: caption on the left, the
/// value in `hepMetric` navy and its unit on the right.
struct CalcMetricRow: View {
    let label: String
    let value: String
    var unit: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            Text(label).font(.hepCaption).foregroundStyle(Color.hepMuted)
            Spacer()
            Text(value).font(.hepMetric).foregroundStyle(Color.hepNavy)
            if let unit {
                Text(unit).font(.hepCaption).foregroundStyle(Color.hepMuted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// A short tinted caution inside a calculator (e.g. "use the child's own
/// ALP ULN"), in the `urg` tier.
struct CalcCaution: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.hepIconMedium)
                .foregroundStyle(Tier.urg.solid)
            Text(text).font(.hepCaption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tier.urg.tint, in: RoundedRectangle(cornerRadius: Radius.medium))
    }
}
