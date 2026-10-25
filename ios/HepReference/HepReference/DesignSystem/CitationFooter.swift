import SwiftUI

/// A block's sources under a thin rule (CLAUDE.md §12.3): `hepCitation` in
/// `muted`, joined by " · ". Renders nothing when there are no citations.
struct CitationFooter: View {
    let citations: [String]

    var body: some View {
        if !citations.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Rectangle()
                    .fill(Color.hepRule)
                    .frame(height: 0.5)
                Text(citations.joined(separator: " · "))
                    .font(.hepCitation)
                    .foregroundStyle(Color.hepMuted)
            }
        }
    }
}
