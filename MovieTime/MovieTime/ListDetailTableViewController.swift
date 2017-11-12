//
//  ListDetailTableViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 05/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

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
        return listMovieId.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! posterTableCell

        // Configure the cell...
        let baseUrlString = "http://image.tmdb.org/t/p/w185"
        let movieID = self.listMovieId[indexPath.row]
        let posterPath = "\(popularMovies[movieID]!.poster_path)"
        let title = popularMovies[movieID]!.title
        if let imageURL = URL(string:"\(baseUrlString)\(posterPath)"){
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imgView.image = image
                        cell.title.text = title
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
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(listMovieId, forKey: listName)
    }
}
