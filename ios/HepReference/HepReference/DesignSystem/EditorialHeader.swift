import SwiftUI

/// Roman numerals for section numbering, as in the lesson decks
/// (I Red flags · II Age · … · IX Test yourself; home categories I–IX).
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

/// The back chevron beside a fixed screen header (card, category): navy,
/// scaled with Dynamic Type, never smaller than a 44 pt target. Screens
/// hide the system bar to keep their lesson-style header, so they share
/// this one button instead of each drawing their own.
struct HeaderBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.hepBodyEmphasis)
                .imageScale(.large)
                .foregroundStyle(Color.hepNavy)
                .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
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
