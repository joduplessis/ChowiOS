//
//  Notification.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/16.
//  Copyright © 2016 CHOW. All rights reserved.
//

import Foundation
import UIKit

func createNotification(viewForNotification: UIViewController, message: String) {
    let toastLabel = UILabel(frame: CGRectMake(viewForNotification.view.frame.size.width/2 - 150, viewForNotification.view.frame.size.height-100, 300, 35))
    toastLabel.backgroundColor = UIColor.blackColor()
    toastLabel.textColor = UIColor.whiteColor()
    toastLabel.textAlignment = NSTextAlignment.Center;
    viewForNotification.view.addSubview(toastLabel)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    UIView.animateWithDuration(4.0, delay: 0.1, options: .CurveEaseOut, animations: {toastLabel.alpha = 0.0 }, completion: nil)
}