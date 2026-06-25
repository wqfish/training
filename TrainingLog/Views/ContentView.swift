import SwiftUI
import SwiftData
import OSLog

/// Surfaces persistence failures in the console instead of letting them vanish.
private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TrainingLog",
                            category: "persistence")

/// The main screen: a month calendar on top, the selected day's workout below.
struct ContentView: View {
    @Query(sort: \WorkoutEntry.position) private var allEntries: [WorkoutEntry]
    @Query(sort: \FingerEntry.position) private var allFingerEntries: [FingerEntry]

    @Environment(\.modelContext) private var context

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

    // MARK: - Reorder & delete
    //
    // The day's slices arrive position-sorted, so the row offsets handed back by the List
    // map straight onto them. `DayOrdering` deletes / reorders and renumbers the survivors,
    // keeping each day's positions dense.

    private func deleteStrength(at offsets: IndexSet) {
        DayOrdering.delete(entriesForSelectedDate, at: offsets, from: context)
        save("delete strength \(offsets.count == 1 ? "entry" : "entries")")
    }

    private func moveStrength(fromOffsets source: IndexSet, toOffset destination: Int) {
        DayOrdering.move(entriesForSelectedDate, fromOffsets: source, toOffset: destination)
        save("reorder strength entries")
    }

    private func deleteFingers(at offsets: IndexSet) {
        DayOrdering.delete(fingerEntriesForSelectedDate, at: offsets, from: context)
        save("delete finger \(offsets.count == 1 ? "entry" : "entries")")
    }

    private func moveFingers(fromOffsets source: IndexSet, toOffset destination: Int) {
        DayOrdering.move(fingerEntriesForSelectedDate, fromOffsets: source, toOffset: destination)
        save("reorder finger entries")
    }

    private func save(_ action: String) {
        do {
            try context.save()
        } catch {
            logger.error("Failed to \(action, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
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
                    onEditFingers: { isEditingFingers = true },
                    onDeleteStrength: deleteStrength(at:),
                    onMoveStrength: moveStrength(fromOffsets:toOffset:),
                    onDeleteFingers: deleteFingers(at:),
                    onMoveFingers: moveFingers(fromOffsets:toOffset:)
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
