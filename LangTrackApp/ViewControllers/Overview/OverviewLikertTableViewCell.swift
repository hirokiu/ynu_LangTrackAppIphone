//
//  OverviewLikertTableViewCell.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-04-07.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class OverviewLikertTableViewCell: UITableViewCell {

    @IBOutlet weak var likertButton0: LikertRadioButton!
    @IBOutlet weak var likertButton1: LikertRadioButton!
    @IBOutlet weak var likertButton2: LikertRadioButton!
    @IBOutlet weak var likertButton3: LikertRadioButton!
    @IBOutlet weak var likertButton4: LikertRadioButton!
//    @IBOutlet weak var likertButtonNA: LikertRadioButton!
    //@IBOutlet weak var likert0: UIView!
    //@IBOutlet weak var likert1: UIView!
    //@IBOutlet weak var likert2: UIView!
    //@IBOutlet weak var likert3: UIView!
    //@IBOutlet weak var likert4: UIView!
    //@IBOutlet weak var likertNA: UIView!
    @IBOutlet weak var likertTextLabel: UILabel!
    @IBOutlet weak var likertMinLabel: UILabel!
    @IBOutlet weak var likertMaxLabel: UILabel!
    
    var question: Question?
    var answer : Answer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        /*likert0.layer.cornerRadius = likert0.frame.width / 2
        likert1.layer.cornerRadius = likert1.frame.width / 2
        likert2.layer.cornerRadius = likert2.frame.width / 2
        likert3.layer.cornerRadius = likert3.frame.width / 2
        likert4.layer.cornerRadius = likert4.frame.width / 2
        likertNA.layer.cornerRadius = likertNA.frame.width / 2
        likert0.layer.borderWidth = 0.5
        likert1.layer.borderWidth = 0.5
        likert2.layer.borderWidth = 0.5
        likert3.layer.borderWidth = 0.5
        likert4.layer.borderWidth = 0.5
        likertNA.layer.borderWidth = 0.5
        likert0.backgroundColor = UIColor.white
        likert1.backgroundColor = UIColor.white
        likert2.backgroundColor = UIColor.white
        likert3.backgroundColor = UIColor.white
        likert4.backgroundColor = UIColor.white
        likertNA.backgroundColor = UIColor.white*/
    }
    
    func setValues(item: OverviewListItem?){
        self.question = item?.question
        self.answer = item?.answer
        setLikertScale()
        likertTextLabel.text = question?.text
        likertMinLabel.text = question?.likertMin
        likertMaxLabel.text = question?.likertMax
    }
    
    func setAllUnmarked(){
        likertButton0.isSelected = false
        likertButton1.isSelected = false
        likertButton2.isSelected = false
        likertButton3.isSelected = false
        likertButton4.isSelected = false
//        likertButtonNA.isSelected = false
    }
    
    func setLikertScale(){
        if answer != nil{
            if answer!.likertAnswer != nil{
                switch answer!.likertAnswer! {
                case 0:
                    likertButton0.isSelected = true
                    likertButton1.isSelected = false
                    likertButton2.isSelected = false
                    likertButton3.isSelected = false
                    likertButton4.isSelected = false
//                    likertButtonNA.isSelected = false
                case 1:
                    likertButton0.isSelected = false
                    likertButton1.isSelected = true
                    likertButton2.isSelected = false
                    likertButton3.isSelected = false
                    likertButton4.isSelected = false
//                    likertButtonNA.isSelected = false
                case 2:
                    likertButton0.isSelected = false
                    likertButton1.isSelected = false
                    likertButton2.isSelected = true
                    likertButton3.isSelected = false
                    likertButton4.isSelected = false
//                    likertButtonNA.isSelected = false
                case 3:
                    likertButton0.isSelected = false
                    likertButton1.isSelected = false
                    likertButton2.isSelected = false
                    likertButton3.isSelected = true
                    likertButton4.isSelected = false
//                    likertButtonNA.isSelected = false
                case 4:
                    likertButton0.isSelected = false
                    likertButton1.isSelected = false
                    likertButton2.isSelected = false
                    likertButton3.isSelected = false
                    likertButton4.isSelected = true
//                    likertButtonNA.isSelected = false
                case 5:
                    likertButton0.isSelected = false
                    likertButton1.isSelected = false
                    likertButton2.isSelected = false
                    likertButton3.isSelected = false
                    likertButton4.isSelected = false
//                    likertButtonNA.isSelected = true
                default:
                    likertButton0.isSelected = false
                    likertButton1.isSelected = false
                    likertButton2.isSelected = false
                    likertButton3.isSelected = false
                    likertButton4.isSelected = false
//                    likertButtonNA.isSelected = false
                }
            }else{
                setAllUnmarked()
            }
        }else{
            setAllUnmarked()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
