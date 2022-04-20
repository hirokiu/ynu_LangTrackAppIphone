//
//  applicationExtension.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-04-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static func getLanguageCode() -> String{
        let langStr = Locale.current.languageCode
        var languageCode = "eng"
        switch langStr{
        case "ar": languageCode = "ar" //arabic
        case "tr": languageCode = "tu" //turkish
        case "fa": languageCode = "fa" //farsi (persiska, iran)
        case "fa-AF": languageCode = "da" //dari (afganistan)
        case "sv": languageCode = "swe"
        default: languageCode = "eng"
        }
        return languageCode
    }
}
