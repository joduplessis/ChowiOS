//
//  RestaurantDetailViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/27.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var restaurantId = "0"
    var restaurantGps = "0,0"
    var restaurantNumber = "0"
    var restaurantMeals = [[String: String]]()
    var restaurantDescriptionOpen = false
    var restaurantDescriptionCopy = ""
    var selectedMealId: String = "0"
    var selectedMealTitle: String = "Meal"
    let cellIdentifier = "MealCell"
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentsView: UIView!
    @IBOutlet var contentsViewHeight: NSLayoutConstraint!
    @IBOutlet var favicon: UIButton!
    
    @IBOutlet var restaurantKm: UILabel!
    @IBOutlet var restaurantImage: UIImageView!
    @IBOutlet var restaurantName: UILabel!
    @IBOutlet var restaurantAddress: UILabel!
    @IBOutlet var restaurantNumberIcon: UIImageView!
    @IBOutlet var restaurantNumberButton: UIButton!
    @IBOutlet var restaurantDirectionsIcon: UIImageView!
    @IBOutlet var restaurantDirectionsButton: UIButton!
    @IBOutlet var restaurantDescription: UILabel!
    @IBOutlet var restaurantDescriptionParent: UIView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    
    @IBAction func faviconAction(_ sender: AnyObject) {
        if UserDefaults.standard.object(forKey: "globalUserLoggedIn") != nil
            && UserDefaults.standard.object(forKey: "globalUserLoggedIn")! as! Bool {
            // json Url
            let userId = UserDefaults.standard.string(forKey: "globalUserID")!
            let jsonUrl = URL(string: "API_PATH/app/api/edit.favourite.php?user=\(userId)&restaurant=\(self.restaurantId)")
            
            // Download JSON from the API
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: jsonUrl!) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        if let favourites = json["favourite"] as? [[String: Any]] {
                            for favourite in favourites {
                                if let success = favourite["success"] as? Int {
                                    if success == 1 {
                                        createNotification(self, message: "Favourite added")
                                        self.changeFaviconOn()
                                    } else {
                                        createNotification(self, message: "Favourite removed")
                                        self.changeFaviconOff()
                                    }
                                }
                            }
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                }
            }
        } else {
            okayAlert(self, message: "Sorry, you need to be logged in", title: "Whoops")
        }
    }
    
    @IBAction func restaurantNumberButtonAction(_ sender: AnyObject) {
        if let url = URL(string: "tel://\(self.restaurantNumber.trimmingCharacters(in: CharacterSet.whitespaces))") {
            print(url)
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func restaurantDirectionsbuttonAction(_ sender: AnyObject) {
        let lat: String = self.restaurantGps.components(separatedBy: ",")[0]
        let long:String = self.restaurantGps.components(separatedBy: ",")[1]
        let latFloat = (lat as NSString).doubleValue
        let longFloat = (long as NSString).doubleValue
        let coordinate = CLLocationCoordinate2DMake(latFloat,longFloat)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = self.restaurantName.text
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func changeFaviconOn() {
        let image = UIImage(named: "profile_icon_favourites_light")?.withRenderingMode(.alwaysTemplate)
        self.favicon.setImage(image, for: UIControlState())
        self.favicon.tintColor = UIColor.orange
    }
    
    func changeFaviconOff() {
        let image = UIImage(named: "profile_icon_favourites_dark")?.withRenderingMode(.alwaysTemplate)
        self.favicon.setImage(image, for: UIControlState())
        self.favicon.tintColor = UIColor.darkGray
    }

    override func viewDidLayoutSubviews() {
        // Get the view height
        let mealCount = CGFloat(restaurantMeals.count)
        let mealHeight = CGFloat(tableView.rowHeight)
        let tableHeight = mealCount*mealHeight
        
        // Set the scrollview, contents & table heights
        scrollView.contentSize = CGSize(width: 0, height: tableHeight+300)
        tableViewHeight.constant = tableHeight
        contentsViewHeight.constant = tableHeight + 300
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the user logged in or not
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check to see if this restaurant is favoured by the user
        if UserDefaults.standard.object(forKey: "globalUserLoggedIn") != nil
            && UserDefaults.standard.object(forKey: "globalUserLoggedIn")! as! Bool {
            // json Url
            let userId = UserDefaults.standard.string(forKey: "globalUserID")!
            let jsonUrl = URL(string: "API_PATH/app/api/get.favourite.php?id=\(userId)&restaurant=\(self.restaurantId)")
            
            // Usual ASYNC stuff
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: jsonUrl!) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        if let favourites = json["favourite"] as? [[String: Any]] {
                            for favourite in favourites {
                                if let success = favourite["id"] as? Int {
                                    if success == 1 {
                                        self.changeFaviconOn()
                                    } else {
                                        self.changeFaviconOff()
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
        
        // Notify
        createNotification(self, message: "Loading restaurant & meals...")
        
        // Description tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(RestaurantDetailViewController.tapFunction(_:)))
        restaurantDescription.addGestureRecognizer(tap)
        restaurantDescription.isUserInteractionEnabled = true
        
        // Sets the delegates to the current one
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        
        // Create the API call
        let jsonUrl = URL(string: "API_PATH/app/api/get.restaurant.php?id=\(restaurantId)")
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let restaurants = json["restaurant"] as? [[String: Any]] {
                        for restaurant in restaurants {
                            // Add some variables
                            self.restaurantAddress.text = restaurant["address"] as? String
                            self.restaurantName.text = restaurant["title"] as? String
                            
                            // Save the text - get the optional value using the !
                            self.restaurantDescriptionCopy = (restaurant["description"] as? String)!
                            
                            // Create an attributed string & attributes
                            let attrsBold = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12.0)]
                            let attributedString = NSMutableAttributedString(string: shortenString(self.restaurantDescriptionCopy, start: 0, end: 30))
                            let readString = NSMutableAttributedString(string:"... Read more", attributes:attrsBold)
                            
                            // Append our read more
                            attributedString.append(readString)
                            
                            // Update our label
                            self.restaurantDescription.attributedText = attributedString
                            
                            // GPS
                            if let gps = restaurant["gps"] as? String {
                                self.restaurantGps = gps
                                self.restaurantKm.text = "\(distanceFromHere(gps, location: currentLocation())) km"
                            }
                            
                            // Buttons
                            if let buttonNumber = restaurant["contact"] as? String {
                                self.restaurantNumberButton.setTitle(buttonNumber, for: UIControlState())
                                self.restaurantNumber = buttonNumber
                            }
                            
                            // Main image
                            if let image = restaurant["image"] as? String {
                                DispatchQueue.main.async(execute: {
                                    let url = URL(string: "API_PATH/app/assets/\(image)")
                                    
                                    // Get the data of the image
                                    let data = try? Data(contentsOf: url!)
                                    
                                    if data != nil {
                                        // Assign it to the image
                                        DispatchQueue.main.async(execute: {
                                            self.restaurantImage.image = UIImage(data: data!)
                                        });
                                    }
                                });
                            }
                            
                            // Meals
                            if let meals = restaurant["meals"] as? [[String: String]] {
                                self.restaurantMeals = meals
                            }
                            
                            // Reload the table
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
    }
    
    func tapFunction(_ sender:UITapGestureRecognizer) {
        let attrsBold = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12.0)]
        if restaurantDescriptionOpen {
            restaurantDescriptionOpen = false
            
            // Create an attributed string & attributes
            let attributedString = NSMutableAttributedString(string: shortenString(self.restaurantDescriptionCopy, start: 0, end: 30))
            let readString = NSMutableAttributedString(string:"... Read more", attributes:attrsBold)
            
            // Append our read more
            attributedString.append(readString)
            
            // Update our label
            self.restaurantDescription.attributedText = attributedString
        } else {
            restaurantDescriptionOpen = true
            
            // Create an attributed string & attributes
            let attributedString = NSMutableAttributedString(string: self.restaurantDescriptionCopy)
            let readString = NSMutableAttributedString(string:"... Read less", attributes:attrsBold)
            
            // Append our read more
            attributedString.append(readString)
            
            // Update our label
            self.restaurantDescription.attributedText = attributedString
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Delegate method: get the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Delegate method: get the count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantMeals.count
    }
    
    // Delegate method: structure the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get hold of our views
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        let row = indexPath.row
        
        // Image URL
        if let imageData = restaurantMeals[row]["image"] {
            
            let escapedUrlString = imageData.replacingOccurrences(of: "&", with: "%26")
            let imageUrlString = "API_PATH/app/scripts/image.restaurant.meal.php?image=../assets/\(escapedUrlString)"
            let url = URL(string: imageUrlString)
            
            
            
            print(url)
            
            // Wait for the URL
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let data = try? Data(contentsOf: url!)
                
                // Wait for the data
                if data != nil {
                    DispatchQueue.main.async(execute: {
                        cell.mealImage?.image = UIImage(data: data!)
                    });
                }
            }
        }
        
        // Set the text
        cell.mealHeading?.text = restaurantMeals[row]["title"]
        cell.mealSummary?.text = restaurantMeals[row]["description"]
        
        // Return the cell
        return cell
    }
    
    // Delegate method: get the pressed on row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        selectedMealId = restaurantMeals[row]["id"]!
        selectedMealTitle = restaurantMeals[row]["title"]!
        self.performSegue(withIdentifier: "meal", sender: self)
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "meal" {
            let mealController:MealDetailViewController = segue.destination as! MealDetailViewController
            mealController.mealId = self.selectedMealId
            mealController.title = selectedMealTitle
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

