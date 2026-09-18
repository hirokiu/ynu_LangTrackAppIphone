//
//  SurveyViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit
#if KIROKUN_DEV
import FirebaseAuth
#endif

class SurveyViewController: UIViewController {
    @IBOutlet weak var surveyContainer: UIView!
    
    var answer = [Int:Answer]()
    var theAssignment: Assignment? = nil
    var currentPage = Question()
    var theUser: User?
    var inTestMode = false
    var onSaved: (() -> Void)?
    private var sending = false
    private let surveyTitleLabel = UILabel()
    private let surveyProgressLabel = UILabel()
    private let surveyDetailLabel = UILabel()
    private let datesStack = UIStackView()
    private let publishedValueLabel = UILabel()
    private let expiryValueLabel = UILabel()
    
    var header: HeaderViewController?
    var likertScale: LikertScaleViewController?
    var fillInTheBlank: FillInTheBlankViewController?
    var multipleChoice: MultipleChoiceViewController?
    var singleMultipleAnswers: SingleMultipleAnswersViewController?
    var openEndedTextResponses: OpenEndedTextResponsesViewController?
    var timeDuration: TimeDurationViewController?
    var sliderScale: SliderScaleViewController?
    var footer: FooterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = KirokunTheme.action
        
        configureSurveyHeaders()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        header = storyboard.instantiateViewController(withIdentifier: "header") as? HeaderViewController
        header?.setListener(listener: self)
        header?.theUser = self.theUser
        
        likertScale = storyboard.instantiateViewController(withIdentifier: "likertScale") as? LikertScaleViewController
        likertScale?.setListener(listener: self)
        
        fillInTheBlank = storyboard.instantiateViewController(withIdentifier: "fillInTheBlank") as? FillInTheBlankViewController
        fillInTheBlank?.setListener(listener: self)
        
        multipleChoice = storyboard.instantiateViewController(withIdentifier: "multipleChoice") as? MultipleChoiceViewController
        multipleChoice?.setListener(listener: self)
        
        singleMultipleAnswers = storyboard.instantiateViewController(withIdentifier: "singleMultipleAnswer") as? SingleMultipleAnswersViewController
        singleMultipleAnswers?.setListener(listener: self)
        
        timeDuration = storyboard.instantiateViewController(withIdentifier: "timeDuration") as? TimeDurationViewController
        timeDuration?.setListener(listener: self)
        
        sliderScale = storyboard.instantiateViewController(withIdentifier: "sliderScale") as? SliderScaleViewController
        sliderScale?.setListener(listener: self)
        
        openEndedTextResponses = storyboard.instantiateViewController(withIdentifier: "openEndedTextResponses") as? OpenEndedTextResponsesViewController
        openEndedTextResponses?.setListener(listener: self)
        
        footer = storyboard.instantiateViewController(withIdentifier: "footer") as? FooterViewController
        footer?.setListener(listener: self)
        
        //to convert to json
        //print(theSurvey!.convertToString!)
        
        if theAssignment?.survey.questions.first != nil{
            showPage(newPage: theAssignment!.survey.questions.first!)
        }
         // TODO: popup if error
    }
    

    private func configureSurveyHeaders() {
        let common = KirokunTheme.commonHeader()
        view.addSubview(common)
        datesStack.axis = .vertical; datesStack.spacing = 2
        let dateKeys = [NSLocalizedString("survey_published", comment: ""), NSLocalizedString("dev_deadline", comment: "")].map { text -> UILabel in
            let label = UILabel(); label.text = text; label.font = .systemFont(ofSize: 13); label.textColor = KirokunTheme.onFilled
            return label
        }
        let keyWidth = dateKeys.map { $0.intrinsicContentSize.width }.max() ?? 70
        for (key, value) in zip(dateKeys, [publishedValueLabel, expiryValueLabel]) {
            value.font = .systemFont(ofSize: 13); value.textColor = KirokunTheme.onFilled; value.numberOfLines = 0
            key.widthAnchor.constraint(equalToConstant: keyWidth).isActive = true
            let row = UIStackView(arrangedSubviews: [key, value]); row.spacing = 12; row.alignment = .top
            datesStack.addArrangedSubview(row)
        }
        let info = UIStackView(arrangedSubviews: [surveyTitleLabel, surveyProgressLabel, surveyDetailLabel, datesStack])
        info.axis = .vertical; info.spacing = 4
        info.backgroundColor = KirokunTheme.filledBackground
        info.isLayoutMarginsRelativeArrangement = true
        info.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        info.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(info)
        surveyTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        surveyProgressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        surveyDetailLabel.font = .systemFont(ofSize: 13)
        [surveyTitleLabel, surveyProgressLabel, surveyDetailLabel].forEach {
            $0.textAlignment = .center; $0.textColor = KirokunTheme.onFilled; $0.numberOfLines = 0
        }
        for constraint in view.constraints where constraint.firstItem as? UIView === surveyContainer && constraint.firstAttribute == .top {
            constraint.isActive = false
        }
        NSLayoutConstraint.activate([
            common.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            common.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            common.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            common.heightAnchor.constraint(equalToConstant: 44),
            info.topAnchor.constraint(equalTo: common.bottomAnchor),
            info.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            surveyContainer.topAnchor.constraint(equalTo: info.bottomAnchor)
        ])
    }
    private func updateSurveyHeaders(for question: Question) {
        guard let assignment = theAssignment else { return }
        surveyTitleLabel.text = assignment.survey.title.isEmpty ? assignment.survey.name : assignment.survey.title
        // Exclude introductory/completion pages. The denominator is the survey's total
        // question count, even if conditional branching skips some questions.
        let questions = assignment.survey.questions.filter { $0.type != "header" && $0.type != "footer" }.sorted { $0.index < $1.index }
        datesStack.isHidden = question.type != "header"
        surveyDetailLabel.isHidden = question.type == "header"
        if question.type == "header" {
            surveyProgressLabel.text = String(format: NSLocalizedString("survey_start_count", comment: ""), questions.count)
            func dateText(_ value: String) -> String {
                guard let date = DateParser.getDate(dateString: value) else { return NSLocalizedString("date_unspecified", comment: "") }
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
            }
            publishedValueLabel.text = dateText(assignment.published)
            expiryValueLabel.text = dateText(assignment.expiry)
        } else if question.type == "footer" {
            surveyProgressLabel.text = NSLocalizedString("survey_review", comment: "")
            surveyDetailLabel.text = String(format: NSLocalizedString("survey_total_count", comment: ""), questions.count)
        } else {
            let position = (questions.firstIndex { $0.index == question.index } ?? 0) + 1
            surveyProgressLabel.text = String(format: NSLocalizedString("survey_progress", comment: ""), position, questions.count)
            surveyDetailLabel.text = KirokunTheme.inputDescription(for: question.type)
        }
        view.layoutIfNeeded()
    }

    func showPage(newPage : Question)
    {
        print("showPage index: \(newPage.index)")
        var theQuestion = Question()
        for ques in theAssignment!.survey.questions {
            if ques.index == newPage.index{
                theQuestion = ques
            }
        }
        // STÄDA BORT CURRENT
        if(currentPage.type == Type.header.rawValue)
        {
            header!.willMove(toParent: nil)
            header!.view.removeFromSuperview()
            header!.removeFromParent()
        }
        if(currentPage.type == Type.likertScales.rawValue)
        {
            likertScale!.willMove(toParent: nil)
            likertScale!.view.removeFromSuperview()
            likertScale!.removeFromParent()
        }
        if(currentPage.type == Type.fillInTheBlank.rawValue)
        {
            fillInTheBlank!.willMove(toParent: nil)
            fillInTheBlank!.view.removeFromSuperview()
            fillInTheBlank!.removeFromParent()
        }
        if(currentPage.type == Type.multipleChoice.rawValue)
        {
            multipleChoice!.willMove(toParent: nil)
            multipleChoice!.view.removeFromSuperview()
            multipleChoice!.removeFromParent()
        }
        if(currentPage.type == Type.singleMultipleAnswers.rawValue)
        {
            singleMultipleAnswers!.willMove(toParent: nil)
            singleMultipleAnswers!.view.removeFromSuperview()
            singleMultipleAnswers!.removeFromParent()
        }
        if(currentPage.type == Type.sliderScale.rawValue)
        {
            sliderScale!.willMove(toParent: nil)
            sliderScale!.view.removeFromSuperview()
            sliderScale!.removeFromParent()
        }
        if(currentPage.type == Type.openEndedTextResponses.rawValue)
        {
            openEndedTextResponses!.willMove(toParent: nil)
            openEndedTextResponses!.view.removeFromSuperview()
            openEndedTextResponses!.removeFromParent()
        }
        if(currentPage.type == Type.timeDuration.rawValue)
        {
            timeDuration!.willMove(toParent: nil)
            timeDuration!.view.removeFromSuperview()
            timeDuration!.removeFromParent()
        }
        if(currentPage.type == Type.footer.rawValue)
        {
            footer!.willMove(toParent: nil)
            footer!.view.removeFromSuperview()
            footer!.removeFromParent()
        }
        currentPage = newPage
        updateSurveyHeaders(for: theQuestion)
        
        
        if(currentPage.type == Type.header.rawValue)
        {
            self.addChild(header!)
            surveyContainer.addSubview(header!.view)
            header!.view.frame = surveyContainer.bounds
            header!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            header!.didMove(toParent: self)
            header!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.likertScales.rawValue)
        {
            self.addChild(likertScale!)
            surveyContainer.addSubview(likertScale!.view)
            likertScale!.view.frame = surveyContainer.bounds
            likertScale!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            likertScale!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                likertScale!.theAnswer = theAnswer.value
            }
            //likertScale!.theAnswer = theAssignment!.dataset?.answers.first(where: {$0.index == currentPage.index})
            likertScale!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.fillInTheBlank.rawValue)
        {
            self.addChild(fillInTheBlank!)
            surveyContainer.addSubview(fillInTheBlank!.view)
            fillInTheBlank!.view.frame = surveyContainer.bounds
            fillInTheBlank!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            fillInTheBlank!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                fillInTheBlank!.theAnswer = theAnswer.value
            }
            //fillInTheBlank!.theAnswer = theAssignment!.dataset?.answers.first(where: {$0.index == currentPage.index})
            fillInTheBlank!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.multipleChoice.rawValue)
        {
            self.addChild(multipleChoice!)
            surveyContainer.addSubview(multipleChoice!.view)
            multipleChoice!.view.frame = surveyContainer.bounds
            multipleChoice!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            multipleChoice!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                multipleChoice!.theAnswer = theAnswer.value
            }
            //multipleChoice!.theAnswer = theAssignment!.dataset?.answers.first(where: {$0.index == currentPage.index})
            multipleChoice!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.singleMultipleAnswers.rawValue)
        {
            self.addChild(singleMultipleAnswers!)
            surveyContainer.addSubview(singleMultipleAnswers!.view)
            singleMultipleAnswers!.view.frame = surveyContainer.bounds
            singleMultipleAnswers!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            singleMultipleAnswers!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                singleMultipleAnswers!.theAnswer = theAnswer.value
            }
            singleMultipleAnswers!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.sliderScale.rawValue)
        {
            self.addChild(sliderScale!)
            surveyContainer.addSubview(sliderScale!.view)
            sliderScale!.view.frame = surveyContainer.bounds
            sliderScale!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            sliderScale!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                sliderScale!.theAnswer = theAnswer.value
            }
            sliderScale!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.openEndedTextResponses.rawValue)
        {
            self.addChild(openEndedTextResponses!)
            surveyContainer.addSubview(openEndedTextResponses!.view)
            openEndedTextResponses!.view.frame = surveyContainer.bounds
            openEndedTextResponses!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            openEndedTextResponses!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                openEndedTextResponses!.theAnswer = theAnswer.value
            }
            openEndedTextResponses!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.timeDuration.rawValue)
        {
            self.addChild(timeDuration!)
            surveyContainer.addSubview(timeDuration!.view)
            timeDuration!.view.frame = surveyContainer.bounds
            timeDuration!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            timeDuration!.didMove(toParent: self)
            if let theAnswer = answer.first(where: { $0.value.index == currentPage.index}){
                timeDuration!.theAnswer = theAnswer.value
            }
            timeDuration!.setInfo(question: theQuestion)
        }
        if(currentPage.type == Type.footer.rawValue)
        {
            self.addChild(footer!)
            surveyContainer.addSubview(footer!.view)
            footer!.view.frame = surveyContainer.bounds
            footer!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            footer!.didMove(toParent: self)
            footer!.setInfo(question: theQuestion)
            let submittedQuestions = submissionQuestions()
            footer!.setReview(questions: submittedQuestions, answers: answer)
        }
        children.forEach { KirokunTheme.styleQuestion($0) }
    }
    
    func skipIsExecuted(current: Question) -> Question?{
        if let skip = current.skip{
            // skip if ifChosen is -1 regardless of answer...
            if skip.ifChosen == -1 {
                return theAssignment?.survey.questions.first(where: { $0.index == skip.goto})
            }
            if let answerObj = answer.first(where: { $0.value.index == current.index}){
                let answer = answerObj.value
                switch current.type {
                case "likert":
                    if skip.ifChosen == answer.likertAnswer{
                        return theAssignment?.survey.questions.first(where: { $0.index == skip.goto})
                    }else{
                        return nil
                    }
                case "single":
                    if skip.ifChosen == answer.singleMultipleAnswer{
                        return theAssignment?.survey.questions.first(where: { $0.index == skip.goto})
                    }else{
                        return nil
                    }
                case "blanks":
                    if skip.ifChosen == answer.fillBlankAnswer{
                        return theAssignment?.survey.questions.first(where: { $0.index == skip.goto})
                    }else{
                        return nil
                    }
                case "multi":
                    if answer.multipleChoiceAnswer?.contains(skip.ifChosen) ?? false{
                        return theAssignment?.survey.questions.first(where: { $0.index == skip.goto})
                    }else{
                        return nil
                    }
                default:
                    return nil
                }
            }
        }
        return nil
    }
    
    func deleteAnswerFor(question: Question){
        let ind = self.answer.index(forKey: question.index)
        if ind != nil{
            self.answer.remove(at: ind!)
        }
    }
    
    func checkNext(current: Question){
        
        /*
         [
            "includeIf": {
                "ifIndex": 25,
                "ifValue": 1
            },
            "includeIf": {
                "ifIndex": 25,
                "ifValue": 1
            }
         ]
         */
        
        if current.index + 1 < theAssignment!.survey.questions.count{
            let next = theAssignment!.survey.questions[current.index + 1]
            var showNext = false
            if next.includeIf != nil{
                let includeIfIndexQuestion = theAssignment!.survey.questions[next.includeIf!.ifIndex]
                if next.includeIf!.ifIndex == includeIfIndexQuestion.index{
                    let answer = self.answer[includeIfIndexQuestion.index] ?? Answer(type: includeIfIndexQuestion.type, index: includeIfIndexQuestion.index)
                    switch includeIfIndexQuestion.type {
                    case "likert":
                        if next.includeIf?.ifValue ?? -99 == answer.likertAnswer{
                            showNext = true
                        }
                    case "single":
                        if next.includeIf?.ifValue ?? -99 == answer.singleMultipleAnswer{
                            showNext = true
                        }
                    case "blanks":
                        if next.includeIf?.ifValue ?? -99 == answer.fillBlankAnswer{
                            showNext = true
                        }
                    case "multi":
                        if (answer.multipleChoiceAnswer ?? []).contains(next.includeIf?.ifValue ?? -99){
                            showNext = true
                        }
                    default:
                        showNext = true
                    }
                }else{
                    //next includeIf:ifIndex is not current index - show next
                    showNext = true
                }
            }else{
                //next does not hanve includeIf - show next
                showNext = true
            }
            if showNext{
                next.previous = currentPage.index
                showPage(newPage: next)
            }else{
                // dont show next - check following question
                deleteAnswerFor(question: next)
                checkNext(current: next)
            }
        }else if current.index + 1 == theAssignment!.survey.questions.count{
            //next is last (footer) - dont check, show direct
            if theAssignment!.survey.questions.count > current.index + 1{
                theAssignment!.survey.questions[current.index + 1].previous = currentPage.index
                showPage(newPage: theAssignment!.survey.questions[current.index + 1])
            }
        }
    }
}

//MARK:- QuestionListener
extension SurveyViewController: QuestionListener{
    
    func setSliderAnswer(selected: Int, naButton: Bool) {
        var theValue = selected
        if naButton {
            theValue = -1
        }
        answer[currentPage.index] = Answer(
            type: Type.sliderScale.rawValue,
            index: currentPage.index,
            likertAnswer: nil,
            fillBlankAnswer: nil,
            multipleChoiceAnswer: nil,
            singleMultipleAnswer: nil,
            openEndedAnswer: nil,
            timeDurationAnswer: nil,
            sliderScaleAnswer: theValue)
    }
    
    
    
    func setOpenEndedAnswer(text: String) {
        answer[currentPage.index] = Answer(
            type: "open",
            index: currentPage.index,
            likertAnswer: nil,
            fillBlankAnswer: nil,
            multipleChoiceAnswer: nil,
            singleMultipleAnswer: nil,
            openEndedAnswer: text,
            timeDurationAnswer: nil,
            sliderScaleAnswer: nil)
    }
    
    func setFillBlankAnswer(selected: Int) {
        answer[currentPage.index] = Answer(
            type: "blanks",
            index: currentPage.index,
            likertAnswer: nil,
            fillBlankAnswer: selected,
            multipleChoiceAnswer: nil,
            singleMultipleAnswer: nil,
            openEndedAnswer: nil,
            timeDurationAnswer: nil,
            sliderScaleAnswer: nil)
    }
    
    func setLikertAnswer(selected: Int) {
        answer[currentPage.index] = Answer(
            type: "likert",
            index: currentPage.index,
            likertAnswer: selected,
            fillBlankAnswer: nil,
            multipleChoiceAnswer: nil,
            singleMultipleAnswer: nil,
            openEndedAnswer: nil,
            timeDurationAnswer: nil,
            sliderScaleAnswer: nil)
    }
    
    func setMultipleAnswersAnswer(selected: [Int]) {
        answer[currentPage.index] = Answer(
            type: "multi",
            index: currentPage.index,
            likertAnswer: nil,
            fillBlankAnswer: nil,
            multipleChoiceAnswer: selected,
            singleMultipleAnswer: nil,
            openEndedAnswer: nil,
            timeDurationAnswer: nil,
            sliderScaleAnswer: nil)
    }
    
    
    func setSingleMultipleAnswer(selected: Int) {
        answer[currentPage.index] = Answer(
            type: "single",
            index: currentPage.index,
            likertAnswer: nil,
            fillBlankAnswer: nil,
            multipleChoiceAnswer: nil,
            singleMultipleAnswer: selected,
            openEndedAnswer: nil,
            timeDurationAnswer: nil,
            sliderScaleAnswer: nil)
    }
    
    func setTimeDurationAnswer(selected: Int) {
        answer[currentPage.index] = Answer(
            type: "duration",
            index: currentPage.index,
            likertAnswer: nil,
            fillBlankAnswer: nil,
            multipleChoiceAnswer: nil,
            singleMultipleAnswer: nil,
            openEndedAnswer: nil,
            timeDurationAnswer: selected,
            sliderScaleAnswer: nil)
    }
    
    
    func closeSurvey() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // The preview and payload must use the same branch path; answers from abandoned
    // branches must not appear in the preview or be sent.
    private func submissionQuestions() -> [Question] {
        guard let questions = theAssignment?.survey.questions else { return [] }
        var index = questions.max(by: { $0.index < $1.index })?.index ?? 0
        var visited = Set<Int>()
        var included: [Question] = []
        while index > 0, visited.insert(index).inserted,
              let question = questions.first(where: { $0.index == index }) {
            if question.type != "header" && question.type != "footer", answer[index] != nil { included.append(question) }
            index = question.previous ?? 0
        }
        return included.sorted { $0.index < $1.index }
    }

    func sendInSurvey() {
        #if KIROKUN_DEV && DEBUG && targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("--layout-preview") {
            let alert = UIAlertController(title: "表示テスト完了", message: "この回答は端末内の確認用です。サーバーへは送信していません。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        #endif
        if !answer.isEmpty{
            
            // check if expired
            if theAssignment!.timeLeftToExpiryInMilli() == 0 && inTestMode == false{
                //expired - show popup
                DispatchQueue.main.async {
                    let date = DateParser.displayString(for: DateParser.getDate(dateString: self.theAssignment!.expiry)!)
                    let popup = UIAlertController(title: translatedSurveyExpired, message: "\n\(date)", preferredStyle: .alert)
                    popup.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(popup, animated: true, completion: nil)
                }
            }else{
                //not expired (or in test mode) - send in answers
                var tempAnswers = [Int: Answer]()
                for question in submissionQuestions() { tempAnswers[question.index] = answer[question.index] }
                #if KIROKUN_DEV
                guard !sending else { return }
                sending = true
                view.isUserInteractionEnabled = false
                isModalInPresentation = true
                let progress = UIAlertController(title: NSLocalizedString("dev_sending", comment: ""), message: nil, preferredStyle: .alert)
                present(progress, animated: true)
                guard let user = Auth.auth().currentUser else { sending = false; view.isUserInteractionEnabled = true; isModalInPresentation = false; progress.dismiss(animated: true); return }
                user.getIDTokenForcingRefresh(false) { [weak self] token, error in
                    guard let self = self else { return }
                    let finish: (Bool) -> Void = { success in
                        DispatchQueue.main.async {
                            self.sending = false; self.view.isUserInteractionEnabled = true; self.isModalInPresentation = false
                            progress.dismiss(animated: true) {
                                if success { self.dismiss(animated: true) { self.onSaved?() } }
                                else {
                                    let alert = UIAlertController(title: NSLocalizedString("dev_save_failed", comment: ""), message: NSLocalizedString("dev_answers_retained", comment: ""), preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default)); self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                    guard let token = token, error == nil else { finish(false); return }
                    SurveyRepository.idToken = token
                    SurveyRepository.postAnswer(answerDict: tempAnswers, completion: finish)
                }
                #else
                SurveyRepository.postAnswer(answerDict: tempAnswers)
                self.dismiss(animated: true, completion: nil)
                #endif
            }
        }
    }
    
    func nextQuestion(current: Question) {
        if theAssignment != nil{
            theAssignment!.survey.questions.sort(by: {$0.index < $1.index})
            if let skipGoToQuestion = skipIsExecuted(current: current){
                skipGoToQuestion.previous = currentPage.index
                showPage(newPage: skipGoToQuestion)
            }else{
                checkNext(current: current)
            }
        }
    }
    
    func previousQuestion(current: Question) {
        if theAssignment != nil{
            for q in theAssignment!.survey.questions {
                if q.index == current.previous{
                    showPage(newPage: q)
                }
            }
        }
    }
}
