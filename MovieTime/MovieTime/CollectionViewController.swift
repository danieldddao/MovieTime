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

extension CollectionViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text! == ""){
            populatePosters(page: 1)
            populatePosters(page: 2)
            populatePosters(page: 3)
        } else {
            populateSearchResults(query: searchController.searchBar.text!)
        }
    }
}

class CollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    
    var popularMovies = [Int: MovieMDB]()
    var popMoviesArray = [MovieMDB]()
    var pageToLoad = 4
    
    var searchResults = [MovieMDB]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchResultsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populatePosters(page: 1)
        populatePosters(page: 2)
        populatePosters(page: 3)
        
        // Setup Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return searchResults.count
        }
        return popMoviesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! posterCell
        
        let baseUrlString = "http://image.tmdb.org/t/p/w185"
        
        let movie: MovieMDB
        if isFiltering() {
            movie = searchResults[indexPath.row]
        } else {
            movie = popMoviesArray[indexPath.row]
        }
        if !(movie.poster_path == nil){
            let posterPath = "\(movie.poster_path!)"
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
        } else {
            cell.imgView.image = UIImage(named: "image_not_available")
        }
        
        
        return cell
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie: MovieMDB
        if (searchResultsLoaded){
            movie = self.searchResults[indexPath.row]
        } else {
            movie = self.popMoviesArray[indexPath.row]
        }
        
        clickedMovie = movie
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
        print("Bottom of View")
        if indexPath.item == popMoviesArray.count{
            populatePosters(page: pageToLoad)
            print("Loaded Page \(pageToLoad)")
        }
    }

    
    func populatePosters(page: Int) {
        searchResultsLoaded = false
        
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
    
    func populateSearchResults(query: String) {
        searchResultsLoaded = true

        SearchMDB.movie(TMDBBase.apiKey, query: query, language: "en", page: 1, includeAdult: true, year: nil, primaryReleaseYear: nil){
            data, movies in
            self.searchResults = movies!
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
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

