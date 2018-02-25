//
//  CreateAccountViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/27.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var username: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    
    @IBAction func submit(_ sender: AnyObject) {
        if self.username.text == "" || self.email.text == "" || self.password.text == "" || self.confirmPassword.text == "" {
            okayAlert(self, message: "Please complete all of the fields", title: "Whoops")
        } else {
            if self.password.text != self.confirmPassword.text {
                okayAlert(self, message: "Your passwords don't match", title: "Whoops")
            } else {
                // self.dismissViewControllerAnimated(true, completion: nil)
                let jsonUrl = URL(string: "API_PATH/app/api/add.user.php?name=\(self.username.text!)&password=\(self.password.text!)&email=\(self.email.text!)") ;
                
                // Download JSON from the API
                DispatchQueue.main.async {
                    if let data = try? Data(contentsOf: jsonUrl!) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                            if let users = json["user"] as? [[String: Any]] {
                                for user in users {
                                    // Add some variables
                                    if String(describing: user["success"]!) != "-1" {
                                        // Show the tutoria once the user closes this screen
                                        UserDefaults.standard.set(true, forKey: "globalUserSeeTutorial")
                                        
                                        // Store the local variable
                                        UserDefaults.standard.set(String(describing: user["id"]!), forKey: "globalUserID")
                                        UserDefaults.standard.set(true, forKey: "globalUserLoggedIn")
                                        
                                        // Close
                                        self.dismiss(animated: true, completion: nil)
                                    } else {
                                        if String(describing: user["id"]!) == "1" {
                                            createNotification(self, message: "Sorry, user exists already!")
                                        } else {
                                            createNotification(self, message: "Sorry, there's been an error!")
                                        }
                                    }
                                }
                            }
                            }
                        } catch {
                            print("error serializing JSON: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func goback(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates
        username.delegate = self
        email.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        username.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        confirmPassword.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
