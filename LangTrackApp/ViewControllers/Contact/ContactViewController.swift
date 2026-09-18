//
//  ContactViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-04-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var contactsTextView: UITextView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var theScrollview: UIScrollView!
    
    var showingTopShadow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = KirokunTheme.action
        KirokunTheme.styleModalHeader(topView)

        view2.layer.cornerRadius = 12
        view2.setLargeViewShadow()
        contactsTextView.delegate = self
        theScrollview.delegate = self
        
        setContactText()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 5{
            if showingTopShadow == false{
                topView.setLabelShadow()
                showingTopShadow = true
            }
        }else{
            if showingTopShadow == true{
                topView.removeShadow()
                showingTopShadow = false
            }
        }
    }
    
    func setContactText(){
        let theHeader = ""
        let finalString = NSMutableAttributedString(string: theHeader, attributes: attributeLtaBlueHeaderText)
        
        let contactInfoText = "\(translatedReserchText1)\n"
        let attrcontactInfoText = NSMutableAttributedString(string: contactInfoText, attributes: attributeLtaBlueText)
        finalString.append(attrcontactInfoText)
        
//        let reserchLink = "stephan.bjorck@humlab.lu.se"
        let reserchLink = "ltajapan2024@gmail.com"
        let myreserchRange = NSRange(location: 0, length: reserchLink.count)
        let attrreserchText2 = NSMutableAttributedString(string: reserchLink, attributes: attributeLtaBlueText)
        attrreserchText2.addAttribute(NSAttributedString.Key.link,
                                      value: "research",
                                      range: myreserchRange)
        finalString.append(attrreserchText2)
        
        let techText3 = "\n\n\(translatedTechText1)\n"
        let attrtechText3 = NSMutableAttributedString(string: techText3, attributes: attributeLtaBlueText)
        //finalString.append(attrtechText3)
        
        let techLink = "henriette.arndt@humlab.lu.se"
        let mytechRange = NSRange(location: 0, length: techLink.count)
        let attrtechText2 = NSMutableAttributedString(string: techLink, attributes: attributeLtaBlueText)
        attrtechText2.addAttribute(NSAttributedString.Key.link,
                                      value: "texh",
                                      range: mytechRange)
//        finalString.append(attrtechText2)
        
        contactsTextView.attributedText = finalString
    }
    
    func textView(_ textView: UITextView, shouldInteractWith theURL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if theURL.absoluteString == "tech"{
            // mail to dev
            
            let recipientEmail = "stephan.bjorck@humlab.lu.se"
            let subject = translatedSubject
            //let body = translatedTechBody

            // Show default mail composer
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([recipientEmail])
                mail.setSubject(subject)
                //mail.setMessageBody(body, isHTML: false)

                present(mail, animated: true)

            }else{
                showCantSendMailAlert()
            }
        }else if theURL.absoluteString == "reserch"{
            // mail to Henriette
            
            let recipientEmail = "henriette.arndt@humlab.lu.se"
            let subject = translatedSubject
            // Show default mail composer
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([recipientEmail])
                mail.setSubject(subject)

                present(mail, animated: true)

            }else{
                showCantSendMailAlert()
            }
        }
        return false
    }
    
    func showCantSendMailAlert(){
        let alert = UIAlertController.init(title: translatedCantSendEmailPopupTitle, message: translatedCantSendEmailPopupText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
