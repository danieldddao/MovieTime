//
//  posterCell.swift
//  MovieTime
//
//  Created by Jon Halverson on 10/23/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import TMDBSwift

class posterCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    var movie: MovieMDB?

    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var title: UILabel!
}
