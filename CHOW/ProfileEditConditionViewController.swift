//
//  ProfileEditConditionViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/31.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class ProfileEditConditionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let pickerData = [
        "None",
        "Diabetes",
        "Heart Disease",
        "High Cholesterol",
        "High Blood Pressure",
        "Other"]

    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectAction(_ sender: AnyObject) {
        let selectedValue = pickerData[pickerView.selectedRow(inComponent: 0)]
        
        if selectedValue == "Other" {
            ProfileModalPopupVariables.condition = self.textOther.text
        } else {
            ProfileModalPopupVariables.condition = selectedValue
        }
        
        // Go back
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var textOther: UITextView!
    @IBOutlet var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set some delegates
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        if ProfileModalPopupVariables.condition != "None" && ProfileModalPopupVariables.condition != "" {
            var foundCondition = false;
            
            // Go through the list and try find the condition
            for i in 0 ..< pickerData.count  {
                if pickerData[i] == ProfileModalPopupVariables.condition {
                    self.pickerView.selectRow(i, inComponent: 0, animated: true)
                    foundCondition = true
                }
            }
            
            // If its not found
            if !foundCondition {
                self.pickerView.selectRow(pickerData.count-1, inComponent: 0, animated: true)
                self.textOther.text = ProfileModalPopupVariables.condition
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
