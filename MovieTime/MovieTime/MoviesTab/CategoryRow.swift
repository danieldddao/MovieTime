//
//  CategoryRow.swift
//  MovieTime
//
//  Created by Jon Halverson on 11/10/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift

class CategoryRow : UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var genre:Genre? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
}

extension CategoryRow : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genre!.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath as IndexPath) as! posterCell
        
        let movie: MovieMDB
        movie = (genre?.movies[indexPath.row])!
        
        if movie.poster_path != nil{
            //print("\(TMDBBase.imageURL)\(posterPath)")
            if let imageURL = URL(string:"\(TMDBBase.imageURL)\(movie.poster_path!)"){
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageURL)
                    if let data = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)
                            cell.imgView.image = image
                        }
                    }
                }
            }
        } else {
            cell.imgView.image = UIImage(named: "image_not_available")
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let movie = genre?.movies[indexPath.row]{
//            clickedMovie = movie
            clickedMovieId = movie.id!
        }
    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
//        if indexPath.item == popMoviesArray.count-1 {
//            populatePosters(page: pageToLoad)
//            pageToLoad += 1
//        }
//    }
    
}
