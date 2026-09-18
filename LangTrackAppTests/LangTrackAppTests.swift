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
    @MainActor
    func testLikertFitsSEContentArea() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "likertScale") as! LikertScaleViewController
        controller.loadViewIfNeeded()
        let question = Question()
        question.text = "今日の学習に満足していますか？"
        question.likertMin = "まったく満足していない"
        question.likertMax = "とても満足している"
        controller.setInfo(question: question)
        KirokunTheme.styleQuestion(controller)
        // SE 2/3: 375x667, after status bar and the common/survey headers.
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 480)
        controller.view.layoutIfNeeded()
        let controls: [UIView] = [controller.radioButton1, controller.radioButton2, controller.radioButton3,
                                controller.radioButton4, controller.radioButton5, controller.likertMinLabel,
                                controller.likertMaxLabel, controller.likertTextLabel]
        for control in controls {
            let rect = control.convert(control.bounds, to: controller.view)
            XCTAssertGreaterThanOrEqual(rect.minX, 0)
            XCTAssertLessThanOrEqual(rect.maxX, 375)
            XCTAssertGreaterThanOrEqual(rect.minY, 0)
            XCTAssertLessThanOrEqual(rect.maxY, controller.nextButton.frame.minY)
        }
    }
}
