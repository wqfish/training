import SwiftUI

/// A custom month calendar. Shows a dot under any day that has logged workouts,
/// rings "today", and fills the selected day with the accent color.
struct CalendarView: View {
    @Binding var selectedDate: Date
    /// Any date within the month currently on screen.
    @Binding var month: Date
    /// Start-of-day dates that have at least one logged strength entry.
    let workoutDays: Set<Date>
    /// Start-of-day dates that have at least one logged finger-training entry.
    let fingerDays: Set<Date>

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var grid: MonthGrid {
        MonthGrid(calendar: calendar, month: month)
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            weekdayHeader
            daysGrid
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.title2.weight(.bold))
                .contentTransition(.numericText())
            Spacer()
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            .padding(.trailing, 8)
            Button { changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
            }
        }
        .font(.headline)
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(Array(grid.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Grid

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(grid.cells.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 46)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasWorkout = workoutDays.contains(date.startOfDay)
        let hasFinger = fingerDays.contains(date.startOfDay)

        return VStack(spacing: 4) {
            Text("\(day)")
                .font(.system(size: 17, weight: isSelected ? .bold : .regular, design: .rounded))
                .foregroundStyle(textColor(isSelected: isSelected, isToday: isToday))
                .frame(width: 36, height: 36)
                .background {
                    if isSelected {
                        Circle().fill(Color.accentColor)
                    } else if isToday {
                        Circle().stroke(Color.accentColor, lineWidth: 1.5)
                    }
                }

            // Up to two dots: orange for strength, teal for finger training. Hidden
            // while the day is selected (the cell is already filled with the accent).
            HStack(spacing: 3) {
                if hasWorkout {
                    Circle().fill(Color.strengthAccent).frame(width: 6, height: 6)
                }
                if hasFinger {
                    Circle().fill(Color.fingerAccent).frame(width: 6, height: 6)
                }
            }
            .frame(height: 6)
            .opacity(isSelected ? 0 : 1)
        }
        .frame(maxWidth: .infinity, minHeight: 46)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.snappy(duration: 0.2)) {
                selectedDate = date.startOfDay
            }
        }
    }

    private func textColor(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return Color.accentColor }
        return .primary
    }

    // MARK: - Month navigation

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: month) {
            withAnimation(.snappy(duration: 0.2)) { month = newMonth }
        }
    }
}
