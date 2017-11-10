//
//  CollectionViewController.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/21/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift


struct PopularMoviesPage: Codable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}

var clickedMovie: MovieMDB?

class CollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    
    var popularMovies = [Int: MovieMDB]()
    var popMoviesArray = [MovieMDB]()
    var pageToLoad = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populatePosters(page: 1)
        populatePosters(page: 2)
        populatePosters(page: 3)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popMoviesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! posterCell
                
        let movie: MovieMDB
        movie = popMoviesArray[indexPath.row]
        
        if !(movie.poster_path == nil){
            let posterPath = "\(movie.poster_path!)"
            if let imageURL = URL(string:"\(TMDBBase.imageURL)\(posterPath)"){
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
        } else {
            cell.imgView.image = UIImage(named: "image_not_available")
        }
        
        return cell
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = self.popMoviesArray[indexPath.row]
        clickedMovie = movie
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        if indexPath.item == popMoviesArray.count-1 {
            populatePosters(page: pageToLoad)
            pageToLoad += 1
        }
    }

    
    func populatePosters(page: Int) {
        
        MovieMDB.popular(TMDBBase.apiKey, language: "en", page: page){
            data, popMovies in
            if let movies = popMovies{
                self.popMoviesArray.append(contentsOf: movies)
                for movie in movies{
                    if self.popularMovies[movie.id!] == nil {
                        self.popularMovies[movie.id!] = movie
                    }
                    print(movie.title!)
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
}

