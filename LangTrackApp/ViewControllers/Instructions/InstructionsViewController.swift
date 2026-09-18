//
//  InstructionsViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-05-25.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    
    @IBOutlet weak var dataTextView: UITextView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var theScrollview: UIScrollView!
    
    var showingTopShadow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = KirokunTheme.action
        KirokunTheme.styleModalHeader(topView)

        
        instructionsView.layer.cornerRadius = 12
        instructionsView.setLargeViewShadow()
        dataView.layer.cornerRadius = 12
        dataView.setLargeViewShadow()
        
        theScrollview.delegate = self
        
        instructionsTitleLabel.text = translatedInstructions
        setInstructionsText()
        setDataText()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 5{
            if showingTopShadow == false{
                topView.setLargeViewShadow()
                showingTopShadow = true
            }
        }else{
            if showingTopShadow == true{
                topView.removeShadow()
                showingTopShadow = false
            }
        }
    }
    
    func setInstructionsText(){
        
        let finalString = NSAttributedString(string: translatedInstructionsText1, attributes: attributeLtaBlueText)
        instructionsTextView.attributedText = finalString
    }
    
    
    func setDataText(){
        
        let finalString = NSMutableAttributedString(string: "\(translatedDataHeader)\n\n", attributes: attributeLtaBlueHeaderText)
        finalString.append(NSAttributedString(string: translatedDataProcessing, attributes: attributeLtaBlueText))
        
        dataTextView.attributedText = finalString
        
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
