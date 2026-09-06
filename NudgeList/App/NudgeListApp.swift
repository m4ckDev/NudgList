import SwiftData
import SwiftUI

@main
struct NudgeListApp: App {
    private let modelContainer: ModelContainer

    init() {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        do {
            modelContainer = try PersistenceController.makeModelContainer(
                inMemory: isUITesting,
                cloudSyncEnabled: !isUITesting
            )
        } catch {
            fatalError("Unable to create Nudge List model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
