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
import MaterialComponents

class LSViewController: UIViewController, TextFieldDelegate {
    
    @IBOutlet weak var loginButton: MDCRaisedButton!
    @IBOutlet weak var createButton: MDCRaisedButton!
    @IBOutlet weak var lsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var alertLabel: UILabel!
    
    var loginEmailField: ErrorTextField!
    var loginPasswordField: ErrorTextField!
    var signupEmailField: ErrorTextField!
    var signupPasswordField: ErrorTextField!
    var signupPasswordConfirmationField: ErrorTextField!

    var seguefromSettings = false;
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lsToSettings" {
        }
    }
    
    @IBAction func LSControlChanged(_ sender: UISegmentedControl) {
        self.alertLabel.text = ""
        if sender.selectedSegmentIndex == 0 {
            loginPageSetup()
        } else {
            signupPageSetup()
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: MDCRaisedButton) {
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
    
    @IBAction func createButtonPressed(_ sender: MDCRaisedButton) {
        signupEmailField.isErrorRevealed = false
        signupPasswordField.isErrorRevealed = false
        signupPasswordConfirmationField.isErrorRevealed = false
        if signupPasswordField.text != signupPasswordConfirmationField.text {
            signupPasswordConfirmationField.isErrorRevealed = true
            signupPasswordConfirmationField.detail = "Password confirmation doesn't match"
        } else {
            Auth.auth().createUser(withEmail: signupEmailField.text!, password: signupPasswordField.text!) { (user, error) in
                if user != nil {
                    // sign up successful
                    self.signupEmailField.text = ""
                    self.signupPasswordField.text = ""
                    self.signupPasswordConfirmationField.text = ""
                    self.lsSegmentedControl.selectedSegmentIndex = 0
                    self.LSControlChanged(self.lsSegmentedControl)
                    self.alertLabel.text = "Successfully created new account! Please log in!"
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
                        self.alertLabel.text = "Error! Can't Sign up"
                    }
                }
            }
        }
    }
    
    func isValidEmail(input:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: input)
    }
    
    func loginPageSetup() {
        
        loginEmailField.isHidden = false
        loginPasswordField.isHidden = false
        loginButton.isHidden = false
        signupEmailField.isHidden = true
        signupPasswordField.isHidden = true
        signupPasswordConfirmationField.isHidden = true
        createButton.isHidden = true
        
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

        // Setup login button
        view.layout(loginButton).center(offsetY: 50).left(20).right(20)
    }
    
    func signupPageSetup() {
        
        loginEmailField.isHidden = true
        loginPasswordField.isHidden = true
        loginButton.isHidden = true
        signupEmailField.isHidden = false
        signupPasswordField.isHidden = false
        signupPasswordConfirmationField.isHidden = false
        createButton.isHidden = false
        
        // Setup email textfield for signup
        signupEmailField.autocapitalizationType = UITextAutocapitalizationType.none
        signupEmailField.placeholder = "Enter your email"
        signupEmailField.isClearIconButtonEnabled = true
        let signupEmailFieldLeftView = UIImageView()
        signupEmailFieldLeftView.image = Icon.email
        signupEmailField.leftView = signupEmailFieldLeftView
        view.layout(signupEmailField).center(offsetY: -130).left(20).right(20)

        // Setup password textfield for signup
        signupPasswordField.isSecureTextEntry = true
        signupPasswordField.placeholder = "Enter your password"
        signupPasswordField.isClearIconButtonEnabled = true
        let signupPasswordFieldLeftView = UIImageView()
        signupPasswordFieldLeftView.image = UIImage(named:"lock")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        signupPasswordField.leftView = signupPasswordFieldLeftView
        view.layout(signupPasswordField).center(offsetY: -40).left(20).right(20)

        // Setup password confirmation textfield for signup
        signupPasswordConfirmationField.isSecureTextEntry = true
        signupPasswordConfirmationField.placeholder = "Re-enter your password"
        signupPasswordConfirmationField.isClearIconButtonEnabled = true
        let signupPasswordConfirmationFieldLeftView = UIImageView()
        signupPasswordConfirmationFieldLeftView.image = UIImage(named:"lock")?.withRenderingMode(
            UIImageRenderingMode.alwaysTemplate)
        signupPasswordConfirmationField.leftView = signupPasswordConfirmationFieldLeftView
        view.layout(signupPasswordConfirmationField).center(offsetY: 50).left(20).right(20)

        // Setup create button
        view.layout(createButton).center(offsetY: 140).left(20).right(20)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginEmailField = ErrorTextField()
        loginPasswordField = ErrorTextField()
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
