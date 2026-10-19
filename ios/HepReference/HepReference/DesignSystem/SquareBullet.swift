import SwiftUI

/// The lessons' square list marker (▪) — CLAUDE.md §12.3. A drawn square,
/// not a "▪" glyph, so its size and baseline don't drift with the font.
/// Place it in a `.top`-aligned HStack; `topInset` centers it on the first
/// line of the text beside it.
struct SquareBullet: View {
    var color: Color = Color.hepInk
    var size: CGFloat = 5
    var topInset: CGFloat = 7

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .padding(.top, topInset)
            .accessibilityHidden(true)
    }
}
