import SwiftUI

/// The bottom half of the main screen: what was done on the selected day, split into a
/// Strength section and a Finger Training section. Each is edited independently via its
/// own button in the section header.
struct DayDetailView: View {
    let entries: [WorkoutEntry]
    let fingerEntries: [FingerEntry]
    let onEditStrength: () -> Void
    let onEditFingers: () -> Void
    /// Swipe-to-delete for the strength list, by row offset.
    let onDeleteStrength: (IndexSet) -> Void
    /// Long-press-drag reorder within the strength list.
    let onMoveStrength: (IndexSet, Int) -> Void
    let onDeleteFingers: (IndexSet) -> Void
    let onMoveFingers: (IndexSet, Int) -> Void

    var body: some View {
        // A List (rather than a ScrollView) so each row gets native swipe-to-delete and
        // long-press-drag reordering. The cards keep their look via clear row backgrounds
        // and a hidden scroll background, letting the gradient show through.
        List {
            strengthSection
            fingerSection
        }
        .listStyle(.plain)
        .listSectionSpacing(16)
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Strength

    private var strengthSection: some View {
        Section {
            if entries.isEmpty {
                emptyPrompt("No strength work logged.")
                    .dayDetailRow()
            } else {
                ForEach(entries) { entry in
                    strengthCard(entry)
                        .dayDetailRow()
                }
                .onDelete(perform: onDeleteStrength)
                .onMove(perform: onMoveStrength)
            }
        } header: {
            sectionHeader(title: "Strength", systemImage: "dumbbell.fill",
                          tint: .strengthAccent, isEmpty: entries.isEmpty, onEdit: onEditStrength)
        } footer: {
            if !entries.isEmpty { strengthFooter }
        }
    }

    private func strengthCard(_ entry: WorkoutEntry) -> some View {
        HStack(spacing: 14) {
            iconBadge(ExerciseCatalog.symbol(for: entry.exerciseName), tint: .strengthAccent)
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.exerciseName)
                    .font(.headline)
                Text("\(entry.sets) sets × \(entry.reps) reps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            weightLabel(usesWeight: entry.usesWeight, weight: entry.weight)
        }
        .card(horizontal: 16, vertical: 10)
    }

    private var strengthFooter: some View {
        let totalVolume = Int(entries.reduce(0) { $0 + $1.volume }.rounded())
        return HStack {
            Label("\(entries.count) exercise\(entries.count == 1 ? "" : "s")",
                  systemImage: "list.bullet")
            Spacer()
            Label("\(totalVolume.formatted(.number.grouping(.automatic))) lb total",
                  systemImage: "scalemass")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }

    // MARK: - Finger training

    private var fingerSection: some View {
        Section {
            if fingerEntries.isEmpty {
                emptyPrompt("No finger training logged.")
                    .dayDetailRow()
            } else {
                ForEach(fingerEntries) { entry in
                    fingerCard(entry)
                        .dayDetailRow()
                }
                .onDelete(perform: onDeleteFingers)
                .onMove(perform: onMoveFingers)
            }
        } header: {
            sectionHeader(title: "Finger Training", systemImage: "figure.climbing",
                          tint: .fingerAccent, isEmpty: fingerEntries.isEmpty, onEdit: onEditFingers)
        } footer: {
            if !fingerEntries.isEmpty { fingerFooter }
        }
    }

    private func fingerCard(_ entry: FingerEntry) -> some View {
        HStack(spacing: 14) {
            iconBadge("hand.raised.fill", tint: .fingerAccent)
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.grip)
                    .font(.headline)
                Text(fingerSubtitle(for: entry))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            weightLabel(usesWeight: entry.usesWeight, weight: entry.weight)
        }
        .card(horizontal: 16, vertical: 10)
    }

    /// Subtitle under a finger entry: the protocol, plus the rep count for Max Hang.
    private func fingerSubtitle(for entry: FingerEntry) -> String {
        guard entry.fingerProtocol == .maxHang else { return entry.protocolName }
        return "\(entry.protocolName) · \(entry.reps) rep\(entry.reps == 1 ? "" : "s")"
    }

    private var fingerFooter: some View {
        HStack {
            Label("\(fingerEntries.count) grip\(fingerEntries.count == 1 ? "" : "s")",
                  systemImage: "hand.raised")
            Spacer()
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }

    // MARK: - Shared pieces

    private func sectionHeader(title: String, systemImage: String, tint: Color,
                               isEmpty: Bool, onEdit: @escaping () -> Void) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                Text(title)
                    .foregroundStyle(.primary)
            }
            .font(.headline)
            Spacer()
            Button(action: onEdit) {
                Label(isEmpty ? "Add" : "Edit",
                      systemImage: isEmpty ? "plus" : "square.and.pencil")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(tint)
        }
        .textCase(nil)
    }

    private func iconBadge(_ systemName: String, tint: Color) -> some View {
        Image(systemName: systemName)
            .font(.title2)
            .foregroundStyle(tint)
            .frame(width: 40, height: 40)
            .background(tint.opacity(0.12), in: Circle())
    }

    @ViewBuilder
    private func weightLabel(usesWeight: Bool, weight: Double) -> some View {
        if usesWeight {
            VStack(alignment: .trailing, spacing: 1) {
                Text(weight.lbString)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                Text("lb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("Bodyweight")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func emptyPrompt(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension View {
    /// Shared styling for a day-detail card row: a clear row background and no separator so
    /// the card floats on the screen's gradient, with insets that reproduce the spacing the
    /// cards had in the old LazyVStack.
    func dayDetailRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}
