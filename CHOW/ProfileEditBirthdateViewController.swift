//
//  ProfileEditBirthdateViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/31.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class ProfileEditBirthdateViewController: UIViewController {

    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectAction(_ sender: AnyObject) {
        let datepicker = String(describing: self.datePickerView.date)
        let datepickerArray = datepicker.characters.split{$0 == " "}.map(String.init)
        let birthdateArray = datepickerArray[0].characters.split{$0 == "-"}.map(String.init)
        let day = birthdateArray[2]
        let month = birthdateArray[1]
        let year = birthdateArray[0]
        let birthdate = "\(day)/\(month)/\(year)"
        
        // Store global variables
        ProfileModalPopupVariables.birthdate = birthdate
        
        // Go back
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var datePickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If it's not none
        if ProfileModalPopupVariables.birthdate != "None" && ProfileModalPopupVariables.birthdate != "" {
            let formatter = DateFormatter()
            formatter.dateStyle = .short;
            formatter.dateFormat = "dd-MM-yyyy";
            let formattedDate = formatter.date(from: ProfileModalPopupVariables.birthdate)
            self.datePickerView.setDate(formattedDate!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
