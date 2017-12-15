//
//  NotificationViewController.swift
//  ContentExtension
//
//  Created by Daniel Dao on 12/1/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UITextView!
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        self.titleLabel.text = content.subtitle
        self.releaseDateLabel.text = content.body
        let overview = content.userInfo["overview"]
        if overview != nil {
            self.overviewLabel.text = "Overview:\n\(overview!)"
        } else {
            self.overviewLabel.text = "Overview:\nN/A"
        }
        self.userScoreLabel.text = "TMDB User Score: \(content.userInfo["score"] ?? "N/A") ★"
        self.averageRatingLabel.text = "Average Rating: \(content.userInfo["averageRating"] ?? "N/A") ⭐"
        
        // Get movie poster image
        let imageAttachment:UNNotificationAttachment = content.attachments[0]
        let data = try? Data(contentsOf: imageAttachment.url)
        if let data = data {
            let image = UIImage(data: data)
            
            // Set poster image
            self.posterImage.image = image
            
//            // Add blur effect to image
//            let context = CIContext(options: nil)
//            let currentFilter = CIFilter(name: "CIGaussianBlur")
//            let beginImage = CIImage(image: image!)
//            currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
//            currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
//            let cropFilter = CIFilter(name: "CICrop")
//            cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
//            cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
//            let output = cropFilter!.outputImage
//            let cgimg = context.createCGImage(output!, from: output!.extent)
//            let processedImage = UIImage(cgImage: cgimg!).alpha(0.3)
//            
//            // Set background
//            self.backgroundImage.image = processedImage
        }
    }
}

extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
