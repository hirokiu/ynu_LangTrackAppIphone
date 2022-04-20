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

    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var contactsTextView: UITextView!
    
    @IBOutlet weak var linksTextView: UITextView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var theScrollview: UIScrollView!
    
    var showingTopShadow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        linkView.layer.cornerRadius = 12
        linkView.setLargeViewShadow()
        view2.layer.cornerRadius = 12
        view2.setLargeViewShadow()
        contactsTextView.delegate = self
        theScrollview.delegate = self
        
        setContactText()
        setLinkText()
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
        SurveyRepository.getContactInfo { contactInfo in
            
            let languageCode = UIApplication.getLanguageCode()
            let theHeader = ""
            let finalString = NSMutableAttributedString(string: theHeader, attributes: attributeLtaBlueHeaderText)
            if let contactInfo = contactInfo{
                for (i,contact) in contactInfo{
                    let email = i
                    var listWithLanguages : [String:String] = [:]
                    for language in contact{
                        listWithLanguages[language.key] = language.value
                    }
                    let contactInfo = listWithLanguages[languageCode] ?? "noInfo"
                    let contactInfoText = "\(contactInfo)\n"
                    let attrcontactInfoText = NSMutableAttributedString(string: contactInfoText, attributes: attributeLtaBlueText)
                    finalString.append(attrcontactInfoText)
                    
                    let reserchLink = email
                    let myreserchRange = NSRange(location: 0, length: reserchLink.count)
                    let attrreserchText2 = NSMutableAttributedString(string: reserchLink, attributes: attributeLtaBlueText)
                    attrreserchText2.addAttribute(NSAttributedString.Key.link,
                                                  value: "tech",
                                                  range: myreserchRange)
                    finalString.append(attrreserchText2)
                    if #available(iOS 15, *) {
                        finalString.append(NSAttributedString("\n\n"))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                self.contactsTextView.attributedText = finalString
            }else{
                self.contactsTextView.attributedText = NSAttributedString()
                self.showToast(message: "Unable to retrieve contact information, check internet connection!", font: UIFont.systemFont(ofSize: 17))
            }
        }
        
        
        
        
        /*
        let techText3 = "\n\n\(translatedTechText1)\n"
        let attrtechText3 = NSMutableAttributedString(string: techText3, attributes: attributeLtaBlueText)
        finalString.append(attrtechText3)
        
        let techLink = "henriette.arndt@humlab.lu.se"
        let mytechRange = NSRange(location: 0, length: techLink.count)
        let attrtechText2 = NSMutableAttributedString(string: techLink, attributes: attributeLtaBlueText)
        attrtechText2.addAttribute(NSAttributedString.Key.link,
                                      value: "reserch",
                                      range: mytechRange)
        finalString.append(attrtechText2)*/
        
    }
    
    
    /*func setContactText(){
        
        
        
        let theHeader = ""
        let finalString = NSMutableAttributedString(string: theHeader, attributes: attributeLtaBlueHeaderText)
        
        let contactInfoText = "\(translatedReserchText1)\n"
        let attrcontactInfoText = NSMutableAttributedString(string: contactInfoText, attributes: attributeLtaBlueText)
        finalString.append(attrcontactInfoText)
        
        let reserchLink = "stephan.bjorck@humlab.lu.se"
        let myreserchRange = NSRange(location: 0, length: reserchLink.count)
        let attrreserchText2 = NSMutableAttributedString(string: reserchLink, attributes: attributeLtaBlueText)
        attrreserchText2.addAttribute(NSAttributedString.Key.link,
                                      value: "tech",
                                      range: myreserchRange)
        finalString.append(attrreserchText2)
        
        let techText3 = "\n\n\(translatedTechText1)\n"
        let attrtechText3 = NSMutableAttributedString(string: techText3, attributes: attributeLtaBlueText)
        finalString.append(attrtechText3)
        
        let techLink = "henriette.arndt@humlab.lu.se"
        let mytechRange = NSRange(location: 0, length: techLink.count)
        let attrtechText2 = NSMutableAttributedString(string: techLink, attributes: attributeLtaBlueText)
        attrtechText2.addAttribute(NSAttributedString.Key.link,
                                      value: "reserch",
                                      range: mytechRange)
        finalString.append(attrtechText2)
        
        contactsTextView.attributedText = finalString
    }*/
    
    func setLinkText(){
        let theHeader = "\(translatedLinks)\n\n"
        let finalString = NSMutableAttributedString(string: theHeader, attributes: attributeLtaBlueHeaderText)
        
        let linkText1 = "\(translatedLangTrackAppProject)\n\n"
        let attrText1 = NSMutableAttributedString(string: linkText1, attributes: attributeLtaBlueText)
        let myRange = NSRange(location: 0, length: attrText1.length)
        attrText1.addAttributes([NSAttributedString.Key.link: URL(string: "https://portal.research.lu.se/portal/en/projects/the-langtrackapp-studying-exposure-to-and-use-of-a-new-language-using-smartphone-technology(4e734940-981f-4dd0-841a-eb6ac760af0c).html")!], range: myRange)
        finalString.append(attrText1)
        
        let linkText2 = "\(translatedLundUniversityHumanitiesLab)\n\n"
        let attrText2 = NSMutableAttributedString(string: linkText2, attributes: attributeLtaBlueText)
        let myRange2 = NSRange(location: 0, length: attrText2.length)
        attrText2.addAttributes([NSAttributedString.Key.link: URL(string: "https://www.humlab.lu.se")!], range: myRange2)
        finalString.append(attrText2)
        
        let linkText3 = translatedLundUniversity
        let attrText3 = NSMutableAttributedString(string: linkText3, attributes: attributeLtaBlueText)
        let myRange3 = NSRange(location: 0, length: attrText3.length)
        attrText3.addAttributes([NSAttributedString.Key.link: URL(string: "https://www.lu.se/")!], range: myRange3)
        finalString.append(attrText3)
        
        linksTextView.attributedText = finalString
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
