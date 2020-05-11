//
//  SideMenu.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-03-23.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class SideMenu: UIViewController {
    
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var versionInfoLabel: UILabel!
    
    var listener: MenuListener?

    override func viewDidLoad() {
        super.viewDidLoad()

        menuBackground.layer.cornerRadius = 12
        menuBackground.layer.borderWidth = 2
        menuBackground.layer.borderColor = UIColor(named: "lta_blue")?.cgColor
        
        let version = UIApplication.appVersion
        if version != nil{
            versionInfoLabel.text = "Version \(version ?? "")"
        }else{
            versionInfoLabel.text = ""
        }
    }
    
    func setTestView(userName: String){
        if userName == "stephan" ||
            userName == "josef" ||
            userName == "marianne" ||
            userName == "jonas" ||
            userName == "henriette"  {
            testView.isHidden = false
        }else{
            testView.isHidden = true
        }
    }
    
    func setInfo(name: String, listener: MenuListener){
        self.listener = listener
        userNameLabel.text = name
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        listener?.logOutSelected()
    }
    
    @IBAction func contactButtonPressed(_ sender: Any) {
        listener?.contact()
    }
    
    @IBAction func aboutButtonPressed(_ sender: Any) {
        listener?.about()
    }
    
    @IBAction func testingSwitch(_ sender: UISwitch) {
        listener?.setTestMode(to: sender.isOn)
    }
}
