//
//  RestaurantTableViewCell.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/18.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet var restaurantLabel: UILabel!
    @IBOutlet var restaurantImage: UIImageView!
    @IBOutlet var restaurantSummary: UILabel!
    @IBOutlet var restaurantDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
