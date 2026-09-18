//
//  SuerveyTableViewCell.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-31.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class SurveyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var answeredIndicator: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var surveyBackground: UIView!
    @IBOutlet weak var surveyTitle: UILabel!
    @IBOutlet weak var answeredLabel: UILabel!
    
    let dateformat = "yyyy-MM-dd HH:mm"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func applyRowTheme(index: Int, answered: Bool) {
        let background = KirokunTheme.rowBackground(index)
        backgroundColor = background; contentView.backgroundColor = background; surveyBackground.backgroundColor = background
        let foreground: UIColor = answered ? KirokunTheme.answeredText : KirokunTheme.action
        surveyTitle.textColor = foreground; answeredLabel.textColor = foreground
        surveyTitle.font = .systemFont(ofSize: 17, weight: answered ? .regular : .semibold)
        dateLabel.textColor = KirokunTheme.answeredText
        answeredIndicator.backgroundColor = answered ? .secondaryLabel : KirokunTheme.brand
    }

    func setSurveyInfo(assignment: Assignment)  {
        answeredIndicator.layer.cornerRadius = 5
        surveyTitle.text = assignment.survey.title
        surveyTitle.textColor = KirokunTheme.action
        //dateLabel.text = DateParser.getLocalTime(date: DateParser.getDate(dateString: assignment.published)!)
        dateLabel.text = DateParser.displayString(for: DateParser.getDate(dateString: assignment.published)!)
        if assignment.dataset == nil{
            answeredLabel.text = translatedUnanswered
            answeredIndicator.backgroundColor = UIColor.init(named: "lta_light_grey") ?? UIColor.lightGray
        }else{
            answeredLabel.text = translatedAnswered
            answeredIndicator.backgroundColor = UIColor.init(named: "lta_green") ?? UIColor.green
        }
    }
}
