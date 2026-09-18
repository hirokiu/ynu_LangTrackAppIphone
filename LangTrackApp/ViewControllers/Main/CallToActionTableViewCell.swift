//
//  CallToActionTableViewCell.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-03-07.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class CallToActionTableViewCell: UITableViewCell {

    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var callToActionBackgroundView: UIView!
    @IBOutlet weak var callToActionLabel: UILabel!
    @IBOutlet weak var callToActionHeightConstraint: NSLayoutConstraint!
    
    var theSurvey : Survey? = nil
    var theAssignment: Assignment?
    var listener: CellTimerListener? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callToActionBackgroundView.layer.cornerRadius = 15
        callToActionBackgroundView.backgroundColor = KirokunTheme.brand
        callToActionLabel.textColor = .black
        //update label every minute
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setListener(theListener: CellTimerListener){
        self.listener = theListener
    }
    
    @objc func updateCounter() {
        setExpieryTime()
    }
    
    func setExpieryTime(){
        if theAssignment != nil{
            let now = Date()
            let expiary = DateParser.getDate(dateString: theAssignment!.expiry) ?? now
            let millisecondsLeft = expiary.timeIntervalSince(now)//now.distance(to: expiary)
                expiryLabel.text = "\(translatedTimeLeft) \(TimeInterval().stringFromSecondTimeInterval(time: theAssignment!.timeLeftToExpiryInMilli() / 1000 ))"
                if millisecondsLeft <= 0{
                    listener?.timerExpiered()
                }
        }
    }
    
    func applyRowTheme(index: Int) {
        let background = KirokunTheme.rowBackground(index)
        backgroundColor = background; contentView.backgroundColor = background
        callToActionBackgroundView.backgroundColor = background
        callToActionLabel.textColor = KirokunTheme.action
        expiryLabel.textColor = KirokunTheme.action
        callToActionBackgroundView.layer.borderWidth = 1
        callToActionBackgroundView.layer.borderColor = KirokunTheme.brand.cgColor
    }

    func setSurveyInfo(assignment: Assignment, tableviewHeight: CGFloat)  {
        self.callToActionHeightConstraint.constant = tableviewHeight / 3
        callToActionLabel.text = assignment.survey.title + "\n" + NSLocalizedString("survey_ready", comment: "")
        callToActionLabel.numberOfLines = 0
        self.theSurvey = assignment.survey
        self.theAssignment = assignment
        setExpieryTime()
    }

}
