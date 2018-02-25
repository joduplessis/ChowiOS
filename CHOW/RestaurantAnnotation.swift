//
//  RestaurantAnnotation.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/15.
//  Copyright © 2016 CHOW. All rights reserved.
//

import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation {
    
    let id: String?
    let title: String?
    let summary: String
    let image: String
    let coordinate: CLLocationCoordinate2D
    
    init(id: String, title: String, image: String, summary: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.image = image
        self.summary = summary
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String? {
        return summary
    }
    
}