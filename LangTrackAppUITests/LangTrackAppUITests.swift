import XCTest

final class LangTrackAppUITests: XCTestCase {
    func testLaunchShowsLoginWithoutSubmittingCredentials() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20))
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 20))
        XCTAssertTrue(app.secureTextFields["パスワード"].exists)
        XCTAssertTrue(app.staticTexts["KIROKUN"].exists)
        XCTAssertTrue(app.staticTexts["ユーザー名とパスワードを入力してください"].exists)
    }
}
