import SwiftUI
import UIKit

/// Keeps the edge-swipe "back" gesture on screens that hide the system
/// navigation bar (card, category, search, study, home) to show their own
/// lesson-style header with `HeaderBackButton`.
///
/// UIKit disables `interactivePopGestureRecognizer` when the bar is hidden.
/// A screen opts back in with `.swipeBackEnabled()`, which points the
/// recognizer at one shared, stateless delegate. Nothing in UIKit is
/// overridden or swizzled.
final class SwipeBackGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = SwipeBackGestureDelegate()

    /// The swipe starts only when there is a screen to go back to and no
    /// transition is already running: a swipe on the root screen would
    /// otherwise freeze the stack.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigation = gestureRecognizer.view?.next as? UINavigationController,
              gestureRecognizer === navigation.interactivePopGestureRecognizer else { return false }
        return navigation.viewControllers.count > 1 && navigation.transitionCoordinator == nil
    }

    /// Points `navigation`'s pop gesture at the shared delegate.
    @MainActor
    static func attach(to navigation: UINavigationController?) {
        guard let gesture = navigation?.interactivePopGestureRecognizer,
              gesture.delegate !== shared else { return }
        gesture.delegate = shared
    }
}

/// An invisible child controller that finds the enclosing navigation
/// controller once it is in the hierarchy.
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) {}

    final class Controller: UIViewController {
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            SwipeBackGestureDelegate.attach(to: navigationController)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            SwipeBackGestureDelegate.attach(to: navigationController)
        }
    }
}

extension View {
    /// Restores the edge-swipe back gesture on a screen that hides the
    /// system navigation bar.
    func swipeBackEnabled() -> some View {
        background(SwipeBackEnabler().frame(width: 0, height: 0).accessibilityHidden(true))
    }
}
