import Foundation

/// A predefined strength-training movement that can be logged.
struct Exercise: Identifiable, Hashable {
    var id: String { name }
    let name: String
    /// SF Symbol used to represent the movement in the UI.
    let symbol: String
}

/// The starter catalog of movements. Add more here as needed.
enum ExerciseCatalog {
    static let all: [Exercise] = [
        // Starter catalog
        Exercise(name: "Bench Press",               symbol: "dumbbell.fill"),
        Exercise(name: "Back Squat",                symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Deadlift",                  symbol: "figure.strengthtraining.traditional"),
        Exercise(name: "Overhead Press",            symbol: "dumbbell.fill"),
        Exercise(name: "Barbell Row",               symbol: "figure.rower"),
        Exercise(name: "Pull-Up",                   symbol: "figure.strengthtraining.functional"),
        // Strength Workout 1 — lower-body strength + climbing-specific pulling
        Exercise(name: "Physioball Hamstring Curl", symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Step-Up",                   symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Lat Pulldown",              symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Tripod DB Row",             symbol: "figure.rower"),
        Exercise(name: "T's and W's",               symbol: "dumbbell.fill"),
        // Strength Workout 2 — quad/glute strength + shoulder stability and fly work
        Exercise(name: "DB Front Squat",            symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Single-Leg Hip Thrust",     symbol: "figure.strengthtraining.traditional"),
        Exercise(name: "Lock-Off Isometric",        symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Lateral Raise",             symbol: "dumbbell.fill"),
        Exercise(name: "Back Fly",                  symbol: "dumbbell.fill"),
        Exercise(name: "Chest Fly",                 symbol: "dumbbell.fill"),
    ]

    static func exercise(named name: String) -> Exercise? {
        all.first { $0.name == name }
    }

    /// SF Symbol for a stored exercise name, falling back to a generic icon.
    static func symbol(for name: String) -> String {
        exercise(named: name)?.symbol ?? "dumbbell.fill"
    }
}
