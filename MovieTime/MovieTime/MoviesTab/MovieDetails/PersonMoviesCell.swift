//
//  PersonMoviesCell.swift
//  MovieTime
//
//  Created by Daniel Dao on 11/10/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class PersonMoviesCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var characterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = UIColor.clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
