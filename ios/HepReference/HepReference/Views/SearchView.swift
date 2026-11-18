import SwiftUI

struct SearchView: View {
    let library: CardLibrary
    /// Synonyms widen the search ("BA", "kasai", "атрезия" → biliary
    /// atresia); without the registry, search falls back to titles and tags.
    @Environment(Registry.self) private var registry: Registry?
    @State private var query = Self.launchQuery

    /// Empty, unless a Debug launch argument `-hepSearchQuery <text>` fills
    /// the field (tools/screenshot.sh, `HEP_SEARCH_QUERY`).
    private static var launchQuery: String {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-hepSearchQuery"), args.indices.contains(i + 1) {
            return args[i + 1]
        }
        #endif
        return ""
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField

                ScrollView {
                    let results = library.search(query, synonyms: registry?.synonyms ?? [:])
                    if results.isEmpty {
                        Group {
                            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                ContentUnavailableView { emptyStateLabel }
                            } else {
                                ContentUnavailableView.search(text: query)
                            }
                        }
                        .padding(.top, Spacing.xl)
                    } else {
                        // Same two-column grid as a category list — a search result is
                        // the identical tile, not a different single-column
                        // layout. `.padding(.top, Spacing.s)` matches the
                        // grid's own inter-row `spacing:` exactly, so the gap
                        // above the first row equals the gap between any two
                        // rows, instead of whatever List's own default inset
                        // happened to be.
                        LazyVGrid(columns: GridLayout.twoColumns, spacing: Spacing.s) {
                            ForEach(results) { card in
                                cardLink(card)
                            }
                        }
                        .padding(.horizontal, Spacing.l)
                        .padding(.top, Spacing.s)
                    }
                }
            }
            .background(Color.hepBackground.ignoresSafeArea())
            // No nav title/bar — the search field itself explains the screen
            // now, matching Home's own "title only ate space" fix.
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { id in
                if let card = library.cardsByID[id] {
                    CardDetailView(card: card)
                }
            }
        }
    }

    /// Matches a category header's own title style (`hepTitleStyle`) — no
    /// separate "Search by title, code, or tag" line underneath; the
    /// field's own placeholder already says that.
    private var emptyStateLabel: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.hepNavy)
            Text("Search Cards")
                .hepTitleStyle()
        }
    }

    /// Styled and sized to read as one more tile in `CardRowView`'s own
    /// family rather than a separate system control: same white card with
    /// a navy stripe, same title font, same tile height (`contentHeight`).
    private var searchField: some View {
        SectionCard(background: Color.hepCard, stripe: Color.hepNavy) {
            HStack(spacing: Spacing.s) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.hepNavy)
                TextField("Problem, test, or term", text: $query)
                    .font(.hepSectionHeading)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.hepMuted)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minHeight: CardRowView.contentHeight)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    /// A card link, styled the same way as a category's own tiles.
    private func cardLink(_ card: Card) -> some View {
        NavigationLink(value: card.id) {
            CardRowView(card: card)
        }
        .buttonStyle(.plain)
    }
}
