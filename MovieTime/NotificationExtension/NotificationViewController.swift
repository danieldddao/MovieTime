//
//  NotificationViewController.swift
//  NotificationExtension
//
//  Created by Daniel Dao on 11/29/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var castText: UITextView!
    @IBOutlet weak var crewText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NotificationViewController loaded")
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        self.overviewText.text = content.body
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        print("received response")
        
    }

}
