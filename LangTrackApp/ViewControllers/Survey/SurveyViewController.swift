//
//  SurveyViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {
    @IBOutlet weak var surveyContainer: UIView!
    
    var answer = [Int:Answer]()
    var theAssignment: Assignment? = nil
    var currentPage = Question()
    var theUser: User?
    var inTestMode = false
    
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
        }
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
    
    func sendInSurvey() {
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
                let tempList = theAssignment!.survey.questions.sorted(by: {$0.index > $1.index})
                var answersToInclude = [Int]()
                //begin with last
                var counter = tempList.first?.index ?? -99
                if counter != -99{
                    while counter > 0 {
                        let currentQuestion = tempList.first(where: { $0.index == counter})
                        if currentQuestion?.type ?? "header" != "header" &&
                            currentQuestion?.type ?? "footer" != "footer"{
                            answersToInclude.append(counter)
                        }
                        counter = currentQuestion?.previous ?? 0
                    }
                }
                var tempAnswers = [Int:Answer]()
                for a in answersToInclude{
                    if let theAnswer = answer.first(where: {$0.value.index == a}){
                        tempAnswers[theAnswer.value.index] = theAnswer.value
                    }
                }
                SurveyRepository.postAnswer(answerDict: tempAnswers)
                self.dismiss(animated: true, completion: nil)
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
