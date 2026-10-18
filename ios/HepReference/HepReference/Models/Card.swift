import Foundation

/// Acuity level, drives badge color: crit=red, urg=orange, rt=yellow, ref=gray.
enum AcuLevel: String, Decodable {
    case crit
    case urg
    case rt
    case ref
}

struct Card: Identifiable, Decodable {
    let id: String
    let title: String
    let code: String
    let cat: CardCategory
    let acu: AcuLevel
    let done: Bool?
    /// Visually reviewed/verified in the iOS app specifically — distinct
    /// from `done` (content reworked to CEG standard, a web-app-era flag).
    /// Drives its own badge color in `CardRowView` so on-device review
    /// progress is trackable per card as it happens, separate from content status.
    let reviewed: Bool?
    let src: String?
    let tags: [String]
    let blocks: [Block]
}
