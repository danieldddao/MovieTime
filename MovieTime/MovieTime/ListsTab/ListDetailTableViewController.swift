//
//  ListDetailTableViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 05/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift

class ListDetailTableViewController: UITableViewController {
    var listName:String = ""
    let defaults = UserDefaults.standard
    var listMovieId:[Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 100.0
        //print(self.listName)
        if defaults.object(forKey: listName) == nil{
            self.listMovieId = []
        }else{
            self.listMovieId = defaults.object(forKey: listName) as! [Int]
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(listMovieId.count)
        return listMovieId.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! posterTableCell

        // Configure the cell...
        
        let movieID = self.listMovieId[indexPath.row]
        var posterPath = ""
        var title = ""
        print(movieID)
        MovieMDB.movie(TMDBBase.apiKey, movieID: movieID, language: "en"){
            apiReturn, movie in
            if let movie = movie{
                posterPath = "\(movie.poster_path!)"
                title = movie.title!
                print(title)
                //print(posterPath)
                
            }
            cell.genre.text = movie?.genres[0].name
            cell.title.text = title
            print(cell.title.text!)
            print("\(TMDBBase.imageURL)\(posterPath)")
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
        }
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.listMovieId.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowMovieDetail"{
            let cell=sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                clickedMovieId = self.listMovieId[indexPath.row]
                print(clickedMovieId)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    /*
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        clickedMovieId = self.listMovieId[indexPath.row]
        print("did select:\(clickedMovieId)")
        MovieMDB.movie(TMDBBase.apiKey, movieID: clickedMovieId, language: "en"){
            apiReturn, movie in
            if let movie = movie{
                clickedMovie = movie
                
            }
        }
        return indexPath
    }
    */
    

    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(listMovieId, forKey: listName)
    }
}
