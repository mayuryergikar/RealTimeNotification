//
//  ViewController.swift
//  RealTimeNotifications
//
//  Created by mac_user on 19/09/18.
//  Copyright © 2018 Mayur. All rights reserved.
//

import UIKit
import UserNotifications
import GooglePlaces
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate ,GMSAutocompleteViewControllerDelegate {

    @IBOutlet weak var outletCurrentLocation: UITextField!
    @IBOutlet weak var outletDestinationLocation: UITextField!
    @IBOutlet weak var outletStartBtn: UIButton!
    
    var locManager = CLLocationManager()
    var currentLatLong = ""
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.findCurrentLocation();
    }

    // MARK:- Start/Stop Button asction
    @IBAction func startAction(_ sender: Any) {
        
        let flag = defaults.value(forKey: "FLAG") ?? false
        if flag as! Bool{
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NOTIFICATIONFIRE"), object: nil);
            defaults.set(nil, forKey: "DISTINATIONLATLONG");
            defaults.set(false, forKey: "FLAG");
            self.outletStartBtn.setTitle("START", for: .normal);
        }
        else{
            
            defaults.set(true, forKey: "FLAG");
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NOTIFICATIONFIRE"), object: nil);
            NotificationCenter.default.addObserver(self, selector: #selector(self.fireNotification), name: Notification.Name("NOTIFICATIONFIRE"), object: nil);
            self.outletStartBtn.setTitle("STOP", for: .normal);
        }
    }
    
    // MARK:- Google Autocomplete
    @IBAction func autocompleteAction(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.outletDestinationLocation.text = place.formattedAddress!
        let filterLotlong = String(format:"%f,%f" , place.coordinate.latitude,place.coordinate.longitude)
        defaults.set(filterLotlong, forKey: "DISTINATIONLATLONG");
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @objc func fireNotification(){
        
        let content = UNMutableNotificationContent()
        content.title = "Notification"
        content.body = "Congratulation, Your are Reached within Radius..!"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        defaults.set(nil, forKey: "DISTINATIONLATLONG");
        defaults.set(true, forKey: "FLAG");
    }
    
    // MARK:- Find User current location
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locManager.distanceFilter = 500.0
            locManager.requestAlwaysAuthorization()
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        var currentLocation = locations.last! as CLLocation
        
        currentLocation = locManager.location!
        currentLatLong = String(format:"%f,%f", currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)

        self.getAddressForLatLng(latitude: String(format:"%f",currentLocation.coordinate.latitude), longitude: String(format:"%f",currentLocation.coordinate.longitude))
        
        self.locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    // MARK:- Get user address from user current location
    func getAddressForLatLng(latitude: String, longitude: String) {
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(AppDelegate.GOOGLEAPI_KEY)")
    
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {

                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
            {
                
                if let result = jsonObj!["results"] as? NSArray {
                    
                    DispatchQueue.main.async {
                        
                        let address = (result[0] as AnyObject)["formatted_address"] as? String
                        self.outletCurrentLocation.text = address

                    }
                }
            }
            
        }
        task.resume()
    }
}

