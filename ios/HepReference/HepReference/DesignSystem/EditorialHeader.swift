import SwiftUI

/// Roman numerals for section numbering, as in the lesson decks
/// (I Red flags · II Age · … · IX Test yourself; Browse categories I–IX).
enum RomanNumeral {
    /// `nil` outside 1...39 — the app never numbers past a few dozen.
    static func string(_ n: Int) -> String? {
        guard (1...39).contains(n) else { return nil }
        let tens = String(repeating: "X", count: n / 10)
        let ones = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"][n % 10]
        return tens + ones
    }
}

/// The maroon numbered badge that opens a lesson slide's kicker line.
struct SectionNumberBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.hepKicker)
            .foregroundStyle(Color.hepOnSolid)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .frame(minWidth: 28)
            .background(Color.hepMaroon, in: RoundedRectangle(cornerRadius: 2))
            .hepElevated()
    }
}

/// Kicker line: optional maroon numbered badge, then small blue caps.
struct KickerLine: View {
    var number: String? = nil
    let text: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            if let number {
                SectionNumberBadge(text: number)
            }
            Text(text)
                .hepKickerStyle()
        }
        .accessibilityElement(children: .combine)
    }
}

/// The lessons' title underline: a 2 pt rule, a 2 pt gap, a 0.5 pt rule.
struct DoubleRule: View {
    var body: some View {
        VStack(spacing: 2) {
            Rectangle().fill(Color.hepInk).frame(height: 2)
            Rectangle().fill(Color.hepInk).frame(height: 0.5)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.xs) {
        KickerLine(number: "I", text: "Jaundice & Cholestasis")
        Text("Cholestasis 0–3 Months").hepTitleStyle()
        Text("NASPGHAN/ESPGHAN 2017 · AAP 2022").font(.hepSubtitle).foregroundStyle(Color.hepMuted)
        DoubleRule()
    }
    .padding()
}
