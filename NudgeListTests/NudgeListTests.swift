import SwiftData
import XCTest
@testable import NudgeList

final class NudgeListTests: XCTestCase {
    func testCompletionLifecycle() {
        let completedAt = Date(timeIntervalSince1970: 1_800_000_000)
        let nudge = Nudge(title: "Bring charger")

        XCTAssertFalse(nudge.isCompleted)
        XCTAssertNil(nudge.completedAt)

        nudge.complete(at: completedAt)

        XCTAssertTrue(nudge.isCompleted)
        XCTAssertEqual(nudge.completedAt, completedAt)

        nudge.reopen()

        XCTAssertFalse(nudge.isCompleted)
        XCTAssertNil(nudge.completedAt)
    }

    func testActiveOrderingPutsScheduledNudgesFirst() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let unscheduled = Nudge(title: "Unscheduled", createdAt: now)
        let later = Nudge(title: "Later", createdAt: now, dueDate: now.addingTimeInterval(7200))
        let sooner = Nudge(title: "Sooner", createdAt: now, dueDate: now.addingTimeInterval(3600))

        let ordered = NudgeOrdering.active([unscheduled, later, sooner])

        XCTAssertEqual(ordered.map(\.title), ["Sooner", "Later", "Unscheduled"])
    }

    func testInMemoryPersistenceRoundTrip() throws {
        let container = try PersistenceController.makeModelContainer(
            inMemory: true,
            cloudSyncEnabled: false
        )
        let context = ModelContext(container)

        context.insert(Nudge(title: "Buy dog food", note: "Small bag"))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Nudge>())

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Buy dog food")
        XCTAssertEqual(fetched.first?.note, "Small bag")
    }
}
