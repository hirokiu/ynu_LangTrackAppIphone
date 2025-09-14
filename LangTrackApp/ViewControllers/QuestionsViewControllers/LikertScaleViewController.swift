//
//  LikertScaleViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class LikertScaleViewController: UIViewController {
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var radioButton1: LikertRadioButton!
    @IBOutlet weak var radioButton2: LikertRadioButton!
    @IBOutlet weak var radioButton3: LikertRadioButton!
    @IBOutlet weak var radioButton4: LikertRadioButton!
    @IBOutlet weak var radioButton5: LikertRadioButton!
//    @IBOutlet weak var radioButtonNA: LikertRadioButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likertTextLabel: UILabel!
    @IBOutlet weak var radioButtonContainer: UIView!
    @IBOutlet weak var likertContainer: UIView!
    @IBOutlet weak var theIcon: UIImageView!
    @IBOutlet weak var likertMinLabel: UILabel!
    @IBOutlet weak var likertMaxLabel: UILabel!
    
    
    
    var listener: QuestionListener?
    var theQuestion = Question()
    var theAnswer: Answer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 8
        theIcon.clipsToBounds = false
        theIcon.setSmallViewShadow()
    }
    
    func setInfo(question: Question){
        setSelected(selected: -99)
        self.theQuestion = question
        likertTextLabel.text = theQuestion.text
        descriptionLabel.text = ""//theQuestion.description
        likertMaxLabel.text = theQuestion.likertMax
        likertMinLabel.text = theQuestion.likertMin
        nextButton.setEnabled(enabled: false)
        if theAnswer != nil {
            if theAnswer!.likertAnswer != nil{
                if theAnswer?.index == theQuestion.index{
                    setSelected(selected: theAnswer!.likertAnswer ?? 10)
                    nextButton.setEnabled(enabled: true)
                }
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func setSelected(selected: Int){
        switch selected {
        case 0:
            radioButton1.isSelected = true
            radioButton2.isSelected = false
            radioButton3.isSelected = false
            radioButton4.isSelected = false
            radioButton5.isSelected = false
//            radioButtonNA.isSelected = false
        case 1:
            radioButton1.isSelected = false
            radioButton2.isSelected = true
            radioButton3.isSelected = false
            radioButton4.isSelected = false
            radioButton5.isSelected = false
//            radioButtonNA.isSelected = false
        case 2:
            radioButton1.isSelected = false
            radioButton2.isSelected = false
            radioButton3.isSelected = true
            radioButton4.isSelected = false
            radioButton5.isSelected = false
//            radioButtonNA.isSelected = false
        case 3:
            radioButton1.isSelected = false
            radioButton2.isSelected = false
            radioButton3.isSelected = false
            radioButton4.isSelected = true
            radioButton5.isSelected = false
//            radioButtonNA.isSelected = false
        case 4:
            radioButton1.isSelected = false
            radioButton2.isSelected = false
            radioButton3.isSelected = false
            radioButton4.isSelected = false
            radioButton5.isSelected = true
//            radioButtonNA.isSelected = false
        case 5:
            radioButton1.isSelected = false
            radioButton2.isSelected = false
            radioButton3.isSelected = false
            radioButton4.isSelected = false
            radioButton5.isSelected = false
//            radioButtonNA.isSelected = true
        default:
            radioButton1.isSelected = false
            radioButton2.isSelected = false
            radioButton3.isSelected = false
            radioButton4.isSelected = false
            radioButton5.isSelected = false
//            radioButtonNA.isSelected = false
            print("likert setSelected: \(selected)")
        }
    }
    
    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    
    func deselectAllRadiobuttons(){
        radioButton1.isSelected = false
        radioButton2.isSelected = false
        radioButton3.isSelected = false
        radioButton4.isSelected = false
        radioButton5.isSelected = false
//        radioButtonNA.isSelected = false
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        listener?.previousQuestion(current: theQuestion)
        theAnswer = nil
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        listener?.nextQuestion(current: theQuestion)
        theAnswer = nil
    }
    
    @IBAction func likertButtonPressed(_ sender: LikertRadioButton) {
        deselectAllRadiobuttons()
        sender.isSelected = !sender.isSelected
        nextButton.setEnabled(enabled: true)
        listener?.setLikertAnswer(selected: sender.tag)
    }
}
