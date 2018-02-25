//
//  LoginController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/11.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textPassword: UITextField!
    @IBOutlet var textUsername: UITextField!
    @IBAction func buttonLogin(_ sender: AnyObject) {
    }
    
    @IBAction func buttonFacebook(_ send: AnyObject) {
        print("Hey hey! FB login")
        
        /*
        let login = FBSDKLoginManager()
        login.loginBehavior = FBSDKLoginBehavior.SystemAccount
        login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self, handler: {(result, error) in
            if error != nil {
                print("Error :  \(error.description)")
            } else if result.isCancelled {
                print("Cancelled")
            } else {
                // If it's a success
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, name, id, gender"]).startWithCompletionHandler({(connection, result, error) -> Void in
                    if error != nil{
                        print("Error : \(error.description)")
                    } else {
                        let userID = result["id"] as! NSString
                        let userName = result["name"] as! NSString
                        let userFirstName = result["first_name"] as! NSString
                        let userLastName = result["last_name"] as! NSString
                        let userGender = result["gender"] as! NSString
                        let email = result["email"] as! NSString

                        // Store the local variable
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "globalUserID")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "globalUserLoggedIn")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "globalUserLoggedInFB")
                        
                        // Contruct our API call
                        var jsonUrlString = "API_PATH/app/api/add.fb.user.php"
                        jsonUrlString += "?id=\(userID)"
                        jsonUrlString += "&username=\(userName)"
                        jsonUrlString += "&password=Facebook"
                        jsonUrlString += "&firstname=\(userFirstName)"
                        jsonUrlString += "&lastname=\(userLastName)"
                        jsonUrlString += "&dob="
                        jsonUrlString += "&gender=\(userGender)"
                        jsonUrlString += "&image="
                        jsonUrlString += "&email=\(email)"
                        
                        let escapedAddress = jsonUrlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                        let jsonUrl = NSURL(string: escapedAddress!)
                        
                        // MOCK
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "globalUserSeeTutorial")
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                        // Download JSON from the API
                        dispatch_async(dispatch_get_main_queue()) {
                            if let data = NSData(contentsOfURL: jsonUrl!) {
                                do {
                                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                                    if let users = json["user"] as? [[String: AnyObject]] {
                                        for user in users {
                                            // Add some variables
                                            if String(user["success"]!) == "1" {
                                                // If it's a new user
                                                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "globalUserSeeTutorial")
                                                
                                                // Close
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            } else {
                                                createNotification(self, message: "Sorry, error!")
                                            }
                                        }
                                    }
                                } catch {
                                    print("error serializing JSON: \(error)")
                                }
                            }
                        }
                    }
                })
            }
        })
         */
        
        /*
         
         This is the old code that I uncommented -> The above code is what was in production
         
        if FBSDKAccessToken.currentAccessToken() != nil {
            if let token = FBSDKAccessToken.currentAccessToken() {
                print("Already logged in \(token.userID)")
            }
        } else {
            print("Not logged in")
            
            // Loading Facebook login
            let login = FBSDKLoginManager()
            login.loginBehavior = FBSDKLoginBehavior.SystemAccount
            login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self, handler: {(result, error) in
                if error != nil {
                    print("Error :  \(error.description)")
                }
                else if result.isCancelled {
                    print("Cancelled")
                } else {
                    // Make the FB graph request
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, name, id, gender"]).startWithCompletionHandler({(connection, result, error) -> Void in
                        if error != nil{
                            print("Error : \(error.description)")
                        }else{
                            print("userInfo is \(result))")
                        }
                    })
                }
                
            })
         }
         // Show the tutoria once the user closes this screen
         NSUserDefaults.standardUserDefaults().setObject(true, forKey: "globalUserSeeTutorial")
         */
    }
    
    @IBAction func buttonSkipLogin(_ sender: AnyObject) {
        // Dismiss
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var buttonLogin: UIButton!
    
    @IBAction func buttonLoginAction(_ sender: AnyObject) {
        if self.textUsername.text! != "" || self.textPassword.text! != "" {
            // self.dismissViewControllerAnimated(true, completion: nil)
            let jsonUrl = URL(string: "API_PATH/app/api/get.account.login.php?username=\(self.textUsername.text!)&password=\(self.textPassword.text!)")
            
            // Download JSON from the API
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: jsonUrl!) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        if let users = json["user"] as? [[String: Any]] {
                            for user in users {
                                // Add some variables
                                if String(describing: user["id"]!) != "-1" {
                                    // Store the local variable
                                    UserDefaults.standard.set(String(describing: user["id"]!), forKey: "globalUserID")
                                    UserDefaults.standard.set(true, forKey: "globalUserLoggedIn")
                                    
                                    // Close
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    createNotification(self, message: "Sorry, not found!")
                                }
                            }
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                }
            }
        } else {
            okayAlert(self, message: "Please enter some details", title: "Whoops")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textPassword.delegate = self
        textUsername.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textPassword.resignFirstResponder()
        textUsername.resignFirstResponder()
        return true
    }
}
