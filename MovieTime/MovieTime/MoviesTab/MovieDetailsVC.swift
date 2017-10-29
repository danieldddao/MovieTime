//
//  MovieDetailsVC.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/24/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import Material
import PopupDialog

class MovieDetailsVC: UIViewController {

    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var writeReviewButton: FlatButton!
    
    // Write a review
    @IBAction func writeReviewBtnPressed(_ sender: FlatButton) {
        // Create a custom review & rating view controller
        let ratingVC = ReviewRatingVC(nibName: "ReviewRatingVC", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .bounceUp, gestureDismissal: true)
        
        // Create cancel button
        let cancelButton = CancelButton(title: "CANCEL", height: 50) {
        }
        
        // Create submit button
        let submitButton = DestructiveButton(title: "SUBMIT", height: 50) {
            if (ratingVC.reviewTextView.text.isEmpty) {
                ratingVC.alertLabel.text = "Review can't be empty!"
            } else {
                popup.dismiss()
                
                // Add review to the database
                print(ratingVC.reviewTextView.text)
                print(ratingVC.starRating.value)
            }
        }
        submitButton.dismissOnTap = false
        
        // Add buttons to dialog
        popup.addButtons([cancelButton, submitButton])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("clicked movie ID: \(clickedMovieId)")
        
        // Import Data
        titleLbl.text = popularMovies[clickedMovieId]?.title
    }

}
