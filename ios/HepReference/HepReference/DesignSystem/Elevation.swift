import SwiftUI

/// Soft, layered elevation — gives every `SectionCard` a depth cue
/// (`0 1px 2px rgba(20,26,34,.05), 0 6px 18px rgba(20,26,34,.06)`) instead of
/// conveying "distinct surface" with only a 1px stroke. Applied as `SectionCard`'s
/// default, so every card/badge/calculator surface in the app picks it up.
/// Shadow color is the `hepShadow` token (navy-black in light, black in dark).
///
/// Dark mode does **not** reuse the light-mode values with the color
/// inverted — a low-opacity black shadow barely registers against a
/// near-black `systemBackground`, so it needs more contact opacity and a
/// tighter blur to actually read as depth (the same adjustment Material
/// Design's own dark-theme elevation guidance makes: dark surfaces need
/// stronger, tighter shadows than light ones, not the same recipe darkened).
struct HepElevated: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .shadow(color: Color.hepShadow.opacity(0.45), radius: 2, x: 0, y: 1)
                .shadow(color: Color.hepShadow.opacity(0.35), radius: 10, x: 0, y: 4)
        } else {
            content
                .shadow(color: Color.hepShadow.opacity(0.06), radius: 2, x: 0, y: 1)
                .shadow(color: Color.hepShadow.opacity(0.08), radius: 10, x: 0, y: 4)
        }
    }
}

extension View {
    func hepElevated() -> some View { modifier(HepElevated()) }
}
