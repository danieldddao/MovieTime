//
//  TableViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 04/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//
// watched list and favorate top 100 list
// other user's custom lists
import UIKit

class ListTableViewController: UITableViewController {
    var listNum:Int = 2
    var customListNum:Int = 0
    var listNames:[String] = ["Watched","Favorite top 100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        listNum += customListNum
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
        return listNum + 1
        /*
        if self.tableView.isEditing{
            return listNum + 1
        }else{
            return listNum
        }
        */
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)
        if indexPath.row < listNum{
            cell.textLabel?.text = self.listNames[indexPath.row]
        }
        
        // Configure the cell...
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row > 1{
            return true
        }else{
            return false
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == listNum{
            return .insert
        }else{
            return .delete
        }
        
    }
    
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            if indexPath.row > 1{
                self.listNames.remove(at: indexPath.row)
                self.listNum -= 1
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
            self.listNames.append("waiting")
            self.listNum += 1
            self.tableView.insertRows(at: [indexPath], with: .fade)
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
