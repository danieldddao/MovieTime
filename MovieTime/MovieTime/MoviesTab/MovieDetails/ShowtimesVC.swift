//
//  ShowtimesVC.swift
//  MovieTime
//
//  Created by Daniel Dao on 11/19/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import WebKit

class ShowtimesVC: UIViewController {

    @IBOutlet weak var showtimesLabel: UILabel!
    @IBOutlet var showtimesWebview: WKWebView!
    
    var urlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlString)
        let request = NSURLRequest(url: url!)
        self.showtimesWebview.load(request as URLRequest)
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
