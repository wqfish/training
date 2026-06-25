import Foundation
import SwiftData

/// The two finger-strength protocols. A session is tagged with exactly one.
enum FingerProtocol: String, CaseIterable, Identifiable {
    case repeaters = "Repeaters"
    case maxHang = "Max Hang"
    var id: String { rawValue }
}

/// Grip positions trained across the protocols.
enum GripPosition: String, CaseIterable, Identifiable {
    case halfCrimp = "Half Crimp"
    case threeFingerDrag = "3 Finger Drag"
    case openHand = "4 Finger Open Hand"
    var id: String { rawValue }
}

/// One logged finger-strength grip on a given day, e.g. "Max Hang — Half Crimp × 5 @ 25 lb".
///
/// Stored flat and grouped by `date` (start of day), mirroring `WorkoutEntry`. A session runs
/// one of two protocols: Max Hang records a rep count per grip, while Repeaters' reps and
/// timing are fixed by the protocol, so `reps` is ignored there.
@Model
final class FingerEntry {
    var id: UUID
    /// Normalized to the start of the day (local calendar) so a day's entries group cleanly.
    var date: Date
    /// `FingerProtocol` raw value — the protocol run this session. Stored as a string so the
    /// schema is robust to enum changes, matching how `WorkoutEntry` stores its exercise name.
    var protocolName: String
    /// `GripPosition` raw value — which grip was loaded.
    var grip: String
    /// Added weight in pounds (negative = assisted / offloaded). Ignored when `usesWeight` is false.
    var weight: Double
    /// Number of hangs for this grip. Only meaningful under the Max Hang protocol; Repeaters'
    /// reps are fixed by the protocol, so this is ignored there. Defaults to 1 so existing
    /// entries migrate cleanly.
    var reps: Int = 1
    /// Whether this grip used added weight. False = a bodyweight hang. Defaults to true so
    /// existing entries migrate cleanly.
    var usesWeight: Bool = true
    /// Position within the day's list, for stable ordering.
    var position: Int

    init(
        id: UUID = UUID(),
        date: Date,
        protocolName: String,
        grip: String,
        weight: Double,
        reps: Int = 1,
        position: Int,
        usesWeight: Bool = true
    ) {
        self.id = id
        self.date = date
        self.protocolName = protocolName
        self.grip = grip
        self.weight = weight
        self.reps = reps
        self.position = position
        self.usesWeight = usesWeight
    }

    /// Typed protocol, or nil if a stored raw value is no longer recognized.
    var fingerProtocol: FingerProtocol? { FingerProtocol(rawValue: protocolName) }
    /// Typed grip position, or nil if a stored raw value is no longer recognized.
    var gripPosition: GripPosition? { GripPosition(rawValue: grip) }
}
