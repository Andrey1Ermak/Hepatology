import Foundation

/// A place in the year plan: block and day (both 1-based).
struct PlanPosition: Hashable {
    let block: Int
    let day: Int
}

/// Calendar arithmetic over `plan.json` for the Study tab. Pure functions on
/// plain dates, so the tab and its tests agree on what "today" is. Dates in
/// `plan.json` are calendar days ("YYYY-MM-DD") read in the given calendar's
/// time zone — a plan day starts at the user's local midnight.
enum StudyPlan {
    /// The plan day `date` falls on, or nil before the first block or after
    /// the last one.
    static func position(on date: Date, in plan: [PlanBlock], calendar: Calendar = .current) -> PlanPosition? {
        let today = calendar.startOfDay(for: date)
        for block in plan {
            guard let start = Self.date(block.start, calendar: calendar),
                  let offset = calendar.dateComponents([.day], from: start, to: today).day
            else { continue }
            let day = offset + 1
            if block.days.contains(where: { $0.day == day }) {
                return PlanPosition(block: block.block, day: day)
            }
        }
        return nil
    }

    /// The block to open on `date`: today's, else the first block before the
    /// plan starts, else the last one after it ends.
    static func initialBlock(on date: Date, in plan: [PlanBlock], calendar: Calendar = .current) -> Int? {
        if let position = position(on: date, in: plan, calendar: calendar) { return position.block }
        guard let first = plan.first else { return nil }
        if let start = Self.date(first.start, calendar: calendar), calendar.startOfDay(for: date) < start {
            return first.block
        }
        return plan.last?.block
    }

    /// The day to scroll to in `block`: today when it is in this block,
    /// otherwise the block's first day.
    static func scrollTarget(in block: PlanBlock, today: PlanPosition?) -> Int? {
        if let today, today.block == block.block { return today.day }
        return block.days.first?.day
    }

    /// The calendar date of `day` in `block`.
    static func date(of day: Int, in block: PlanBlock, calendar: Calendar = .current) -> Date? {
        guard let start = Self.date(block.start, calendar: calendar) else { return nil }
        return calendar.date(byAdding: .day, value: day - 1, to: start)
    }

    /// Parses "YYYY-MM-DD" as midnight in `calendar`'s time zone.
    static func date(_ text: String, calendar: Calendar = .current) -> Date? {
        let parts = text.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}
