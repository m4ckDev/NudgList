import Foundation
import SwiftData

enum PersistenceController {
    static let cloudContainerIdentifier = "iCloud.com.m4ckdev.NudgeList"

    static func makeModelContainer(
        inMemory: Bool = false,
        cloudSyncEnabled: Bool = true
    ) throws -> ModelContainer {
        let schema = Schema([
            Nudge.self,
        ])

        let cloudDatabase: ModelConfiguration.CloudKitDatabase =
            cloudSyncEnabled && !inMemory
            ? .private(cloudContainerIdentifier)
            : .none

        let configuration = ModelConfiguration(
            "NudgeList",
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: cloudDatabase
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
