import SwiftUI

@main
struct HepReferenceApp: App {
    init() {
        // The tab bar's default translucent "glass" material sits in a
        // higher system layer than anything inside a tab's own content view
        // — no overlay/background trick within CardListView/SearchView can
        // ever composite above it, and SwiftUI's own `.toolbarBackground(_:
        // for: .tabBar)` (see ContentView) only blends a tint *under* that
        // glass rather than replacing it, so cards were still visibly
        // bleeding through at the very bottom of the scroll.
        // `UITabBarAppearance.configureWithOpaqueBackground()` is the
        // lower-level, reliable way to force a genuinely solid tab bar.
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "appBackground")
        // Tab labels in Avenir Next too (UIKit-drawn, outside SwiftUI fonts).
        if let avenir = UIFont(name: Font.AvenirFace.demiBold.rawValue, size: 10) {
            let font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: avenir)
            for item in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
                item.normal.titleTextAttributes = [.font: font]
                item.selected.titleTextAttributes = [.font: font]
            }
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
