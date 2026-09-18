//
//  SideMenu.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-03-23.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit
import DGCharts

let attributeLtaBlueHeaderText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                   NSAttributedString.Key.foregroundColor: KirokunTheme.action ]

let attributeLtaRedHeaderText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                                   NSAttributedString.Key.foregroundColor: KirokunTheme.action ]

let attributeLtaBlueText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
                             NSAttributedString.Key.foregroundColor: UIColor.label ]

let attributeSmallText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]

class SideMenu: UIViewController {
    
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var versionInfoLabel: UILabel!
    @IBOutlet weak var testViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var testViewDivider: UIView!
    @IBOutlet weak var serverSwitch: UISwitch!
    @IBOutlet weak var testingSwitch: UISwitch!
    
    var listener: MenuListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let project = KirokunProject.selector(title: NSLocalizedString("project_switch", comment: ""))
        project.translatesAutoresizingMaskIntoConstraints = false
        menuBackground.addSubview(project)
        NSLayoutConstraint.activate([
            project.topAnchor.constraint(equalTo: aboutButton.bottomAnchor, constant: 16),
            project.leadingAnchor.constraint(equalTo: menuBackground.leadingAnchor, constant: 15),
            project.trailingAnchor.constraint(equalTo: menuBackground.trailingAnchor, constant: -15),
            project.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        view.tintColor = KirokunTheme.action
        menuBackground.subviews.compactMap { $0 as? UILabel }.forEach { $0.textColor = KirokunTheme.action }
        [instructionsButton, aboutButton, contactButton, logOutButton].forEach { $0?.setTitleColor(KirokunTheme.action, for: .normal) }
        testViewDivider.layer.cornerRadius = 1

        menuBackground.layer.cornerRadius = 12
        menuBackground.layer.borderWidth = 2
        menuBackground.layer.borderColor = KirokunTheme.brand.cgColor
        
        let version = UIApplication.appVersion
        if version != nil{
            versionInfoLabel.text = String(format: NSLocalizedString("Version %@", comment: "App version"), version ?? "")
        }else{
            versionInfoLabel.text = ""
        }
        instructionsButton.setTitle(translatedInstructions, for: .normal)
    }
    
    func setTestView(userName: String){
        
        /*
        Adding userName for team members
         will let them
         * switch between staging server and production server
         * using app in testMode -> open all surveys as active
         */
        
        if  userName == "stephan" ||
            userName == "stephandroid" ||
            userName == "josef" ||
            userName == "marianne" ||
            userName == "jonas" ||
            userName == "henriette"  {
            testViewBottomConstraint.constant = 10
            testView.isHidden = false
        }else{
            testView.isHidden = true
            testViewBottomConstraint.constant = -testView.frame.height
        }
    }
    
    func setInfo(name: String, listener: MenuListener){
        self.listener = listener
        userNameLabel.text = name
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        listener?.logOutSelected()
    }
    
    @IBAction func testingSwitch(_ sender: UISwitch) {
        listener?.setTestMode(to: sender.isOn)
    }
    
    @IBAction func serverSwitch(_ sender: UISwitch) {
        listener?.setStagingServer(to: sender.isOn)
    }
}
