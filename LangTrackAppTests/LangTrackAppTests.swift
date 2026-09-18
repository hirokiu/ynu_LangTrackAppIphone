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
    #if KIROKUN_DEV && DEBUG && targetEnvironment(simulator)
    @MainActor
    func testAllQuestionFormsOnCurrentDevice() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "surveyContainer") as! SurveyViewController
        controller.theAssignment = DevSceneDelegate.layoutFixture()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
        controller.view.layoutIfNeeded()
        for question in controller.theAssignment!.survey.questions {
            controller.showPage(newPage: question)
            controller.view.layoutIfNeeded()
            guard let child = controller.children.first else { XCTFail("Missing page"); continue }
            child.view.layoutIfNeeded()
            var buttons: [UIButton] = []
            if let c = child as? HeaderViewController { buttons = [c.nextButton, c.closeButton] }
            if let c = child as? OpenEndedTextResponsesViewController { buttons = [c.nextButton, c.previousButton] }
            if let c = child as? LikertScaleViewController { buttons = [c.nextButton, c.previousButton, c.radioButton1, c.radioButton2, c.radioButton3, c.radioButton4, c.radioButton5] }
            if let c = child as? SingleMultipleAnswersViewController { buttons = [c.nextButton, c.previousButton] }
            if let c = child as? MultipleChoiceViewController { buttons = [c.nextButton, c.previousButton] }
            if let c = child as? FillInTheBlankViewController { buttons = [c.nextButton, c.previousButton] }
            if let c = child as? SliderScaleViewController { buttons = [c.nextButton, c.previousButton] }
            if let c = child as? TimeDurationViewController { buttons = [c.nextButton, c.previousButton] }
            if let c = child as? FooterViewController { buttons = [c.sendInButton, c.previousButton] }
            for button in buttons {
                let rect = button.convert(button.bounds, to: controller.view)
                XCTAssertGreaterThanOrEqual(rect.minX, -1, question.type)
                XCTAssertLessThanOrEqual(rect.maxX, controller.view.bounds.width + 1, question.type)
                XCTAssertGreaterThanOrEqual(rect.minY, controller.surveyContainer.frame.minY - 1, question.type)
                XCTAssertLessThanOrEqual(rect.maxY, controller.view.bounds.height + 1, question.type)
            }
        }
        window.isHidden = true
    }
    @MainActor
    func testModalMetadataAlignmentAndTheme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let oldSelection = SurveyRepository.selectedAssignment
        defer { SurveyRepository.selectedAssignment = oldSelection }
        SurveyRepository.selectedAssignment = DevSceneDelegate.layoutFixture()
        let popup = storyboard.instantiateViewController(withIdentifier: "unansweredPopup") as! UnansweredPopupViewController
        let overview = storyboard.instantiateViewController(withIdentifier: "answeredPreview") as! OverviewViewController
        overview.theAssignment = DevSceneDelegate.layoutFixture()
        for controller in [popup as UIViewController, overview as UIViewController] {
            controller.loadViewIfNeeded()
            controller.view.frame = UIScreen.main.bounds
            controller.view.layoutIfNeeded()
            let values: [UILabel] = controller === popup ? [popup.numberQuestionsLabel, popup.publishedLabel, popup.expiredLabel] : [overview.topViewNumberOfQuestionsLabel, overview.topViewPublishedLabel, overview.topViewAnsweredLabel]
            let origin = values[0].convert(values[0].bounds, to: controller.view).minX
            for value in values {
                XCTAssertEqual(value.convert(value.bounds, to: controller.view).minX, origin, accuracy: 0.5)
                XCTAssertEqual(value.textColor, UIColor.white)
            }
            XCTAssertEqual((controller === popup ? popup.popupContainer : overview.topViewContainer)?.backgroundColor, KirokunTheme.brand)
        }
    }
    #endif
}
