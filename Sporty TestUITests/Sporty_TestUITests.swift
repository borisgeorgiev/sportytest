import XCTest

final class Sporty_TestUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testNavigationBarTitle() {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.staticTexts["swiftlang"].exists)
    }
}
