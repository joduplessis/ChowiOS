//
//  RecoverPasswordViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/24.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class RecoverPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitButtonAction(_ sender: AnyObject) {
        if self.emailTextField.text! != "" {
            let jsonUrl = URL(string: "API_PATH/app/api/get.password.php?name=\(self.emailTextField.text!)") ;
            
            // Download JSON from the API
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: jsonUrl!) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        if let lostpasswords = json["lostpassword"] as? [[String: Any]] {
                            for lostpassword in lostpasswords {
                                // Add some variables
                                if String(describing: lostpassword["success"]!) != "-1" {
                                    // Store the local variable
                                    okayAlert(self, message: "Your password has been sent to you!", title: "Success")
                                    
                                    // Close
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    createNotification(self, message: "Sorry, user not found!")
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
        emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        emailTextField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

