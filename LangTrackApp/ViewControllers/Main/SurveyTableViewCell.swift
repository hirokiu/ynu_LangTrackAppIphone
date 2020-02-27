//
//  SuerveyTableViewCell.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-31.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class SurveyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var surveyBackground: UIView!
    @IBOutlet weak var surveyTitle: UILabel!
    @IBOutlet weak var surveyUnansweredIndicator: UIImageView!
    @IBOutlet weak var surveyDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        surveyUnansweredIndicator.layer.cornerRadius = 10
        surveyUnansweredIndicator.layer.borderWidth = 0.5
        surveyBackground.layer.borderWidth = 1.5
        surveyBackground.layer.cornerRadius = 8
        surveyBackground.layer.borderColor = UIColor.init(named: "lta_blue")?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSurveyInfo(survey: Survey)  {
        surveyTitle.text = survey.title
        if (survey.responded ?? false || survey.active ?? false != true) {
            surveyUnansweredIndicator.isHidden = true
            surveyDate.text = "Inaktiv"
            if(survey.responded ?? false){
                surveyDate.text?.append(", besvarad")
            }else{
                surveyDate.text?.append(", obesvarad")
            }
        }else{
            surveyUnansweredIndicator.isHidden = false
            surveyUnansweredIndicator.image = #imageLiteral(resourceName: "lta_icon_ground_light")
            surveyDate.text = "53 minuter kvar"
        }
    }

}
