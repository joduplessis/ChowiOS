//
//  StoreViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/11.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class StoreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Still general font stuff
        // let font = UIFont(name: "JennaSue", size: 50)
        //let fontHeading = UIFont(name: "JennaSue", size: 30)
        
        // Assign the textview the font & text
        //storeComingSoon.font = font
        //headingText.font = fontHeading
        //let i = self.resizeImage(image: !, targetSize: CGSizeMake(50.0, 50.0))
        
        // Add the button to the top right
        let myimage = UIImage(named: "icon-filter@2x.png")?.resizeImage(targetSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: myimage, style: .plain, target: self, action: #selector(logOutOfAppWrapper))

        // Change the font of the tab bar title
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Ubuntu", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func logOutOfAppWrapper() {
    }
    
    func addRightBarButtonWrapper() {
        let rightItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutOfAppWrapper))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 11.0)!], for: UIControlState())
        rightItem.setTitlePositionAdjustment(UIOffsetMake(0.0, 5.0), for: UIBarMetrics.default)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func checkIfUserIsLoggedIn() {
    }    
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SearchMealCollectionViewCell
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
}


extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

