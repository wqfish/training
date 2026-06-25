import SwiftUI
import SwiftData

/// A mutable, in-memory copy of one grip while editing. Nothing is written to the store
/// until the user taps Save.
private struct FingerDraft: Identifiable {
    let id = UUID()
    var grip: String
    var weight: Double
    var usesWeight: Bool
}

/// The finger-training edit sheet. The session is tagged with one protocol; under it the
/// user adds the grips they trained and the added weight for each. Mirrors `EditDayView`'s
/// wholesale delete-and-reinsert save.
struct EditFingerView: View {
    let date: Date
    /// The day's existing finger entries; these are replaced wholesale on Save.
    let existing: [FingerEntry]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProtocol: FingerProtocol
    @State private var drafts: [FingerDraft]
    @State private var showingPicker = false
    @FocusState private var focusedWeight: UUID?

    init(date: Date, existing: [FingerEntry]) {
        self.date = date
        self.existing = existing
        let sorted = existing.sorted { $0.position < $1.position }
        // Default to the existing session's protocol, falling back to Repeaters.
        _selectedProtocol = State(initialValue: sorted.first?.fingerProtocol ?? .repeaters)
        _drafts = State(initialValue: sorted.map { FingerDraft(grip: $0.grip, weight: $0.weight, usesWeight: $0.usesWeight) })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Protocol") {
                    Picker("Protocol", selection: $selectedProtocol) {
                        ForEach(FingerProtocol.allCases) { proto in
                            Text(proto.rawValue).tag(proto)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                if drafts.isEmpty {
                    emptyPrompt
                }

                ForEach($drafts) { $draft in
                    Section {
                        Toggle("Uses weight", isOn: $draft.usesWeight)
                        if draft.usesWeight {
                            weightRow($draft)
                        }
                    } header: {
                        gripHeader(for: draft)
                    }
                }

                Section {
                    Button {
                        showingPicker = true
                    } label: {
                        Label("Add Grip", systemImage: "plus.circle.fill")
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
                GripPickerView { grip in
                    drafts.append(FingerDraft(grip: grip.rawValue, weight: 0, usesWeight: true))
                }
            }
        }
    }

    // MARK: - Rows

    private func gripHeader(for draft: FingerDraft) -> some View {
        HStack {
            Label(draft.grip, systemImage: "hand.raised.fill")
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

    private func weightRow(_ draft: Binding<FingerDraft>) -> some View {
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
            Text("No grips yet. Tap **Add Grip** to log half crimp, 3-finger drag, or open hand.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Save

    private func save() {
        // Replace the day's finger entries with the edited set, all tagged with the
        // chosen protocol. Mirrors EditDayView — simple and correct for a personal log.
        for entry in existing {
            context.delete(entry)
        }
        for (index, draft) in drafts.enumerated() {
            context.insert(FingerEntry(
                date: date.startOfDay,
                protocolName: selectedProtocol.rawValue,
                grip: draft.grip,
                weight: draft.usesWeight ? draft.weight : 0,
                position: index,
                usesWeight: draft.usesWeight
            ))
        }
        try? context.save()
        dismiss()
    }
}

/// A simple list of the grip positions. Tapping one adds it to the session.
private struct GripPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (GripPosition) -> Void

    var body: some View {
        NavigationStack {
            List(GripPosition.allCases) { grip in
                Button {
                    onSelect(grip)
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "hand.raised.fill")
                            .font(.title3)
                            .foregroundStyle(Color.fingerAccent)
                            .frame(width: 30)
                        Text(grip.rawValue)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.fingerAccent)
                    }
                }
            }
            .navigationTitle("Add Grip")
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
