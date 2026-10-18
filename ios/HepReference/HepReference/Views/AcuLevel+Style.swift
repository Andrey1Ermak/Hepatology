import SwiftUI

extension AcuLevel {
    /// Same 4-tier palette as the rest of the app (see DesignSystem's Tier).
    var tier: Tier {
        switch self {
        case .crit: .crit
        case .urg: .urg
        case .rt: .rt
        case .ref: .ref
        }
    }

    var label: String {
        switch self {
        case .crit: "CRIT"
        case .urg: "URG"
        case .rt: "RT"
        case .ref: "REF"
        }
    }
}
