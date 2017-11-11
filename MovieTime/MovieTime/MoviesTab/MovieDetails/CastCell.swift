//
//  CastCell.swift
//  MovieTime
//
//  Created by Daniel Dao on 11/6/17.
//  Copyright © 2017 Team 4. All rights reserved.
//

import UIKit

class CastCell: UICollectionViewCell {
    @IBOutlet weak var castImage: UIImageView!
    @IBOutlet weak var castName: UILabel!
    @IBOutlet weak var castRole: UILabel!
    var castId: Int!
}
