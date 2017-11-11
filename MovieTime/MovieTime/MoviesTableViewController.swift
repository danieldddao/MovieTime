//
//  MoviesTableViewController.swift
//  MovieTime
//
//  Created by Jon Halverson on 11/10/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift

class Genre {
    let name:String
    let movies:[MovieMDB]
    
    init(name: String, movies: [MovieMDB]){
        self.name = name
        self.movies = movies
    }
}

var clickedMovie: MovieMDB?

class MoviesTableViewController: UITableViewController {

    let categories = ["Popular", "Drama", "Comedy"]
    
    var popularMovies = [MovieMDB]()
    var dramaMovies = [MovieMDB]()
    var comedyMovies = [MovieMDB]()
    
    var genres = [Genre]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populatePosters(page: 1)
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return genres.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return genres[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryRow
        cell.genre = genres[indexPath.section]
        return cell
    }
    
    func populatePosters(page: Int) {
        
        // Load Popular
        MovieMDB.popular(TMDBBase.apiKey, language: "en", page: page){
            data, popMovies in
            if let movies = popMovies{
                self.popularMovies.append(contentsOf: movies)                
                self.genres.append(Genre(name: "Popular", movies: self.popularMovies))
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
        
        // Load Dramas
        DiscoverMovieMDB.discoverMovies(apikey: TMDBBase.apiKey,  language:"EN", page: Double(page), vote_average_gte: 8.0, vote_average_lte: 8, vote_count_gte: 2, with_genres: MovieGenres.Drama.rawValue){
            data, movieArr  in
            if let movieArr = movieArr{
                self.dramaMovies.append(contentsOf: movieArr)
                self.genres.append(Genre(name: "Drama", movies: self.dramaMovies))
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
        
        // Load Comedy
        DiscoverMovieMDB.discoverMovies(apikey: TMDBBase.apiKey,  language:"EN", page: Double(page), vote_average_gte: 8.0, vote_average_lte: 8, vote_count_gte: 2, with_genres: MovieGenres.Comedy.rawValue){
            data, movieArr  in
            if let movieArr = movieArr{
                self.comedyMovies.append(contentsOf: movieArr)
                self.genres.append(Genre(name: "Comedy", movies: self.comedyMovies))
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
    }

}
