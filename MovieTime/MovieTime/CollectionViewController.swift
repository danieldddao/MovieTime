//
//  CollectionViewController.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/21/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit


struct PopularMoviesPage: Codable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}



let apiKey = "3cc9e662a8461532d3d5e5d722ef582b"
var clickedMovie: Movie?


class CollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    
    var popMoviesArray = [Movie]()
    
    
    var searchResults = [Movie]()
    
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
        
        let baseUrlString = "http://image.tmdb.org/t/p/w185"
        let movie = self.popMoviesArray[indexPath.row]
        let posterPath = "\(movie.poster_path)"
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
        let movie = self.popMoviesArray[indexPath.row]
        clickedMovie = movie
    }

    
    func populatePosters(page: Int) {
        
        let jsonUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=\(page)"

        guard let url = URL(string: jsonUrlString) else{ return }
        URLSession.shared.dataTask(with: url) { (data, urlResponse, err) in

            guard let data = data else { return }

            do {

                let popularMoviesPage =  try JSONDecoder().decode(PopularMoviesPage.self, from: data)
                
                self.popMoviesArray.append(contentsOf: popularMoviesPage.results)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }

            }.resume()
    }
    
    func populateSearchResults() {
        
        let jsonUrlString = "https://api.themoviedb.org/3/search/movie?api_key=3cc9e662a8461532d3d5e5d722ef582b&query=dunk&page=1"
        
        guard let url = URL(string: jsonUrlString) else{ return }
        URLSession.shared.dataTask(with: url) { (data, urlResponse, err) in
            
            guard let data = data else { return }
            
            do {
                
                let popularMoviesPage =  try JSONDecoder().decode(PopularMoviesPage.self, from: data)
                
                for movie in popularMoviesPage.results{
                    print(movie.title)
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            
            }.resume()
    }
    
}

