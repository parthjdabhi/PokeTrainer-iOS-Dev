//
//  PDGlobalTimer.swift
//  PokeTrainerApp
//
//  Created by iParth on 8/8/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

@objc protocol PDGlobalTimerDelegate: class {
    optional func timePassedIn(Hours:Int,Minutes:Int,Seconds:Int,MiliSeconds:Int)
    optional func timePassInSeconds(strTime:String)
    optional func timePassinHours(strTime:String)
    optional func caloriesBurned(strCalories:String)
}

class PDGlobalTimer: NSObject {
    
    var zeroTime = NSTimeInterval()
    var internalTimer: NSTimer?
    var internalTimerStartDate = NSDate()
    var previouslyElapsedSeconds: NSTimeInterval = NSTimeInterval(0)
    var secondsElapsedSinceTimerStart: NSTimeInterval = NSTimeInterval(0)
    var totalSecondsElapsedOnLocal: NSTimeInterval = NSTimeInterval(0)
    
    var syncTimer: NSTimer?
    var totalSecondsElapsedOnServer: NSTimeInterval = NSTimeInterval(0)
    var totalElapsedSavingOffset: NSTimeInterval = NSTimeInterval(0)
    
    var isTimerSyncOnServerInProgress = false
    var isDistanceSyncOnServerInProgress = false
    var caloriesBurned:Double = 0
    
    weak var delegate: PDGlobalTimerDelegate?
    
    private static let _sharedInstance = PDGlobalTimer()
    
    class func sharedInstance() -> PDGlobalTimer {
        return _sharedInstance
    }
    
    func resetData() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("traveledDistanceOnLocal")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("previouslyElapsedSecondsOnLocal")
        self.stopTimer()
        secondsElapsedSinceTimerStart = 0
        totalSecondsElapsedOnLocal = 0
        totalSecondsElapsedOnServer = 0
        
        PDLocationService.sharedInstance.stopUpdatingLocation()
        PDLocationService.sharedInstance.traveledDistanceOnLocal = 0
        PDLocationService.sharedInstance.traveledDistanceSavingOffset = 0
        PDLocationService.sharedInstance.traveledDistanceOnServer = 0
    }
    
    func restartCounting() {
        resetData()
        self.startTimer()
        PDLocationService.sharedInstance.startUpdatingLocation()
    }
    
    func startTimer()
    {
        guard self.internalTimer == nil else {
            //fatalError("Timer already intialized, how did we get here with a singleton?!")
            return
        }
        
        if let PEseconds = NSUserDefaults.standardUserDefaults().objectForKey("previouslyElapsedSecondsOnLocal") as? Double {
            previouslyElapsedSeconds = NSTimeInterval(PEseconds)
            print("previouslyElapsedSecondsOnLocal : \(previouslyElapsedSeconds)")
        }
        totalSecondsElapsedOnLocal = NSTimeInterval(0)
        
        internalTimerStartDate = NSDate()
        self.internalTimer = NSTimer.scheduledTimerWithTimeInterval(0.1 /*seconds*/, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
        syncTimer = NSTimer.scheduledTimerWithTimeInterval(60*1 /*seconds*/, target: self, selector: #selector(syncDistanceTraveled), userInfo: nil, repeats: true)
        syncDistanceTraveled()
    }
    
    func stopTimer()
    {
        guard internalTimer != nil else {
            //fatalError("No timer active, start the timer before you stop it.")
            return
        }
        
        secondsElapsedSinceTimerStart = NSDate().timeIntervalSinceDate(internalTimerStartDate)
        totalSecondsElapsedOnLocal = self.previouslyElapsedSeconds + secondsElapsedSinceTimerStart
        
        print("Save totalSecondsElapsed : \(totalSecondsElapsedOnLocal)")
        
        NSUserDefaults.standardUserDefaults().setDouble(self.totalSecondsElapsedOnLocal, forKey: "previouslyElapsedSecondsOnLocal")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.internalTimer?.invalidate()
        self.internalTimer = nil
    }
    
    func fireTimerAction(sender: NSTimer?) {
        
        secondsElapsedSinceTimerStart = NSDate().timeIntervalSinceDate(internalTimerStartDate)
        //print("secondsElapsedSinceTimerStart : \(secondsElapsedSinceTimerStart) -- \(NSDate().timeIntervalSinceDate(internalTimerStartDate))")
        self.totalSecondsElapsedOnLocal = previouslyElapsedSeconds + secondsElapsedSinceTimerStart
        //debugPrint("Timer Fired! \(sender)  totalSecondsElapsed : \(self.totalSecondsElapsed) seconds : \(self.totalSecondsElapsed?.seconds)")
        
        //var timePassed: NSTimeInterval = self.totalSecondsElapsed!
        let timePassed: NSTimeInterval = (totalSecondsElapsedOnServer + self.totalSecondsElapsedOnLocal) >= 0 ? (totalSecondsElapsedOnServer + self.totalSecondsElapsedOnLocal) : 0
        
        //        let hours = UInt8(timePassed / 360.0)
        //        timePassed -= (NSTimeInterval(hours) * 360)
        //        let minutes = UInt8(timePassed / 60.0)
        //        timePassed -= (NSTimeInterval(minutes) * 60)
        //        let seconds = UInt8(timePassed)
        //        timePassed -= NSTimeInterval(seconds)
        //        let millisecsX10 = UInt8(timePassed * 100)
        
        let ti = NSInteger(timePassed)
        let ms = Int((timePassed % 1) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        //        print("Time : \(String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms))")
        
        delegate?.timePassedIn?(hours, Minutes: minutes, Seconds: seconds, MiliSeconds: ms)
        
        delegate?.timePassInSeconds?(String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms))
        delegate?.timePassinHours?(String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds))
        
        let Part1 = ((25 * 0.2017) - (175 * 0.09036) + (100 * 0.6309) - 55.0969)
        let Part2 = ( (Double(hours) + (Double(minutes) * 0.01)) / 4.184)
        caloriesBurned = abs(Part1 * Part2)
        delegate?.caloriesBurned?(String(format: "%0.2f", caloriesBurned))
    }
    
    func syncDistanceTraveled() {
        
        
        
        //        self.totalElapsedSavingOffset = self.totalSecondsElapsedOnLocal
        //        self.totalSecondsElapsedOnServer = 0
        //        debugPrint("Before Update totalSecondsElapsedOnServer \(self.totalSecondsElapsedOnServer) totalSecondsElapsedOnLocal : \(self.totalSecondsElapsedOnLocal)  totalElapsedSavingOffset : \(self.totalElapsedSavingOffset)")
        //
        //        self.totalSecondsElapsedOnServer = self.totalSecondsElapsedOnServer + self.totalElapsedSavingOffset
        //        self.totalSecondsElapsedOnLocal = self.totalSecondsElapsedOnLocal - self.totalElapsedSavingOffset
        //        debugPrint("After Update totalSecondsElapsedOnServer \(self.totalSecondsElapsedOnServer)  totalSecondsElapsedOnLocal : \(self.totalSecondsElapsedOnLocal)")
        //
        //        NSUserDefaults.standardUserDefaults().setDouble(self.totalSecondsElapsedOnLocal, forKey: "previouslyElapsedSecondsOnLocal")
        //        NSUserDefaults.standardUserDefaults().synchronize()
        //
        //        return
        
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        
        //FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("userInfo").setValue(["HelthData": ["totalSecondsElapsed":  self.totalSecondsElapsed!]])
        PDLocationService.sharedInstance.traveledDistanceSavingOffset = PDLocationService.sharedInstance.traveledDistanceOnLocal
        
        //timer.invalidate()
        //startTimer()
        
        FIRDatabase.database().reference().child("users").child(user.uid).child("userInfo").observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            if snapshot.exists() {
                print(snapshot.childrenCount) // I got the expected number of items
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    //                    if var dictionary = rest.value as? [NSString : AnyObject]
                    //                        where (dictionary[FRECENT_USERID] as! String) == FIRAuth.auth()?.currentUser?.uid
                    //                    {
                    //                        //let recent = Diction .init(dictionary: dictionary)
                    //                        print("\(dictionary) : make counter zero")
                    //                        dictionary[FRECENT_COUNTER] = 0
                    //
                    //                        let firebaseR: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
                    //                        firebaseR.updateChildValues(dictionary) { (error, FIRDBRef) in
                    //                            if error == nil {
                    //                                print("saved recent object : ")
                    //                            } else {
                    //                                print("Failed to save recent object : ")
                    //                            }
                    //                        }
                    //                    }
                }
                
                let Dictionary = snapshot.valueInExportFormat() as? NSDictionary
                print(Dictionary)
                
                if self.isTimerSyncOnServerInProgress == false {
                    self.isTimerSyncOnServerInProgress = true
                    self.totalElapsedSavingOffset = self.totalSecondsElapsedOnLocal
                    self.totalSecondsElapsedOnServer = snapshot.value!["totalSecondsElapsed"] as? Double ?? 0
                    let SyncStartdate = NSDate()
                    FIRDatabase.database().reference().child("users").child(user.uid).child("userInfo").updateChildValues(["totalSecondsElapsed":  self.totalSecondsElapsedOnServer + self.totalElapsedSavingOffset], withCompletionBlock: { (error, ref) in
                        self.isTimerSyncOnServerInProgress = false
                        if error == nil {
                            // update server count
                            debugPrint("Before Update totalSecondsElapsedOnServer \(self.totalSecondsElapsedOnServer) totalSecondsElapsedOnLocal : \(self.totalSecondsElapsedOnLocal)  totalElapsedSavingOffset : \(self.totalElapsedSavingOffset)")
                            self.internalTimerStartDate = SyncStartdate
                            self.totalSecondsElapsedOnServer = self.totalSecondsElapsedOnServer + self.totalElapsedSavingOffset
                            self.totalSecondsElapsedOnLocal = self.totalSecondsElapsedOnLocal - self.totalElapsedSavingOffset
                            debugPrint("After Update totalSecondsElapsedOnServer \(self.totalSecondsElapsedOnServer)  totalSecondsElapsedOnLocal : \(self.totalSecondsElapsedOnLocal)")
                            
                            NSUserDefaults.standardUserDefaults().setDouble(self.totalSecondsElapsedOnLocal, forKey: "previouslyElapsedSecondsOnLocal")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        }
                    })
                }
                
                
                let traveledDistanceOfServer = snapshot.value!["traveledDistance"] as? Double ?? 0
                
                FIRDatabase.database().reference().child("users").child(user.uid).child("userInfo").updateChildValues(["traveledDistance":  traveledDistanceOfServer + PDLocationService.sharedInstance.traveledDistanceSavingOffset], withCompletionBlock: { (error, ref) in
                    
                    if error == nil {
                        // update server count
                        PDLocationService.sharedInstance.traveledDistanceOnServer = traveledDistanceOfServer + PDLocationService.sharedInstance.traveledDistanceSavingOffset
                        PDLocationService.sharedInstance.traveledDistanceOnLocal = PDLocationService.sharedInstance.traveledDistanceOnLocal - PDLocationService.sharedInstance.traveledDistanceSavingOffset
                        
                        NSUserDefaults.standardUserDefaults().setDouble(PDLocationService.sharedInstance.traveledDistanceOnLocal, forKey: "traveledDistanceOnLocal")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                })
                
                
            }
        })
    }
}
