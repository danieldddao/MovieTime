//
//  LSViewController.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/19/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import FirebaseAuth
import Motion
import Material
import PopupDialog
import CDAlertView

class LoginSignupVC: UIViewController, TextFieldDelegate {
    
    @IBOutlet weak var loginButton: RaisedButton!
    @IBOutlet weak var createButton: RaisedButton!
    @IBOutlet weak var lsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    var loginEmailField: ErrorTextField!
    var loginPasswordField: ErrorTextField!
    var signupNameField: ErrorTextField!
    var signupEmailField: ErrorTextField!
    var signupPasswordField: ErrorTextField!
    var signupPasswordConfirmationField: ErrorTextField!

    var alert = "";
    var alertDialog: CDAlertView!

    @IBAction func LSControlChanged(_ sender: UISegmentedControl) {
        self.alertLabel.text = ""
        if sender.selectedSegmentIndex == 0 {
            loginPageSetup()
        } else {
            signupPageSetup()
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        // Create a custom account update view controller
        let forgotPwdVC = AccountUpdateVC(nibName: "AccountUpdateVC", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: forgotPwdVC, buttonAlignment: .vertical, transitionStyle: .fadeIn, gestureDismissal: true)
        forgotPwdVC.accountLabel.text = "FORGOT PASSWORD?"
        forgotPwdVC.newTextField.isHidden = true
        forgotPwdVC.oldTextField.placeholder = "Enter your email to reset password"
        
        // Create cancel button
        let cancelButton = CancelButton(title: "CANCEL", height: 30) {
        }
        
        // Create submit button
        let submitButton = DestructiveButton(title: "SEND", height: 30) {
            
            if forgotPwdVC.oldTextField.text == nil || forgotPwdVC.oldTextField.text == "" {
                forgotPwdVC.alertLabel.text = "Please enter your email!"
            } else {
                Auth.auth().sendPasswordReset(withEmail: forgotPwdVC.oldTextField.text!) { error in
                    if let myError = error?.localizedDescription {
                        // An error happened.
                        forgotPwdVC.alertLabel.text = myError
                    } else {
                        self.alertDialog = CDAlertView(title: "Email sent to \(forgotPwdVC.oldTextField.text!)", message: "A link to reset your password has been sent to this email", type: .success)
                        self.alertDialog.show()
                        Timer.scheduledTimer(timeInterval:2, target:self, selector:#selector(self.dismissAlert), userInfo: nil, repeats: true)
                        popup.dismiss()
                    }
                }
            }
        }
        submitButton.dismissOnTap = false
        
        // Add buttons to dialog
        popup.addButtons([cancelButton, submitButton])

        // Create the dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: RaisedButton) {
        loginEmailField.isErrorRevealed = false
        loginPasswordField.isErrorRevealed = false
        Auth.auth().signIn(withEmail: loginEmailField.text!, password: loginPasswordField.text!) { (user, error) in
            if user != nil {
                // sign in successful
                print("logged in")
                self.navigationController?.popViewController(animated: true)
            } else {
                if let myError = error?.localizedDescription {
                    if myError.contains("email") {
                        self.loginEmailField.isErrorRevealed = true
                        self.loginEmailField.detail = myError
                    } else if myError.contains("password") {
                        self.loginPasswordField.isErrorRevealed = true
                        self.loginPasswordField.detail = myError
                    } else if myError.contains("no user") {
                        self.alertLabel.text = "Account associated with this email doesn't exist!"
                    } else {
                        self.alertLabel.text = myError
                    }
                } else {
                    self.alertLabel.text = "Error! Can't Login"
                }
            }
        }
    }
    
    @IBAction func createButtonPressed(_ sender: RaisedButton) {
        signupNameField.isErrorRevealed = false
        signupEmailField.isErrorRevealed = false
        signupPasswordField.isErrorRevealed = false
        signupPasswordConfirmationField.isErrorRevealed = false
        if signupNameField.text == nil || signupNameField.text == "" {
            signupNameField.isErrorRevealed = true
            signupNameField.detail = "Please enter your name!"
        } else if signupPasswordField.text != signupPasswordConfirmationField.text {
            signupPasswordConfirmationField.isErrorRevealed = true
            signupPasswordConfirmationField.detail = "Password confirmation doesn't match!"
        } else {
            Auth.auth().createUser(withEmail: signupEmailField.text!, password: signupPasswordField.text!) { (user, error) in
                if user != nil {
                    // sign up successful
                    // Add profile name
                    let changeRequest = user!.createProfileChangeRequest()
                    changeRequest.displayName = self.signupNameField.text
//                    changeRequest.photoURL =
//                        NSURL(string: "https://example.com/jane-q-user/profile.jpg")
                    changeRequest.commitChanges { error in
                        if let myError = error?.localizedDescription {
                            // An error happened.
                            self.alertLabel.text = myError
                        } else {
                            // Name updated.
                            self.signupEmailField.text = ""
                            self.signupPasswordField.text = ""
                            self.signupPasswordConfirmationField.text = ""
                            self.lsSegmentedControl.selectedSegmentIndex = 0
                            self.LSControlChanged(self.lsSegmentedControl)
                            self.alertLabel.text = "Successfully created new account! Please log in!"
                        }
                    }
                } else {
                    if let myError = error?.localizedDescription {
                        if myError.contains("email") {
                            self.signupEmailField.isErrorRevealed = true
                            self.signupEmailField.detail = myError
                        } else if myError.contains("password") {
                            self.signupPasswordField.isErrorRevealed = true
                            self.signupPasswordField.detail = myError
                        } else {
                            self.alertLabel.text = myError
                        }
                    } else {
                        self.alertLabel.text = "Error! Can't Sign up. Please try again!"
                    }
                }
            }
        }
    }

    func loginPageSetup() {
        
        loginEmailField.isHidden = false
        loginPasswordField.isHidden = false
        loginButton.isHidden = false
        signupNameField.isHidden = true
        signupEmailField.isHidden = true
        signupPasswordField.isHidden = true
        signupPasswordConfirmationField.isHidden = true
        createButton.isHidden = true
        forgotPasswordBtn.isHidden = false
        
        // Setup email textfield for login
        loginEmailField.autocapitalizationType = UITextAutocapitalizationType.none
        loginEmailField.placeholder = "Enter your email"
        loginEmailField.isClearIconButtonEnabled = true
        let loginEmailFieldLeftView = UIImageView()
        loginEmailFieldLeftView.image = Icon.email
        loginEmailField.leftView = loginEmailFieldLeftView
        view.layout(loginEmailField).center(offsetY: -130).left(20).right(20)
        
        // Setup password textfield for login
        loginPasswordField.isSecureTextEntry = true
        loginPasswordField.placeholder = "Enter your password"
        loginPasswordField.isClearIconButtonEnabled = true
        let loginPasswordFieldLeftView = UIImageView()
        loginPasswordFieldLeftView.image = UIImage(named:"lock")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        loginPasswordField.leftView = loginPasswordFieldLeftView
        view.layout(loginPasswordField).center(offsetY: -40).left(20).right(20)

        // Setup forgot password button
        view.layout(forgotPasswordBtn).center(offsetY: 10).left(20).right(20)

        // Setup login button
        view.layout(loginButton).center(offsetY: 60).left(20).right(20)
    }
    
    func signupPageSetup() {
        
        loginEmailField.isHidden = true
        loginPasswordField.isHidden = true
        loginButton.isHidden = true
        signupNameField.isHidden = false
        signupEmailField.isHidden = false
        signupPasswordField.isHidden = false
        signupPasswordConfirmationField.isHidden = false
        createButton.isHidden = false
        forgotPasswordBtn.isHidden = true
        
        // Setup name textfield for signup
        signupNameField.autocapitalizationType = UITextAutocapitalizationType.none
        signupNameField.placeholder = "Enter your name"
        signupNameField.isClearIconButtonEnabled = true
        let signupNameFieldLeftView = UIImageView()
        signupNameFieldLeftView.image = UIImage(named:"person")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        signupNameField.leftView = signupNameFieldLeftView
        view.layout(signupNameField).center(offsetY: -130).left(20).right(20)
        
        // Setup email textfield for signup
        signupEmailField.autocapitalizationType = UITextAutocapitalizationType.none
        signupEmailField.placeholder = "Enter your email"
        signupEmailField.isClearIconButtonEnabled = true
        let signupEmailFieldLeftView = UIImageView()
        signupEmailFieldLeftView.image = Icon.email
        signupEmailField.leftView = signupEmailFieldLeftView
        view.layout(signupEmailField).center(offsetY: -40).left(20).right(20)

        // Setup password textfield for signup
        signupPasswordField.isSecureTextEntry = true
        signupPasswordField.placeholder = "Enter your password"
        signupPasswordField.isClearIconButtonEnabled = true
        let signupPasswordFieldLeftView = UIImageView()
        signupPasswordFieldLeftView.image = UIImage(named:"lock")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        signupPasswordField.leftView = signupPasswordFieldLeftView
        view.layout(signupPasswordField).center(offsetY: 50).left(20).right(20)

        // Setup password confirmation textfield for signup
        signupPasswordConfirmationField.isSecureTextEntry = true
        signupPasswordConfirmationField.placeholder = "Re-enter your password"
        signupPasswordConfirmationField.isClearIconButtonEnabled = true
        let signupPasswordConfirmationFieldLeftView = UIImageView()
        signupPasswordConfirmationFieldLeftView.image = UIImage(named:"lock")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        signupPasswordConfirmationField.leftView = signupPasswordConfirmationFieldLeftView
        view.layout(signupPasswordConfirmationField).center(offsetY: 140).left(20).right(20)

        // Setup create button
        view.layout(createButton).center(offsetY: 230).left(20).right(20)
    }
    
    @objc func dismissAlert() {
        self.alertDialog.hide(isPopupAnimated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertLabel.text = alert
        loginEmailField = ErrorTextField()
        loginPasswordField = ErrorTextField()
        signupNameField = ErrorTextField()
        signupEmailField = ErrorTextField()
        signupPasswordField = ErrorTextField()
        signupPasswordConfirmationField = ErrorTextField()
        
        lsSegmentedControl.frame = CGRect(origin: lsSegmentedControl.frame.origin, size: CGSize(width: lsSegmentedControl.frame.size.width, height: 35))

        loginPageSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
