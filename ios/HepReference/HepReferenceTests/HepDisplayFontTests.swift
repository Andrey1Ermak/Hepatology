import XCTest
import UIKit
@testable import HepReference

/// Guards the one concrete risk in notes/ios_premium_pass_plan.md's Phase P1:
/// the bundled Space Grotesk accent font must actually be registered (via
/// Info.plist's UIAppFonts) and must scale with Dynamic Type the same way
/// every other `hep*` token does — a static one-time Simulator check would
/// catch a regression once; this catches it on every future build.
final class HepDisplayFontTests: XCTestCase {
    func testAllBundledWeightsAreRegistered() {
        for name in ["SpaceGrotesk-Regular", "SpaceGrotesk-Medium", "SpaceGrotesk-Bold"] {
            XCTAssertNotNil(UIFont(name: name, size: 22), "\(name) must be registered via Info.plist UIAppFonts")
        }
    }

    func testHepDisplayScalesWithDynamicType() {
        let metrics = UIFontMetrics(forTextStyle: .title2)
        let base = UIFont(name: "SpaceGrotesk-Bold", size: 22)!
        let small = metrics.scaledFont(for: base, compatibleWith: UITraitCollection(preferredContentSizeCategory: .small))
        let xxxLarge = metrics.scaledFont(for: base, compatibleWith: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge))
        XCTAssertGreaterThan(xxxLarge.pointSize, small.pointSize, "hepDisplay must grow at larger accessibility text sizes, not stay fixed")
    }
}
