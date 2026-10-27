import SwiftUI

extension CardCategory {
    /// SF Symbol on the category's home-screen tile (all available on iOS 17).
    var symbol: String {
        switch self {
        case .jaundice: "sun.max"
        case .labs: "testtube.2"
        case .acute: "bolt.heart"
        case .organomegaly: "arrow.up.left.and.arrow.down.right"
        case .portal: "arrow.triangle.branch"
        case .mass: "circle.dashed"
        case .disease: "stethoscope"
        case .special: "person.2"
        case .ref: "book.closed"
        }
    }
}
