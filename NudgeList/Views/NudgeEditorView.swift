import SwiftData
import SwiftUI

struct NudgeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let nudge: Nudge?

    @State private var title: String
    @State private var note: String
    @State private var hasReminder: Bool
    @State private var dueDate: Date
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(nudge: Nudge?) {
        self.nudge = nudge
        _title = State(initialValue: nudge?.title ?? "")
        _note = State(initialValue: nudge?.note ?? "")
        _hasReminder = State(initialValue: nudge?.dueDate != nil)
        _dueDate = State(initialValue: nudge?.dueDate ?? Date().addingTimeInterval(60 * 60))
    }

    private var navigationTitle: String {
        nudge == nil ? "New Nudge" : "Edit Nudge"
    }

    private var canSave: Bool {
        !title.trimmed.isEmpty && !isSaving
    }

    private var pageBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What do you need to remember?", text: $title)
                        .font(.title3.weight(.semibold))
                        .accessibilityIdentifier("nudge-title-field")

                    TextField("Optional note", text: $note, axis: .vertical)
                        .font(.body)
                        .lineLimit(2...5)
                        .accessibilityIdentifier("nudge-note-field")
                } header: {
                    Label("Nudge", systemImage: "square.and.pencil")
                }

                Section {
                    Toggle(isOn: $hasReminder) {
                        Label("Remind me", systemImage: "bell")
                    }
                    .tint(.accentColor)
                    .accessibilityIdentifier("nudge-reminder-toggle")

                    if hasReminder {
                        DatePicker(
                            "When",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .accessibilityIdentifier("nudge-date-picker")

                        if dueDate <= .now {
                            Label("Choose a future time.", systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Label("Reminder", systemImage: "clock")
                } footer: {
                    if hasReminder && dueDate > .now {
                        Text("Nudge List will alert you at the selected time.")
                    }
                }

                Section {
                    Label {
                        Text("Nudges stay private on your device and can sync through your private iCloud account on your Apple devices.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(pageBackground)
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave || (hasReminder && dueDate <= .now))
                    .accessibilityIdentifier("save-nudge-button")
                }
            }
            .alert(
                "Unable to Save Reminder",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            #if os(iOS)
            .presentationDragIndicator(.visible)
            #endif
            #if os(macOS)
            .frame(minWidth: 460, minHeight: 440)
            #endif
        }
    }

    @MainActor
    private func save() async {
        let cleanTitle = title.trimmed
        guard !cleanTitle.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        if hasReminder {
            do {
                let allowed = try await NotificationService.shared.requestPermissionIfNeeded()
                guard allowed else {
                    errorMessage = "Notifications are disabled for Nudge List. Enable notifications in System Settings, or turn off Remind me and save the nudge without an alert."
                    return
                }
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }

        let target: Nudge

        if let nudge {
            target = nudge
            target.title = cleanTitle
            target.note = note.trimmed
            target.dueDate = hasReminder ? dueDate : nil
        } else {
            target = Nudge(
                title: cleanTitle,
                note: note.trimmed,
                dueDate: hasReminder ? dueDate : nil
            )
            modelContext.insert(target)
        }

        do {
            try modelContext.save()

            if let dueDate = target.dueDate, !target.isCompleted {
                try await NotificationService.shared.schedule(
                    identifier: target.notificationIdentifier,
                    title: target.title,
                    note: target.note,
                    dueDate: dueDate
                )
            } else {
                NotificationService.shared.remove(identifier: target.notificationIdentifier)
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
