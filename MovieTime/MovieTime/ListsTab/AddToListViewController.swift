//
//  AddToListViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 05/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class AddToListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let defaults = UserDefaults.standard
    var listMovieID:[Int] = []
    
    @IBOutlet weak var picker: UIPickerView!
    var listNames:[String] = []
    
    @IBAction func selectedList(_ sender: Any) {
        let listName = self.listNames[picker.selectedRow(inComponent: 0)]
        if defaults.object(forKey: listName) == nil{
            listMovieID = []
        }else{
            listMovieID = defaults.object(forKey: listName) as! [Int]
        }
        // add clickedMovieId to the list
        listMovieID.append((clickedMovie?.id)!)
        // exclude duplicated ID
        listMovieID = Array(Set(listMovieID))
        print(listMovieID)
        defaults.set(listMovieID, forKey: listName)
        removeAnimate()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self as UIPickerViewDelegate
        self.picker.dataSource = self as UIPickerViewDataSource
        if defaults.object(forKey: "ListNames") == nil{
            listNames = ["Watched","Favorite top 100"]
        }else{
            
            listNames = defaults.object(forKey: "ListNames") as! [String]
            if listNames[0] == "Explored History" {
                self.listNames.remove(at: 0)
            }
            print(listNames)
        }
        
        
        // Do any additional setup after loading the view.
        //self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
    }
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listNames.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //print(listNames[row])
        return listNames[row]
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
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                
            }
        });
    }

}
