//
//  EveningViewController.swift
//  PokeTrainerApp
//
//  Created by Dustin Allen on 7/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit

class EveningViewController: UIViewController {
    
    @IBAction func time1Button(sender: AnyObject) {
        let youreSetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
        self.navigationController?.pushViewController(youreSetViewController, animated: true)
    }
    
    @IBAction func time2Button(sender: AnyObject) {
        let youreSetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
        self.navigationController?.pushViewController(youreSetViewController, animated: true)
    }
    
    @IBAction func time3Button(sender: AnyObject) {
        let youreSetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
        self.navigationController?.pushViewController(youreSetViewController, animated: true)
    }
    

}
