import XCTest

final class LangTrackAppUITests: XCTestCase {
    func testLaunchShowsLoginWithoutSubmittingCredentials() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20))
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 20))
        XCTAssertTrue(app.secureTextFields.firstMatch.exists)
    }
}
