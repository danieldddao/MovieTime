//
//  RecommendationCollectionViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 30/10/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift

private let reuseIdentifier = "cell"

class RecommendationCollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    
    
    
    var recommendMovieId = [Int]()
    var myRecommender:recommender?
    var recommendMovie:[Int:MovieMDB] = [:]
    var recommendationMovies = [MovieMDB]()
    
    @IBAction func perturb(_ sender: Any) {
        myRecommender = recommender(){
            (recommender:recommender) -> () in
        self.myRecommender = recommender
        self.myRecommender?.preprocessing(yearInterval: 5)
        self.myRecommender?.basicVotingRecommend(movieNum: 20, noisyTerm: 0.5){
                (basicRecommendMovieId:[Int]) -> () in
                let tmpId = basicRecommendMovieId
                print("-----------------------------")
                print("get basic voting")
                print(tmpId)
                self.recommendMovieId = tmpId
                print(self.recommendMovieId)
//                self.collectionView?.reloadData()
                self.loadRecommendationMovies()
            }
        }
    }
    @IBAction func refresh(_ sender: Any) {
        myRecommender = recommender(){
            (recommender:recommender) -> () in
            self.myRecommender = recommender
            self.myRecommender?.preprocessing(yearInterval: 5)
            self.myRecommender?.basicVotingRecommend(movieNum: 20, noisyTerm: 0){
                (basicRecommendMovieId:[Int]) -> () in
                let tmpId = basicRecommendMovieId
                print("-----------------------------")
                print("get basic voting")
                print(tmpId)
                self.recommendMovieId = tmpId
                print(self.recommendMovieId)
//                self.collectionView?.reloadData()
                self.loadRecommendationMovies()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        myRecommender = recommender(){
//            (recommender:recommender) -> () in
//            self.myRecommender = recommender
//            self.myRecommender?.preprocessing(yearInterval: 5)
//            self.myRecommender?.basicVotingRecommend(movieNum: 20, noisyTerm: 0){
//                (basicRecommendMovieId:[Int]) -> () in
//                let tmpId = basicRecommendMovieId
//                print("-----------------------------")
//                print("get basic voting")
//                print(tmpId)
//                self.recommendMovieId = tmpId
//                print(self.recommendMovieId)
////                self.collectionView?.reloadData()
//                self.loadRecommendationMovies()
//            }
//        }
        
        /*
        self.recommend(num: 20){
            (tmpId:[Int]) ->() in
            let tmpId = tmpId
            print("++++++++++++++++++++++++++")
            self.recommendMovieId = tmpId
            print(self.recommendMovieId)
        self.collectionView?.reloadData()
            
        }
         */
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myRecommender = recommender(){
            (recommender:recommender) -> () in
            self.myRecommender = recommender
            self.myRecommender?.preprocessing(yearInterval: 5)
            self.myRecommender?.basicVotingRecommend(movieNum: 20, noisyTerm: 0){
                (basicRecommendMovieId:[Int]) -> () in
                let tmpId = basicRecommendMovieId
                print("-----------------------------")
                print("get basic voting")
                print(tmpId)
                self.recommendMovieId = tmpId
                print(self.recommendMovieId)
                //                self.collectionView?.reloadData()
                self.loadRecommendationMovies()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadRecommendationMovies() {
        self.recommendationMovies.removeAll()
        print("\nLoading Recommendation Movies:")
        print(self.recommendMovieId)
        for movieId in self.recommendMovieId {
//            print("\nLoading Movie: \(movieId)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Load movie after 0.5 second
                MovieMDB.movie(TMDBBase.apiKey, movieID: movieId, language: "en"){
                    apiReturn, movie in
                    if let movie = movie{
                        //print("movieId: \(movieId) - movie loaded: \(String(describing: movie.id))")
                        if movie.id != nil {
                            // print("Loaded Movie: \(movie.id!)")
                            self.recommendationMovies.append(movie)
                            self.collectionView?.reloadData()
                        } else {
                            print("Couldn't load Movie: \(movieId)")
                        }
                    }
                }
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("set collection count: \(self.recommendationMovies.count)")
//        print(self.recommendMovieId.count)
//        return self.recommendMovieId.count
        return self.recommendationMovies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! posterCell
        cell.imgView.image = UIImage(named: "emptyPoster")
        cell.title.text = ""
        cell.genres.text = ""
        
        // new way to load movie
        let movie = self.recommendationMovies[indexPath.row]
        if movie.title != nil {
//            print("Loading cell for movie: \(movie.title!)")
            cell.title.text = movie.title!
        }
        if movie.genres.count > 0 {
            cell.genres.text = movie.genres[0].name
            if movie.genres.count > 1 {
                cell.genres.text?.append(", ")
                cell.genres.text?.append(movie.genres[1].name!)
            }
        }
        if movie.poster_path != nil{
            let posterPath = movie.poster_path!
//            print("\(TMDBBase.imageURL)\(posterPath)")
            if let imageURL = URL(string:"\(TMDBBase.imageURL)\(posterPath)"){
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        // Old way to load movie
//        let movieID = self.recommendMovieId[indexPath.row]
//        print(indexPath.row)
//        print(movieID)
//        MovieMDB.movie(TMDBBase.apiKey, movieID: movieID, language: "en"){
//            apiReturn, movie in
//            if let movie = movie{
//                if movie.id != nil{
//
//                    print(movie.id!)
//                    self.recommendMovie[movie.id!] = movie
//
//                    DispatchQueue.main.async {
//                        let title = movie.title!
//                        print(title)
//                        //print(posterPath)
//                        cell.title.text = title
//
//                        cell.genres.text = movie.genres[0].name
//                        if movie.genres.count > 1{
//                            cell.genres.text?.append(", ")
//                            cell.genres.text?.append(movie.genres[1].name!)
//                        }
//                    }
//
//                    if movie.poster_path != nil{
//                        let posterPath = "\(movie.poster_path!)"
//                        print("\(TMDBBase.imageURL)\(String(describing: posterPath))")
//                        if let imageURL = URL(string:"\(TMDBBase.imageURL)\(String(describing: posterPath))"){
//                            let data = try? Data(contentsOf: imageURL)
//                            if let data = data {
//                                DispatchQueue.main.async {
//                                    let image = UIImage(data: data)
//                                    cell.imgView.image = image
//                                    //cell.title.text = title
//                                    //print(cell.title.text!)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
        return cell
    }
    
    


    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieID = self.recommendationMovies[indexPath.row].id!
        clickedMovieId = movieID
//        clickedMovie = recommendMovie[movieID]
        print("in function id: \(clickedMovieId)")
        print("clicked movie: \(self.recommendationMovies[indexPath.row].title ?? "N/A")")
        
    }
    
    
    func recommend(num: Int, completion:@escaping (_ tmpId:[Int]) -> ()) {
        //generate recommendMovieId with size: num
        //use machine learning here
        
        myRecommender?.preprocessing(yearInterval: 5)
        myRecommender?.basicVotingRecommend(movieNum: num, noisyTerm: 0){
            (basicRecommendMovieId:[Int]) -> () in
            let tmpId = basicRecommendMovieId
            print("-----------------------------")
            print("get basic voting")
            print(tmpId)
            completion(tmpId)
        }
        
        
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
