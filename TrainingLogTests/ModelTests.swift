import Testing
import Foundation
@testable import TrainingLog

/// Tests for the value types: volume math, weight formatting, the date helper,
/// and the exercise catalog.
struct ModelTests {

    @Test func volumeIsSetsTimesRepsTimesWeight() {
        let entry = WorkoutEntry(date: Date(), exerciseName: "Bench Press",
                                 sets: 3, reps: 5, weight: 185, position: 0)
        #expect(entry.volume == 2775)
    }

    @Test func volumeIsZeroForBodyweightMovements() {
        let entry = WorkoutEntry(date: Date(), exerciseName: "Pull-Up",
                                 sets: 4, reps: 8, weight: 0, position: 0)
        #expect(entry.volume == 0)
    }

    @Test func wholeWeightsFormatWithoutDecimals() {
        #expect((185.0).lbString == "185")
        #expect((0.0).lbString == "0")
    }

    @Test func fractionalWeightsKeepOneDecimal() {
        #expect((22.5).lbString == "22.5")
    }

    @Test func startOfDayZeroesTheTimeComponents() {
        let noon = Calendar.current.date(bySettingHour: 13, minute: 37, second: 5, of: Date())!
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: noon.startOfDay)
        #expect(comps.hour == 0)
        #expect(comps.minute == 0)
        #expect(comps.second == 0)
    }

    @Test func catalogLooksUpKnownExercise() {
        #expect(ExerciseCatalog.exercise(named: "Bench Press")?.symbol == "dumbbell.fill")
    }

    @Test func catalogFallsBackToDefaultSymbol() {
        #expect(ExerciseCatalog.symbol(for: "Something Unknown") == "dumbbell.fill")
    }

    @Test func catalogIdentifiersAreUnique() {
        let ids = ExerciseCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)
        #expect(!ids.isEmpty)
    }

    @Test func catalogIncludesTrainingPlanMovements() {
        // Movements pulled from the strength training plan should be loggable.
        let planMovements = [
            "Physioball Hamstring Curl", "Step-Up", "Lat Pulldown", "Tripod DB Row",
            "T's and W's", "DB Front Squat", "Single-Leg Hip Thrust",
            "Lock-Off Isometric", "Lateral Raise", "Back Fly", "Chest Fly",
        ]
        for name in planMovements {
            #expect(ExerciseCatalog.exercise(named: name) != nil, "missing \(name)")
        }
    }

    @Test func everyCatalogEntryHasSymbol() {
        // Guards against a blank icon slipping into the picker.
        for exercise in ExerciseCatalog.all {
            #expect(!exercise.symbol.isEmpty, "\(exercise.name) has no symbol")
        }
    }
}
