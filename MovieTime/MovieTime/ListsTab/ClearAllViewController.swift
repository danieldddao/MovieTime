//
//  ClearAllViewController.swift
//  MovieTime
//
//  Created by Dixian Zhu on 26/11/2017.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class ClearAllViewController: UIViewController {

    @IBAction func cancel(_ sender: Any) {
        self.cancelClear()
    }
    @IBAction func clear(_ sender: Any) {
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
    
    func cancelClear(){
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
                for name in listVC.listNames{
                    listVC.defaults.removeObject(forKey: name)
                    print(listVC.listNames)
                }
                
                listVC.tableView.reloadData()
                self.view.removeFromSuperview()
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
