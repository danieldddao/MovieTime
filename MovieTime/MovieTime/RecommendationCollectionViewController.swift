//
//  RecommendationCollectionViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 30/10/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class RecommendationCollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    
    
    var recommendMovieId = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recommend(num: 12)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMovies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! posterCell
        
        let baseUrlString = "http://image.tmdb.org/t/p/w185"
        let movieID = self.recommendMovieId[indexPath.row]
        print(indexPath.row)
        let posterPath = "\(popularMovies[movieID]!.poster_path)"
        if let imageURL = URL(string:"\(baseUrlString)\(posterPath)"){
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imgView.image = image
                    }
                }
            }
        }
        
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieID = self.recommendMovieId[indexPath.row]
        clickedMovieId = popularMovies[movieID]!.id
        print("in function id: \(clickedMovieId)")
        
    }
    
    
    func recommend(num: Int) {
        //generate recommendMovieId with size: num
        
        self.recommendMovieId = popularMoviesAsArray.slice(start: 0, end: num-1)
        print(self.recommendMovieId)
        self.collectionView?.reloadData()
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
