//
//  Review.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/29/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import Foundation

class Review: NSObject {
    
    private var movieId: Int?
    private var userEmail: String?
    private var userName: String?
    private var comment: String?
    private var rating: Float?
    private var date: String?
    
    init(userEmail:String, userName:String, tmdbMovieId: Int, reviewComment: String, rating: Float) {
        self.userEmail = userEmail
        self.userName = userName
        self.movieId = tmdbMovieId
        self.comment = reviewComment
        self.rating = rating

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = .medium
        self.date = formatter.string(from:date)
    }
    
    init(userEmail:String, userName:String, tmdbMovieId: Int, reviewComment: String, rating: Float, date: String) {
        self.userEmail = userEmail
        self.userName = userName
        self.movieId = tmdbMovieId
        self.comment = reviewComment
        self.rating = rating
        self.date = date
    }
    
    func getUserEmail() -> String {
        return self.userEmail!
    }
    
    func getUserName() -> String {
        return self.userName!
    }
    
    func getMovieId() -> Int {
        return self.movieId!
    }
    
    func getComment() -> String {
        return self.comment!
    }
    
    func getRating() -> Float {
        return self.rating!
    }
    
    func getDate() -> String {
        return self.date!
    }
}
