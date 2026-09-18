//
//  UnansweredPopupViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-04-08.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class UnansweredPopupViewController: UIViewController {
    
    
    @IBOutlet weak var popupContainer: UIView!
    @IBOutlet weak var expiredLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var numberQuestionsLabel: UILabel!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundClickRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backgroundClicked))
        backgroundView.addGestureRecognizer(backgroundClickRecognizer)
        KirokunTheme.styleModalHeader(popupContainer)
        KirokunTheme.alignMetadataValues([numberQuestionsLabel, publishedLabel, expiredLabel], in: popupContainer)
        popupContainer.layer.cornerRadius = 24
        popupContainer.clipsToBounds = true
        if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled {
            let glass = UIGlassEffect(style: .regular)
            glass.tintColor = KirokunTheme.brand
            let effect = UIVisualEffectView(effect: glass)
            effect.frame = popupContainer.bounds
            effect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effect.isUserInteractionEnabled = false
            popupContainer.insertSubview(effect, at: 0)
        }
        popupContainer.layer.borderWidth = 2
        popupContainer.layer.borderColor = UIColor.white.cgColor
        
        if let current = SurveyRepository.selectedAssignment{
            popupTitle.text = current.survey.title
            publishedLabel.text = DateParser.displayString(for: DateParser.getDate(dateString: current.published)!)
            expiredLabel.text = DateParser.displayString(for: DateParser.getDate(dateString: current.expiry)!)
            numberQuestionsLabel.text = "\(current.survey.questions.filter { $0.type != "header" && $0.type != "footer" }.count) \(translatedNumberEnding)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        showAnimate()
    }
    
    func showAnimate(){
        self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.alpha = 1.0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func backgroundClicked(sender: UITapGestureRecognizer){
        removeAnimate()
    }
    
    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion:{(finished: Bool) in
            if(finished){
                self.view.removeFromSuperview()
            }
        })
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        removeAnimate()
    }
}
