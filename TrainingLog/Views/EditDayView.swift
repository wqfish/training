import SwiftUI
import SwiftData

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
                        Stepper("Sets: \(draft.sets)", value: $draft.sets, in: 1...20)
                        Stepper("Reps: \(draft.reps)", value: $draft.reps, in: 1...100)
                        Toggle("Uses weight", isOn: $draft.usesWeight)
                        if draft.usesWeight {
                            weightRow($draft)
                        }
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

    private func weightRow(_ draft: Binding<DraftEntry>) -> some View {
        HStack {
            Text("Weight")
            Spacer()
            TextField("0", value: draft.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedWeight, equals: draft.id)
                .frame(width: 90)
            Text("lb")
                .foregroundStyle(.secondary)
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
        try? context.save()
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
