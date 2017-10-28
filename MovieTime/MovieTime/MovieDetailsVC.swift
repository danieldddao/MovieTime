//
//  MovieDetailsVC.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/24/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class MovieDetailsVC: UIViewController {

    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("clicked movie ID: \(clickedMovieId)")
        
        // Import Data
        titleLbl.text = popularMovies[clickedMovieId]?.title
    }

}
