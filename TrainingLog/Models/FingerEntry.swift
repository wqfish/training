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

/// One logged finger-strength grip on a given day, e.g. "Repeaters — Half Crimp @ 25 lb".
///
/// Stored flat and grouped by `date` (start of day), mirroring `WorkoutEntry`. Finger
/// training follows one of two protocols and we only record the added weight per grip
/// position — sets and timing are fixed by the protocol, so there's nothing else to log.
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
        position: Int,
        usesWeight: Bool = true
    ) {
        self.id = id
        self.date = date
        self.protocolName = protocolName
        self.grip = grip
        self.weight = weight
        self.position = position
        self.usesWeight = usesWeight
    }

    /// Typed protocol, or nil if a stored raw value is no longer recognized.
    var fingerProtocol: FingerProtocol? { FingerProtocol(rawValue: protocolName) }
    /// Typed grip position, or nil if a stored raw value is no longer recognized.
    var gripPosition: GripPosition? { GripPosition(rawValue: grip) }
}
