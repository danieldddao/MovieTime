//
//  CollectionViewController.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/21/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

struct PopularMoviesPage: Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}

struct Movie: Decodable {
    let id: Int
    let poster_path: String
    let title: String
}

class CollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    
    var popularMovies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=3cc9e662a8461532d3d5e5d722ef582b&language=en-US&page=1"
        
        guard let url = URL(string: jsonUrlString) else{ return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            // check err
            // check response
            
            guard let data = data else { return }
            
            do {
                let popularMoviesPage =  try JSONDecoder().decode(PopularMoviesPage.self, from: data)
                
                for movie in popularMoviesPage.results {
                    self.popularMovies.append(movie)
                }
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            
            }.resume()
        print("resumed")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMovies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("Create Cell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! posterCell
        cell.titleLbl.text = popularMovies[indexPath.row].title
        
        
        return cell
    }
    
    
}

