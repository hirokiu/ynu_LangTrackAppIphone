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
    
    
    var authHandle : AuthStateDidChangeListenerHandle?
    
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
        authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("auth addStateDidChangeListener email: \(auth.currentUser?.email ?? "nil")")
            if auth.currentUser != nil{
                var username = auth.currentUser?.email
                username!.until("@")
                if username != nil{
                    if username! != ""{
                        Messaging.messaging().subscribe(toTopic: username!) { error in
                            if error != nil{
                                print("messaging().subscribe ERROR: \(error.debugDescription)")
                            }else{
                                print("Messaging subscribed to \(username!)")
                            }
                        }
                    }
                }
                self.close()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authHandle!)
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
        let username = userNameTextField.text
        let password = passwordTextField.text
        if (username ?? "" == "") || (password ?? "" == ""){
            DispatchQueue.main.async {
                let popup = UIAlertController(title: translatedIncorrectEntry, message: translatedPleaseEnterYourUsernameAndPasswordAndTryAgain, preferredStyle: .alert)
                popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(popup, animated: true, completion: nil)
            }
        }else{
            activityIndicator.startAnimating()
            let userEmail = "\(username!)@humlablu.com"
            
            Auth.auth().signIn(withEmail: userEmail, password: password!) { (result, error) in
                if error == nil{
                    print("auth signIn: \(result?.debugDescription)")
                }else{
                    self.activityIndicator.stopAnimating()
                    print("auth signIn ERROR: \(error?.localizedDescription ?? "")")
                    DispatchQueue.main.async {
                        let popup = UIAlertController(title: translatedErrorLogin, message: translatedInvalidUsernameOrPassword, preferredStyle: .alert)
                        popup.addAction(UIAlertAction(title: "OK", style: .default, handler:{alert -> Void in
                            self.userNameTextField.becomeFirstResponder()
                        }))
                        
                        self.present(popup, animated: true, completion: nil)
                    }
                }
                
            }
        }
    }
   
    @IBAction func logInButtonPressed(_ sender: Any) {
        logIn()
    }
    
    func close(){
        self.activityIndicator.stopAnimating()
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func helpButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            let popup = UIAlertController(title: translatedInfo, message: translatedDevelopedBy, preferredStyle: .alert)
            popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(popup, animated: true, completion: nil)
        }
    }
}
