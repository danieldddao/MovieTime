//
//  ReviewTableViewCell.swift
//  MovieTime
//
//  Created by Daniel Dao on 10/30/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit
import HCSStarRatingView
import Material

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratedDateLabel: UILabel!
    @IBOutlet weak var userRating: HCSStarRatingView!
    @IBOutlet var userComment: TextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
