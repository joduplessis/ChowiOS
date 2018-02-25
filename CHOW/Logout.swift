//
//  Logout.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/23.
//  Copyright © 2016 CHOW. All rights reserved.
//

import Foundation
import UIKit

func checkIfUserIsLoggedIn() -> Bool {
    if NSUserDefaults.standardUserDefaults().objectForKey("globalUserLoggedIn")! as! Bool {
        return true
    } else {
        return false
    }
}

func cleanApplicationPreferences() {
    NSUserDefaults.standardUserDefaults().setObject("0", forKey: "globalUserID")
    NSUserDefaults.standardUserDefaults().setObject(false, forKey: "globalUserLoggedIn")
    print("Logged user out")
}