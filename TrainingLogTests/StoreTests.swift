import Testing
import Foundation
import SwiftData
@testable import TrainingLog

/// Tests that exercise the SwiftData model in an in-memory store (nothing touches disk).
@MainActor
struct StoreTests {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutEntry.self, FingerEntry.self, configurations: config)
        return ModelContext(container)
    }

    @Test func insertsAndFetchesInPositionOrder() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(WorkoutEntry(date: day, exerciseName: "Back Squat", sets: 5, reps: 5, weight: 225, position: 1))
        context.insert(WorkoutEntry(date: day, exerciseName: "Bench Press", sets: 3, reps: 5, weight: 185, position: 0))
        try context.save()

        let fetched = try context.fetch(
            FetchDescriptor<WorkoutEntry>(sortBy: [SortDescriptor(\.position)])
        )

        #expect(fetched.count == 2)
        #expect(fetched.first?.exerciseName == "Bench Press")
        #expect(fetched.last?.exerciseName == "Back Squat")

        let totalVolume = fetched.reduce(0) { $0 + $1.volume }
        #expect(totalVolume == 2775 + 5625)
    }

    /// Mirrors what `EditDayView.save()` does: replace a day's entries wholesale.
    @Test func replacingADayClearsPreviousEntries() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(WorkoutEntry(date: day, exerciseName: "Deadlift", sets: 1, reps: 1, weight: 405, position: 0))
        try context.save()

        for existing in try context.fetch(FetchDescriptor<WorkoutEntry>()) {
            context.delete(existing)
        }
        context.insert(WorkoutEntry(date: day, exerciseName: "Overhead Press", sets: 3, reps: 5, weight: 95, position: 0))
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<WorkoutEntry>())
        #expect(remaining.count == 1)
        #expect(remaining.first?.exerciseName == "Overhead Press")
    }

    @Test func entriesOnDifferentDaysAreIndependent() throws {
        let context = try makeContext()
        let calendar = Calendar.current
        let today = Date().startOfDay
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        context.insert(WorkoutEntry(date: today, exerciseName: "Bench Press", sets: 3, reps: 5, weight: 185, position: 0))
        context.insert(WorkoutEntry(date: yesterday, exerciseName: "Deadlift", sets: 3, reps: 3, weight: 315, position: 0))
        try context.save()

        let todayEntries = try context.fetch(FetchDescriptor<WorkoutEntry>())
            .filter { calendar.isDate($0.date, inSameDayAs: today) }

        #expect(todayEntries.count == 1)
        #expect(todayEntries.first?.exerciseName == "Bench Press")
    }

    @Test func fingerEntriesInsertAndFetchInPositionOrder() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(FingerEntry(date: day, protocolName: FingerProtocol.repeaters.rawValue,
                                   grip: GripPosition.halfCrimp.rawValue, weight: 25, position: 1))
        context.insert(FingerEntry(date: day, protocolName: FingerProtocol.repeaters.rawValue,
                                   grip: GripPosition.threeFingerDrag.rawValue, weight: 15, position: 0))
        try context.save()

        let fetched = try context.fetch(
            FetchDescriptor<FingerEntry>(sortBy: [SortDescriptor(\.position)])
        )

        #expect(fetched.count == 2)
        #expect(fetched.first?.gripPosition == .threeFingerDrag)
        #expect(fetched.last?.gripPosition == .halfCrimp)
        #expect(fetched.allSatisfy { $0.fingerProtocol == .repeaters })
    }

    /// Strength and finger entries on the same day live in independent tables.
    @Test func strengthAndFingerEntriesAreIndependent() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(WorkoutEntry(date: day, exerciseName: "Bench Press", sets: 3, reps: 5, weight: 185, position: 0))
        context.insert(FingerEntry(date: day, protocolName: FingerProtocol.maxHang.rawValue,
                                   grip: GripPosition.halfCrimp.rawValue, weight: 40, position: 0))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<WorkoutEntry>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<FingerEntry>()).count == 1)
    }

    @Test func bodyweightFlagRoundTripsThroughTheStore() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(WorkoutEntry(date: day, exerciseName: "Lock-Off Isometric",
                                    sets: 3, reps: 2, weight: 0, position: 0, usesWeight: false))
        context.insert(FingerEntry(date: day, protocolName: FingerProtocol.maxHang.rawValue,
                                   grip: GripPosition.halfCrimp.rawValue, weight: 0, position: 0, usesWeight: false))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<WorkoutEntry>()).first?.usesWeight == false)
        #expect(try context.fetch(FetchDescriptor<FingerEntry>()).first?.usesWeight == false)
    }

    @Test func maxHangRepsRoundTripThroughTheStore() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(FingerEntry(date: day, protocolName: FingerProtocol.maxHang.rawValue,
                                   grip: GripPosition.halfCrimp.rawValue, weight: 35, reps: 5, position: 0))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<FingerEntry>()).first?.reps == 5)
    }

    // MARK: - Reorder & delete (mirrors what DayDetailView's row actions do via DayOrdering)

    private func strengthSorted(_ context: ModelContext) throws -> [WorkoutEntry] {
        try context.fetch(FetchDescriptor<WorkoutEntry>(sortBy: [SortDescriptor(\.position)]))
    }

    private func fingerSorted(_ context: ModelContext) throws -> [FingerEntry] {
        try context.fetch(FetchDescriptor<FingerEntry>(sortBy: [SortDescriptor(\.position)]))
    }

    @Test func reorderingStrengthEntriesPersistsNewOrder() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(WorkoutEntry(date: day, exerciseName: "Bench Press", sets: 3, reps: 5, weight: 185, position: 0))
        context.insert(WorkoutEntry(date: day, exerciseName: "Back Squat", sets: 5, reps: 5, weight: 225, position: 1))
        context.insert(WorkoutEntry(date: day, exerciseName: "Deadlift", sets: 1, reps: 5, weight: 315, position: 2))
        try context.save()

        // Drag the last entry to the front.
        DayOrdering.move(try strengthSorted(context), fromOffsets: IndexSet(integer: 2), toOffset: 0)
        try context.save()

        let reordered = try strengthSorted(context)
        #expect(reordered.map(\.exerciseName) == ["Deadlift", "Bench Press", "Back Squat"])
        #expect(reordered.map(\.position) == [0, 1, 2])
    }

    @Test func deletingStrengthEntryReindexesSurvivors() throws {
        let context = try makeContext()
        let day = Date().startOfDay

        context.insert(WorkoutEntry(date: day, exerciseName: "Bench Press", sets: 3, reps: 5, weight: 185, position: 0))
        context.insert(WorkoutEntry(date: day, exerciseName: "Back Squat", sets: 5, reps: 5, weight: 225, position: 1))
        context.insert(WorkoutEntry(date: day, exerciseName: "Deadlift", sets: 1, reps: 5, weight: 315, position: 2))
        try context.save()

        // Swipe-delete the middle entry; the survivors must renumber to stay dense.
        DayOrdering.delete(try strengthSorted(context), at: IndexSet(integer: 1), from: context)
        try context.save()

        let remaining = try strengthSorted(context)
        #expect(remaining.map(\.exerciseName) == ["Bench Press", "Deadlift"])
        #expect(remaining.map(\.position) == [0, 1])
    }

    @Test func reorderingFingerEntriesPersistsNewOrder() throws {
        let context = try makeContext()
        let day = Date().startOfDay
        let proto = FingerProtocol.repeaters.rawValue

        context.insert(FingerEntry(date: day, protocolName: proto, grip: GripPosition.halfCrimp.rawValue, weight: 25, position: 0))
        context.insert(FingerEntry(date: day, protocolName: proto, grip: GripPosition.threeFingerDrag.rawValue, weight: 15, position: 1))
        context.insert(FingerEntry(date: day, protocolName: proto, grip: GripPosition.openHand.rawValue, weight: 0, position: 2))
        try context.save()

        // Drag the first grip to the end.
        DayOrdering.move(try fingerSorted(context), fromOffsets: IndexSet(integer: 0), toOffset: 3)
        try context.save()

        let reordered = try fingerSorted(context)
        #expect(reordered.map(\.gripPosition) == [.threeFingerDrag, .openHand, .halfCrimp])
        #expect(reordered.map(\.position) == [0, 1, 2])
    }

    @Test func deletingFingerEntryReindexesSurvivors() throws {
        let context = try makeContext()
        let day = Date().startOfDay
        let proto = FingerProtocol.maxHang.rawValue

        context.insert(FingerEntry(date: day, protocolName: proto, grip: GripPosition.halfCrimp.rawValue, weight: 25, position: 0))
        context.insert(FingerEntry(date: day, protocolName: proto, grip: GripPosition.threeFingerDrag.rawValue, weight: 15, position: 1))
        context.insert(FingerEntry(date: day, protocolName: proto, grip: GripPosition.openHand.rawValue, weight: 0, position: 2))
        try context.save()

        DayOrdering.delete(try fingerSorted(context), at: IndexSet(integer: 0), from: context)
        try context.save()

        let remaining = try fingerSorted(context)
        #expect(remaining.map(\.gripPosition) == [.threeFingerDrag, .openHand])
        #expect(remaining.map(\.position) == [0, 1])
    }
}
