import Foundation

/// A predefined strength-training movement that can be logged.
struct Exercise: Identifiable, Hashable {
    var id: String { name }
    let name: String
    /// SF Symbol used to represent the movement in the UI.
    let symbol: String
    /// Whether this movement is bodyweight by default. Presets the editor's "uses weight"
    /// toggle to off; usually-loaded movements leave this false.
    let isBodyweight: Bool

    init(name: String, symbol: String, isBodyweight: Bool = false) {
        self.name = name
        self.symbol = symbol
        self.isBodyweight = isBodyweight
    }
}

/// The starter catalog of movements. Add more here as needed.
enum ExerciseCatalog {
    static let all: [Exercise] = [
        Exercise(name: "Bench Press",               symbol: "dumbbell.fill"),
        Exercise(name: "Back Squat",                symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Deadlift",                  symbol: "figure.strengthtraining.traditional"),
        Exercise(name: "Barbell Row",               symbol: "figure.strengthtraining.traditional"),
        Exercise(name: "Pull-Up",                   symbol: "figure.strengthtraining.functional"),
        Exercise(name: "Physioball Hamstring Curl", symbol: "figure.strengthtraining.functional", isBodyweight: true),
        Exercise(name: "Step-Up",                   symbol: "figure.step.training", isBodyweight: true),
        Exercise(name: "Tripod DB Row",             symbol: "dumbbell.fill"),
        Exercise(name: "T's and W's",               symbol: "dumbbell.fill", isBodyweight: true),
        Exercise(name: "Single-Leg Hip Thrust",     symbol: "figure.strengthtraining.traditional", isBodyweight: true),
        Exercise(name: "Lock-Off Isometric",        symbol: "figure.climbing", isBodyweight: true),
        Exercise(name: "Lateral Raise",             symbol: "dumbbell.fill"),
        Exercise(name: "Back Fly",                  symbol: "dumbbell.fill"),
        Exercise(name: "Chest Fly",                 symbol: "dumbbell.fill"),
        Exercise(name: "Landmine Press",            symbol: "dumbbell.fill"),
    ]

    static func exercise(named name: String) -> Exercise? {
        all.first { $0.name == name }
    }

    /// SF Symbol for a stored exercise name, falling back to a generic icon.
    static func symbol(for name: String) -> String {
        exercise(named: name)?.symbol ?? "dumbbell.fill"
    }
}
