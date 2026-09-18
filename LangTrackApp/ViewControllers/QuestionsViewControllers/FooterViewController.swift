//
//  FooterViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class FooterViewController: UIViewController {

    @IBOutlet weak var sendInButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var theIcon: UIImageView!
    
    var listener: QuestionListener?
    var theQuestion = Question()
    private let reviewScroll = UIScrollView()
    private let reviewStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if KIROKUN_DEV
        sendInButton.backgroundColor = .clear
        sendInButton.configuration = KirokunTheme.primaryButton(title: sendInButton.currentTitle ?? "")
        previousButton.tintColor = KirokunTheme.action
        #endif
        previousButton.layer.cornerRadius = 8
        sendInButton.layer.cornerRadius = 8
        theIcon.clipsToBounds = false
        theIcon.setSmallViewShadow()
        theIcon.isHidden = true; tempLabel.isHidden = true
        reviewScroll.translatesAutoresizingMaskIntoConstraints = false
        reviewStack.axis = .vertical; reviewStack.spacing = 16
        reviewStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reviewScroll); reviewScroll.addSubview(reviewStack)
        NSLayoutConstraint.activate([
            reviewScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            reviewScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            reviewScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            reviewScroll.bottomAnchor.constraint(equalTo: sendInButton.topAnchor, constant: -16),
            reviewStack.topAnchor.constraint(equalTo: reviewScroll.contentLayoutGuide.topAnchor),
            reviewStack.bottomAnchor.constraint(equalTo: reviewScroll.contentLayoutGuide.bottomAnchor, constant: -12),
            reviewStack.leadingAnchor.constraint(equalTo: reviewScroll.contentLayoutGuide.leadingAnchor),
            reviewStack.trailingAnchor.constraint(equalTo: reviewScroll.contentLayoutGuide.trailingAnchor),
            reviewStack.widthAnchor.constraint(equalTo: reviewScroll.frameLayoutGuide.widthAnchor)
        ])
    }
    
    func setInfo(question: Question){
        self.theQuestion = question
        tempLabel.text = theQuestion.text
        sendInButton.setTitle(NSLocalizedString("submit_answers", comment: ""), for: .normal)
    }
    
    func setReview(questions: [Question], answers: [Int: Answer]) {
        reviewStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let intro = UILabel(); intro.numberOfLines = 0
        intro.text = NSLocalizedString("review_before_submit", comment: "")
        intro.font = .preferredFont(forTextStyle: .body)
        reviewStack.addArrangedSubview(intro)
        for (position, question) in questions.enumerated() {
            let title = UILabel(); title.numberOfLines = 0
            title.font = .preferredFont(forTextStyle: .headline)
            title.text = "\(position + 1). " + (question.text.isEmpty ? question.title : question.text)
            let value = UILabel(); value.numberOfLines = 0
            value.font = .preferredFont(forTextStyle: .body)
            value.textColor = KirokunTheme.action
            value.text = Self.answerText(question: question, answer: answers[question.index])
            let card = UIStackView(arrangedSubviews: [title, value])
            card.axis = .vertical; card.spacing = 8
            card.isLayoutMarginsRelativeArrangement = true
            card.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
            card.backgroundColor = KirokunTheme.rowBackground(position + 1)
            card.layer.cornerRadius = 12
            reviewStack.addArrangedSubview(card)
        }
        reviewScroll.setContentOffset(.zero, animated: false)
        sendInButton.isEnabled = !questions.isEmpty
    }

    static func answerText(question: Question, answer: Answer?) -> String {
        let missing = NSLocalizedString("review_no_answer", comment: "")
        guard let answer = answer else { return missing }
        func option(_ options: [String]?, _ index: Int?) -> String {
            guard let index = index, let options = options, options.indices.contains(index) else { return missing }
            return options[index]
        }
        switch question.type {
        case "open": return (answer.openEndedAnswer?.isEmpty == false) ? answer.openEndedAnswer! : NSLocalizedString("review_empty_text", comment: "")
        case "likert":
            guard let value = answer.likertAnswer else { return missing }
            return (0...4).contains(value) ? "\(value + 1) / 5" : NSLocalizedString("review_na", comment: "")
        case "single": return option(question.singleMultipleAnswers, answer.singleMultipleAnswer)
        case "multi": return answer.multipleChoiceAnswer?.sorted().map { option(question.multipleChoisesAnswers, $0) }.joined(separator: "、") ?? missing
        case "blanks": return option(question.fillBlanksChoises, answer.fillBlankAnswer)
        case "slider":
            guard let value = answer.sliderScaleAnswer else { return missing }
            return value < 0 ? NSLocalizedString("review_na", comment: "") : "\(value) / 100"
        case "duration":
            guard let seconds = answer.timeDurationAnswer else { return missing }
            return String(format: NSLocalizedString("review_duration", comment: ""), seconds / 3600, (seconds % 3600) / 60)
        default: return missing
        }
    }

    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        listener?.previousQuestion(current: theQuestion)
    }
    
    @IBAction func sendInButtonPressed(_ sender: Any) {
        listener?.sendInSurvey()
    }
    
}
