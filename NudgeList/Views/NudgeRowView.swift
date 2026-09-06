import SwiftUI

struct NudgeRowView: View {
    let nudge: Nudge
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var isOverdue: Bool {
        guard let dueDate = nudge.dueDate else { return false }
        return !nudge.isCompleted && dueDate < .now
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggleCompletion) {
                Image(systemName: nudge.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                nudge.isCompleted
                ? "Reopen \(nudge.title)"
                : "Complete \(nudge.title)"
            )

            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(nudge.title)
                        .font(.body.weight(.medium))
                        .strikethrough(nudge.isCompleted)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !nudge.note.trimmed.isEmpty {
                        Text(nudge.note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let dueDate = nudge.dueDate {
                        HStack(spacing: 5) {
                            Image(systemName: "bell")
                            Text(isOverdue ? "Overdue · \(dueDate.nudgeDisplayText)" : dueDate.nudgeDisplayText)
                        }
                        .font(.caption)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(nudge.title)")
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: onEdit)

            Button(
                nudge.isCompleted ? "Reopen" : "Complete",
                systemImage: nudge.isCompleted ? "arrow.uturn.backward" : "checkmark",
                action: onToggleCompletion
            )

            Divider()

            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
        #if os(iOS)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }

            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.accentColor)
        }
        #endif
    }
}
