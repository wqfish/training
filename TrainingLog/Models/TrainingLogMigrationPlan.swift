import Foundation
import SwiftData

/// Describes how the persistent store moves across schema versions.
///
/// With a registered plan, SwiftData migrates an existing store to the current
/// schema on launch rather than failing to open it. Only `TrainingLogSchemaV1`
/// exists today, so there are no migration stages yet.
///
/// To evolve the model:
///   1. Add a `TrainingLogSchemaV2: VersionedSchema` with the new model shape.
///   2. Repoint the `WorkoutEntry` typealias to `TrainingLogSchemaV2`.
///   3. Append `TrainingLogSchemaV2.self` to `schemas`, and a `MigrationStage`
///      to `stages` — `.lightweight` for purely additive/renamed changes, or
///      `.custom` when existing rows must be transformed.
enum TrainingLogMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TrainingLogSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
