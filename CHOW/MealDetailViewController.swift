//
//  MealDetailViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/27.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class MealDetailViewController: UIViewController, UIWebViewDelegate {
    
    var mealId = ""
    var mealDescriptionOpen = false
    var mealDescriptionCopy = ""
    var mealNutritionFrameSize = CGSize(width: 100, height: 100)
    
    @IBOutlet var mealImage: UIImageView!
    @IBOutlet var mealName: UILabel!
    @IBOutlet var mealDescription: UILabel!
    @IBOutlet var mealNutrition: UIWebView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the user logged in or not
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate for the webview
        mealNutrition.delegate = self
        
        // Description tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(MealDetailViewController.tapFunction(_:)))
        mealDescription.addGestureRecognizer(tap)
        mealDescription.isUserInteractionEnabled = true
        
        // Notify
        createNotification(self, message: "Loading meal...")
        
        // Create the API call
        let jsonUrl = URL(string: "API_PATH/app/api/get.meal.php?id=\(mealId)")
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let meals = json["meal"] as? [[String: Any]] {
                        for meal in meals {
                            // Add some variables
                            self.mealName.text = meal["title"] as? String
                            self.mealDescription.text = meal["description"] as? String
                            
                            // Save the text - get the optional value using the !
                            self.mealDescriptionCopy = (meal["description"] as? String)!
                            
                            // Create an attributed string & attributes
                            let attrsBold = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12.0)]
                            let attributedString = NSMutableAttributedString(string: shortenString(self.mealDescriptionCopy, start: 0, end: 30))
                            let readString = NSMutableAttributedString(string:"... Read more", attributes:attrsBold)
                            
                            // Append our read more
                            attributedString.append(readString)
                            
                            // Update our label
                            self.mealDescription.attributedText = attributedString
                            
                            // HTML
                            if let html = meal["information"] as? String {
                                let css = "<style>* {font-family: arial, helvetica, sans-serif; font-size: 0.95em;} table {width: 100%;}</style>"+html
                                self.mealNutrition.loadHTMLString(css, baseURL: nil)
                            }
                            
                            // Main image
                            if let image = meal["image"] as? String {
                                DispatchQueue.main.async(execute: {
                                    let url = URL(string: "API_PATH/app/assets/\(image)")
                                    
                                    // Get the data of the image
                                    let data = try? Data(contentsOf: url!)
                                    
                                    // Assign it to the image
                                    if data != nil {
                                        DispatchQueue.main.async(execute: {
                                            self.mealImage.image = UIImage(data: data!)
                                        });
                                    }
                                });
                            }
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //mealNutritionFrameSize = webView.sizeThatFits(CGSizeZero)
        //mealNutrition.frame.size = mealNutritionFrameSize
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapFunction(_ sender:UITapGestureRecognizer) {
        let attrsBold = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12.0)]
        if mealDescriptionOpen {
            mealDescriptionOpen = false
            
            // Create an attributed string & attributes
            let attributedString = NSMutableAttributedString(string: shortenString(self.mealDescriptionCopy, start: 0, end: 30))
            let readString = NSMutableAttributedString(string:"... Read more", attributes:attrsBold)
            
            // Append our read more
            attributedString.append(readString)
            
            // Update our label
            self.mealDescription.attributedText = attributedString
        } else {
            mealDescriptionOpen = true
            
            // Create an attributed string & attributes
            let attributedString = NSMutableAttributedString(string: self.mealDescriptionCopy)
            let readString = NSMutableAttributedString(string:"... Read less", attributes:attrsBold)
            
            // Append our read more
            attributedString.append(readString)
            
            // Update our label
            self.mealDescription.attributedText = attributedString
        }
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

