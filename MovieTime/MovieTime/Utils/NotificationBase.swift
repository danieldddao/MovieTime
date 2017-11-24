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
import TMDBSwift

class NotificationBase {
    
    static var mostPopularMovieId = "LocalNotificationMostPopularMovie"
    static var mostPopularMovieTime = "LocalNotificationMostPopularMovieTime"
    static var newlyReleasedMovie = "LocalNotificationNewlyReleasedMovie"
    static var subscribedMovie = "LocalNotificationSubscribedMovie"

    static func setupNotificationContent(title: String, subtitle: String, body: String?) -> UNMutableNotificationContent{
        var contentBody = ""
        if body != nil {
            contentBody = body!
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = contentBody
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
    
    static func scheduleNotificationForNewlyReleasedMovies() {
        // Remove current notification for most popular movie if exists
        removePendingNotifications(identifier: newlyReleasedMovie)
        
        // Schedule new notification for 4 newly released movies
        // at 4 random time periods
        MovieMDB.nowplaying(TMDBBase.apiKey, language: "en", page: 1){
            data, nowPlaying in
            if let movies = nowPlaying{
                self.setupNotificationForNewlyReleasedMovies(movies: movies)
            }
        }
    }
    static func setupNotificationForNewlyReleasedMovies(movies: [MovieMDB]) {
        // Randomly choose 4 time periods
        let time = ["09:45", "09:47", "09:48", "09:49"]
        
        // Randomly choose 4 movies
        
        for i in 0...3 {
            print("Scheduling notification for newly released movie \(movies[i].title!) on \(time[i])")
            // Schedule notification daily
            var contentBody = ""
            let contentSubtitle = movies[i].title!
            if movies[i].release_date != nil {
                contentBody += "Released on \(movies[i].release_date!)\n"
            }
            if movies[i].overview != nil {
                contentBody += "Overview: \(movies[i].overview!)"
            }
            let content = setupNotificationContent(title: "New movie is released!", subtitle: contentSubtitle, body: contentBody)
            
            // Trigger notification at release date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let date = dateFormatter.date(from: time[i])!
            let triggerDate = Calendar.current.dateComponents([.hour,.minute,], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                        repeats: true)
            
            // Create new notification request and add it to the notification center
            var id = i
            if movies[i].id != nil {id = movies[i].id!}
            let request = UNNotificationRequest(identifier: "\(newlyReleasedMovie)_\(id)",
                content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    static func scheduleNotificationForMostPopularMovie(time: String) {
        // Remove current notification for most popular movie if exists
        removePendingNotifications(identifier: mostPopularMovieId)
        
        // Schedule new notification for most popular movie
        MovieMDB.popular(TMDBBase.apiKey, language: "en", page: 1){
            data, popularMovies in
            if let movie = popularMovies{
                self.setupNotificationForMostPopularMovie(movie: movie[0], time: time)
            }
        }
    }
    static func setupNotificationForMostPopularMovie(movie: MovieMDB, time: String) {
        print("Scheduling notification for popular movie \(movie.title!) on \(time)")
        let contentSub = movie.title!
        var contentBody = ""
        if movie.release_date != nil {
            //                    print("released: \(movie[0].release_date!)")
            contentBody += "Released on \(movie.release_date!)\n"
        }
        if movie.overview != nil {
            contentBody += "Overview: \(movie.overview!)"
        }
        let content = setupNotificationContent(title: "Today's popular movie:", subtitle: contentSub, body: contentBody)
        
        // Trigger notification at release date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: time)!
        let triggerDate = Calendar.current.dateComponents([.hour,.minute,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: true)
        
        // Create new notification request and add it to the notification center
        let request = UNNotificationRequest(identifier: mostPopularMovieId,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    static func removePendingNotifications(identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for item in notifications {
                if(item.identifier.contains(identifier)) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.identifier])
                    print("Removed Pending Notification: \(item.identifier)")
                }
            }
        }
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
        let alertDialog = CDAlertView(title: "NOTIFICATION", message: "You'll receive notification when this movie is released", type: .success)
        alertDialog.add(action: CDAlertViewAction(title: "OK"))
        alertDialog.show()
    }
    
    static func showUnreleasedMovieNotReleaseDateAlert() {
        let alertDialog = CDAlertView(title: "NOTIFICATION", message: "This movie doesn't have a release date yet! Please try again when the release date is available!", type: .notification)
        alertDialog.add(action: CDAlertViewAction(title: "OK"))
        alertDialog.show()
    }
}
