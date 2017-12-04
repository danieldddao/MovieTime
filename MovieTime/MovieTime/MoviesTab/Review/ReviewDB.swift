//
//  ReviewRatingDB.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/29/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CDAlertView

extension MovieDetailsVC {

    func addReviewToDatabase(review: Review) {
        let reviewVal = [
            "name": review.getUserName(),
            "comment": review.getComment(),
            "rating": review.getRating(),
            "date": review.getDate()
            ] as [String : Any]
        let username = encodeUserEmail(userEmail: review.getUserEmail())
        self.ref.child("reviews").child(String(review.getMovieId())).child(username).setValue(reviewVal) { (error, ref) -> Void in
            // Review already posted for this user
            if (error != nil) {
                print("Review already posted for this user")
                let alert = CDAlertView(title: "Error!", message: "You already posted review for this movie.", type: .error)
                let doneAction = CDAlertViewAction(title: "OK")
                alert.add(action: doneAction)
                alert.show()
            } else {
                print("Successfully added new review of user \(review.getUserEmail()) for movie with id=\(review.getMovieId()), review: \(review.getComment()), rating:\(review.getRating())")
                self.alert = CDAlertView(title: "Thank you!", message: "Your review has been posted!", type: .success)
                self.alert.show()
                Timer.scheduledTimer(timeInterval:0.8, target:self, selector:#selector(self.dismissAlert), userInfo: nil, repeats: true)
            }
        }
    
        // Get average rating and compute new average rating
        ref.child("averageRatings").child(String(review.getMovieId())).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                // Get average rating value
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    var avgRating = child.value as! Float
                    avgRating = (avgRating + review.getRating()) / 2
                    
                    // update new average rating
                    self.ref.child("averageRatings/" + String(review.getMovieId())).updateChildValues(["avgRatingValue": avgRating]) { (error, ref) -> Void in
                        // Can't update new average rating
                        if (error != nil) {
                            print("Can't update new average rating")
                            self.showAlert("There was an error! Please try again!")
                        } else {
                            print("Successfully updated new average rating for movie with id=\(review.getMovieId()), rating:\(avgRating)")
                            
                            // Load new average rating
                            self.loadAvgRating()
                        }
                    }
                }
            } else {
                // Create new average rating for this movie
                self.ref.child("averageRatings").child(String(review.getMovieId())).setValue(["avgRatingValue": review.getRating()]) { (error, ref) -> Void in
                    // Can't create new average rating
                    if (error != nil) {
                        print("Can't create new average rating")
                        self.showAlert("There was an error! Please try again!")
                    } else {
                        print("Successfully added new average rating for movie with id=\(review.getMovieId()), rating:\(review.getRating())")
                        
                        // Load new average rating
                        self.loadAvgRating()
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func loadReviewsToReviewTable() {
        self.ref.child("reviews").child(String(movieId)).observe(.childAdded, with: { (snapshot) in
            if let reviewDict = snapshot.value as? [String: Any] {
                let userEmail: String = self.decodeUserEmail(userEmail: snapshot.key)
                let review = Review(userEmail: userEmail, userName: reviewDict["name"] as! String, tmdbMovieId: self.movieId, reviewComment: reviewDict["comment"] as! String, rating: reviewDict["rating"] as! Float, date: reviewDict["date"] as! String)
                
                self.reviews.append(review)
                DispatchQueue.main.async {
                    self.reviewTableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func checkIfCurrentUserPostedReview() {
        if (self.currentUser != nil) {
            self.ref.child("reviews").child(String(movieId)).child((self.encodeUserEmail(userEmail: (self.currentUser!.email)!))).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    self.writeReviewButton.isEnabled = false
                    self.writeReviewButton.title = "Already Posted Review"
                    self.writeReviewButton.titleColor = UIColor.black
                    self.writeReviewButton.backgroundColor = UIColor.lightGray
                }
            }, withCancel: nil)
        }
    }
    
    func loadAvgRating() {
        self.ref.child("averageRatings").child(String(movieId)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                // Get average rating value
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    let avgRating = child.value as! Float
                    print("avgRating: \(avgRating)")
                    self.starRatingBar.value = CGFloat(avgRating)
                    self.starRatingBar.tintColor = UIColor(red: 1.000, green: 0.776, blue: 0.067, alpha: 1.000)
                    self.starRatingValueLabel.textColor = UIColor(red: 1.000, green: 0.776, blue: 0.067, alpha: 1.000)
                    self.starRatingValueLabel.text = String(format: "%.1f", avgRating)
                }
            } else {
                // This movie hasn't been reviewed yet
                self.starRatingBar.value = CGFloat(0)
                self.starRatingBar.tintColor = UIColor.lightGray
                self.starRatingValueLabel.textColor = UIColor.lightGray
                self.starRatingValueLabel.text = "N/A"
            }
        }, withCancel: nil)
    }
    
    func encodeUserEmail(userEmail: String) -> String {
        return userEmail.replacingOccurrences(of: ".", with: ",")
    }
    
    func decodeUserEmail(userEmail: String) -> String {
        return userEmail.replacingOccurrences(of: ",", with: ".")
    }
    
    func showAlert(_ message: String) {
        let alert = CDAlertView(title: "Error!", message: message, type: .error)
        let doneAction = CDAlertViewAction(title: "OK")
        alert.add(action: doneAction)
        alert.show()
    }
    
    @objc func dismissAlert() {
        alert.hide(isPopupAnimated: true)
    }
    
}
