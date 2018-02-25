//
//  RestaurantCalloutView.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/17.
//  Copyright © 2016 CHOW. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class RestaurantCalloutView: MKAnnotationView {
    @IBOutlet var summary: UITextView!
    @IBOutlet var title: UILabel!
    @IBOutlet var picture: UIImageView!
    @IBAction func click(_ sender: AnyObject) {
        print("hi")
    }
}
