//
//  TeamMember.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2022-04-01.
//  Copyright © 2022 Stephan Björck. All rights reserved.
//

import Foundation

class TeamMember{
    var description: [String:String]
    var name: [String:String]
    
    init(name:[String:String],description:[String:String]){
        self.name = name
        self.description = description
    }
}
