//
//  SearchResultViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/20.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var coordinates: CLLocation? = nil
    var categoriesChosen: [String] = []
    var restaurantsList = [[String: String]]()
    var restaurantsListMaster = [[String: String]]()
    let cellIdentifier = "RestaurantCell"
    let jsonUrl = URL(string: "API_PATH/app/api/get.restaurants.php")
    var selectedRestaurantId: String = "0"
    var selectedRestaurantTitle: String = "Restaurant"
    
    // Isn't really needed
    @IBOutlet var startDistance: UILabel!
    @IBOutlet var endDistance: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentsViewHeight: NSLayoutConstraint!
    @IBOutlet var contentsView: UIView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var heading: UILabel!
    @IBAction func searchValueChanged(_ sender: UISlider) {
        self.initTableData(sender.value)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the user logged in or not
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNotification(self, message: "Searching...")
        
        // Still general font stuff
        let font = UIFont(name: "JennaSue", size: 35)
        
        // Assign the textview the font & text
        heading.font = font
        
        // Sets the delegates to the current one
        tableView.delegate = self
        tableView.dataSource = self
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: self.jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let restaurants = json["restaurants"] as? [[String: Any]] {
                        // Store our variables
                        for restaurant in restaurants {
                            var dic: [String: String] = [:]
                            
                            // Increase the count
                            if let title = restaurant["title"] as? String {
                                dic["title"] = title
                            }
                            if let image = restaurant["image"] as? String {
                                dic["image"] = image
                            }
                            if let id = restaurant["id"] as? String {
                                dic["id"] = id
                            }
                            if let summary = restaurant["description"] as? String {
                                dic["summary"] = summary
                            }
                            if let gps = restaurant["gps"] as? String {
                                dic["gps"] = gps
                            }
                            
                            // Get the distance from the searched location
                            let dis = distanceFromHere(dic["gps"]!, location: self.coordinates!)
                            
                            // Add it to the dictionary
                            dic["distance"] = String(dis)
                            
                            // Append it to the master
                            self.restaurantsListMaster.append(dic)
                            
                            // Decide if it's over 50
                            if dis <= 50 {
                                self.restaurantsList.append(dic)
                                
                                self.tableView.reloadData()
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                    self.initTableData(0.5)
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
    }
    
    func initTableData(_ dis: Float) {
        let selectedValue = Int(Float(dis)*50)
        let sliderValue: String = String(stringInterpolationSegment: selectedValue)
        
        // Reset the list
        self.restaurantsList = [[String: String]]()
        
        // Go through the list & narrow it down
        for restaurant in self.restaurantsListMaster {
            if Int(restaurant["distance"]!) <= Int(sliderValue) {
                self.restaurantsList.append(restaurant)
            }
        }
        
        // Adjust the height of the panels
        self.adjustTableAndScrollHeightWithNumber(self.restaurantsList.count)
        
        // Notify
        createNotification(self, message: "Searching within \(selectedValue)km")
        
        
        
        
        
        self.restaurantsList = self.restaurantsList.sorted { $0["distance"] < $1["distance"] }
        
        // Reload the table
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        adjustTableAndScrollHeightWithNumber(restaurantsList.count)
    }
    
    func adjustTableAndScrollHeightWithNumber(_ no: Int) {
        // Get the view height
        let mealCount = CGFloat(no)
        let mealHeight = CGFloat(tableView.rowHeight)
        let tableHeight = mealCount*mealHeight
        
        // Set the scrollview, contents & table heights
        scrollView.contentSize = CGSize(width: 0, height: tableHeight+300)
        tableViewHeight.constant = tableHeight
        contentsViewHeight.constant = tableHeight + 300
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsList.count
    }
    
    // Delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get hold of our views
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
        let row = indexPath.row
        
        // Image URL
        let imageName = restaurantsList[row]["image"]!
        // let url = NSURL(string: "API_PATH/app/assets/\(imageName)")
        // let url = NSURL(string: "API_PATH/app/scripts/image.restaurant.meal.php?image=../assets/\(imageName)")
        
        let escapedUrlString = imageName.replacingOccurrences(of: "&", with: "%26")
        let imageUrlString = "API_PATH/app/scripts/image.restaurant.meal.php?image=../assets/\(escapedUrlString)"
        let url = URL(string: imageUrlString)
        
        
        
        let dis = restaurantsList[row]["distance"]!
        
        // let dis = distanceFromHere(restaurantsList[row]["gps"]!)
        // Asynchronously update the image
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            // Get the data of the image
            let data = try? Data(contentsOf: url!)
            
            if data != nil {
                // Assign it to the image
                DispatchQueue.main.async(execute: {
                    cell.restaurantImage.image = UIImage(data: data!)
                });
            }
        }
        
        // Set the text
        cell.restaurantDistance?.text = " \(dis)km "
        cell.restaurantLabel?.text = restaurantsList[row]["title"]
        cell.restaurantSummary?.text = restaurantsList[row]["summary"]
      
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Store the variables
        let row = indexPath.row
        selectedRestaurantId = restaurantsList[row]["id"]!
        selectedRestaurantTitle = restaurantsList[row]["title"]!
        
        // Call the segue
        self.performSegue(withIdentifier: "restaurant", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "restaurant" {
            let restaurantController:RestaurantDetailViewController = segue.destination as! RestaurantDetailViewController
            restaurantController.restaurantId = self.selectedRestaurantId
            restaurantController.title = self.selectedRestaurantTitle
        }
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
