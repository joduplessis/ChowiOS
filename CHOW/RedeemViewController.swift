//
//  RedeemViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/11.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class RedeemViewController: UIViewController {
    
    @IBOutlet var pointsComingSoon: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Still general font stuff
        let font = UIFont(name: "JennaSue", size: 50)
        
        // Assign the textview the font & text
        pointsComingSoon.font = font
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the user logged in or not
        checkIfUserIsLoggedIn()
    }
    
    /**
     * These functions are the ones pasted into every file
     * They use a #selector - so they need to have access to current class scope
     * Hence pasting this in
     * TODO: find a way to keep this in the util
     */
    
    func logOutOfAppWrapper() {
        logOutOfApp(self)
    }
    
    func addRightBarButtonWrapper() {
        let rightItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutOfAppWrapper))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 11.0)!], for: UIControlState())
        rightItem.setTitlePositionAdjustment(UIOffsetMake(0.0, 5.0), for: UIBarMetrics.default)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func checkIfUserIsLoggedIn() {
        /*
        // If the user is logged in with FB - but the token is nil - then log out
        if UserDefaults.standardUserDefaults().objectForKey("globalUserLoggedInFB") != nil
            && UserDefaults.standardUserDefaults().objectForKey("globalUserLoggedInFB")! as! Bool
            && FBSDKAccessToken.currentAccessToken() == nil {
            logOutOfAppWrapper()
        } else {
            // If the user is logged in, show the button & add the click
            if UserDefaults.standard.object(forKey: "globalUserLoggedIn") != nil
                && UserDefaults.standard.object(forKey: "globalUserLoggedIn")! as! Bool {
                addRightBarButtonWrapper()
            } else {
                // Clear the button
                self.navigationItem.rightBarButtonItem = nil
            }
        }
         */
    }    
}
