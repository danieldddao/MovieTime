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
import AVFoundation
import AVKit
import youtube_ios_player_helper
import NVActivityIndicatorView

class MovieDetailsVC: UIViewController, TableViewDelegate, TableViewDataSource, CollectionViewDelegate, CollectionViewDataSource, YTPlayerViewDelegate, NVActivityIndicatorViewable {
    
    var movieId: Int = 141052
    var currentUser:User? = nil
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var nativationItem: UINavigationItem!
    
    @IBAction func addToList(_ sender: Any) {
        let popupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectListID") as! AddToListViewController
        self.addChildViewController(popupVC)
        popupVC.view.frame = self.view.frame
        self.view.addSubview(popupVC.view)
        popupVC.didMove(toParentViewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "writeReviewMustLogin" {
            let lsVC:LoginSignupVC = segue.destination as! LoginSignupVC
            lsVC.alert = "Please login to write a review!"
        } else if segue.identifier == "movieToPersonInfo" {
            let personVC:PersonInfoVC = segue.destination as! PersonInfoVC
            personVC.tableTitle = personInfoTableTitle
            personVC.personId = personInfoId
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
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    
    @IBOutlet weak var castCollectionView: CollectionView!
    @IBOutlet weak var crewCollectionView: CollectionView!
    @IBOutlet weak var genresCollectionView: CollectionView!
    
    var youtubePlayerView: YTPlayerView!
    var homepage:String?
    
    var crewMembers: [CrewMDB] = []
    var castMembers: [MovieCastMDB] = []
    var genres: [genresType] = []
    public typealias genresType = (id: Int?, name: String?)
    var personInfoTableTitle:String!
    var personInfoId:Int!
    
    // Set headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == castCollectionView {
            switch kind {
            case UICollectionElementKindSectionHeader:
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "castHeader", for: indexPath)
                reusableview.backgroundColor = UIColor.clear
                return reusableview
                
            default:  fatalError("Unexpected element kind")
            }
        } else if collectionView == crewCollectionView {
            switch kind {
            case UICollectionElementKindSectionHeader:
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "crewHeader", for: indexPath)
                reusableview.backgroundColor = UIColor.clear
                return reusableview
                
            default:  fatalError("Unexpected element kind")
            }
        } else {
            switch kind {
            case UICollectionElementKindSectionHeader:
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "genreHeader", for: indexPath)
                reusableview.backgroundColor = UIColor.clear
                return reusableview
                
            default:  fatalError("Unexpected element kind")
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == castCollectionView {
            return castMembers.count
        } else if collectionView == crewCollectionView {
            return crewMembers.count
        } else {
            return genres.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == castCollectionView {
            let member = castMembers[indexPath.row]
            //            print("cell for cast member: \(member.name)")
            let cell = castCollectionView.dequeueReusableCell(withReuseIdentifier: "castCell", for: indexPath) as! CastCell
            cell.castImage.image = UIImage(named: "emptyCast")
            cell.castName.text = member.name
            cell.castRole.text = member.character
            cell.castId = member.cast_id
            //            print("cast: \(member.name) \(member.profile_path)")
            if member.profile_path != nil {
                if let castImageUrl = URL(string: "\(TMDBBase.imageURL)\(member.profile_path!)"){
                    let data = try? Data(contentsOf: castImageUrl)
                    if let data = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)!
                            cell.castImage.image = image
                        }
                    }
                }
            }
            return cell
        } else if collectionView == crewCollectionView {
            let member = crewMembers[indexPath.row]
            //            print("cell for crew member: \(member.name)")
            let cell = crewCollectionView.dequeueReusableCell(withReuseIdentifier: "crewCell", for: indexPath) as! CrewCell
            cell.jobLabel.text = member.job
            cell.departmentLabel.text = member.department
            cell.nameLabel.text = member.name
            cell.crewId = member.id
            return cell
        } else {
            let genre = genres[indexPath.row]
            //            print("cell for genre: \(member.name)")
            let cell = genresCollectionView.dequeueReusableCell(withReuseIdentifier: "genreCell", for: indexPath) as! GenreCell
            cell.genreLabel.text = genre.name!
            return cell
            
        }
    }
    // Tap on a crew or cast
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == castCollectionView || collectionView == crewCollectionView {
            //            print("cast/crew cell selected: \(indexPath.row)")
            if collectionView == castCollectionView {
                let cast = castMembers[indexPath.row]
                personInfoId = cast.id
                personInfoTableTitle = "Appeared in:"
            } else {
                personInfoId = crewMembers[indexPath.row].id
                personInfoTableTitle = "In Movies:"
            }
            self.performSegue(withIdentifier: "movieToPersonInfo", sender: self)
        }
    }
    
    // Automatically play trailer video when it's ready
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayerView.playVideo()
        self.stopAnimating() // stop activity indicator
    }
    // Play Youtube trailer when trailer button is pressed
    @IBAction func trailerButtonPressed(_ sender: RaisedButton) {
        MovieMDB.videos(TMDBBase.apiKey, movieID: movieId, language: "en"){
            apiReturn, videos in
            var youtubetrailerID: String?
            if let videos = videos {
                for i in videos {
                    if i.site != nil && i.site! == "YouTube" {
                        youtubetrailerID = i.key!
                        break;
                    }
                }
            }
            if youtubetrailerID == nil {
                self.showAlert("Sorry! Trailer is currently not available for this movie!")
            } else {
                // show activity indicator
                self.startAnimating(nil, message: "Loading Trailer", messageFont: nil, type: nil, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
                
                self.youtubePlayerView.load(withVideoId: youtubetrailerID!)
            }
        }
    }
    @IBAction func homeButtonPressed(_ sender: RaisedButton) {
        if (self.homepage == nil || (self.homepage?.isEmpty)!) {
            self.showAlert("Homepage is not available")
        } else {
            if let url = URL(string: homepage!) {
                UIApplication.shared.open(url, options: [:])
            } else {
                self.showAlert("Homepage is not available")
            }
        }
    }
    
    func loadMovieDetails() {
        // Load Movie details from Movie Id and show datails on screen
        MovieMDB.movie(TMDBBase.apiKey, movieID: movieId, language: "en"){
            apiReturn, movie in
            if let movie = movie {
                
                // Show poster and background
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
                            let processedImage = UIImage(cgImage: cgimg!).alpha(0.5)
                            
                            //                            print("image darkness:\(processedImage.isDark)")
                            self.movieDetailView.image = processedImage
                            
                            self.stopAnimating()
                        }
                    }
                }
                
                if movie.title == nil {
                    self.navigationItem.title = "N/A"
                    self.titleLabel.text = "N/A"
                } else {
                    self.navigationItem.title = movie.title!
                    self.titleLabel.text = movie.title!
                }
                
                if movie.overview == nil {
                    self.overviewTextView.text = "Overview:"
                } else {
                    self.overviewTextView.text = "Overview:\n\(movie.overview!)"
                }
                
                if movie.vote_average == nil {
                    self.userScoreIndicator.value = CGFloat(0)
                } else {
                    self.userScoreIndicator.value = CGFloat(movie.vote_average!)
                }
                
                if movie.status == nil {
                    self.statusLabel.text = "Status:\n-"
                } else {
                    self.statusLabel.text = "Status:\n\(movie.status!)"
                    if movie.status!.lowercased() != "released" {
                        self.writeReviewButton.isEnabled = false
                        self.writeReviewButton.title = "Review not available"
                        self.writeReviewButton.titleColor = UIColor.black
                        self.writeReviewButton.backgroundColor = UIColor.lightGray
                    }
                }
                
                if movie.runtime == nil {
                    self.runtimeLabel.text = "Runtime:\n-"
                } else {
                    let runTime = movie.runtime!
                    self.runtimeLabel.text = "Runtime:\n\(runTime/60)h \(runTime%60)m"
                }
                
                if movie.release_date == nil {
                    self.releaseDateLabel.text = "Release Date:\n-"
                } else {
                    let releaseDate = movie.release_date!
                    let releaseYear = releaseDate[..<(releaseDate.index(of: "-")!)]
                    
                    self.releaseDateLabel.text = "Release Date:\n\(releaseDate)"
                    self.navigationItem.title = self.navigationItem.title!  + " (\(releaseYear))"
                    self.titleLabel.text = self.titleLabel.text!  + " (\(releaseYear))"
                }
                
                if movie.budget == nil {
                    self.budgetLabel.text = "Budget:\n-"
                } else {
                    if movie.budget! >= 1000000000 {
                        let budget = movie.budget! / 1000000
                        self.budgetLabel.text = "Budget:\n\(budget)B"
                    } else {
                        let budget = movie.budget! / 1000000
                        self.budgetLabel.text = "Budget:\n\(budget)M"
                    }
                }
                
                if movie.revenue == nil {
                    self.revenueLabel.text = "Revenue:\n-"
                } else {
                    if movie.revenue! >= 1000000000 {
                        let revenue = movie.revenue! / 1000000000
                        self.revenueLabel.text = "Revenue:\n\(revenue)B"
                    } else {
                        let revenue = movie.revenue! / 1000000
                        self.revenueLabel.text = "Revenue:\n\(revenue)M"
                    }
                }
                
                if movie.original_language == nil {
                    self.languageLabel.text = "Language:\n-"
                } else {
                    self.languageLabel.text = "Language:\n\(movie.original_language!)"
                }
                
                if movie.adult == true {
                    self.adultLabel.text = "For Adult:\nYes"
                } else {
                    self.adultLabel.text = "For Adult:\nNo"
                }
                
                self.taglineLabel.text = "Tagline:\n\(movie.tagline!)"
                self.homepage = movie.homepage
                
                for genre in movie.genres {
                    if (genre.name != nil) {
                        self.genres.append(genre)
                        DispatchQueue.main.async {
                            self.genresCollectionView.reloadData()
                        }
                    }
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
                    DispatchQueue.main.async {
                        self.castCollectionView.reloadData()
                    }
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
                    self.checkIfCurrentUserPostedReview()
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
        print("MovieDetailsVC loading")
        self.startAnimating(nil, message: "Loading", messageFont: nil, type: nil, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.9), textColor: nil)
        
        // get clicked movie id
        self.movieId = clickedMovieId
        var historyMovieID:[Int] = []
        // deal with user explored history
        //defaults.removeObject(forKey: "Explored History")
        if defaults.object(forKey: "Explored History") == nil{
            historyMovieID = []
        }else{
            historyMovieID = defaults.object(forKey: "Explored History") as! [Int]
        }
        historyMovieID.insert(self.movieId, at: 0)
        // only care about 50 history records
        if historyMovieID.count > 50 {
            historyMovieID.remove(at: 50)
        }
        defaults.set(historyMovieID, forKey: "Explored History")
        
        
        self.youtubePlayerView = YTPlayerView()
        self.youtubePlayerView.delegate = self
        
        // Set background color of each collection view to clear
        castCollectionView.backgroundColor = UIColor.clear
        var layout = castCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        crewCollectionView.backgroundColor = UIColor.clear
        layout = crewCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        genresCollectionView.backgroundColor = UIColor.clear
        layout = genresCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
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
