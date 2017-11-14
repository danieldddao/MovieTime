//
//  recommend.swift
//  MovieTime
//
//  Created by Dixian Zhu on 12/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import Foundation
import TMDBSwift

class recommender{
    let listNames = ["Explored History","Watched","Favorite top 100"]
    var hisID:[Int] = []
    var watchedID:[Int] = []
    var favoID:[Int] = []
    var allGenres:[String] = [] //featureToGenre
    var genreToFeature:[String:Int] = [:]
    var genreFeatureToRaw:[Int:Int] = [:]
    var hisFeature:[(Int,Double)] = []
    var favoFeature:[(Int,Double)] = []
    var hisDiscreteDate:[Int] = []
    var favoDiscreteDate:[Int] = []
    let defaults = UserDefaults.standard
    var yearInterval:Double = 5
    var basicRecommendMovieId:[Int] = []
    init(completion:@escaping (_ recommender: recommender) -> ()) {
        if defaults.object(forKey: listNames[0]) == nil{
            hisID = []
        }else{
            hisID = defaults.object(forKey: listNames[0]) as! [Int]
        }
        if defaults.object(forKey: listNames[1]) == nil{
            watchedID = []
        }else{
            watchedID = defaults.object(forKey: listNames[1]) as! [Int]
        }
        if defaults.object(forKey: listNames[2]) == nil{
            favoID = []
        }else{
            favoID = defaults.object(forKey: listNames[2]) as! [Int]
        }
        GenresMDB.genres(TMDBBase.apiKey, listType: .movie, language: "en"){
            apiReturn, genres in
            if let genres = genres{
                var i = 0
                genres.forEach{
                    print($0.name!)
                    print($0.id!)
                    self.allGenres.append($0.name!)
                    
                    self.genreToFeature[$0.name!] = i
                    self.genreFeatureToRaw[i] = $0.id!
                    i += 1
                }
                for id in self.hisID{
                    MovieMDB.movie(TMDBBase.apiKey, movieID: id, language: "en"){
                        apiReturn, movie in
                        if let movie = movie{
                            print(movie.genres[1].name!)
                            
                            print(movie.release_date!)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: movie.release_date!)
                            let startDate = dateFormatter.date(from: "1900-01-01")
                            // date to integer
                            let dateFeature = date?.timeIntervalSince(startDate!)
                            
                            let genreFeature = self.genreToFeature[movie.genres[1].name!]
                            print(dateFeature!, genreFeature!)
                            self.hisFeature.append((genreFeature!, dateFeature!))
                            if self.hisFeature.count == self.hisID.count && self.favoFeature.count == self.favoID.count{
                                completion(self)
                            }
                        }
                    }
                    
                }
                
                for id in self.favoID{
                    MovieMDB.movie(TMDBBase.apiKey, movieID: id, language: "en"){
                        apiReturn, movie in
                        if let movie = movie{
                            print(movie.genres[1].name!)
                            
                            print(movie.release_date!)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.date(from: movie.release_date!)
                            let startDate = dateFormatter.date(from: "1900-01-01")
                            // date to integer
                            let dateFeature = date?.timeIntervalSince(startDate!)
                            let genreFeature = self.genreToFeature[movie.genres[1].name!]
                            print(dateFeature!, genreFeature!)
                            self.favoFeature.append((genreFeature!, dateFeature!))
                            if self.hisFeature.count == self.hisID.count && self.favoFeature.count == self.favoID.count{
                                completion(self)
                            }
                        }
                        
                    }
                    
                }
                
                
            }
        }
        
        
    }
    func preprocessing(yearInterval: Double){
        
        self.yearInterval = yearInterval
        let timeInterval:Double = yearInterval*365*24*3600
        
        // discretize date
        if self.hisFeature.count > 0{
            for i in 0...self.hisFeature.count-1{
                let discreteDate = Int(self.hisFeature[i].1/timeInterval)
                //print(discreteDate)
                self.hisDiscreteDate.append(discreteDate)
            }
        }
        if self.favoFeature.count > 0{
            for i in 0...self.favoFeature.count-1{
                let discreteDate = Int(self.favoFeature[i].1/timeInterval)
                //print(discreteDate)
                self.favoDiscreteDate.append(discreteDate)
            }
        }
        
    }
    func basicVotingRecommend(movieNum:Int, completion:@escaping (_ basicRecommendMovieId:[Int]) -> ()){
        let favoWeight:Double = 5
        let hisWeight:Double = 1
        let maxYear:Double = 2020 - 1900
        let dateBin:Int = Int(maxYear/yearInterval)
        var genreVote:[Double] = []
        var dateVote:[Double] = []
        var cardinality:[Double] = []
        var sumGenreVote:Double = 0
        var sumDateVote:Double = 0
        var recommendMovieNum = movieNum
        var notRecommended:Bool = true
        for _ in 0...self.allGenres.count-1{
            genreVote.append(0)
        }
        for _ in 0...dateBin-1{
            dateVote.append(0)
        }
        for elem in self.hisFeature{
            genreVote[elem.0] += hisWeight
            sumGenreVote += hisWeight
        }
        for elem in self.favoFeature{
            genreVote[elem.0] += favoWeight
            sumGenreVote += favoWeight
        }
        for elem in self.hisDiscreteDate{
            dateVote[elem] += hisWeight
            sumDateVote += hisWeight
        }
        for elem in self.favoDiscreteDate{
            dateVote[elem] += favoWeight
            sumDateVote += favoWeight
        }
        
        for i in 0...genreVote.count-1{
            genreVote[i] = genreVote[i]/sumGenreVote
            genreVote[i] = genreVote[i] * Double(movieNum)
        }
        for i in 0...dateVote.count-1{
            dateVote[i] = dateVote[i]/sumDateVote
        }
        
        for i in 0...genreVote.count-1{
            for j in 0...dateVote.count-1{
                cardinality.append(genreVote[i]*dateVote[j])
            }
        }
        print(cardinality)
         let rankCardinality = cardinality.indices.sorted(by: {(obj1:Int, obj2:Int) -> Bool in return cardinality[obj1]>cardinality[obj2]})
        print(rankCardinality)
        var sum:Int = 0
        for k in rankCardinality{
            cardinality[k] = round(cardinality[k])
            sum += Int(cardinality[k])
        }
        cardinality[rankCardinality[0]] += Double(movieNum - sum)
        for k in rankCardinality{
            let i = Int(k / dateVote.count)
            let j = Int(k % dateVote.count)
            var budget:Int = Int(cardinality[k])
            print(budget)
            let recommendGenre = self.genreFeatureToRaw[i]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDate = dateFormatter.date(from: "1900-01-01")
            // Double to date
            let date1 = Date.init(timeInterval: Double(j)*yearInterval*365*24*3600, since: startDate!)
            let date1str = dateFormatter.string(from: date1)
            
            let date2 = Date.init(timeInterval: Double(j+1)*yearInterval*365*24*3600, since: startDate!)
            let date2str = dateFormatter.string(from: date2)
            
            DiscoverMovieMDB.discoverMovies(apikey: TMDBBase.apiKey, language: "EN", page: 2, primary_release_date_gte: "\(date1str)", primary_release_date_lte: "\(date2str)", with_genres: "\(recommendGenre!)"){
            //DiscoverMovieMDB.discoverMovies(apikey: TMDBBase.apiKey,  language:"EN", page: 1, vote_average_gte: 8.0, vote_average_lte: 8, vote_count_gte: 2, with_genres: "\(recommendGenre!)"){
                
                data, movieArr  in
                if let movieArr = movieArr{
                    
                    if budget > 0 && recommendMovieNum > 0{
                        print(date1str)
                        print(date2str)
                        print(recommendGenre!)
                        if movieArr.count > 0 {
                            for i in 0...movieArr.count-1{
                                
                                //check it is not in watched list
                                
                                if budget > 0 && recommendMovieNum > 0{
                                    if self.watchedID.contains(movieArr[i].id!) == false && self.basicRecommendMovieId.contains(movieArr[i].id!) == false && movieArr[i].id != nil{
                                        self.basicRecommendMovieId.append(movieArr[i].id!)
                                        budget -= 1
                                        recommendMovieNum -= 1
                                        
                                        print(movieArr[i].title!)
                                        if budget <= 0{
                                            print(self.basicRecommendMovieId)
                                            print(recommendMovieNum)
                                            break
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                
                            }
                        }
                    }
                    //print("returning")
                    if recommendMovieNum <= 0 && notRecommended{
                        notRecommended = false
                        completion(self.basicRecommendMovieId)
                    }
                }
            }
            //print(k)
            
        }
        
    }
}
