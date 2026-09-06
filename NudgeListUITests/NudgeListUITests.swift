import XCTest

final class NudgeListUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateNudge() {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()

        app.buttons["add-nudge-button"].tap()

        let titleField = app.textFields["nudge-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("Bring charger")

        app.buttons["save-nudge-button"].tap()

        XCTAssertTrue(app.staticTexts["Bring charger"].waitForExistence(timeout: 3))
    }
}
