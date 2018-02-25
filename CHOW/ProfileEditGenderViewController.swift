//
//  ProfileEditGenderViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/31.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit


class ProfileEditGenderViewController: UIViewController {
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func female(_ sender: AnyObject) {
        ProfileModalPopupVariables.gender = "Female"
        
        // Go back
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func male(_ sender: AnyObject) {
        ProfileModalPopupVariables.gender = "Male"
        
        // Go back
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
