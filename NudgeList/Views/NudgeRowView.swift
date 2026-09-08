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

    private var cardBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    private var reminderColor: Color {
        isOverdue ? .red : .accentColor
    }

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Button(action: onToggleCompletion) {
                Image(systemName: nudge.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(nudge.isCompleted ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                nudge.isCompleted
                ? "Reopen \(nudge.title)"
                : "Complete \(nudge.title)"
            )

            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(nudge.title)
                        .font(.body.weight(.semibold))
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
                            Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "bell.fill")
                            Text(isOverdue ? "Overdue · \(dueDate.nudgeDisplayText)" : dueDate.nudgeDisplayText)
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(reminderColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(reminderColor.opacity(0.10), in: Capsule())
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(nudge.title)")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardBackground)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.055), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .opacity(nudge.isCompleted ? 0.66 : 1)
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
