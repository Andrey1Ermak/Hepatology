import Foundation

/// Home-screen entry points. Every card's `cat` is one of these; Home shows
/// one tile per category in `homeOrder`. Named `CardCategory`, not
/// `Category` — the latter collides with the Objective-C runtime's
/// `Category` typedef.
enum CardCategory: String, Decodable, CaseIterable {
    case jaundice
    case labs
    case acute
    case organomegaly
    case portal
    case mass
    case disease
    case special
    case ref

    /// Natural-case section title — rendered uppercase by the header view.
    var displayName: String {
        switch self {
        case .jaundice: "Jaundice & Cholestasis"
        case .labs: "Abnormal Liver Tests"
        case .acute: "Acute Liver Illness"
        case .organomegaly: "Big Liver or Spleen"
        case .portal: "Portal Hypertension"
        case .mass: "Mass, Ducts & Gallbladder"
        case .disease: "Suspected Disease"
        case .special: "Special Populations"
        case .ref: "Reference"
        }
    }

    /// 1-based position in `homeOrder` — shown as the roman-numeral
    /// badge in category and card kickers, like a lesson's section number.
    var number: Int {
        (Self.homeOrder.firstIndex(of: self) ?? 0) + 1
    }

    /// Fixed home-screen order: the most frequent consult questions first,
    /// reference material last.
    static let homeOrder: [CardCategory] = [
        .jaundice, .labs, .acute, .organomegaly, .portal, .mass, .disease, .special, .ref,
    ]
}
