//
//  SettingsVC.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/22/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import Material
import FirebaseAuth
import PopupDialog
import CDAlertView

class SettingsVC: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lsOrLogoutButton: FlatButton!
    
    var currentUser:User? = nil
    var alertDialog: CDAlertView!

    @IBAction func lsOrLogoutButtonPressed(_ sender: FlatButton) {
        if currentUser == nil {
            // go to login/signup page
            print("go to login/signup page")
            self.performSegue(withIdentifier: "settingsToLS", sender: self)
        } else {
            // log out and update settings page
            do {
                try Auth.auth().signOut()
                lsOrLogoutButton.titleColor = UIColor.black
                lsOrLogoutButton.title = "Log in / Sign up"
                currentUser = Auth.auth().currentUser
                print("logged out")
                self.refreshTableView()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 && currentUser == nil {
            return 0.0
        }
        // expanded with row height of parent
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update Account
        if indexPath.section == 1 {
            // Create a custom account update view controller
            let auVC = AccountUpdateVC(nibName: "AccountUpdateVC", bundle: nil)
            
            // Create the dialog
            let popup = PopupDialog(viewController: auVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
            //
            // Update user's name
            //
            if indexPath.row == 0 {
                auVC.accountLabel.text = "UPDATE NAME"
                if currentUser!.displayName == nil {
                    auVC.oldTextField.text = "Current name is empty"
                } else {
                    auVC.oldTextField.text = "Current name: \(currentUser!.displayName!)"
                }
                auVC.oldTextField.isEnabled = false
                auVC.newTextField.placeholder = "Enter your new name"
                
                // Create cancel button
                let cancelButton = CancelButton(title: "CANCEL", height: 40) {
                }
                
                // Create submit button
                let submitButton = DestructiveButton(title: "UPDATE", height: 40) {
                    if auVC.newTextField.text == nil || auVC.newTextField.text == "" {
                        auVC.alertLabel.text = "Please enter your new name!"
                    } else {
                        let changeRequest = self.currentUser!.createProfileChangeRequest()
                        changeRequest.displayName = auVC.newTextField.text
                        changeRequest.commitChanges { error in
                            if let myError = error?.localizedDescription {
                                // An error happened.
                                auVC.alertLabel.text = myError
                            } else {
                                self.refreshTableView()
                                popup.dismiss()
                                self.alertDialog = CDAlertView(title: "UPDATED!", message: "Your name has been successfully updated to \(auVC.newTextField.text!)", type: .success)
                                self.alertDialog.show()
                                Timer.scheduledTimer(timeInterval:1.5, target:self, selector:#selector(self.dismissAlert), userInfo: nil, repeats: true)
                            }
                        }
                    }
                }
                submitButton.dismissOnTap = false
                
                // Add buttons to dialog
                popup.addButtons([cancelButton, submitButton])
                
            //
            // Update email
            //
            } else if indexPath.row == 1 {
                auVC.accountLabel.text = "UPDATE EMAIL"
                if currentUser!.email == nil {
                    auVC.oldTextField.text = "Current email is empty"
                } else {
                    auVC.oldTextField.text = "Current email: \(currentUser!.email!)"
                }
                auVC.oldTextField.isEnabled = false
                auVC.newTextField.placeholder = "Enter your new email"
                
                // Create cancel button
                let cancelButton = CancelButton(title: "CANCEL", height: 40) {
                }
                
                // Create submit button
                let submitButton = DestructiveButton(title: "UPDATE", height: 40) {
                    if auVC.newTextField.text == nil || auVC.newTextField.text == "" {
                        auVC.alertLabel.text = "Please enter your new email!"
                    } else {
                        self.currentUser!.updateEmail(to: auVC.newTextField.text!) { error in
                            if let myError = error?.localizedDescription {
                                // An error happened.
                                auVC.alertLabel.text = myError
                            } else {
                                self.refreshTableView()
                                popup.dismiss()
                                self.alertDialog = CDAlertView(title: "UPDATED!", message: "Your email has been successfully updated to \(auVC.newTextField.text!)", type: .success)
                                self.alertDialog.show()
                                Timer.scheduledTimer(timeInterval:1.5, target:self, selector:#selector(self.dismissAlert), userInfo: nil, repeats: true)
                            }
                        }
                    }
                }
                submitButton.dismissOnTap = false
                
                // Add buttons to dialog
                popup.addButtons([cancelButton, submitButton])
            }
            //
            // Update password
            //
            else if indexPath.row == 2 {
                auVC.accountLabel.text = "UPDATE PASSWORD"
                auVC.oldTextField.text = ""
                auVC.oldTextField.placeholder = "Enter your current password"
                auVC.oldTextField.isSecureTextEntry = true
                auVC.newTextField.placeholder = "Enter your new password"
                auVC.newTextField.isSecureTextEntry = true

                // Create cancel button
                let cancelButton = CancelButton(title: "CANCEL", height: 40) {
                }
                
                // Create submit button
                let submitButton = DestructiveButton(title: "UPDATE", height: 40) {
                    if auVC.oldTextField.text == nil || auVC.oldTextField.text == "" {
                        auVC.alertLabel.text = "Please enter your current password!"
                    }
                    if auVC.newTextField.text == nil || auVC.newTextField.text == "" {
                        auVC.alertLabel.text = "Please enter your new password!"
                    }
                    
                    let credential = EmailAuthProvider.credential(withEmail: self.currentUser!.email!, password: auVC.oldTextField.text!)
                    // Authenticate current password
                    self.currentUser!.reauthenticate(with: credential, completion: { (error) in
                        if let myError = error?.localizedDescription {
                            auVC.alertLabel.text = myError
                        } else{
                            //change to new password
                            self.currentUser!.updatePassword(to: auVC.newTextField.text!) { error in
                                if let myError = error?.localizedDescription {
                                    // An error happened.
                                    auVC.alertLabel.text = myError
                                } else {
                                    self.refreshTableView()
                                    popup.dismiss()
                                    self.alertDialog = CDAlertView(title: "UPDATED!", message: "Your password has been successfully updated", type: .success)
                                    self.alertDialog.show()
                                    Timer.scheduledTimer(timeInterval:1.5, target:self, selector:#selector(self.dismissAlert), userInfo: nil, repeats: true)
                                }
                            }
                        }
                    })
                }
                submitButton.dismissOnTap = false
                
                // Add buttons to dialog
                popup.addButtons([cancelButton, submitButton])
            }
            
            // Create the dialog
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    
    func refreshTableView() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        nameLabel.text = currentUser?.displayName
        emailLabel.text = currentUser?.email
    }
    
    @objc func dismissAlert() {
        self.alertDialog.hide(isPopupAnimated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        currentUser = Auth.auth().currentUser

        if currentUser != nil {
            nameLabel.text = currentUser!.displayName
            emailLabel.text = currentUser!.email
            lsOrLogoutButton.titleColor = UIColor.red
            lsOrLogoutButton.title = "Log out"
        } else {
            lsOrLogoutButton.titleColor = UIColor.black
            lsOrLogoutButton.title = "Log in / Sign up"
        }
        self.refreshTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
