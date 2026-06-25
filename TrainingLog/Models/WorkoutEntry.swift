import Foundation
import SwiftData

/// One logged movement on a given day, e.g. "Bench Press — 3 × 5 @ 135 lb".
///
/// Entries are stored flat and grouped by `date` (normalized to the start of the
/// day) rather than via a parent "day" object — simpler to query and plenty for a
/// personal log.
@Model
final class WorkoutEntry {
    var id: UUID
    /// Normalized to the start of the day (local calendar) so a day's entries group cleanly.
    var date: Date
    var exerciseName: String
    var sets: Int
    var reps: Int
    /// Weight in pounds.
    var weight: Double
    /// Position within the day's list, for stable ordering.
    var position: Int

    init(
        id: UUID = UUID(),
        date: Date,
        exerciseName: String,
        sets: Int,
        reps: Int,
        weight: Double,
        position: Int
    ) {
        self.id = id
        self.date = date
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.position = position
    }

    /// Total weight moved by this entry: sets × reps × weight.
    var volume: Double {
        Double(sets * reps) * weight
    }
}
