//
//  AddToListViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 05/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class AddToListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var picker: UIPickerView!
    var listNames:[String] = []
    let defaults = UserDefaults.standard
    @IBAction func selectedList(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self as UIPickerViewDelegate
        self.picker.dataSource = self as? UIPickerViewDataSource
        if defaults.object(forKey: "ListNames") == nil{
            listNames = ["Watched","Favorite top 100"]
        }else{
            
            listNames = defaults.object(forKey: "ListNames") as! [String]
            print(listNames)
        }
        
        // Do any additional setup after loading the view.
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
        print(listNames[row])
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

}
