//
//  OpenEndedTextResponsesViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class OpenEndedTextResponsesViewController: UIViewController {

    @IBOutlet weak var theIcon: UIImageView!
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var openTextLabel: UILabel!
    @IBOutlet weak var openTextView: UITextView!
    
    var listener: QuestionListener?
    var theQuestion = Question()
    var theAnswer: Answer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 8
        theIcon.clipsToBounds = false
        theIcon.setSmallViewShadow()
        openTextView.layer.cornerRadius = 8
        openTextView.layer.borderWidth = 1
        openTextView.addDoneButton(title: "OK", target: self, selector: #selector(tapDone(sender:)))
    }
    
    func setInfo(question: Question){
        self.theQuestion = question
        openTextLabel.text = theQuestion.text
        if theAnswer?.openEndedAnswer != nil{
            if theAnswer?.index == theQuestion.index{
                if theAnswer?.index == theQuestion.index{
                    openTextView.text = theAnswer?.openEndedAnswer
                }
            }
        }else{
            openTextView.text = ""
        }
    }
    
    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    
    func saveAnswer(){
        listener?.setOpenEndedAnswer(text: openTextView.text)
    }
    
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        saveAnswer()
        listener?.previousQuestion(current: theQuestion)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        saveAnswer()
        listener?.nextQuestion(current: theQuestion)
    }
    
}
