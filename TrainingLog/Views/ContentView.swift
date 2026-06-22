import SwiftUI
import SwiftData

/// The main screen: a month calendar on top, the selected day's workout below.
struct ContentView: View {
    @Query(sort: \WorkoutEntry.position) private var allEntries: [WorkoutEntry]

    @State private var selectedDate: Date = Date().startOfDay
    @State private var displayedMonth: Date = Date()
    @State private var isEditing = false

    /// Start-of-day dates that have at least one entry — used to dot the calendar.
    private var workoutDays: Set<Date> {
        Set(allEntries.map { $0.date.startOfDay })
    }

    private var entriesForSelectedDate: [WorkoutEntry] {
        allEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.position < $1.position }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarView(
                    selectedDate: $selectedDate,
                    month: $displayedMonth,
                    workoutDays: workoutDays
                )
                .card()
                .padding(.horizontal)
                .padding(.top, 8)

                DayDetailView(date: selectedDate, entries: entriesForSelectedDate) {
                    isEditing = true
                }
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
            .sheet(isPresented: $isEditing) {
                EditDayView(date: selectedDate, existing: entriesForSelectedDate)
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
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}
