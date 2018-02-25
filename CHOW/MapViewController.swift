//
//  MapViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/07/11.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    let locationManager = CLLocationManager()
    var myLocation = CLLocation(latitude: -29.7772063, longitude: 31.0365951)
    let initialLocation = CLLocation(latitude: -29.7772063, longitude: 31.0365951)
    let regionRadius: CLLocationDistance = 1000
    var searchCoordinates: CLLocation! = nil
    let jsonUrl = URL(string: "API_PATH/app/api/get.restaurants.php")
    var restaurantsList = [[String: String]]()
    var restaurantId = "0"
    var restaurantTitle = "0"

    @IBOutlet var map: MKMapView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchField: UITextField!
    @IBAction func searchAction(_ sender: AnyObject) {
        
        // Setup our geocoder
        let geocoder = CLGeocoder()
        let address = self.searchField.text!
        
        // Here we retreive the lat/long from the search text
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            // If there is an error
            if((error) != nil){
                print("Error", error)
            } else if let placemark = placemarks?.first {
                // Convert the CLLocationCoordinate2D object to a CLLocation object
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                let getLat: CLLocationDegrees = coordinates.latitude
                let getLon: CLLocationDegrees = coordinates.longitude
                self.searchCoordinates =  CLLocation(latitude: getLat, longitude: getLon)
                
                // Call a segue & pass out variable
                self.performSegue(withIdentifier: "categories", sender: self)
            }
        })
        
        // Notify
        createNotification(self, message: "Finding places...")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            let categoriesController:CategoriesViewController = segue.destination as! CategoriesViewController
            categoriesController.coordinates = self.searchCoordinates
        }
        if segue.identifier == "restaurant" {
            let restaurantController:RestaurantDetailViewController = segue.destination as! RestaurantDetailViewController
            restaurantController.restaurantId = self.restaurantId
            restaurantController.title = self.restaurantTitle
        }
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
    
    func checkIfUserIsLoggedIn() {
        /*
        // If the user is logged in with FB - but the token is nil - then log out
        if UserDefaults.standardUserDefaults().objectForKey("globalUserLoggedInFB") != nil
            && UserDefaults.standardUserDefaults().objectForKey("globalUserLoggedInFB")! as! Bool
            && FBSDKAccessToken.currentAccessToken() == nil {
                logOutOfAppWrapper()
        } else {
                // If the user is logged in
                if UserDefaults.standard.object(forKey: "globalUserLoggedIn") != nil
                    && UserDefaults.standard.object(forKey: "globalUserLoggedIn")! as! Bool {
                    addRightBarButtonWrapper()
                } else {
                    // Clear the button
                    self.navigationItem.rightBarButtonItem = nil
                    
                    // Reset all of the keys
                    resetAppPreferences()
                }
        }
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the user logged in or not
        checkIfUserIsLoggedIn()
        
        // Set the delegate
        searchField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pad the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.searchField.frame.height))
        searchField.leftView = paddingView
        searchField.leftViewMode = UITextFieldViewMode.always
        
        // We center it once
        centerMapOnLocation(initialLocation)
    
        // Make the request to get location from the user
        self.locationManager.requestWhenInUseAuthorization()
        
        // If it is available
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // Set some properties
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        
        // If we have the user location
        if let coor = map.userLocation.location?.coordinate {
            map.setCenter(coor, animated: true)
        }
        
        // Download JSON from the API
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: self.jsonUrl!) {
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
                            
                            self.restaurantsList.append(dic)
                        }

                        // Iterate through the list and add our annotations
                        for i in 0 ..< self.restaurantsList.count  {
                            let lat = self.restaurantsList[i]["gps"]!.components(separatedBy: ",")[0]
                            let long = self.restaurantsList[i]["gps"]!.components(separatedBy: ",")[1]
                            let latFloat = (lat as NSString).doubleValue
                            let longFloat = (long as NSString).doubleValue
                            
                            self.map.addAnnotation(RestaurantAnnotation(id: self.restaurantsList[i]["id"]!,
                                title: self.restaurantsList[i]["title"]!,
                                image: self.restaurantsList[i]["image"]!,
                                summary: self.restaurantsList[i]["summary"]!,
                                coordinate: CLLocationCoordinate2D(latitude: latFloat, longitude: longFloat)))
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var locationHasUpdated = false
    
    // Delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locationHasUpdated) {
            
            // Only update it once
            let location = locations.last
            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map.setRegion(region, animated: true)
            self.myLocation = locations.last!
            
            // Set the location is has updated
            locationHasUpdated = true
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }

}

func fadeViewInThenOut(_ view : UIView) {

}

extension MapViewController: MKMapViewDelegate {
    // When the user deselects the annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    // When a user clicks on the callout
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as! RestaurantAnnotation
        let animationDuration = 0.1
        let delay = 0.1
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in view.alpha = 1 }, completion: {
            (Bool) -> Void in
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                view.alpha = 0.5
                }, completion: nil)
        }) 
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in view.alpha = 0.5 }, completion: {
            (Bool) -> Void in
            UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
                view.alpha = 1
                }, completion:  { finished in
                    if(finished) {
                        
                        self.restaurantId = annotation.id!
                        self.restaurantTitle = annotation.title!
                        self.performSegue(withIdentifier: "restaurant", sender: view)
                        
                    }
                }
            )
        }) 
        
    }
    
    // When the user presses an annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation!.isKind(of: MKUserLocation.self){
            return
        }
    }
    
    // Might return nil though (if it's the user location annotation), hence the "?"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Make sure it isn't the user location annotation
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        // Define some variables to use - MKAnnotationView might be nil
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        
        // If the annotation is off screen - we recycle it with "dequeueReusableAnnotationViewWithIdentifier"
        // The optionality id "?" is starting to look like a nice way of working around null pointer issues in Java
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            // Else we create a new one
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            // Set some properties of the annotation view
            av.canShowCallout = false
            av.calloutOffset = CGPoint(x: -5, y: 5)
            
            // And assign it back to the main annotation view
            annotationView = av
        }
        
        // Same as using annotationView as annotationView!
        if let annotationView = annotationView {
            // Get our annotation
            let customAnnotationView = annotationView.annotation as! RestaurantAnnotation
    
            let escapedUrlString = customAnnotationView.image.replacingOccurrences(of: "&", with: "%26")
            let imageUrlString = "API_PATH/app/scripts/image.restaurant.meal.php?image=../assets/\(escapedUrlString)"
            let url = URL(string: imageUrlString)
            
            // Asynchronously update the image
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async(execute: {
                    annotationView.leftCalloutAccessoryView = UIImageView(image: UIImage(data: data!))
                    annotationView.leftCalloutAccessoryView?.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
                });
            }
            
            // Create our button
            let image = UIImage(named: "find_icon_arrow_padding.png") as UIImage?
            let button   = UIButton(type: UIButtonType.custom) as UIButton
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.setImage(image, for: UIControlState())
            
            // Add it to the annotation view
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = button
            annotationView.image = UIImage(named: "find_map_pin")
        }
        
        // Return the view - might be nil if something breaks
        // Hence the optional on the return value
        return annotationView
    }
    
}
