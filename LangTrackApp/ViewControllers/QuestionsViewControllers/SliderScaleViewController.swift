//
//  SliderScaleViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2021-03-14.
//  Copyright © 2021 Stephan Björck. All rights reserved.
//

import UIKit

class SliderScaleViewController: UIViewController {

    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sliderTextLabel: UILabel!
    @IBOutlet weak var theIcon: UIImageView!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var naButton: LikertRadioButton!
    @IBOutlet weak var theSlider: UISlider!
    
    var listener: QuestionListener?
    var theQuestion = Question()
    var theAnswer: Answer?
    var savedTempAnswer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 8
        theIcon.clipsToBounds = false
        theIcon.setSmallViewShadow()
        maxLabel.text = " "
        theSlider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
    }

    @objc func sliderDidEndSliding() {
        self.listener?.setSliderAnswer(selected: Int(theSlider.value), naButton: false)
    }
    
    func setInfo(question: Question){
        self.theQuestion = question
        descriptionLabel.text = theQuestion.text
        savedTempAnswer = theAnswer?.sliderScaleAnswer ?? 0
        if savedTempAnswer < 0 || savedTempAnswer > 100{
            naButton.isSelected = true
            theSlider.value = Float(0)
            maxLabel.text = " "
        }else{
            naButton.isSelected = false
            theSlider.value = Float(savedTempAnswer)
            maxLabel.text = "\(savedTempAnswer)"
        }
    }
    
    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    
    func setNa(selected: Bool){
        if selected{
            theSlider.value = 0
            maxLabel.text = " "
            theSlider.isEnabled = false
        }else{
            theSlider.value = Float(savedTempAnswer)
            if savedTempAnswer > -1 && savedTempAnswer < 100{
                maxLabel.text = "\(savedTempAnswer)"
            }else{
                maxLabel.text = " "
            }
            theSlider.isEnabled = true
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        maxLabel.text = "\(Int(sender.value))"
        savedTempAnswer = Int(sender.value)
    }
    
    @IBAction func naButtonPressed(_ sender: LikertRadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            setNa(selected: true)
            self.listener?.setSliderAnswer(selected: Int(theSlider.value), naButton: true)
        }else{
            setNa(selected: false)
            self.listener?.setSliderAnswer(selected: Int(theSlider.value), naButton: false)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        listener?.nextQuestion(current: theQuestion)
        theAnswer = nil
        savedTempAnswer = 0
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        listener?.previousQuestion(current: theQuestion)
        theAnswer = nil
        savedTempAnswer = 0
    }
}
