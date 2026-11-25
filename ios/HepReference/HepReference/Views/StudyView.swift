import SwiftUI

/// The Study tab (CLAUDE.md §3.4): the year plan beside the app. Opens on
/// today's block with today's day marked; each day shows its topic, whether
/// the lesson has arrived, and the cards it feeds. Chevrons page through the
/// 26 blocks. Everything comes from `plan.json` — nothing is authored here.
struct StudyView: View {
    let library: CardLibrary
    @Environment(Registry.self) private var registry: Registry?
    @State private var path = NavigationPath()
    /// Nil until the plan loads; then the block on screen.
    @State private var shownBlock: Int?
    /// "Today", refreshed whenever the app comes to the foreground, so the
    /// marks stay right past midnight.
    @State private var now = Date()
    /// Scroll to today once per launch, not on every return from a card.
    @State private var didInitialScroll = false
    @Environment(\.scenePhase) private var scenePhase

    private var plan: [PlanBlock] { registry?.plan ?? [] }
    private var today: PlanPosition? { StudyPlan.position(on: now, in: plan) }
    private var block: PlanBlock? {
        if let shownBlock, let shown = plan.first(where: { $0.block == shownBlock }) {
            return shown
        }
        let number = StudyPlan.initialBlock(on: now, in: plan)
        return plan.first { $0.block == number }
    }

    init(library: CardLibrary) {
        self.library = library
        #if DEBUG
        // `-hepStudyBlock <n>` opens that block, so tools/screenshot.sh can
        // capture any block without UI automation.
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-hepStudyBlock"), args.indices.contains(i + 1) {
            _shownBlock = State(initialValue: Int(args[i + 1]))
        }
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollViewReader { proxy in
                ScrollView {
                    if let block {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            ForEach(block.days, id: \.day) { day in
                                dayCard(day, in: block)
                                    .id(day.day)
                            }
                        }
                        .padding(.horizontal, Spacing.l)
                        .padding(.vertical, Spacing.s)
                    } else {
                        ContentUnavailableView("No year plan", systemImage: "book.closed")
                            .padding(.top, Spacing.xl)
                    }
                }
                .background(Color.hepBackground.ignoresSafeArea())
                .safeAreaInset(edge: .top, spacing: 0) {
                    if let block { header(block) }
                }
                .onAppear {
                    guard !didInitialScroll else { return }
                    didInitialScroll = true
                    now = Date()
                    scrollToToday(proxy, animated: false)
                }
                .onChange(of: shownBlock) {
                    scrollToToday(proxy, animated: true)
                }
                .onChange(of: scenePhase) {
                    guard scenePhase == .active else { return }
                    now = Date()
                    // Follow today into a new day or block unless the user
                    // has paged to another block.
                    if shownBlock == nil { scrollToToday(proxy, animated: false) }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .swipeBackEnabled()
            .navigationDestination(for: String.self) { id in
                if let card = library.cardsByID[id] {
                    CardDetailView(card: card)
                }
            }
        }
    }

    /// Today's day when the shown block is today's block, otherwise the top.
    private func scrollToToday(_ proxy: ScrollViewProxy, animated: Bool) {
        guard let block, let target = StudyPlan.scrollTarget(in: block, today: today) else { return }
        if animated {
            withAnimation { proxy.scrollTo(target, anchor: .top) }
        } else {
            proxy.scrollTo(target, anchor: .top)
        }
    }

    // MARK: Header

    private func header(_ block: PlanBlock) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .center, spacing: Spacing.s) {
                VStack(alignment: .leading, spacing: 2) {
                    KickerLine(number: RomanNumeral.string(block.block), text: "Year plan · Block \(block.block) of \(plan.count)")
                    Text(block.title)
                        .hepTitleStyle()
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(dateRange(block))
                        .font(.hepSubtitle)
                        .foregroundStyle(Color.hepMuted)
                }
                Spacer(minLength: 0)
                pager(block)
            }
            if let today, today.block != block.block {
                Button {
                    shownBlock = today.block
                } label: {
                    Label("Today: block \(today.block), day \(today.day)", systemImage: "calendar")
                        .font(.hepCaptionBold)
                        .foregroundStyle(Color.hepNavy)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }
            DoubleRule()
                .padding(.top, Spacing.xs)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.xs)
        .background(Color.hepBackground)
    }

    private func pager(_ block: PlanBlock) -> some View {
        let index = plan.firstIndex { $0.block == block.block }
        let previous = index.flatMap { $0 > plan.startIndex ? plan[$0 - 1].block : nil }
        let next = index.flatMap { $0 + 1 < plan.endIndex ? plan[$0 + 1].block : nil }
        return HStack(spacing: 0) {
            pageButton("chevron.left", target: previous, label: "Previous block")
            pageButton("chevron.right", target: next, label: "Next block")
        }
    }

    private func pageButton(_ icon: String, target: Int?, label: String) -> some View {
        Button {
            shownBlock = target
        } label: {
            Image(systemName: icon)
                .font(.hepBodyEmphasis)
                .imageScale(.large)
                // `gap` on white is ~3.2:1 — acceptable only because the
                // button is disabled (WCAG exempts inactive controls).
                .foregroundStyle(target == nil ? Color.hepGap : Color.hepNavy)
                .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.plain)
        .disabled(target == nil)
        .accessibilityLabel(target.map { "\(label), block \($0)" } ?? label)
    }

    // MARK: Day

    private func dayCard(_ day: PlanDay, in block: PlanBlock) -> some View {
        let isToday = today == PlanPosition(block: block.block, day: day.day)
        let cards = day.cards.compactMap { library.cardsByID[$0] }
        return SectionCard(background: isToday ? Tier.ref.tint : Color.hepCard,
                           stripe: isToday ? Color.hepNavy : nil) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
                    Text(dayLabel(day, in: block))
                        .hepKickerStyle()
                    Spacer(minLength: Spacing.s)
                    if isToday {
                        Badge(text: "Today", tier: .ref)
                    }
                    lessonBadge(day)
                }
                .accessibilityElement(children: .combine)
                Text(day.topic)
                    .font(.hepSectionHeading)
                    .foregroundStyle(Color.hepInk)
                    .fixedSize(horizontal: false, vertical: true)
                if cards.isEmpty {
                    Text("No card for this day yet")
                        .font(.hepCaption)
                        .foregroundStyle(Color.hepMuted)
                } else {
                    ForEach(cards) { card in
                        NavigationLink(value: card.id) {
                            cardRow(card.title)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func lessonBadge(_ day: PlanDay) -> some View {
        if day.lesson != nil {
            Badge(text: "Lesson in", tier: .rt, style: .tint)
                .accessibilityLabel("Lesson has arrived")
        } else {
            Badge(text: "No lesson yet", style: .neutral)
        }
    }

    private func cardRow(_ title: String) -> some View {
        HStack(spacing: Spacing.s) {
            Text(title)
                .font(.hepCaption)
                .foregroundStyle(Color.hepInk)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.s)
            Image(systemName: "arrow.right")
                .font(.hepIconSmall)
                .foregroundStyle(Color.hepNavy)
        }
        // 44 pt tap target without extra padding, so rows sit close together.
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    // MARK: Dates

    private static let dayFormat = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day()
    private static let rangeFormat = Date.FormatStyle().month(.abbreviated).day().year()

    /// "Day 9 · Tue, Nov 17".
    private func dayLabel(_ day: PlanDay, in block: PlanBlock) -> String {
        let date = StudyPlan.date(of: day.day, in: block).map { " · " + $0.formatted(Self.dayFormat) } ?? ""
        return "Day \(day.day)" + date
    }

    /// "Nov 9, 2026 – Nov 22, 2026".
    private func dateRange(_ block: PlanBlock) -> String {
        guard let first = block.days.first, let last = block.days.last,
              let start = StudyPlan.date(of: first.day, in: block),
              let end = StudyPlan.date(of: last.day, in: block)
        else { return "" }
        return "\(start.formatted(Self.rangeFormat)) – \(end.formatted(Self.rangeFormat))"
    }
}
