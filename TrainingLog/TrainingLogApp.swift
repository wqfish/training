import SwiftUI
import SwiftData

@main
struct TrainingLogApp: App {
    /// Persistent store with a registered migration plan and iCloud (CloudKit) sync.
    let modelContainer: ModelContainer

    init() {
        do {
            // `.automatic` adopts the CloudKit container declared in the app's
            // entitlements, syncing entries to the user's private database.
            let configuration = ModelConfiguration(cloudKitDatabase: .automatic)
            modelContainer = try ModelContainer(
                for: WorkoutEntry.self,
                migrationPlan: TrainingLogMigrationPlan.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
