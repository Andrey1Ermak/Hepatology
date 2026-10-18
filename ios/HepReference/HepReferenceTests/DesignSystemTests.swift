import XCTest
import UIKit
import SwiftUI
@testable import HepReference

/// Guards the design system of CLAUDE.md §12: every Avenir Next face the
/// type roles use is installed and scales with Dynamic Type, every color
/// token exists in both themes, and the text/background pairs the app
/// actually draws keep ≥ 4.5:1 contrast in light and dark mode (§12.4).
final class DesignSystemTests: XCTestCase {
    private let light = UITraitCollection(userInterfaceStyle: .light)
    private let dark = UITraitCollection(userInterfaceStyle: .dark)

    func testEveryAvenirFaceIsInstalled() {
        for face in Font.AvenirFace.allCases {
            XCTAssertNotNil(UIFont(name: face.rawValue, size: 17), "\(face.rawValue) must be available on iOS")
        }
    }

    func testAvenirScalesWithDynamicType() {
        let base = UIFont(name: Font.AvenirFace.heavy.rawValue, size: 20)!
        let metrics = UIFontMetrics(forTextStyle: .title3)
        let small = metrics.scaledFont(for: base, compatibleWith: UITraitCollection(preferredContentSizeCategory: .small))
        let huge = metrics.scaledFont(for: base, compatibleWith: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge))
        XCTAssertGreaterThan(huge.pointSize, small.pointSize)
    }

    func testEveryColorTokenExists() {
        let names = ["ink", "brandAccent", "blue", "maroon", "muted", "surface", "appBackground", "card",
                     "crit", "critTint", "urg", "urgTint", "ok", "okTint", "info", "infoTint", "gap",
                     "onSolid", "onBright", "launchBackground"]
        for name in names {
            XCTAssertNotNil(UIColor(named: name, in: Bundle(for: CardLibrary.self), compatibleWith: nil), "missing color set \(name)")
        }
    }

    /// Text on fill pairs drawn by the app — (text, background).
    private let textPairs: [(String, String)] = [
        ("ink", "appBackground"), ("ink", "surface"), ("ink", "card"),
        ("muted", "appBackground"), ("muted", "surface"), ("muted", "card"),
        ("brandAccent", "appBackground"), ("blue", "appBackground"),
        ("ink", "critTint"), ("ink", "urgTint"), ("ink", "okTint"), ("ink", "infoTint"),
        ("onSolid", "crit"), ("onSolid", "ok"), ("onSolid", "info"), ("onSolid", "brandAccent"),
        ("onSolid", "maroon"), ("onBright", "urg"), ("onBright", "gap"),
        ("muted", "critTint"), ("muted", "urgTint"), ("muted", "okTint"), ("muted", "infoTint"),
        ("brandAccent", "card"), ("brandAccent", "surface"), ("blue", "surface"), ("blue", "card"),
    ]

    func testTextContrastInBothThemes() {
        for (text, fill) in textPairs {
            for traits in [light, dark] {
                let ratio = contrast(color(text, traits), color(fill, traits))
                XCTAssertGreaterThanOrEqual(ratio, 4.5, "\(text) on \(fill) (\(traits.userInterfaceStyle == .dark ? "dark" : "light")): \(ratio)")
            }
        }
    }

    func testTierTextColorMatchesItsFill() {
        for tier in [Tier.crit, .urg, .rt, .ref] {
            for traits in [light, dark] {
                let text = UIColor(tier.onSolid).resolvedColor(with: traits)
                let fill = UIColor(tier.solid).resolvedColor(with: traits)
                XCTAssertGreaterThanOrEqual(contrast(text, fill), 4.5, "\(tier)")
            }
        }
    }

    func testRomanNumerals() {
        XCTAssertEqual(RomanNumeral.string(1), "I")
        XCTAssertEqual(RomanNumeral.string(4), "IV")
        XCTAssertEqual(RomanNumeral.string(9), "IX")
        XCTAssertEqual(RomanNumeral.string(14), "XIV")
        XCTAssertEqual(RomanNumeral.string(26), "XXVI")
        XCTAssertNil(RomanNumeral.string(0))
        XCTAssertNil(RomanNumeral.string(40))
    }

    func testCategoryNumbersFollowBrowseOrder() {
        XCTAssertEqual(CardCategory.jaundice.number, 1)
        XCTAssertEqual(CardCategory.ref.number, CardCategory.browseOrder.count)
    }

    // MARK: - WCAG relative luminance

    private func color(_ name: String, _ traits: UITraitCollection) -> UIColor {
        UIColor(named: name, in: Bundle(for: CardLibrary.self), compatibleWith: nil)!.resolvedColor(with: traits)
    }

    private func contrast(_ a: UIColor, _ b: UIColor) -> Double {
        let la = luminance(a), lb = luminance(b)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }

    private func luminance(_ c: UIColor) -> Double {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        c.getRed(&r, green: &g, blue: &b, alpha: &a)
        func lin(_ v: CGFloat) -> Double {
            let v = Double(v)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }
}
