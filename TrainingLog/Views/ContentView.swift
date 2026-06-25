import SwiftUI
import SwiftData

/// The main screen: a month calendar on top, the selected day's workout below.
struct ContentView: View {
    @Query(sort: \WorkoutEntry.position) private var allEntries: [WorkoutEntry]
    @Query(sort: \FingerEntry.position) private var allFingerEntries: [FingerEntry]

    @State private var selectedDate: Date = Date().startOfDay
    @State private var displayedMonth: Date = Date()
    @State private var isEditingStrength = false
    @State private var isEditingFingers = false

    /// Start-of-day dates with at least one strength entry — the orange calendar dot.
    private var workoutDays: Set<Date> {
        Set(allEntries.map { $0.date.startOfDay })
    }

    /// Start-of-day dates with at least one finger-training entry — the teal calendar dot.
    private var fingerDays: Set<Date> {
        Set(allFingerEntries.map { $0.date.startOfDay })
    }

    // `allEntries` / `allFingerEntries` already arrive position-sorted from the @Query,
    // and `filter` preserves that order, so the day's slice needs no further sorting.
    private var entriesForSelectedDate: [WorkoutEntry] {
        allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var fingerEntriesForSelectedDate: [FingerEntry] {
        allFingerEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarView(
                    selectedDate: $selectedDate,
                    month: $displayedMonth,
                    workoutDays: workoutDays,
                    fingerDays: fingerDays
                )
                .card(padding: 12)
                .padding(.horizontal)
                .padding(.top, 8)

                DayDetailView(
                    entries: entriesForSelectedDate,
                    fingerEntries: fingerEntriesForSelectedDate,
                    onEditStrength: { isEditingStrength = true },
                    onEditFingers: { isEditingFingers = true }
                )
            }
            .background(backgroundGradient)
            .navigationTitle("Training Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Today") {
                        let today = Date().startOfDay
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedDate = today
                            displayedMonth = today
                        }
                    }
                    .disabled(Calendar.current.isDateInToday(selectedDate))
                }
            }
            .sheet(isPresented: $isEditingStrength) {
                EditDayView(date: selectedDate, existing: entriesForSelectedDate)
            }
            .sheet(isPresented: $isEditingFingers) {
                EditFingerView(date: selectedDate, existing: fingerEntriesForSelectedDate)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.accentColor.opacity(0.12), Color(.systemGroupedBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WorkoutEntry.self, FingerEntry.self], inMemory: true)
}
