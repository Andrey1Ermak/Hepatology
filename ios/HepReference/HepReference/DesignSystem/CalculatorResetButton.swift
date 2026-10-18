import SwiftUI

/// The shared "clear this calculator's inputs" button — every calculator
/// view uses this instead of its own `Button("Reset")`.
struct CalculatorResetButton: View {
    var label: String = "Reset"
    let action: () -> Void

    var body: some View {
        Button(label, action: action)
            .font(.hepCaption)
            .buttonStyle(.bordered)
    }
}
