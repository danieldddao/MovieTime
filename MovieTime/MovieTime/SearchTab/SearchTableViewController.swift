//
//  SearchTableViewController.swift
//  MovieTime
//
//  Created by Jon Halverson on 11/10/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        populateSearchResults(query: searchController.searchBar.text!)
    }
}

class SearchTableViewController: UITableViewController {

    var searchResults = [MovieMDB]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchResultCell

        let movie: MovieMDB
        movie = searchResults[indexPath.row]
        
        // Load Title into cell
        cell.titleLbl.text = movie.title
        
        // Load poster into cell
        if !(movie.poster_path == nil){
            let posterPath = "\(movie.poster_path!)"
            if let imageURL = URL(string:"\(TMDBBase.imageURL)\(posterPath)"){
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageURL)
                    if let data = data {
                        let image = UIImage(data: data)
                        DispatchQueue.main.async {
                            cell.posterImg.image = image
                        }
                    }
                }
            }
        } else {
            cell.posterImg.image = UIImage(named: "image_not_available")
        }

        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "searchpageToMovieDetailPage" {
//            let mdVC:MovieDetailsVC = segue.destination as! MovieDetailsVC
//            mdVC.movieId = clickedMovieId
//            mdVC.startAnimating(nil, message: "Loading", messageFont: nil, type: nil, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.9), textColor: nil)
//        }
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = searchResults[indexPath.row]
//        clickedMovie = movie
        clickedMovieId = movie.id!
    }
    
    func populateSearchResults(query: String) {
        
        SearchMDB.movie(TMDBBase.apiKey, query: query, language: "en", page: 1, includeAdult: true, year: nil, primaryReleaseYear: nil){
            data, movies in
            if let tempSearchResults = movies{
                self.searchResults = tempSearchResults
            } else {
                self.searchResults.removeAll()
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}
