//
//  SingleItemTableViewCell.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-04-03.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class SingleItemTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var checkBox: VKCheckbox!
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCheck(enabled: Bool){
        checkBox.setOn(enabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
