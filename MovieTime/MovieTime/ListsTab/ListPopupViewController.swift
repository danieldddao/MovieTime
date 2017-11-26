//
//  ListPopupViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 05/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class ListPopupViewController: UIViewController {
    var listName: String = "default"
    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func cancelEnter(_ sender: Any) {
        self.removeAnimateNull()
    }
    @IBAction func enterListName(_ sender: Any) {
        self.listName = inputField.text!
        //print("in:")
        //print(self.listName)
        self.removeAnimate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
        // Do any additional setup after loading the view.
    }
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimateNull(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                
                self.view.removeFromSuperview()
                
            }
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
                let listVC = self.parent as! ListTableViewController
                listVC.listNames.append(self.listName)
                listVC.listNum += 1
                print(listVC.listNames)
                listVC.tableView.reloadData()
                self.view.removeFromSuperview()
                listVC.defaults.set(listVC.listNames, forKey: "ListNames")
            }
        });
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
