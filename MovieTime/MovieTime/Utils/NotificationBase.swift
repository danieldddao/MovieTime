//
//  NotificationBase.swift
//  MovieTime
//
//  Created by Daniel Dao on 11/21/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import CDAlertView

class NotificationBase {
    
    static func setupNotificationContent(title: String, subtitle: String, body: String) -> UNMutableNotificationContent{
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default()
        return content
    }
    
    static func setupNotificationTriggerForDate(dateString: String) -> UNCalendarNotificationTrigger{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: dateString)!
        // let date = Date(timeIntervalSinceNow: 5) // Test date
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        return trigger
    }
    
    static func showNotificationDisabledAlert() {
        let alertDialog = CDAlertView(title: "NOTIFICATIONS DISABLED", message: "Please visit Settings and tap Allow Notifications", type: .error)
        let changeSettings = CDAlertViewAction(title: "Settings", font: nil, textColor: nil, backgroundColor: nil, handler: { (action) in
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        alertDialog.add(action: CDAlertViewAction(title: "Cancel"))
        alertDialog.add(action: changeSettings)
        alertDialog.show()
    }
    
    static func showErrorAlert(error: String) {
        let alertDialog = CDAlertView(title: "ERROR!", message: error, type: .error)
        alertDialog.add(action: CDAlertViewAction(title: "OK"))
        alertDialog.show()
    }
    
    static func showNotifyUnreleasedMovieSuccessAlert() {
        let alertDialog = CDAlertView(title: "SUCCESS!", message: "You'll be notified when this movie is released", type: .success)
        alertDialog.add(action: CDAlertViewAction(title: "OK"))
        alertDialog.show()
    }
    
    static func showUnreleasedMovieNotReleaseDateAlert() {
        let alertDialog = CDAlertView(title: "NOTIFICATION", message: "This movie doesn't have a release date yet! Please try again when the release date is available!", type: .notification)
        alertDialog.add(action: CDAlertViewAction(title: "OK"))
        alertDialog.show()
    }
}
