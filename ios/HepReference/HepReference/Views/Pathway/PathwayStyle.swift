import SwiftUI

// Same 4-tier semantic mapping as the rest of the app (see DesignSystem's
// Tier): mild≈rt, mod≈urg,
// sev≈crit, floor≈ref.
extension ArmKind {
    var tier: Tier {
        switch self {
        case .mild: .rt
        case .mod: .urg
        case .sev: .crit
        case .floor: .ref
        }
    }
}

extension PillKind {
    var tier: Tier {
        switch self {
        case .dc: .rt
        case .step: .urg
        case .picu: .crit
        case .floor: .ref
        }
    }
}

extension BoxStyle {
    /// `nil` for `.plain` — a plain box has no severity tint, just a neutral background.
    var tier: Tier? {
        switch self {
        case .plain: nil
        case .info: .ref
        case .warn: .urg
        case .crit: .crit
        }
    }
}
