import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "nudge-"

    private init() {}

    func requestPermissionIfNeeded() async throws -> Bool {
        let settings = await notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        #if os(iOS)
        case .ephemeral:
            return true
        #endif
        case .denied:
            return false
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        @unknown default:
            return false
        }
    }

    func schedule(
        identifier: String,
        title: String,
        note: String,
        dueDate: Date
    ) async throws {
        guard dueDate > .now else { return }

        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = note.trimmed.isEmpty ? "Nudge List reminder" : note.trimmed
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func remove(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    func reconcile(_ nudges: [Nudge]) async {
        let settings = await notificationSettings()

        let isAuthorized: Bool
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            isAuthorized = true
        #if os(iOS)
        case .ephemeral:
            isAuthorized = true
        #endif
        default:
            isAuthorized = false
        }

        guard isAuthorized else { return }

        let pending = await pendingRequests()
        let managedIdentifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }

        if !managedIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: managedIdentifiers)
        }

        for nudge in nudges where !nudge.isCompleted {
            guard let dueDate = nudge.dueDate, dueDate > .now else { continue }
            try? await schedule(
                identifier: nudge.notificationIdentifier,
                title: nudge.title,
                note: nudge.note,
                dueDate: dueDate
            )
        }
    }

    private func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
}
