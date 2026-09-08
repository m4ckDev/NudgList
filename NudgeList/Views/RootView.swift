import SwiftData
import SwiftUI

private enum NudgeFilter: String, CaseIterable, Identifiable {
    case active = "Now"
    case completed = "Done"

    var id: Self { self }
}

private struct EditorRoute: Identifiable {
    let id = UUID()
    let nudge: Nudge?
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Nudge.createdAt, order: .forward) private var nudges: [Nudge]

    @State private var filter: NudgeFilter = .active
    @State private var editorRoute: EditorRoute?

    private var visibleNudges: [Nudge] {
        switch filter {
        case .active:
            NudgeOrdering.active(nudges)
        case .completed:
            NudgeOrdering.completed(nudges)
        }
    }

    private var pageBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    private var reminderSignature: String {
        nudges
            .map { nudge in
                let due = nudge.dueDate?.timeIntervalSince1970.description ?? "none"
                return "\(nudge.id.uuidString)|\(due)|\(nudge.isCompleted)|\(nudge.title)|\(nudge.note)"
            }
            .sorted()
            .joined(separator: ";")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                pageBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("View", selection: $filter) {
                        ForEach(NudgeFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .accessibilityIdentifier("nudge-filter-picker")

                    if visibleNudges.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(visibleNudges) { nudge in
                                NudgeRowView(
                                    nudge: nudge,
                                    onToggleCompletion: { toggleCompletion(nudge) },
                                    onEdit: { editorRoute = EditorRoute(nudge: nudge) },
                                    onDelete: { delete(nudge) }
                                )
                                .listRowInsets(
                                    EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Nudge List")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editorRoute = EditorRoute(nudge: nil)
                    } label: {
                        Label("New Nudge", systemImage: "plus")
                    }
                    .accessibilityIdentifier("add-nudge-button")
                }
            }
            .sheet(item: $editorRoute) { route in
                NudgeEditorView(nudge: route.nudge)
            }
            .task(id: reminderSignature) {
                await NotificationService.shared.reconcile(nudges)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 82, height: 82)

                Image(systemName: filter == .active ? "checkmark.circle.fill" : "clock.arrow.circlepath")
                    .font(.system(size: 36, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(spacing: 6) {
                Text(filter == .active ? "Nothing to nudge" : "Nothing completed yet")
                    .font(.title3.weight(.semibold))

                Text(
                    filter == .active
                    ? "Add something small you do not want to forget."
                    : "Completed nudges will appear here."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func toggleCompletion(_ nudge: Nudge) {
        if nudge.isCompleted {
            nudge.reopen()
        } else {
            nudge.complete()
        }

        try? modelContext.save()

        if nudge.isCompleted {
            NotificationService.shared.remove(identifier: nudge.notificationIdentifier)
        } else if let dueDate = nudge.dueDate, dueDate > .now {
            Task {
                try? await NotificationService.shared.schedule(
                    identifier: nudge.notificationIdentifier,
                    title: nudge.title,
                    note: nudge.note,
                    dueDate: dueDate
                )
            }
        }
    }

    private func delete(_ nudge: Nudge) {
        NotificationService.shared.remove(identifier: nudge.notificationIdentifier)
        modelContext.delete(nudge)
        try? modelContext.save()
    }
}
