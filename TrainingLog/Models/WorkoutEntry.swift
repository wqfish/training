import Foundation
import SwiftData

/// Versioned schema for the app's persistent store.
///
/// Wrapping the model in a `VersionedSchema` lets SwiftData migrate an existing
/// store when the model changes instead of failing to open it. There is a single
/// version today; see `TrainingLogMigrationPlan` for how to add the next one.
enum TrainingLogSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [WorkoutEntry.self]
    }

    /// One logged movement on a given day, e.g. "Bench Press — 3 × 5 @ 135 lb".
    ///
    /// Entries are stored flat and grouped by `date` (normalized to the start of the
    /// day) rather than via a parent "day" object — simpler to query and plenty for a
    /// personal log.
    ///
    /// Every stored property carries a default value because CloudKit (used for
    /// iCloud sync) requires attributes to be optional or have a default.
    @Model
    final class WorkoutEntry {
        var id: UUID = UUID()
        /// Normalized to the start of the day (local calendar) so a day's entries group cleanly.
        var date: Date = Date()
        var exerciseName: String = ""
        var sets: Int = 0
        var reps: Int = 0
        /// Weight in pounds.
        var weight: Double = 0
        /// Position within the day's list, for stable ordering.
        var position: Int = 0

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
}

/// The current `WorkoutEntry` shape. App code refers to this alias so a future
/// schema bump only needs to repoint it (e.g. to `TrainingLogSchemaV2`).
typealias WorkoutEntry = TrainingLogSchemaV1.WorkoutEntry
