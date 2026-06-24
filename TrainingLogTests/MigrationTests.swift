import Testing
import Foundation
import SwiftData
@testable import TrainingLog

/// Verifies the versioned schema and migration plan produce a valid store. These
/// run in-memory, exercising the schema/migration wiring without touching disk or
/// CloudKit (real iCloud sync needs a device signed into iCloud).
@MainActor
struct MigrationTests {

    @Test func currentSchemaIsVersionOne() {
        #expect(TrainingLogSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }

    @Test func migrationPlanRegistersTheCurrentSchemaWithNoStagesYet() {
        #expect(TrainingLogMigrationPlan.schemas.count == 1)
        #expect(TrainingLogMigrationPlan.stages.isEmpty)
    }

    /// Builds the container the same way `TrainingLogApp` does — through the
    /// migration plan — so a malformed schema or migration stage fails here.
    @Test func containerBuildsThroughMigrationPlanAndPersistsEntries() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: WorkoutEntry.self,
            migrationPlan: TrainingLogMigrationPlan.self,
            configurations: config
        )
        let context = ModelContext(container)

        context.insert(WorkoutEntry(date: Date().startOfDay, exerciseName: "Bench Press",
                                    sets: 3, reps: 5, weight: 185, position: 0))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<WorkoutEntry>()).count == 1)
    }
}
