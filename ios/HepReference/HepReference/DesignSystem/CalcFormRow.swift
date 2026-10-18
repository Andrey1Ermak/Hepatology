import SwiftUI

/// A single labeled input row for a numeric calculator sheet — label above
/// a full-width field, replacing the ad hoc "HStack { Text; TextField }" /
/// two-field-per-row pattern that risked clipping on narrow phones (see
/// notes/ios_redesign_plan.md §Phase R4, Diagnosis §4).
struct CalcFormRow<Field: View>: View {
    let label: String
    @ViewBuilder let field: () -> Field

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.hepCaption)
                .foregroundStyle(.secondary)
            field()
        }
    }
}
