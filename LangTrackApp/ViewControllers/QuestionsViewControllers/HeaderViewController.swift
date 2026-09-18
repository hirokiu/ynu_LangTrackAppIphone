//
//  HeaderViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class HeaderViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lu_inageView: UIImageView!
    
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var theUser: User?
    var listener: QuestionListener?
    var theQuestion = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lu_inageView.isHidden = true
        for constraint in lu_inageView.constraints where constraint.firstAttribute == .height { constraint.constant = 0 }
        #if KIROKUN_DEV
        nextButton.backgroundColor = .clear
        nextButton.configuration = KirokunTheme.primaryButton(title: nextButton.currentTitle ?? "")
        closeButton.tintColor = KirokunTheme.action
        #endif
        closeButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 8
    }
    
    func setInfo(question: Question){
        self.theQuestion = question
        userNameLabel.text = ""//"Inloggad som\n\(theUser?.userName ?? "noName")"
        greetingsLabel.text = question.text
        subTitleLabel.text = question.title
    }
    
    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    

    @IBAction func closeButtonPressed(_ sender: Any) {
        listener?.closeSurvey()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        listener?.nextQuestion(current: theQuestion)
    }
    
}
