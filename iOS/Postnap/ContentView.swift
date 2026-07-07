import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PostnapStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingEntry: PostnapEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            entryRow(entry)
                                .listRowBackground(Theme.cardBackground)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEntry = entry }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Postnap")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No entries yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Rate how groggy naps leave you to learn your ideal nap length.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func entryRow(_ entry: PostnapEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
            HStack {
                Text("Duration (min): \(entry.value1)")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if !entry.value2.isEmpty {
                    Text("Grogginess (1-5): \(entry.value2)")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.accent)
                }
            }
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var value1: String
    @State private var value2: String
    @State private var note: String
    @State private var date: Date
    private let existing: PostnapEntry?
    let onSave: (PostnapEntry) -> Void

    init(entry: PostnapEntry?, onSave: @escaping (PostnapEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _value1 = State(initialValue: entry?.value1 ?? "")
        _value2 = State(initialValue: entry?.value2 ?? "")
        _note = State(initialValue: entry?.note ?? "")
        _date = State(initialValue: entry?.date ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nap") {
                    DatePicker("Date", selection: $date)
                    TextField("Duration (min)", text: $value1)
                        .accessibilityIdentifier("value1Field")
                    TextField("Grogginess (1-5)", text: $value2)
                        .accessibilityIdentifier("value2Field")
                    TextField("Note (optional)", text: $note)
                        .accessibilityIdentifier("noteField")
                }
            }
            .navigationTitle(existing == nil ? "Add Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = PostnapEntry(
                            id: existing?.id ?? UUID(),
                            date: date,
                            note: note,
                            value1: value1,
                            value2: value2
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .tint(Theme.accent)
    }
}
