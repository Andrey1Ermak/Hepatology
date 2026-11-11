import Foundation

/// `c_kasai_clock`: age in days and the days to 30, 45 and 60. Outcome falls
/// with every band of age at Kasai (Serinet 2009: ≤ 30, 31–45, 46–60, 61–75,
/// 76–90 d) — a gradient, not a deadline, so the result never says "window
/// closed" (D-2026-11-11-3).
enum KasaiClockCalc {
    static let sourceIds = ["serinet_2009_kasai_age", "schreiber_2007_ba_canada", "fanna_2019_ba_france", "hoshino_2023_kasai_age_meta"]

    /// Reference days shown on the clock. 30: best outcomes (Serinet,
    /// Schreiber, Hoshino ≤ 30 d); 45: Serinet — Kasai for all before
    /// 46 days would spare 5.7% of pediatric transplants in France;
    /// 60: end of Serinet's 46–60 d band and of the second month (Fanna).
    static let milestones = [30, 45, 60]

    enum Band: Equatable {
        case upTo30, d31to45, d46to60, d61to90, over90

        init(ageDays: Int) {
            switch ageDays {
            case ...30: self = .upTo30
            case 31...45: self = .d31to45
            case 46...60: self = .d46to60
            case 61...90: self = .d61to90
            default: self = .over90
            }
        }

        var label: String {
            switch self {
            case .upTo30: "30 days or younger"
            case .d31to45: "31–45 days"
            case .d46to60: "46–60 days"
            case .d61to90: "61–90 days"
            case .over90: "Over 90 days"
            }
        }

        /// Past the second month: show the late-Kasai decision lines.
        var isLate: Bool { self == .d61to90 || self == .over90 }
    }

    struct Milestone: Equatable {
        let day: Int
        /// Positive: days left; zero: today; negative: days since.
        let daysLeft: Int
    }

    struct Result: Equatable {
        let ageDays: Int
        let band: Band
        let milestones: [Milestone]
    }

    /// Whole calendar days from birth to `today` (day of birth = day 0), in
    /// the given calendar so a daylight-saving change never loses a day.
    /// Nil if the birth date is after `today`.
    static func ageDays(birth: Date, today: Date, calendar: Calendar = .current) -> Int? {
        let start = calendar.startOfDay(for: birth)
        let end = calendar.startOfDay(for: today)
        guard let days = calendar.dateComponents([.day], from: start, to: end).day, days >= 0 else { return nil }
        return days
    }

    static func compute(ageDays: Int) -> Result? {
        guard ageDays >= 0 else { return nil }
        return Result(ageDays: ageDays, band: Band(ageDays: ageDays),
                      milestones: milestones.map { Milestone(day: $0, daysLeft: $0 - ageDays) })
    }

    static func compute(birth: Date, today: Date, calendar: Calendar = .current) -> Result? {
        ageDays(birth: birth, today: today, calendar: calendar).flatMap { compute(ageDays: $0) }
    }

    /// "8 wk 3 d".
    static func formatWeeks(_ days: Int) -> String {
        "\(days / 7) wk \(days % 7) d"
    }

    /// "in 12 days" / "today" / "5 days past". Not "missed": the days are
    /// reference points, not deadlines.
    static func formatMilestone(_ m: Milestone) -> String {
        switch m.daysLeft {
        case 0: "today"
        case 1: "in 1 day"
        case 2...: "in \(m.daysLeft) days"
        case -1: "1 day past"
        default: "\(-m.daysLeft) days past"
        }
    }
}
