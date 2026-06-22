import SwiftUI

/// The bottom half of the main screen: what was done on the selected day, plus an Edit button.
struct DayDetailView: View {
    let date: Date
    let entries: [WorkoutEntry]
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.horizontal)
                .padding(.top, 18)
                .padding(.bottom, 12)

            if entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(entries) { entry in
                            entryCard(entry)
                        }
                        summaryFooter
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.wide)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(date.formatted(.dateTime.month(.wide).day().year()))
                    .font(.title3.weight(.semibold))
            }
            Spacer()
            Button(action: onEdit) {
                Label("Edit", systemImage: "square.and.pencil")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
    }

    // MARK: - Entry card

    private func entryCard(_ entry: WorkoutEntry) -> some View {
        HStack(spacing: 14) {
            Image(systemName: ExerciseCatalog.symbol(for: entry.exerciseName))
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.exerciseName)
                    .font(.headline)
                Text("\(entry.sets) sets × \(entry.reps) reps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text(entry.weight.lbString)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                Text("lb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    private var summaryFooter: some View {
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

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 46))
                .foregroundStyle(.secondary.opacity(0.6))
            Text("No workout logged")
                .font(.headline)
            Text("Tap Edit to add exercises for this day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 40)
    }
}
