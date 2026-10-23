import SwiftUI
import UIKit

/// First-contact orders (CLAUDE.md §3.3 row 4, §5.2): each group's items
/// can be ticked, and Copy puts the ticked items — or all of them when none
/// is ticked — on the clipboard as plain text (`WorkupBlock.copyText`).
/// Ticks live in this view's state only: they vanish when the card is left
/// and are never stored, so nothing about a patient outlives the screen.
/// The whole row toggles its tick, so a `[m]…[/m]` phone link inside an
/// order is not tappable here — orders don't carry phone numbers.
struct WorkupBlockView: View {
    let block: WorkupBlock

    @State private var checked: Set<WorkupItemID> = []
    @State private var copiedCount = 0
    @State private var showCopied = false

    var body: some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                BlockHeading(text: block.h)
                ForEach(Array(block.groups.enumerated()), id: \.offset) { g, group in
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(group.label)
                            .hepKickerStyle()
                            .accessibilityAddTraits(.isHeader)
                        ForEach(Array(group.items.enumerated()), id: \.offset) { i, item in
                            itemRow(item, id: WorkupItemID(group: g, item: i))
                        }
                    }
                }
                actions
            }
        }
    }

    private func itemRow(_ item: String, id: WorkupItemID) -> some View {
        let isOn = checked.contains(id)
        return Button {
            if isOn { checked.remove(id) } else { checked.insert(id) }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.hepIconMedium)
                    .foregroundStyle(isOn ? Color.hepNavy : Color.hepMuted)
                Text(CardMarkup.attributedString(item))
                    .font(.hepBody)
                    .foregroundStyle(Color.hepInk)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(CardMarkup.plainText(item))
        .accessibilityValue(isOn ? "Checked" : "Unchecked")
        .accessibilityAddTraits(.isToggle)
        .sensoryFeedback(.selection, trigger: isOn)
    }

    private var actions: some View {
        // Wraps at large Dynamic Type sizes instead of truncating.
        FlowLayout {
            Button(action: copy) {
                Label(checked.isEmpty ? "Copy all" : "Copy \(checked.count) selected", systemImage: "doc.on.doc")
                    .font(.hepTag)
                    .textCase(.uppercase)
                    .frame(minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.hepNavy)
            .foregroundStyle(Color.hepOnSolid)
            .accessibilityHint("Copies the ticked orders, or all of them when none is ticked")
            if !checked.isEmpty {
                CalculatorResetButton(label: "Clear") { checked.removeAll() }
            }
            if showCopied {
                Text("Copied")
                    .font(.hepCaption)
                    .foregroundStyle(Color.hepMuted)
                    .transition(.opacity)
            }
        }
        .padding(.top, Spacing.xs)
        .sensoryFeedback(.success, trigger: copiedCount)
        .task(id: copiedCount) {
            guard copiedCount > 0 else { return }
            withAnimation { showCopied = true }
            // A newer copy cancels this task; let it own the indicator.
            do { try await Task.sleep(for: .seconds(1.5)) } catch { return }
            withAnimation { showCopied = false }
        }
    }

    private func copy() {
        UIPasteboard.general.string = block.copyText(checked: checked)
        copiedCount += 1
        AccessibilityNotification.Announcement("Copied").post()
    }
}
