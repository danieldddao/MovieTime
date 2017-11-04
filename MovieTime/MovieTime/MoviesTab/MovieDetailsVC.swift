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
import TMDBSwift
import CDAlertView
import UICircularProgressRing

class MovieDetailsVC: UIViewController, TableViewDelegate, TableViewDataSource, CollectionViewDelegate, CollectionViewDataSource {
    
    var movieId: Int = 440021
    var currentUser:User? = nil
    
    @IBOutlet weak var nativationItem: UINavigationItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "writeReviewMustLogin" {
            let lsVC:LoginSignupVC = segue.destination as! LoginSignupVC
            lsVC.alert = "Please Login to write a review!"
        }
    }
    
    //
    // Movie' Details
    //
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var movieDetailView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var userScoreIndicator: UICircularProgressRingView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var crewCollectionView: CollectionView!
    
    var crewMembers: [CrewMDB] = []
    var castMembers: [MovieCastMDB] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return crewMembers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Crews: \(crewMembers.count)")
        let member = crewMembers[indexPath.row]
        let cell = crewCollectionView.dequeueReusableCell(withReuseIdentifier: "crewCell", for: indexPath) as! CrewCell
        cell.jobLabel.text = member.job
        cell.departmentLabel.text = member.department
        cell.nameLabel.text = member.name
        return cell
    }
    
    func loadMovieDetails() {
        // Load Movie details from Movie Id and show datails on screen
        MovieMDB.movie(TMDBBase.apiKey, movieID: movieId, language: "en"){
            apiReturn, movie in
            if let movie = movie {
//                if let backgroundUrl = URL(string: "\(Movie.imageURL)\(movie.backdrop_path!)"){
//                    DispatchQueue.global().async {
//                        let data = try? Data(contentsOf: backgroundUrl)
//                        if let data = data {
//                            DispatchQueue.main.async {
//                                let image: UIImage = UIImage(data: data)!
//
//
//                            }
//                        }
//                    }
//                }
                
                if let posterUrl = URL(string: "\(TMDBBase.imageURL)\(movie.poster_path!)"){
                    let data = try? Data(contentsOf: posterUrl)
                    if let data = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)!
                            self.posterImage.image = image
                            
                            // Add blur effect to image
                            let context = CIContext(options: nil)
                            let currentFilter = CIFilter(name: "CIGaussianBlur")
                            let beginImage = CIImage(image: image)
                            currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
                            currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
                            
                            let cropFilter = CIFilter(name: "CICrop")
                            cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
                            cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
                            let output = cropFilter!.outputImage
                            let cgimg = context.createCGImage(output!, from: output!.extent)
                            let processedImage = UIImage(cgImage: cgimg!)
                            
                            print("image darkness:\(processedImage.isDark)")
                            self.movieDetailView.image = processedImage
                        }
                    }
                }
                
                self.navigationItem.title = movie.title!
                self.titleLabel.text = movie.title!
                if movie.overview == nil {
                    self.overviewTextView.text = "Overview:"
                } else {
                    self.overviewTextView.text = "Overview:\n\(movie.overview!)"
                }
                
                if movie.vote_average == nil {
                    self.userScoreIndicator.value = CGFloat(0)
                } else {
                    self.userScoreIndicator.value = CGFloat(movie.vote_average! * 10)
                }
                
                if movie.status == nil {
                    self.statusLabel.text = "Status:\nN/A"
                } else {
                    self.statusLabel.text = "Status:\n\(movie.status!)"
                }
                
                if (movie.runtime == nil) {
                    self.runtimeLabel.text = "Runtime:\nN/A"
                } else {
                    let runTime = movie.runtime!
                    self.runtimeLabel.text = "Runtime:\n\(runTime/60)h\(runTime%60)m"
                }
                
                if (movie.release_date == nil) {
                    self.releaseDateLabel.text = "Release Date:\nN/A"
                } else {
                    self.releaseDateLabel.text = "Release Date:\n\(movie.release_date!)"
                }
                
                
            } else {
                // Default details
            }
        }
        
        // Get cast and crew
        MovieMDB.credits(TMDBBase.apiKey, movieID: movieId){
            apiReturn, credits in
            if let credits = credits{
                for crew in credits.crew {
                    self.crewMembers.append(crew)
                    DispatchQueue.main.async {
                        self.crewCollectionView.reloadData()
                    }
                }
                for cast in credits.cast {
                    self.castMembers.append(cast)
                }
            }
        }
    }
    
    
    //
    // Reviews And Ratings
    //
    var ref: DatabaseReference!
    var alert: CDAlertView!
    var dataSourceItems: [DataSourceItem] = []
    var reviews = [Review]()
    
    @IBOutlet weak var writeReviewButton: FlatButton!
    @IBOutlet weak var reviewTableView: TableView!
    @IBOutlet weak var starRatingBar: HCSStarRatingView!
    @IBOutlet weak var starRatingValueLabel: UILabel!
    
    // Write a review
    @IBAction func writeReviewBtnPressed(_ sender: FlatButton) {
        if (currentUser == nil) {
            // Show login page
            self.performSegue(withIdentifier: "writeReviewMustLogin", sender: self)
        } else {
            showWriteReviewPopup()
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
                    self.addReviewToDatabase(review: review)
                } else {

                }
            }
        }
        submitButton.dismissOnTap = false

        // Add buttons to dialog
        popup.addButtons([cancelButton, submitButton])
        
        // Create the dialog
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
    // Set the height of each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = reviews[indexPath.section]
        print("Create cell for \(review.getUserEmail())")
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        let email = review.getUserEmail()
        cell.usernameLabel.text = String(email[..<(email.index(of: "@")!)])
        cell.ratedDateLabel.text = "On \(review.getDate())"
        cell.userRating.value = CGFloat(review.getRating())
        cell.userComment.text = review.getComment()
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.movieId = clickedMovieId
        
        // Create a reference to Firebase database
        self.ref = Database.database().reference()
        
        // Load current user if user already logged in
        self.currentUser = Auth.auth().currentUser
        
        // Load movie's details
        self.loadMovieDetails()
        
        self.loadReviewsToReviewTable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load current user if user's just logged in
        self.currentUser = Auth.auth().currentUser
        
        // Check if current user already posted a review for this book
        self.checkIfCurrentUserPostedReview()
        
        // Load average rating
        self.loadAvgRating()
    }
}


