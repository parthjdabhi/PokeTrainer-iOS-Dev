//
//  Global.swift
//  PokeTrainerApp
//
//  Created by Blue on 7/26/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreLocation

let conversion = 0.000621371192

class Global: NSObject {
    
    static func mileToMeter(distanceMile:Double) -> Double {
        
        
        return (distanceMile / conversion)
    }
    
    static func meterToMile(distanceMeter:Double) -> Double {
        
        return (distanceMeter * conversion)
    }
    
    static func getDistanceFromCoordinate(firstPoint:CLLocationCoordinate2D, secondPoint:CLLocationCoordinate2D) -> CLLocationDistance {
        
        let location1 = CLLocation(latitude: firstPoint.latitude, longitude: firstPoint.longitude)
        let location2 = CLLocation(latitude: secondPoint.latitude, longitude: secondPoint.longitude)
        
        let distance = location1.distanceFromLocation(location2)
        
        return Global.meterToMile(distance)
        
    }

}
