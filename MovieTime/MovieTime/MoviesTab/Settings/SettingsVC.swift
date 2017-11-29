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
import UserNotifications
import TMDBSwift

class SettingsVC: UITableViewController {
    
    let defaults = UserDefaults.standard
    var alertDialog: CDAlertView!

    /////////////////////////////////////////
    // Notifications
    /////////////////////////////////////////
    @IBOutlet weak var mpmTimeButton: UIButton!
    @IBOutlet weak var subscribeSwitch: UISwitch!
    @IBOutlet weak var newlyReleaseMoviesSwitch: UISwitch!
    @IBOutlet weak var mostPopularMovieSwitch: UISwitch!
    
    let timePicker = UIDatePicker()
    let toolBar = UIToolbar()
    var mostPopularMovieTime = "08:00"

    @IBAction func unleasedMovieSubscribedSwitched(_ sender: UISwitch) {
        if sender.isOn {
            print("unleasedMovieSubscribedSwitched on")
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if(settings.authorizationStatus == .authorized)
                {
                    // Now user can subscribe to a movie and receive notification
                    // Set subscribe movie key in UserDefaults to true
                    self.defaults.set(true, forKey: Notifications.subscribedMovie)
                    print("set \(Notifications.subscribedMovie) to true")
                } else {
                    print("Notifications not allowed")
                    DispatchQueue.main.async {
                        sender.setOn(false, animated: false)
                        Notifications.showNotificationDisabledAlert()
                    }
                }
            }
        } else {
            print("unleasedMovieSubscribedSwitched off")
            // Set subscribe movie key in UserDefaults to false
            self.defaults.set(false, forKey: Notifications.subscribedMovie)
            print("set \(Notifications.subscribedMovie) to false")

            // Remove notification pending requests
            Notifications.removePendingNotifications(identifier: Notifications.subscribedMovie)
        }
    }
    
    @IBAction func newlyReleasedMoviesSwitched(_ sender: UISwitch) {
        if sender.isOn {
            print("newlyReleasedMoviesSwitched on")
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if(settings.authorizationStatus == .authorized)
                {
                    print("Notifications allowed. Schedule local notification for newly released movies...")
                    DispatchQueue.main.async {
                        // Set newly released movie key in UserDefaults to true
                        self.defaults.set(true, forKey: Notifications.newlyReleasedMovie)
                        
                        // Schedule notification to notify newly released movies daily
                        Notifications.scheduleNotificationForNewlyReleasedMovies()
                    }
                } else {
                    print("Notifications not allowed")
                    DispatchQueue.main.async {
                        sender.setOn(false, animated: false)
                        Notifications.showNotificationDisabledAlert()
                    }
                }
            }
        } else {
            print("newlyReleasedMoviesSwitched off")
            // Set newly released movie key in UserDefaults to false
            self.defaults.set(false, forKey: Notifications.newlyReleasedMovie)
            
            // Remove notification pending requests
            Notifications.removePendingNotifications(identifier: Notifications.newlyReleasedMovie)
        }
    }
    
    @IBAction func mostPopularMovieSwitched(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if(settings.authorizationStatus == .authorized)
                {
                    print("Notifications allowed. Schedule local notification for most popular movie...")
                    DispatchQueue.main.async {
                        // Set most popular movie key in UserDefaults to true
                        self.defaults.set(true, forKey: Notifications.mostPopularMovieId)
                        
                        // Schedule notification to notify most popular movie daily
                        Notifications.scheduleNotificationForMostPopularMovie(time: self.mostPopularMovieTime)
                    }
                } else {
                    print("Notifications not allowed")
                    DispatchQueue.main.async {
                        sender.setOn(false, animated: false)
                        Notifications.showNotificationDisabledAlert()
                    }
                }
            }
        } else {
            // Set most popular movie key in UserDefaults to false
            self.defaults.set(false, forKey: Notifications.mostPopularMovieId)

            // Remove notification pending requests
            Notifications.removePendingNotifications(identifier: Notifications.mostPopularMovieId)
        }
    }
    
    @IBAction func mpmTimeButtonPressed(_ sender: UIButton) {
        self.view.addSubview(toolBar)
        self.view.addSubview(timePicker)
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: timePicker.date)
        mpmTimeButton.titleLabel?.text = time
        mostPopularMovieTime = time
        self.defaults.set(time, forKey: Notifications.mostPopularMovieTime)
        
        // Set up new notification for most popular movie
        if mostPopularMovieSwitch.isOn {
            Notifications.scheduleNotificationForMostPopularMovie(time: time)
        }
        
        toolBar.removeFromSuperview()
        timePicker.removeFromSuperview()
    }
    @objc func cancelPressed() {
        toolBar.removeFromSuperview()
        timePicker.removeFromSuperview()
        mpmTimeButton.titleLabel?.text = mostPopularMovieTime
    }
    func createTimePicker() {
        // format for picker
        timePicker.datePickerMode = .time
        timePicker.backgroundColor = UIColor.white
        timePicker.frame = CGRect(x: 0, y: self.view.frame.height-300, width: self.view.frame.width, height: 300)
        
        // toolbar
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        toolBar.frame = CGRect(x: 0, y: self.view.frame.height-350, width: self.view.frame.width, height: 50)
        
        // Adding Buttons ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    func notifyMostPopularMovie(movie: MovieMDB) {
        var releaseYear = ""
        if movie.release_date != nil {
            let releaseDate = movie.release_date!
            releaseYear = " (\(releaseDate[..<(releaseDate.index(of: "-")!)]))"
        }
        var overview = ""
        if movie.overview != nil {
            overview = movie.overview!
        }
        
        // Send notification
        let content = UNMutableNotificationContent()
        content.badge = 1
        content.title = "Most popular movie!"
        content.subtitle = "\(movie.title!)\(releaseYear) is the most popular movie until now."
        content.body = "\(overview)"
        content.sound = UNNotificationSound.default()
    }
    
    
    
    /////////////////////////////////////////
    // Account
    /////////////////////////////////////////
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lsOrLogoutButton: FlatButton!
    
    var currentUser:User? = nil

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
        
        self.createTimePicker()

        // Load notifications' settings
        print("Loading notifications' settings")
        let time = self.defaults.string(forKey: Notifications.mostPopularMovieTime)

        if time != nil {
            self.mostPopularMovieTime = time!
            self.mpmTimeButton.setTitle(self.mostPopularMovieTime, for: .normal)
        } else {
            self.mpmTimeButton.setTitle("08:00", for: .normal)
        }

        self.mostPopularMovieSwitch.setOn(self.defaults.bool(forKey: Notifications.mostPopularMovieId), animated: false)
        self.newlyReleaseMoviesSwitch.setOn(self.defaults.bool(forKey: Notifications.newlyReleasedMovie), animated: false)
        self.subscribeSwitch.setOn(self.defaults.bool(forKey: Notifications.subscribedMovie), animated: false)
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
