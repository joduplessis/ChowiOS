//
//  TabBarController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/13.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up some variables for us
        let numberOfTabs = CGFloat(tabBar.items!.count)
        let tabSize = CGSize(width: tabBar.frame.width / numberOfTabs, height: tabBar.frame.height)
        let tabBarHeight = self.tabBar.bounds.height
        let titleFontAll : UIFont = UIFont(name: "Ubuntu", size: 9.0)!
        
        UITabBarItem.appearance().setTitleTextAttributes([ NSFontAttributeName : titleFontAll ], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([ NSFontAttributeName : titleFontAll ], for: .selected)
        
        // Remove the top border 
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        
        //UITabBar.appearance().layer.shadowOffset = CGSize(width: 100, height: 100)
        //UITabBar.appearance().layer.shadowRadius = 10;
        //ITabBar.appearance().layer.shadowColor = UIColor.lightGray.cgColor
        //ITabBar.appearance().layer.shadowOpacity = 0.75;
        
        //UITabBar.appearance().backgroundImage = UIImage()
        //UITabBar.appearance().shadowImage = getImageWithColor(color: UIColor.black, size: CGSize(width: 1.0, height: 5.0))
        
        // If there are items in the tab bar - these are for the seperators
        if let items = self.tabBar.items {
            for (index, _) in items.enumerated() {
                if index > 0 {
                    // x position of the item
                    let xPosition = tabSize.width * CGFloat(index)
                    
                    // Create UI view at the Xposition,
                    let separator = UIView(frame: CGRect(x: xPosition, y: 0, width: 0.5, height: tabBarHeight))
                    
                    // Set the color
                    separator.backgroundColor = UIColor(netHex:0xEFEFEF)
                    
                    // Insert the seperator
                    tabBar.insertSubview(separator, at: 1)
                }
            }
        }
        
        // Check all font names
        for fontfamily in UIFont.familyNames{
            for fontname in UIFont.fontNames(forFamilyName: fontfamily){
                print(fontname)
            }
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
    {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Extension for getting a HEX color
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

// Creating a square image on the fly for the background
extension UIImage {
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
