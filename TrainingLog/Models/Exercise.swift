import Foundation

/// A predefined strength-training movement that can be logged.
struct Exercise: Identifiable, Hashable {
    var id: String { name }
    let name: String
    /// SF Symbol used to represent the movement in the UI.
    let symbol: String
    let muscleGroup: String
}

/// The starter catalog of movements. Add more here as needed.
enum ExerciseCatalog {
    static let all: [Exercise] = [
        Exercise(name: "Bench Press",    symbol: "dumbbell.fill",                        muscleGroup: "Chest"),
        Exercise(name: "Back Squat",     symbol: "figure.strengthtraining.functional",   muscleGroup: "Legs"),
        Exercise(name: "Deadlift",       symbol: "figure.strengthtraining.traditional",  muscleGroup: "Back"),
        Exercise(name: "Overhead Press", symbol: "dumbbell.fill",                        muscleGroup: "Shoulders"),
        Exercise(name: "Barbell Row",    symbol: "figure.rower",                         muscleGroup: "Back"),
        Exercise(name: "Pull-Up",        symbol: "figure.strengthtraining.functional",   muscleGroup: "Back"),
    ]

    static func exercise(named name: String) -> Exercise? {
        all.first { $0.name == name }
    }

    /// SF Symbol for a stored exercise name, falling back to a generic icon.
    static func symbol(for name: String) -> String {
        exercise(named: name)?.symbol ?? "dumbbell.fill"
    }
}
