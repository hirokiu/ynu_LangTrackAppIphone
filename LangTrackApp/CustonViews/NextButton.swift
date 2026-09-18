//
//  NextButton.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-03-22.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import Foundation
import UIKit

class NextButton: UIButton {
    
    func setEnabled(enabled: Bool){
        self.isEnabled = enabled
        self.backgroundColor = .clear
    }
}
