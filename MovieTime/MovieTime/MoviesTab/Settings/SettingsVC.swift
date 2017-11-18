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

class SettingsVC: UITableViewController {

//    @IBOutlet var notificationsSection: UITableViewSection!
//    @IBOutlet var accountSection: UITableViewSection!
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        currentUser = Auth.auth().currentUser

        if currentUser != nil {
            lsOrLogoutButton.titleColor = UIColor.red
            lsOrLogoutButton.title = "Log out"
        } else {
            lsOrLogoutButton.titleColor = UIColor.black
            lsOrLogoutButton.title = "Log in / Sign up"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
