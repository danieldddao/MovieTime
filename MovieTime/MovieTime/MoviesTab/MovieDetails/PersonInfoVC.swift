//
//  MemberInfoVC.swift
//  MovieTime
//
//  Created by Daniel Dao on 11/9/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import Material
import TMDBSwift

class PersonInfoVC: UIViewController, TableViewDelegate, TableViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var biographyLabel: TextView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var placeOfBirthLabel: UILabel!
    @IBOutlet weak var deathdayLabel: UILabel!
    @IBOutlet weak var akaTextView: TextView!
    @IBOutlet weak var tableLabel: UILabel!
    @IBOutlet weak var movieTableView: UITableView!
    
    var personId:Int!
    var tableTitle:String!
    var castMovies:[PersonMovieCast] = []
    var crewMovies:[PersonMovieCrew] = []

    var dataSourceItems: [DataSourceItem] = []
    
    func tableView(_ movieTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableTitle == "Appeared in:" {
            return castMovies.count
        } else {
            return crewMovies.count
        }
    }
    func tableView(_ movieTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.movieTableView.dequeueReusableCell(withIdentifier: "personMoviesCell", for: indexPath) as! PersonMoviesCell
        cell.movieImage.image = UIImage(named: "emptyPoster")

        if tableTitle == "Appeared in:" {
            let movie = castMovies[indexPath.row]
            let releaseDate = movie.release_date
            if releaseDate != nil && releaseDate != "" {
                let releaseYear = releaseDate![..<(releaseDate!.index(of: "-")!)]
                cell.movieTitleLabel.text = "\(movie.title!) (\(releaseYear))"
            } else {
                cell.movieTitleLabel.text = "\(movie.title!)"
            }
            cell.characterLabel.text = "as \(movie.character!)"
            if movie.poster_path != nil {
                if let posterUrl = URL(string: "\(TMDBBase.imageURL)\(movie.poster_path!)"){
                    let data = try? Data(contentsOf: posterUrl)
                    if let data = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)!
                            cell.movieImage.image = image
                        }
                    }
                }
            }
        } else {
            let movie = crewMovies[indexPath.row]
            let releaseDate = movie.release_date
            if releaseDate != nil && releaseDate != "" {
                let releaseYear = releaseDate![..<(releaseDate!.index(of: "-")!)]
                cell.movieTitleLabel.text = "\(movie.title!) (\(releaseYear))"
            } else {
                cell.movieTitleLabel.text = "\(movie.title!)"
            }
            cell.characterLabel.text = "\(movie.job!)"
            if movie.poster_path != nil {
                if let posterUrl = URL(string: "\(TMDBBase.imageURL)\(movie.poster_path!)"){
                    let data = try? Data(contentsOf: posterUrl)
                    if let data = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)!
                            cell.movieImage.image = image
                        }
                    }
                }
            }
        }
        return cell
    }
    // Select a movie, go to detail page of that movie
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // movie from cast's movies
        if tableTitle == "Appeared in:" {
            clickedMovieId = castMovies[indexPath.row].id
        } else {
            clickedMovieId = crewMovies[indexPath.row].id
        }
        self.performSegue(withIdentifier: "personToMovieDetails", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("loading member \(personId!)")
        tableLabel.text = tableTitle
        movieTableView.backgroundColor = UIColor.clear
        movieTableView.tableHeaderView = nil
        
        PersonMDB.person_id(TMDBBase.apiKey, personID: personId){
            data, personData in
            if let person = personData{
                if person.profile_path != nil {
                    if let castImageUrl = URL(string: "\(TMDBBase.imageURL)\(person.profile_path!)"){
                        let data = try? Data(contentsOf: castImageUrl)
                        if let data = data {
                            DispatchQueue.main.async {
                                let image = UIImage(data: data)!
                                self.imageView.image = image
                            }
                        }
                    }
                }
                self.nameLabel.text = person.name
                if person.biography == nil {
                    self.biographyLabel.text = "Biography:\n-"
                } else {
                    self.biographyLabel.text = "Biography:\n\(person.biography!)"
                }
                
                if person.gender == 0 {
                    self.genderLabel.text = "Gender:\n-"
                } else if person.gender == 1 {
                    self.genderLabel.text = "Gender:\nFemale"
                } else {
                    self.genderLabel.text = "Gender:\nMale"
                }
                
                if person.birthday == nil {
                    self.birthdayLabel.text = "Birthday:\n-"
                } else {
                    self.birthdayLabel.text = "Birthday:\(person.birthday!)"
                }
                if person.place_of_birth == nil {
                    self.placeOfBirthLabel.text = "Place of birth:\n-"
                } else {
                    self.placeOfBirthLabel.text = "Place of birth:\n\(person.place_of_birth!)"
                }
                
                if person.deathday == nil {
                    self.deathdayLabel.text = ""
                } else {
                    self.deathdayLabel.text = "Deathday:\n\(person.deathday!)"
                }

                if person.also_known_as == nil {
                    self.akaTextView.text = "Also Known As:\n-"
                } else {
                    var nameString = "Also Known As:\n"
                    for name in person.also_known_as! {
                        nameString += name + "\n"
                    }
                    self.akaTextView.text = nameString
                }
                
            }
        }
        
        if tableTitle == "Appeared in:" {
            PersonMDB.movie_credits(TMDBBase.apiKey, personID: personId!, language: "en"){
                data, credits in
                if let d = credits{
                    let casts = d.cast.sorted(by: { $0.id < $1.id })
                    for cast in casts {
                        self.castMovies.append(cast)
                        DispatchQueue.main.async {
                            self.movieTableView.reloadData()
                        }
                        
                    }
                }
            }
        } else {
            PersonMDB.movie_credits(TMDBBase.apiKey, personID: personId!, language: "en"){
                data, credits in
                if let d = credits{
                    let crews = d.crew.sorted(by: { $0.id < $1.id })
                    for crew in crews {
                        self.crewMovies.append(crew)
                        DispatchQueue.main.async {
                            self.movieTableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
