//
//  YoureSetViewController.swift
//  PokeTrainerApp
//
//  Created by Dustin Allen on 7/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class YoureSetViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager:CLLocationManager!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        let userLocation:CLLocation = locations[0]
        print("Latitude: \(userLocation.coordinate.latitude)")
        print("Longitude: \(userLocation.coordinate.longitude)")
        print("Course: \(userLocation.course)")
        print("Speed: \(userLocation.speed)")
        print("Altitude: \(userLocation.altitude)")
        print("Time: \(userLocation.timestamp)")
        print("Floor: \(userLocation.floor)")
        print("Course: \(userLocation.course)")
        print("Horizontal Accuracy: \(userLocation.horizontalAccuracy)")
        print("Veritcal Accuracy: \(userLocation.verticalAccuracy)")
        
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                if let p = placemarks?[0] {
                    var subThoroughfare:String = ""
                    if (p.subThoroughfare != nil) {
                        subThoroughfare = p.subThoroughfare!
                    }
                    print("Address: \(subThoroughfare) \(p.thoroughfare) \n \(p.subLocality) \n \(p.subAdministrativeArea) \n \(p.postalCode) \n \(p.country)")
                }
            }
        })
    }
    
    @IBAction func actionmainScreen(sender: AnyObject) {
        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
    }
    
    
    @IBAction func pairUp(sender: AnyObject) {
        //        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        //        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
