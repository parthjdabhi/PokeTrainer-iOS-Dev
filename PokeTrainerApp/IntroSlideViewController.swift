//
//  IntroSlideViewController.swift
//  PokeTrainerApp
//
//  Created by Dustin Allen on 8/9/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class IntroSlideViewController: UIViewController {
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func signInButton(sender: AnyObject) {
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! FirebaseSignInViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        let signupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController!
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }

}
