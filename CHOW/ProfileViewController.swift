//
//  ProfileViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/11.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var loginViewControllerHasLoadedOnce: Bool = false
    var tutorialViewControllerHasLoadedOnce: Bool = false
    var restaurantsList = [[String: String]]()
    let cellIdentifier = "ProfileRestaurantCell"
    var selectedRestaurantId: String = "0"
    var selectedRestaurantTitle: String = "Restaurant"
    
    @IBOutlet var please: UILabel!
    @IBOutlet var imageProfile: UIImageView!
    @IBOutlet var favouriteCount: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentsViewHeight: NSLayoutConstraint!
    @IBOutlet var contentsView: UIView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shadow: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the delegates to the current one
        tableView.delegate = self
        tableView.dataSource = self
        
        // Testing
        // performSegueWithIdentifier("tutorial", sender: view)
        // self.navigationItem.rightBarButtonItem = nil
        // self.tabBarController?.selectedIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If the user is logged in, show the button & add the click
        checkIfUserIsLoggedIn()
        
        // clear the restaurant list
        self.restaurantsList = [[String: String]]()
        
        // If this user needs to see the tutorial - sign ups
        if UserDefaults.standard.object(forKey: "globalUserSeeTutorial") != nil
            && UserDefaults.standard.object(forKey: "globalUserSeeTutorial")! as! Bool
            && !tutorialViewControllerHasLoadedOnce {
            // reset the variables
            tutorialViewControllerHasLoadedOnce = true
            UserDefaults.standard.set(false, forKey: "globalUserSeeTutorial")
            
            // Show the tutorial
            performSegue(withIdentifier: "tutorial", sender: view)
            
            // Remove the button & go to the map screen
            self.navigationItem.rightBarButtonItem = nil
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    // It's here because the selectors give issues when calling outside func
    func checkIfUserIsLoggedIn() {
        if UserDefaults.standard.object(forKey: "globalUserLoggedIn") != nil
        && UserDefaults.standard.object(forKey: "globalUserLoggedIn")! as! Bool {
            addRightBarButtonWrapper()
            loadProfileDataForUser()
            loadFavouritesDataForUser()
            
            // Hide the overlay
            shadow.alpha = 0.0
            please.alpha = 0.0
        } else {
            if !loginViewControllerHasLoadedOnce {
                loginViewControllerHasLoadedOnce = true
                
                // Load the segue for the login screen only once
                performSegue(withIdentifier: "login", sender: view)
            }
            
            // Still general font stuff
            let font = UIFont(name: "JennaSue", size: 50)
            
            // Clear the button
            // self.navigationItem.rightBarButtonItem = nil
            // Hide everything
            please.font = font
            
            // Show the overlay
            shadow.alpha = 0.75
            please.alpha = 1.0
            
            // Add teh login button
            let rightItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(logInToAppWrapper))
            rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 11.0)!], for: UIControlState())
            rightItem.setTitlePositionAdjustment(UIOffsetMake(0.0, 5.0), for: UIBarMetrics.default)
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    func logInToAppWrapper() {
        performSegue(withIdentifier: "login", sender: view)
    }
    
    func logOutOfAppWrapper() {
        logOutOfApp(self)
    }
    
    func addRightBarButtonWrapper() {
        let rightItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutOfAppWrapper))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 11.0)!], for: UIControlState())
        rightItem.setTitlePositionAdjustment(UIOffsetMake(0.0, 5.0), for: UIBarMetrics.default)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func loadProfileDataForUser() {
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
                            if let name = user["name"] as? String {
                                print("Loading profile for \(name) - \(userId)")
                            }
                            if let imageString = user["image"] as? String {
                                // Convert to a nsurl
                                let fileUrl = URL(string: imageString)
                                let pickedImageAsset = imageFromAsset(fileUrl!)
                                
                                // Format the profile pic
                                self.imageProfile.contentMode = .scaleAspectFill
                                self.imageProfile.image = pickedImageAsset
                            }
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
    }
    
    func loadFavouritesDataForUser() {
        // json Url
        let userId = UserDefaults.standard.string(forKey: "globalUserID")!
        let jsonUrl = URL(string: "API_PATH/app/api/get.favourites.php?id=\(userId)")
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: jsonUrl!) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    if let restaurants = json["restaurants"] as? [[String: Any]] {
                        // Store our variables
                        for restaurant in restaurants {
                            var dic: [String: String] = [:]
                            
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
                            
                            // Get the distance
                            let dis = distanceFromHere(dic["gps"]!, location: currentLocation())
                            
                            // Add it to the dictionary
                            dic["distance"] = String(dis)
                            
                            // Append it to the master
                            self.restaurantsList.append(dic)
                        }
                        
                        self.tableView.reloadData()
                        self.adjustTableAndScrollHeightWithNumber(self.restaurantsList.count)
                        self.favouriteCount.text = String(self.restaurantsList.count)
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
    
    // Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsList.count
    }
    
    func adjustTableAndScrollHeightWithNumber(_ no: Int) {
        // Get the view height
        let restaurantCount = CGFloat(no)
        let restaurantHeight = CGFloat(tableView.rowHeight)
        let tableHeight = restaurantCount*restaurantHeight
        
        // Set the scrollview, contents & table heights
        scrollView.contentSize = CGSize(width: 0, height: tableHeight+300)
        tableViewHeight.constant = tableHeight
        contentsViewHeight.constant = tableHeight + 300
    }
    
    // Delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get hold of our views
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileRestaurantTableViewCell
        let row = indexPath.row
        
        // Image URL
        let imageName = restaurantsList[row]["image"]!
        let url = URL(string: "API_PATH/app/assets/\(imageName)")
        let dis = restaurantsList[row]["distance"]!
        // let dis = distanceFromHere(restaurantsList[row]["gps"]!)
        
        // Asynchronously update the image
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            // Get the data of the image
            let data = try? Data(contentsOf: url!)
            
            // Assign it to the image
            DispatchQueue.main.async(execute: {
                cell.restaurantImage.image = UIImage(data: data!)
            });
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


}

