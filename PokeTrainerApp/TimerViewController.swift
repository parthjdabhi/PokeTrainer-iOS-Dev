//
//  TimerViewController.swift
//  PokeTrainerApp
//
//  Created by Dustin Allen on 7/19/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
class TimerViewController: UIViewController, PDGlobalTimerDelegate, PDLocationServiceDelegate {
    
    @IBOutlet weak var lblProgressText: UILabel!
    @IBOutlet weak var lblMilesTralveled: UILabel!
    @IBOutlet weak var lblMilesPerHour: UILabel!
    @IBOutlet weak var lblMinPlayed: UILabel!
    @IBOutlet weak var lblCalBurnedPerHour: UILabel!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var Progress: PDCircularProgress!
    
    var lastLocation: CLLocation!
    var distanceTraveled = 0.0
    
    let healthManager:HealthKitManager = HealthKitManager()
    var height: HKQuantitySample?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PDGlobalTimer.sharedInstance().delegate = self
        PDLocationService.sharedInstance.delegate = self
        
        Progress.trackTintColor = UIColor.init(red: 74 / 255, green: 144 / 255, blue: 226 / 255, alpha: 0.2)
        Progress.progressTintColor = UIColor.init(red: 74 / 255, green: 144 / 255, blue: 226 / 255, alpha: 1)
        Progress.thicknessRatio = 0.2
        Progress.updateProgress(0.01, animated: true, initialDelay: 1)
        
        btnHome.alignImageAndTitleVertically()
    }
    
    override func viewWillDisappear(animated: Bool) {
        PDGlobalTimer.sharedInstance().delegate = nil
        PDLocationService.sharedInstance.delegate = nil
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startTimer(sender: AnyObject) {
        PDGlobalTimer.sharedInstance().startTimer()
        PDLocationService.sharedInstance.startUpdatingLocation()
    }
    
    @IBAction func stopTimer(sender: AnyObject) {
        PDGlobalTimer.sharedInstance().stopTimer()
        PDLocationService.sharedInstance.stopUpdatingLocation()
    }
    
    func timePassedIn(Hours: Int, Minutes: Int, Seconds: Int, MiliSeconds: Int) {
        //String(format: "%0.2d:%0.2d:%0.2d.%0.3d",Hours,Minutes,Seconds,MiliSeconds)
        lblMinPlayed.text = String(format: "%0.2d:%0.2d min\nPlayed",Hours,Minutes)
        lblMilesPerHour.text = String(format: "%0.2f miles\nPer hour",((PDLocationService.sharedInstance.traveledDistanceOnServer + PDLocationService.sharedInstance.traveledDistanceOnLocal)/(Double(Hours) + (Double(Minutes) * 0.6))))
    }
    
    func tracingTraveledDistance(traveledDistance: Double) {
        lblMilesTralveled.text = String(format: "%0.2f miles\nTraveled",traveledDistance)
        //Progress.updateProgress(((CGFloat(traveledDistance) % 100) / 100), animated: true, initialDelay: 0)
    }
    
    func caloriesBurned(strCalories: String) {
        lblCalBurnedPerHour.text = "\(strCalories) cal\nPer hour"
        lblProgressText.text = "\(strCalories) KCal"
        Progress.updateProgress((CGFloat(PDGlobalTimer.sharedInstance().caloriesBurned) / 10), animated: true, initialDelay: 0)
    }
    
    @IBAction func homeButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
//        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
//        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
    }
    
    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func share(sender: AnyObject) {
        healthManager.saveDistance(distanceTraveled, date: NSDate())
    }
    
}


extension UIButton {
    
    func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
    
}
