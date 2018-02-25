//
//  CategoriesViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/24.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var coordinates: CLLocation? = nil
    let jsonUrl = URL(string: "API_PATH/app/api/get.category.php")
    let cellIdentifier = "CategoryCell"
    var categoriesId: [String] = []
    var categoriesTitle: [String] = []
    var categoriesImage: [String] = []
    var categoriesChosen: [String] = []
    var selectAll: Bool = false
    
    @IBOutlet var selectAllButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var categoriesHeading: UILabel!
    @IBAction func selectAllButton(_ sender: AnyObject) {
        // Typical select IF THEN
        if selectAll == true {
            selectAll = false
            self.selectAllButton.setTitle("SELECT ALL", for: UIControlState())
            self.categoriesChosen = []
        } else {
            selectAll = true
            self.selectAllButton.setTitle("SELECT NONE", for: UIControlState())
            self.categoriesChosen = self.categoriesId
        }
        
        // Reload data
        self.collectionView.reloadData()
    }
    
    @IBAction func categoryButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "searchresult", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the user logged in or not
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Making it the delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Still general font stuff
        let font = UIFont(name: "JennaSue", size: 35)
        
        // Assign the textview the font & text
        categoriesHeading.font = font
        
        // These are the coordinates that tuser searched for
        // let coordinateFromPreviousScreen = coordinates?.coordinate
        
        // Download API JSON
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: self.jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let categories = json["category"] as? [[String: AnyObject]] {
                        for category in categories {
                            // Store the title
                            if let title = category["title"] as? String {
                                self.categoriesTitle.append(title)
                            }
                            // Store the image
                            if let image = category["image"] as? String {
                                self.categoriesImage.append(image)
                            }
                            // Store the id
                            if let id = category["id"] as? String {
                                self.categoriesId.append(id)
                            }
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
            
            // Reload data
            self.collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchresult" {
            let searchResultController:SearchResultViewController = segue.destination as! SearchResultViewController
            searchResultController.coordinates = self.coordinates
            searchResultController.categoriesChosen = self.categoriesChosen
            
        }
    }
     
    // MARK: - UICollectionViewDataSource protocol

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoriesId.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CategoriesCollectionViewCell

        // Set the text label
        cell.myLabel.text = self.categoriesTitle[indexPath.item]
        
        // Hide the check image
        if self.categoriesChosen.contains(self.categoriesId[indexPath.item]) {
            cell.myImageCheck.isHidden = false
        } else {
            cell.myImageCheck.isHidden = true
        }
        
        // Image url
        let url = URL(string: "API_PATH/app/assets/\(self.categoriesImage[indexPath.item])")
        
        // Get the data of the image
        let data = try? Data(contentsOf: url!)
        
        // Assign it to the image
        DispatchQueue.main.async(execute: {
            cell.myImage.image = UIImage(data: data!)
        });

        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // If it has been checked
        if self.categoriesChosen.contains(self.categoriesId[indexPath.item]) {
            // It does contain it - so we remove it
            if let index = categoriesChosen.index(of: self.categoriesId[indexPath.item]) {
                categoriesChosen.remove(at: index)
            }
        } else {
            // It's not there, so we add it
            self.categoriesChosen.append(self.categoriesId[indexPath.item])
        }
        
        // Reload data
        self.collectionView.reloadData()
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
