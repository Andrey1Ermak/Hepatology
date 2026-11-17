import SwiftUI

struct ContentView: View {
    @State private var library = CardLibrary()
    @State private var registry = Registry()
    @StateObject private var calculatorPresenter = CalculatorPresenter()
    @State private var tab: AppTab = Self.launchTab

    enum AppTab: String {
        case home, study, search
    }

    /// Home, unless a Debug launch argument `-hepOpenTab <home|study|search>`
    /// asks for another tab (tools/screenshot.sh, `HEP_OPEN_TAB`).
    private static var launchTab: AppTab {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-hepOpenTab"), args.indices.contains(i + 1),
           let tab = AppTab(rawValue: args[i + 1]) {
            return tab
        }
        #endif
        return .home
    }

    var body: some View {
        TabView(selection: $tab) {
            HomeView(library: library)
                .tabItem { Label("Home", systemImage: "square.grid.2x2") }
                .tag(AppTab.home)

            StudyView(library: library)
                .tabItem { Label("Study", systemImage: "book") }
                .tag(AppTab.study)

            SearchView(library: library)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.search)
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
        // numeric_calc opened from any tab grows from screen-center over
        // everything, tab bar included. See CalculatorPresenter.
        .overlay {
            if let active = calculatorPresenter.active {
                // An overlay does not inherit the environment set on the
                // view it decorates, so pass the registry on explicitly
                // (`c_uln` reads labs.json, every calculator cites sources) and the
                // library (any card link inside a calculator).
                NumericCalcSheet(calcId: active.calcId, title: active.title)
                    .environmentObject(calculatorPresenter)
                    .environment(registry)
                    .environment(library)
                    .transition(.scale(scale: 0.01, anchor: .center).combined(with: .opacity))
            }
        }
        #if DEBUG
        // `-hepOpenCalc <calc_id>` opens a calculator on launch, so
        // tools/screenshot.sh can capture it without UI automation.
        .task {
            let args = ProcessInfo.processInfo.arguments
            if let i = args.firstIndex(of: "-hepOpenCalc"), args.indices.contains(i + 1) {
                calculatorPresenter.present(calcId: args[i + 1], title: NumericCalcRegistry.title(for: args[i + 1]))
            }
        }
        #endif
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
