//
//  CollectionViewController.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/21/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

struct Movie: Codable {
    var id: Int
    var title: String
    var poster_path: String
}

struct PopularMoviesPage: Codable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}

var popularMovies = [Int: Movie]()
var clickedMovieId = 0


class CollectionViewController: UICollectionViewController {
    
    var baseURI: String = "api.themoviedb.org/3"
    var apiKey: String = "3cc9e662a8461532d3d5e5d722ef582b"
    

    var popularMoviesAsArray = [Int]()
    

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
        return popularMovies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! posterCell
        
        let baseUrlString = "http://image.tmdb.org/t/p/w185"
        let movieID = self.popularMoviesAsArray[indexPath.row]
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
        let movieID = self.popularMoviesAsArray[indexPath.row]
        clickedMovieId = popularMovies[movieID]!.id
        print("in function id: \(clickedMovieId)")
        self.performSegue(withIdentifier: "gotoMovieDetailPage", sender: self)
    }

    
    func populatePosters(page: Int) {
        
        let jsonUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=3cc9e662a8461532d3d5e5d722ef582b&language=en-US&page=\(page)"

        guard let url = URL(string: jsonUrlString) else{ return }
        URLSession.shared.dataTask(with: url) { (data, urlResponse, err) in

            guard let data = data else { return }

            do {
                let popularMoviesPage =  try JSONDecoder().decode(PopularMoviesPage.self, from: data)
                print("popularMoviesPage: \(popularMoviesPage)")
                for movie in popularMoviesPage.results{
                    popularMovies[movie.id] = movie
                }
                self.popularMoviesAsArray = Array(popularMovies.keys)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }

            }.resume()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoMovieDetailPage" {
            let mdVC:MovieDetailsVC = segue.destination as! MovieDetailsVC
            mdVC.movieId = clickedMovieId
            mdVC.startAnimating(nil, message: "Loading", messageFont: nil, type: nil, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.9), textColor: nil)
        }
    }
}

