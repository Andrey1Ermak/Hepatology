import SwiftUI

struct ContentView: View {
    @State private var library = CardLibrary()
    @State private var registry = Registry()
    @StateObject private var calculatorPresenter = CalculatorPresenter()

    var body: some View {
        TabView {
            CardListView(library: library)
                .tabItem { Label("Browse", systemImage: "list.bullet") }

            SearchView(library: library)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
        // Explicit .tint (redundant with the Assets.xcassets global accent
        // color, but self-documenting). The tab bar's actual opacity fix
        // lives in HepReferenceApp's init (UITabBarAppearance) — SwiftUI's
        // own `.toolbarBackground(_:for: .tabBar)` only tints *under* the
        // system's translucent glass material rather than replacing it, so
        // it isn't enough on its own and was dropped here to avoid the two
        // fighting each other.
        .tint(Color.hepNavy)
        // iOS 26's tab bar auto-minimizes/goes more glass-like on scroll by
        // default (like Safari's toolbar) — that's the likely actual source
        // of the bleed-through, separate from its baseline translucency.
        // The API itself only exists on iOS 26+, but the app's deployment
        // target is 17.0, so it needs an availability guard.
        .modifier(TabBarNeverMinimizesModifier())
        .environmentObject(calculatorPresenter)
        // Card links (`CardLinkButton`, `CardLinksView`) read targets from
        // the library; the header and Study links read the registries.
        .environment(library)
        .environment(registry)
        // Overlaid above the whole TabView (not a per-tab .sheet) so a
        // numeric_calc opened from either tab grows from screen-center over
        // everything, tab bar included. See CalculatorPresenter.
        .overlay {
            if let active = calculatorPresenter.active {
                NumericCalcSheet(calcId: active.calcId, title: active.title)
                    .environmentObject(calculatorPresenter)
                    .transition(.scale(scale: 0.01, anchor: .center).combined(with: .opacity))
            }
        }
        // Avenir Next body in ink for any text without an explicit role —
        // applied last so the calculator overlay inherits it too.
        .font(.hepBody)
        .foregroundStyle(Color.hepInk)
    }
}

/// Wraps `.tabBarMinimizeBehavior(.never)` (iOS 26+ only API) behind an
/// availability check so the app can still target iOS 17. On iOS < 26 the
/// tab bar has no minimize-on-scroll behavior to disable in the first place.
private struct TabBarNeverMinimizesModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.tabBarMinimizeBehavior(.never)
        } else {
            content
        }
    }
}

#Preview {
    ContentView()
}
