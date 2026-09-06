import Foundation
import SwiftData

@Model
final class Nudge {
    var id: UUID = UUID()
    var title: String = ""
    var note: String = ""
    var createdAt: Date = Date()
    var dueDate: Date?
    var isCompleted: Bool = false
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        createdAt: Date = .now,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }

    var notificationIdentifier: String {
        "nudge-\(id.uuidString)"
    }

    func complete(at date: Date = .now) {
        isCompleted = true
        completedAt = date
    }

    func reopen() {
        isCompleted = false
        completedAt = nil
    }
}
