//
//  ProfileEditViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/31.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let imagePicker = UIImagePickerController()
    var imageAssetLibrary = ""
    
    @IBOutlet var textFirstname: UITextField!
    @IBOutlet var textLastname: UITextField!
    @IBOutlet var textUsername: UITextField!
    @IBOutlet var textEmail: UITextField!
    @IBOutlet var textConfirmPassword: UITextField!
    @IBOutlet var textPassword: UITextField!
    @IBOutlet var textBirthdate: UILabel!
    @IBOutlet var textCondition: UILabel!
    @IBOutlet var textGender: UILabel!
    @IBOutlet var imageProfile: UIImageView!
    
    @IBAction func updateAction(_ sender: AnyObject) {
        // Get the user id
        let userId = UserDefaults.standard.string(forKey: "globalUserID")!
        
        // Save data URL
        var jsonUrlString = "API_PATH/app/api/edit.user.php"
        jsonUrlString += "?id=\(userId)"
        jsonUrlString += "&name=\(self.textUsername.text!)"
        jsonUrlString += "&password=\(self.textPassword.text!)"
        jsonUrlString += "&email=\(self.textEmail.text!)"
        jsonUrlString += "&bucks=0"
        jsonUrlString += "&firstname=\(self.textFirstname.text!)"
        jsonUrlString += "&lastname=\(self.textLastname.text!)"
        jsonUrlString += "&condition=\(self.textCondition.text!)"
        jsonUrlString += "&dob=\(self.textBirthdate.text!)"
        jsonUrlString += "&gender=\(self.textGender.text!)"
        jsonUrlString += "&image=\(self.imageAssetLibrary)"
        
        let escapedAddress = jsonUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let jsonUrl = URL(string: escapedAddress!)
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let users = json["user"] as? [[String: Any]] {
                        for user in users {
                            if let success = user["success"] as? Int {
                                if success == 1 {
                                    okayAlert(self, message: "Details successfully updated", title: "Success")
                                    
                                    // Go back
                                    // self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    okayAlert(self, message: "Sorry there seems to be problem", title: "Whoops")
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
    
    @IBAction func editImageAction(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        // Load teh image picker screen
        present(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textFirstname.resignFirstResponder()
        textLastname.resignFirstResponder()
        textUsername.resignFirstResponder()
        textEmail.resignFirstResponder()
        textConfirmPassword.resignFirstResponder()
        textPassword.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate to this view controller
        imagePicker.delegate = self
        textFirstname.delegate = self
        textLastname.delegate = self
        textUsername.delegate = self
        textEmail.delegate = self
        textConfirmPassword.delegate = self
        textPassword.delegate = self
        
        // Load all the details
        // json Url
        let userId = UserDefaults.standard.string(forKey: "globalUserID")!
        let jsonUrl = URL(string: "API_PATH/app/api/get.account.php?id=\(userId)")
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let users = json["user"] as? [[String: Any]] {
                        // Store our variables
                        for user in users {
                            if let username = user["name"] as? String {
                                self.textUsername.text = username
                            }
                            if let email = user["email"] as? String {
                                self.textEmail.text = email
                            }
                            if let firstname = user["firstname"] as? String {
                                self.textFirstname.text = firstname
                            }
                            if let lastname = user["lastname"] as? String {
                                self.textLastname.text = lastname
                            }
                            if let password = user["password"] as? String {
                                self.textPassword.text = password
                                self.textConfirmPassword.text = password
                            }
                            if let dob = user["dob"] as? String {
                                self.textBirthdate.text = dob
                                ProfileModalPopupVariables.birthdate = dob
                            }
                            if let gender = user["gender"] as? String {
                                self.textGender.text = gender
                                ProfileModalPopupVariables.gender = gender
                            }
                            if let condition = user["condition"] as? String {
                                self.textCondition.text = condition
                                ProfileModalPopupVariables.condition = condition
                            }
                            if let imageString = user["image"] as? String {
                                // Convert to a nsurl
                                let fileUrl = URL(string: imageString)
                                let pickedImageAsset = imageFromAsset(fileUrl!)
                                
                                // Format the profile pic
                                // We us the imageAssetLibrary in the URL
                                // When interacting with the API
                                self.imageProfile.contentMode = .scaleAspectFill
                                self.imageProfile.image = pickedImageAsset
                                self.imageAssetLibrary = imageString
                            }
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let pickedImageUrl = info[UIImagePickerControllerReferenceURL] as? URL {
                // Convert our NSURL to an image  & string
                let pickedImageAsset = imageFromAsset(pickedImageUrl)
                let pickedImageAssetString = String(describing: pickedImageUrl)
                
                // Format the profile pic
                self.imageProfile.contentMode = .scaleAspectFill
                self.imageProfile.image = pickedImageAsset
                self.imageAssetLibrary = pickedImageAssetString
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update the variables
        self.textGender.text = ProfileModalPopupVariables.gender
        self.textBirthdate.text = ProfileModalPopupVariables.birthdate
        self.textCondition.text = ProfileModalPopupVariables.condition
        
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
