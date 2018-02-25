//
//  DistanceFromCurrentLocation.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/13.
//  Copyright © 2016 CHOW. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Photos

func distanceFromHere(_ gps: String, location: CLLocation) -> Int {
    let lat = gps.components(separatedBy: ",")[0]
    let long = gps.components(separatedBy: ",")[1]
    let latFloat = (lat as NSString).doubleValue
    let longFloat = (long as NSString).doubleValue
    let toLocation = CLLocation(latitude: latFloat, longitude: longFloat)
    let fromLocation = location
    // let myMapViewController: MapViewController = MapViewController(nibName: nil, bundle: nil)
    // let fromLocation = myMapViewController.myLocation
    let distance = fromLocation.distance(from: toLocation)
    return Int(distance/1000)
}

func currentLocation() -> CLLocation {
    var location = CLLocation(latitude: -29.7772063, longitude: 31.0365951)
    if UserDefaults.standard.object(forKey: "globalUserLongitude") != nil &&
        UserDefaults.standard.object(forKey: "globalUserLatitude") != nil {
            let lat = UserDefaults.standard.string(forKey: "globalUserLatitude")
            let long = UserDefaults.standard.string(forKey: "globalUserLongitude")
            let latFloat = (lat! as NSString).doubleValue
            let longFloat = (long! as NSString).doubleValue
            location = CLLocation(latitude: latFloat, longitude: longFloat)
    }
    return location
}

func shortenString(_ text: String, start: Int, end: Int) -> String {
    return text[text.characters.index(text.startIndex, offsetBy: start)...text.characters.index(text.startIndex, offsetBy: end)]
}

func createNotification(_ viewForNotification: UIViewController, message: String) {
    let toastLabel = UILabel(frame: CGRect(x: viewForNotification.view.frame.size.width/2 - 150, y: viewForNotification.view.frame.size.height-100, width: 300, height: 35))
    toastLabel.backgroundColor = UIColor.black
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = NSTextAlignment.center;
    viewForNotification.view.addSubview(toastLabel)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {toastLabel.alpha = 0.0 }, completion: nil)
}

func resetAppPreferences() {
    UserDefaults.standard.set("0", forKey: "globalUserID")
    UserDefaults.standard.set(false, forKey: "globalUserLoggedIn")
    UserDefaults.standard.set(false, forKey: "globalUserLoggedInFB")
    UserDefaults.standard.set(false, forKey: "globalUserSeeTutorial")
    UserDefaults.standard.set("31.0365951", forKey: "globalUserLongitude")
    UserDefaults.standard.set("-29.7772063", forKey: "globalUserLatitude")
}

func logOutOfApp(_ view: UIViewController) {
    // Reset all of the keys
    resetAppPreferences()
    
    // Show the alert
    okayAlert(view, message: "You've been logged out", title: "Logged Out")
    
    // Logout of FB
    // FBSDKLoginManager().logOut()
    
    // Remove the button & go to the map screen
    view.navigationItem.rightBarButtonItem = nil
    view.tabBarController?.selectedIndex = 0
}

func okayAlert(_ viewForNotification: UIViewController, message: String, title: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
    viewForNotification.present(alert, animated: true, completion: nil)
}

func imageFromAsset(_ nsurl: URL!) -> UIImage {
    var returnedImage = UIImage(color: .lightGray)
    let targetSize = CGSize(width: 300, height: 300)
    let options = PHImageRequestOptions()
    
    if nsurl != nil && nsurl.absoluteString != "none" && nsurl.absoluteString != "" {
        if let asset = PHAsset.fetchAssets(withALAssetURLs: [nsurl], options: nil).firstObject as? PHAsset {
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: {
            (result, info) in
                if result != nil {
                    returnedImage = result!
                }
            })
        }
    }
    
    // Return it
    return returnedImage!
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image!.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

struct ProfileModalPopupVariables {
    static var gender = "None"
    static var birthdate = "None"
    static var condition = "None"
}





