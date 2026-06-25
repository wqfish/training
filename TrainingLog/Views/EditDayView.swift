import SwiftUI
import SwiftData
import OSLog

/// Surfaces persistence failures in the console instead of letting them vanish.
private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TrainingLog",
                            category: "persistence")

/// A mutable, in-memory copy of one exercise entry while editing. Nothing is written
/// to the store until the user taps Save.
private struct DraftEntry: Identifiable {
    let id = UUID()
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double
    var usesWeight: Bool
}

/// The edit screen presented as a sheet. The user adds movements from the predefined
/// catalog, dials in sets / reps / weight, then taps Save to commit the whole day.
struct EditDayView: View {
    let date: Date
    /// The day's existing entries; these are replaced wholesale on Save.
    let existing: [WorkoutEntry]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var drafts: [DraftEntry]
    @State private var showingPicker = false
    @FocusState private var focusedWeight: UUID?

    init(date: Date, existing: [WorkoutEntry]) {
        self.date = date
        self.existing = existing
        _drafts = State(initialValue: existing
            .sorted { $0.position < $1.position }
            .map { DraftEntry(exerciseName: $0.exerciseName, sets: $0.sets, reps: $0.reps, weight: $0.weight, usesWeight: $0.usesWeight) })
    }

    var body: some View {
        NavigationStack {
            Form {
                if drafts.isEmpty {
                    emptyPrompt
                }

                ForEach($drafts) { $draft in
                    Section {
                        countRow($draft)
                        weightRow($draft)
                    } header: {
                        sectionHeader(for: draft)
                    }
                }

                Section {
                    Button {
                        showingPicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle(date.formatted(.dateTime.month().day().weekday(.abbreviated)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedWeight = nil }
                }
            }
            .sheet(isPresented: $showingPicker) {
                ExercisePickerView { exercise in
                    // Preset the weight toggle from the catalog: bodyweight movements
                    // start with weight off, loaded movements start at an empty barbell.
                    drafts.append(DraftEntry(
                        exerciseName: exercise.name,
                        sets: 3,
                        reps: 5,
                        weight: exercise.isBodyweight ? 0 : 45,
                        usesWeight: !exercise.isBodyweight
                    ))
                }
            }
        }
    }

    // MARK: - Rows

    private func sectionHeader(for draft: DraftEntry) -> some View {
        HStack {
            Label(draft.exerciseName, systemImage: ExerciseCatalog.symbol(for: draft.exerciseName))
                .font(.headline)
                .textCase(nil)
                .foregroundStyle(.primary)
            Spacer()
            Button(role: .destructive) {
                drafts.removeAll { $0.id == draft.id }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
    }

    /// Sets and reps share a single row: two compact steppers split by a divider.
    private func countRow(_ draft: Binding<DraftEntry>) -> some View {
        HStack(spacing: 0) {
            Stepper(value: draft.sets, in: 1...20) {
                countLabel("Sets", draft.wrappedValue.sets)
            }
            Divider()
                .padding(.horizontal, 6)
            Stepper(value: draft.reps, in: 1...100) {
                countLabel("Reps", draft.wrappedValue.reps)
            }
        }
    }

    /// A "Sets 3" / "Reps 5" caption sized to leave the stepper buttons room.
    /// Scales down rather than truncating when the value reaches two or three digits.
    private func countLabel(_ title: String, _ value: Int) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .fontWeight(.medium)
                .monospacedDigit()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    /// The weight toggle and, when enabled, the editable weight — all on one row.
    private func weightRow(_ draft: Binding<DraftEntry>) -> some View {
        HStack(spacing: 8) {
            Text("Weight")
            Spacer()
            if draft.wrappedValue.usesWeight {
                TextField("0", value: draft.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedWeight, equals: draft.id)
                    .frame(width: 70)
                Text("lb")
                    .foregroundStyle(.secondary)
            }
            Toggle("Uses weight", isOn: draft.usesWeight)
                .labelsHidden()
        }
    }

    private var emptyPrompt: some View {
        Section {
            Text("No exercises yet. Tap **Add Exercise** to start logging this day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Save

    private func save() {
        // Replace the day's entries with the edited set. Simple and correct for a
        // personal log with only a handful of entries per day.
        for entry in existing {
            context.delete(entry)
        }
        for (index, draft) in drafts.enumerated() {
            context.insert(WorkoutEntry(
                date: date.startOfDay,
                exerciseName: draft.exerciseName,
                sets: draft.sets,
                reps: draft.reps,
                weight: draft.usesWeight ? draft.weight : 0,
                position: index,
                usesWeight: draft.usesWeight
            ))
        }
        do {
            try context.save()
        } catch {
            logger.error("Failed to save strength entries: \(error.localizedDescription, privacy: .public)")
        }
        dismiss()
    }
}

/// A simple list of the predefined movements. Tapping one adds it to the day.
private struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            List(ExerciseCatalog.all) { exercise in
                Button {
                    onSelect(exercise)
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: exercise.symbol)
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 30)
                        Text(exercise.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
