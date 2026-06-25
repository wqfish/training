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
    /// Weight in pounds. Ignored when `usesWeight` is false.
    var weight: Double
    /// Whether this movement uses external weight. False = a bodyweight movement
    /// (hamstring curl, lock-off, pull-up, …). Defaults to true so existing entries
    /// migrate cleanly.
    var usesWeight: Bool = true
    /// Position within the day's list, for stable ordering.
    var position: Int

    init(
        id: UUID = UUID(),
        date: Date,
        exerciseName: String,
        sets: Int,
        reps: Int,
        weight: Double,
        position: Int,
        usesWeight: Bool = true
    ) {
        self.id = id
        self.date = date
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.position = position
        self.usesWeight = usesWeight
    }

    /// Total weight moved by this entry: sets × reps × weight. Zero for bodyweight movements.
    var volume: Double {
        usesWeight ? Double(sets * reps) * weight : 0
    }
}
