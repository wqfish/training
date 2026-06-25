import Foundation
import SwiftData
import SwiftUI  // for Array.move(fromOffsets:toOffset:) and IndexSet-based reordering

/// A stored entry whose `position` gives it a stable slot within its day's list.
/// Both `WorkoutEntry` and `FingerEntry` order this way, so the delete/move position
/// bookkeeping below is written once and shared.
protocol DayOrdered: PersistentModel {
    var position: Int { get set }
}

extension WorkoutEntry: DayOrdered {}
extension FingerEntry: DayOrdered {}

/// Position bookkeeping for a single day's entries. Positions are kept dense (`0..<count`)
/// within a day; the global `@Query(sort: \.position)` then filters per day in that order.
enum DayOrdering {
    /// Assign 0-based positions to `entries` in their current array order.
    static func reindex<T: DayOrdered>(_ entries: [T]) {
        for (index, entry) in entries.enumerated() {
            entry.position = index
        }
    }

    /// Apply a list reorder to a day's slice (already position-sorted) and reindex so the
    /// new order persists. Mutates the entries' `position` in place.
    static func move<T: DayOrdered>(_ entries: [T], fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = entries
        reordered.move(fromOffsets: source, toOffset: destination)
        reindex(reordered)
    }

    /// Delete the entries at `offsets` from `context`, then reindex the survivors so the
    /// day stays densely numbered.
    static func delete<T: DayOrdered>(_ entries: [T], at offsets: IndexSet, from context: ModelContext) {
        let survivors = entries.indices
            .filter { !offsets.contains($0) }
            .map { entries[$0] }
        for index in offsets {
            context.delete(entries[index])
        }
        reindex(survivors)
    }
}
