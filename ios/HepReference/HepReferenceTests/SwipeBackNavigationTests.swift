import UIKit
import XCTest
@testable import HepReference

/// The edge-swipe back gesture must work on screens that hide the system bar,
/// and must never start on the root screen (that freezes the stack).
@MainActor
final class SwipeBackNavigationTests: XCTestCase {
    private func navigation() throws -> (UINavigationController, UIGestureRecognizer) {
        let nav = UINavigationController(rootViewController: UIViewController())
        nav.loadViewIfNeeded()
        SwipeBackGestureDelegate.attach(to: nav)
        return (nav, try XCTUnwrap(nav.interactivePopGestureRecognizer))
    }

    func testAttachPointsPopGestureAtSharedDelegate() throws {
        let (_, gesture) = try navigation()
        XCTAssertTrue(gesture.delegate === SwipeBackGestureDelegate.shared)
    }

    func testPopGestureOnlyBeginsWithAScreenToGoBackTo() throws {
        let (nav, gesture) = try navigation()
        let delegate = SwipeBackGestureDelegate.shared
        XCTAssertFalse(delegate.gestureRecognizerShouldBegin(gesture), "root screen: nothing to pop")

        nav.pushViewController(UIViewController(), animated: false)
        XCTAssertTrue(delegate.gestureRecognizerShouldBegin(gesture), "pushed screen: swipe back allowed")

        nav.popViewController(animated: false)
        XCTAssertFalse(delegate.gestureRecognizerShouldBegin(gesture), "back on root: blocked again")
    }

    func testUnrelatedGestureIsNotStarted() {
        XCTAssertFalse(SwipeBackGestureDelegate.shared.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))
    }
}
