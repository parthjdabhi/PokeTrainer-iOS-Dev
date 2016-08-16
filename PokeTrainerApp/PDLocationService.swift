//
//  LocationService.swift
//
//
//  Created by Anak Mirasing on 5/18/2558 BE.
//
//

import Foundation
import CoreLocation

@objc protocol PDLocationServiceDelegate: class {
    optional func tracingLocation(currentLocation: CLLocation)
    optional func tracingLocationDidFailWithError(error: NSError)
    optional func tracingTraveledDistance(traveledDistance:Double)
}


class PDLocationService: NSObject, CLLocationManagerDelegate {
    
    class var sharedInstance: PDLocationService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: PDLocationService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PDLocationService()
        }
        return Static.instance!
    }

    var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    var previousLastLocation: CLLocation?
    var lastLocation: CLLocation?
    var delegate: PDLocationServiceDelegate?
    var traveledDistanceOnLocal:Double = 0
    var traveledDistanceOnServer:Double = 0
    var traveledDistanceSavingOffset:Double = 0
    var isUpdatingLocation = false
    
    override init() {
        super.init()

        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            // you have 2 choice 
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        // locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        
        if isUpdatingLocation == true {
            return
        }
        
        traveledDistanceOnLocal = 0
        isUpdatingLocation = true
        if let traveledDistanceSavedOffline = NSUserDefaults.standardUserDefaults().objectForKey("traveledDistanceOnLocal") as? Double {
            traveledDistanceOnLocal = traveledDistanceSavedOffline
            print("traveledDistanceSavedOffline : \(traveledDistanceOnLocal)")
        }
        
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
        isUpdatingLocation = false
        print("Saving traveledDistanceSavedOffline : \(traveledDistanceOnLocal)")
        
        NSUserDefaults.standardUserDefaults().setDouble(self.traveledDistanceOnLocal, forKey: "traveledDistanceOnLocal")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else {
            return
        }
        
        if startLocation == nil {
            startLocation = locations.first as CLLocation!
            self.lastLocation = startLocation
        } else {
            let lastDistance = self.lastLocation!.distanceFromLocation(location)
            traveledDistanceOnLocal += lastDistance * 0.000621371
            
            //print("\(lastLocation) - \(location)")
            //let trimmedDistance = String(format: "%.2f", traveledDistance)
            
            //print("FULL DISTANCE: \(traveledDistanceOnLocal+traveledDistanceOnServer) - \(String(format: "%.2f", traveledDistanceOnLocal+traveledDistanceOnServer)) Miles")
        }
        
        // singleton for get last location
        self.lastLocation = location
        
        // use for real time update location
        updateLocation(location)
        delegate?.tracingLocation?(location)
        delegate?.tracingTraveledDistance?(traveledDistanceOnLocal+traveledDistanceOnServer)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // do on error
        updateLocationDidFailWithError(error)
        isUpdatingLocation = false
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){

        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation?(currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError?(error)
    }
}
