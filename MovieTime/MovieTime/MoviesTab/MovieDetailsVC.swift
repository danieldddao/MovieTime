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
import FirebaseAuth
import FirebaseDatabase
import HCSStarRatingView

class MovieDetailsVC: UIViewController, TableViewDelegate, TableViewDataSource {
    var dataSourceItems: [DataSourceItem] = []

    var reviewDB:ReviewDB?
    var movieId: Int = 1
    private var currentUser:User? = nil

    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var writeReviewButton: FlatButton!
    @IBOutlet weak var reviewTableView: TableView!
    @IBOutlet weak var starRating: HCSStarRatingView!
    @IBOutlet weak var starRatingValue: UILabel!
    
    // Write a review
    @IBAction func writeReviewBtnPressed(_ sender: FlatButton) {
        if (currentUser == nil) {
            // Show login page
            self.performSegue(withIdentifier: "writeReviewMustLogin", sender: self)
        } else {
            showWriteReviewPopup()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "writeReviewMustLogin" {
            let lsVC:LoginSignupVC = segue.destination as! LoginSignupVC
            lsVC.alert = "Please Login to write a review!"
        }
    }
    
    func showWriteReviewPopup() {
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
                if (self.currentUser != nil) {
                    let review = Review(userEmail: self.currentUser!.email!, tmdbMovieId: self.movieId, reviewComment: ratingVC.reviewTextView.text, rating: Float(ratingVC.starRating.value))
                    self.reviewDB?.addReviewToDatabase(review: review)
                } else {
                    
                }
            }
        }
        submitButton.dismissOnTap = false
        
        // Add buttons to dialog
        popup.addButtons([cancelButton, submitButton])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    
    // Table view contains reviews for this movie
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.reviews.count
    }
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = reviews[indexPath.row]
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        cell.userLabel.text = review.getUserEmail()
        cell.userRating.value = CGFloat(review.getRating())
//        cell.userComment.text = review.getComment()
        return cell
    }
    
    var reviews = [Review]()
    func fetchReview() {
        reviewDB?.getDBReference().child("reviews").child(String(movieId)).observe(.childAdded, with: { (snapshot) in
            if let reviewDict = snapshot.value as? [String: Any] {
                let userEmail: String = self.reviewDB!.decodeUserEmail(userEmail: snapshot.key)
                let review = Review(userEmail: userEmail, tmdbMovieId: self.movieId, reviewComment: reviewDict["comment"] as! String, rating: reviewDict["rating"] as! Float, date: reviewDict["date"] as! String)
                
                self.reviews.append(review)
                DispatchQueue.main.async {
                    self.reviewTableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func checkIfCurrentUserPostedReview() {
        reviewDB?.getDBReference().child("reviews").child(String(movieId)).child((reviewDB?.encodeUserEmail(userEmail: (currentUser?.email)!))!).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.writeReviewButton.isEnabled = false
                self.writeReviewButton.title = "Already Posted Review"
                self.writeReviewButton.titleColor = UIColor.black
                self.writeReviewButton.backgroundColor = UIColor.lightGray
            }
        }, withCancel: nil)
    }
    
    func loadAvgRating() {
        reviewDB?.getDBReference().child("averageRatings").child(String(movieId)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                // Get average rating value
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    let avgRating = child.value as! Float
                    print("avgRating: \(avgRating)")
                    self.starRating.value = CGFloat(avgRating)
                    self.starRatingValue.text = String(format: "%.1f", avgRating)
                }
            } else {
                // This movie hasn't been reviewed yet
                self.starRating.value = CGFloat(0)
                self.starRating.tintColor = UIColor.lightGray
                self.starRatingValue.textColor = UIColor.lightGray
                self.starRatingValue.text = "N/A"
            }
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a reference to Firebase database
        reviewDB = ReviewDB()
        currentUser = Auth.auth().currentUser
        fetchReview()

        print("clicked movie ID: \(clickedMovieId)")
        // Import Data
        titleLbl.text = popularMovies[clickedMovieId]?.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentUser = Auth.auth().currentUser
        
        // Check if current user already posted a review for this book
        checkIfCurrentUserPostedReview()
        
        // Load average rating
        loadAvgRating()
    }

}
