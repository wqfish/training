import Foundation

/// Pure, testable layout math for one month shown as a 7-column calendar grid.
///
/// Kept free of SwiftUI so it can be unit-tested directly.
struct MonthGrid {
    let calendar: Calendar
    /// Any date within the month to lay out.
    let month: Date

    /// Cells for the grid: leading `nil`s for the days before the 1st, one entry per
    /// day of the month, then trailing `nil`s padding out to whole weeks.
    var cells: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        let dayCount = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0

        var result: [Date?] = Array(repeating: nil, count: leading)
        for offset in 0..<dayCount {
            result.append(calendar.date(byAdding: .day, value: offset, to: firstDay))
        }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    /// Weekday header symbols (e.g. "S M T W T F S"), rotated to match the
    /// calendar's `firstWeekday`.
    var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }
}
