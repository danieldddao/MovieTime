//
//  SettingsViewController.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/22/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import Material
import FirebaseAuth

class SettingsViewController: UIViewController {

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
                lsOrLogoutButton.title = "Log In / Sign Up"
                currentUser = Auth.auth().currentUser
                print("logged out")
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    
    // Prepare for login/signup page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsToLS" {
            let lsVC:LoginSignupVC = segue.destination as! LoginSignupVC
            lsVC.seguefromSettings = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        currentUser = Auth.auth().currentUser
        if currentUser != nil {
            lsOrLogoutButton.title = "Log Out"
        }
        else {
            lsOrLogoutButton.title = "Log In / Sign Up"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
