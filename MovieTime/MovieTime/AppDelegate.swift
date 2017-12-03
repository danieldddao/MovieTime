//
//  AppDelegate.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/19/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog
import UserNotifications
import TMDBSwift
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure();
        
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Notification granted: \(granted)")
        }
        
        Notifications.addCategory()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(30)

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("performFetchWithCompletionHandler")
        let defaults = UserDefaults.standard
        
        // Schedule notification for most popular movie
        if defaults.bool(forKey: Notifications.mostPopularMovieId) == true {
            // Load time
            let time = defaults.string(forKey: Notifications.mostPopularMovieTime)
            if time != nil {
                MovieMDB.popular(TMDBBase.apiKey, language: "en", page: 1){
                    data, popularMovies in
                    if let popularMovies = popularMovies{
                        Notifications.setupNotificationForMostPopularMovie(movie: popularMovies[0], time: time!)
                        completionHandler(UIBackgroundFetchResult.newData)
                    }
                }
            }
        }
        
        // Schedule notification for newly released movies
        if defaults.bool(forKey: Notifications.newlyReleasedMovie) == true {
            MovieMDB.nowplaying(TMDBBase.apiKey, language: "en", page: 1){
                data, nowPlaying in
                if let nowPlaying = nowPlaying{
                    Notifications.setupNotificationForNewlyReleasedMovies(moviesInput: nowPlaying)
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        scheduleNotifications()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        scheduleNotifications()
    }

    func scheduleNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized)
            {
                print("Notifications allowed. Schedule local notification")
                let defaults = UserDefaults.standard
                
                // Schedule notification for most popular movie
                if defaults.bool(forKey: Notifications.mostPopularMovieId) == true {
                    // Load time
                    let time = defaults.string(forKey: Notifications.mostPopularMovieTime)
                    if time != nil {
                        Notifications.scheduleNotificationForMostPopularMovie(time: time!)
                    }
                }
                
                // Schedule notification for newly released movies
                if defaults.bool(forKey: Notifications.newlyReleasedMovie) == true {
                    Notifications.scheduleNotificationForNewlyReleasedMovies()
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Get movie id
        let requestId = response.notification.request.identifier
        let indexId = requestId.index(after: requestId.index(of: "_")!)
        let movieId = Int(requestId[indexId...])

        print("Tapped to open detail view")
        clickedMovieId = movieId!
        
        // Go to movie-detail view
        let tabBarController = self.window?.rootViewController as! BottomNavigationController
        tabBarController.selectedIndex = 0
        let movieDetailVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "movieDetailVC") as! MovieDetailsVC
        let navVC = tabBarController.viewControllers![0] as! UINavigationController
        navVC.popToRootViewController(animated: false)
        navVC.pushViewController(movieDetailVC, animated: true)

        // Play Trailer
        if response.actionIdentifier == Identifiers.playTrailerAction {
            print("Tapped to open detail view")
            movieDetailVC.movieId = movieId!
            movieDetailVC.loadTrailer()
        }
        
        completionHandler()
    }
    
    // Show notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert,.sound,.badge])
    }
}

