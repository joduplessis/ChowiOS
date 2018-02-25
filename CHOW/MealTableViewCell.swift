//
//  MealTableViewCell.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/27.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet var mealImage: UIImageView!
    @IBOutlet var mealHeading: UILabel!
    @IBOutlet var mealSummary: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
