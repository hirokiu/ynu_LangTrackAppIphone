//
//  LoginViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-02-03.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    var onSignedIn: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = KirokunTheme.action
        let project = KirokunProject.selector()
        project.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(project)
        // Insert the project selector before credentials while retaining the original form.
        for constraint in view.constraints where constraint.firstItem as? UIView === userNameTextField && constraint.firstAttribute == .top {
            constraint.isActive = false
        }
        NSLayoutConstraint.activate([
            project.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 16),
            project.leadingAnchor.constraint(equalTo: userNameTextField.leadingAnchor),
            project.trailingAnchor.constraint(equalTo: userNameTextField.trailingAnchor),
            project.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            userNameTextField.topAnchor.constraint(equalTo: project.bottomAnchor, constant: 16)
        ])
        logInButton.configuration = KirokunTheme.primaryButton(title: logInButton.currentTitle ?? "")
        helpButton.layer.cornerRadius = 18
        helpButton.layer.borderColor = UIColor.init(named: "lta_blue")?.cgColor
        helpButton.layer.borderWidth = 0.5

        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        userNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == userNameTextField {
         textField.resignFirstResponder()
         passwordTextField.becomeFirstResponder()
      } else if textField == passwordTextField {
         textField.resignFirstResponder()
         logIn()
      }
     return true
    }
    
    func logIn(){
        guard logInButton.isEnabled else { return }
        let username = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text
        if (username ?? "" == "") || (password ?? "" == ""){
            DispatchQueue.main.async {
                let popup = UIAlertController(title: translatedIncorrectEntry, message: translatedPleaseEnterYourUsernameAndPasswordAndTryAgain, preferredStyle: .alert)
                popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(popup, animated: true, completion: nil)
            }
        }else{
            activityIndicator.startAnimating()
            logInButton.isEnabled = false
            isModalInPresentation = true
            KirokunAccountSession.signIn(username: username!.trimmingCharacters(in: .whitespacesAndNewlines), password: password!) { [weak self] error in
                guard let self = self else { return }
                if error != nil { self.loginFailed(); return }
                KirokunAccountSession.resolve { success in
                    if success {
                        #if !KIROKUN_DEV
                        Messaging.messaging().subscribe(toTopic: SurveyRepository.userId)
                        #endif
                        DispatchQueue.main.async { self.passwordTextField.text = ""; self.close() }
                    } else {
                        try? Auth.auth().signOut()
                        self.loginFailed()
                    }
                }
            }
        }
    }
   
    private func loginFailed() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating(); self.logInButton.isEnabled = true
            self.isModalInPresentation = false
            let popup = UIAlertController(title: translatedErrorLogin,
                message: NSLocalizedString("account_login_failed", comment: ""), preferredStyle: .alert)
            popup.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(popup, animated: true)
        }
    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        logIn()
    }
    
    func close(){
        self.activityIndicator.stopAnimating()
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: onSignedIn)
    }
    @IBAction func helpButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            let popup = UIAlertController(title: translatedInfo, message: translatedDevelopedBy, preferredStyle: .alert)
            popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(popup, animated: true, completion: nil)
        }
    }
}
