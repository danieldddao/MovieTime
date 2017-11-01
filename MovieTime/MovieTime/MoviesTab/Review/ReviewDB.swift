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

class ReviewDB {
    
    private var ref: DatabaseReference!
    private var alert: CDAlertView!
    
    init() {
        ref = Database.database().reference()
    }
    
    func addReviewToDatabase(review: Review) {
        let reviewVal = [
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
                            self.showAlert()
                        } else {
                            print("Successfully updated new average rating for movie with id=\(review.getMovieId()), rating:\(avgRating)")
                        }
                    }
                }
            } else {
                // Create new average rating for this movie
                self.ref.child("averageRatings").child(String(review.getMovieId())).setValue(["avgRatingValue": review.getRating()]) { (error, ref) -> Void in
                    // Can't create new average rating
                    if (error != nil) {
                        print("Can't create new average rating")
                        self.showAlert()
                    } else {
                        print("Successfully added new average rating for movie with id=\(review.getMovieId()), rating:\(review.getRating())")
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func getDBReference() -> DatabaseReference {
        return ref
    }
    
    func loadReviewsFromDatabase(tmdbMovieId: Int) {
        print("Geting all reviews of movie id=\(tmdbMovieId)")
        var reviews = [Review]()
//        ref.child("reviews").child(String(tmdbMovieId)).observe(.childAdded, with: { snapshot in
//            // Get review values for each review
//            let userEmail: String = self.decodeUserEmail(userEmail: snapshot.key)
//            if let reviewDict = snapshot.value as? [String:Any] {
//                let review = Review(userEmail: userEmail, tmdbMovieId: tmdbMovieId, reviewComment: reviewDict["comment"] as! String, rating: reviewDict["rating"] as! Float, date: reviewDict["date"] as! String)
//                reviews.append(review)
//            }
//            DispatchQueue.main.async() {
//                completion(reviews)
//            }
        ref.child("reviews").child(String(tmdbMovieId)).observeSingleEvent(of: .value, with: { snapshot in
            // Get review values for each review
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                print(child)
                let userEmail: String = self.decodeUserEmail(userEmail: child.key)
                if let reviewDict = child.value as? [String:Any] {
                    let review = Review(userEmail: userEmail, tmdbMovieId: tmdbMovieId, reviewComment: reviewDict["comment"] as! String, rating: reviewDict["rating"] as! Float, date: reviewDict["date"] as! String)
                    reviews.append(review)
                }
            }
//
//            DispatchQueue.main.async() {
//                completion(reviews)
//            }
        }, withCancel: nil)
    }
    
    func encodeUserEmail(userEmail: String) -> String {
        return userEmail.replacingOccurrences(of: ".", with: ",")
    }
    
    func decodeUserEmail(userEmail: String) -> String {
        return userEmail.replacingOccurrences(of: ",", with: ".")
    }
    
    func showAlert() {
        let alert = CDAlertView(title: "Error!", message: "There was an error! Please try again!", type: .error)
        let doneAction = CDAlertViewAction(title: "OK")
        alert.add(action: doneAction)
        alert.show()
    }
    
    @objc func dismissAlert() {
        alert.hide(isPopupAnimated: true)
    }
    
}
