import XCTest
@testable import Lang_Track_App

final class LangTrackAppTests: XCTestCase {
    func testServerTimestampParsesUTC() {
        let date = DateParser.getDate(dateString: "2025-11-08T00:00:00.000Z")
        XCTAssertEqual(date?.timeIntervalSince1970, 1762560000)
    }
    func testInvalidServerTimestampIsRejected() {
        XCTAssertNil(DateParser.getDate(dateString: "not-a-date"))
    }
}
