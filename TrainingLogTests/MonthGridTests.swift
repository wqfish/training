import Testing
import Foundation
@testable import TrainingLog

/// Tests for the calendar grid layout math. Uses a fixed Gregorian calendar so the
/// results don't depend on the machine's locale or time zone.
struct MonthGridTests {

    private func gregorian(firstWeekday: Int) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = firstWeekday
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, in cal: Calendar) -> Date {
        cal.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func cellsAlwaysFillWholeWeeks() {
        let cal = gregorian(firstWeekday: 1)
        let grid = MonthGrid(calendar: cal, month: date(2026, 6, 15, in: cal))
        #expect(grid.cells.count % 7 == 0)
    }

    @Test func sundayStartHasOneLeadingBlankForJune2026() {
        // June 1, 2026 is a Monday → one blank before it when the week starts Sunday.
        let cal = gregorian(firstWeekday: 1)
        let grid = MonthGrid(calendar: cal, month: date(2026, 6, 15, in: cal))
        let cells = grid.cells

        #expect(cells[0] == nil)
        #expect(cells[1] != nil)
        #expect(cal.component(.day, from: cells[1]!) == 1)
        #expect(cells.compactMap { $0 }.count == 30)
    }

    @Test func mondayStartHasNoLeadingBlankForJune2026() {
        let cal = gregorian(firstWeekday: 2)
        let grid = MonthGrid(calendar: cal, month: date(2026, 6, 15, in: cal))
        let cells = grid.cells

        #expect(cells[0] != nil)
        #expect(cal.component(.day, from: cells[0]!) == 1)
        #expect(cells.compactMap { $0 }.count == 30)
    }

    @Test func februaryLeapYearHas29Days() {
        let cal = gregorian(firstWeekday: 1)
        let grid = MonthGrid(calendar: cal, month: date(2024, 2, 10, in: cal))
        #expect(grid.cells.compactMap { $0 }.count == 29)
    }

    @Test func weekdaySymbolsRotateWithFirstWeekday() {
        let sunday = MonthGrid(calendar: gregorian(firstWeekday: 1), month: Date())
        let monday = MonthGrid(calendar: gregorian(firstWeekday: 2), month: Date())

        #expect(sunday.weekdaySymbols.count == 7)
        #expect(monday.weekdaySymbols.count == 7)
        #expect(sunday.weekdaySymbols.first != monday.weekdaySymbols.first)
    }
}
