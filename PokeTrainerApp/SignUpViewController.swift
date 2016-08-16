//
//  SignUpViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
//import TwitterKit
//import Fabric
import Firebase
import OAuthSwift
import Google
import GoogleSignIn

class SignUpViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var facebook: UIButton!
    
    @IBOutlet var google: GIDSignInButton!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    var profileData = "profileData"
    
    override func viewDidLoad() {
    }

    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let button = GIDSignInButton()
        button.center = view.center
        
        //view.addSubview(button)
    }
    
    @IBAction func googleSignIn(sender: AnyObject) {
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        GIDSignIn.sharedInstance().signIn()
    }
    
    func authenticateWithGoogle(sender:UIButton){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        CommonUtils.sharedUtils.hideProgress()
        if (error == nil) {
            // Perform any operations on signed in user here.
            
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
            CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
            let authentication = user.authentication
            let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
            
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                
                CommonUtils.sharedUtils.hideProgress()
                var photoURL : String = ""
                for profile in user!.providerData {
                    if(profile.photoURL != nil){
                        photoURL = (profile.photoURL?.absoluteString)!
                    }                }
                //******Start*****By Roswalt*****************
                
                self.ref.child("users").child(user!.uid).child("userInfo").setValue([
                    "email": email,
                    "location":["lat":CommonUtils.sharedUtils.lat, "long":CommonUtils.sharedUtils.long],
                    "googleData": ["userFirstName": givenName,
                        "userLastName": familyName,
                        "email": email,
                        "profilePhotoURL": photoURL],
                    "userFirstName": givenName,
                    "userLastName": familyName
                    ])
                //*****End******By Roswalt*****************
                let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
                self.navigationController?.pushViewController(photoViewController, animated: true)
            })
            
        } else {
            CommonUtils.sharedUtils.hideProgress()
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
        let manager = FBSDKLoginManager()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error.localizedDescription)
            }
            else if result.isCancelled {
                print("Facebook login cancelled")
            }
            else {
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        CommonUtils.sharedUtils.hideProgress()
                    }
                    else {
                        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,friends,picture"])
                        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                            CommonUtils.sharedUtils.hideProgress()
                            if ((error) != nil) {
                                // Process error
                                print("Error: \(error)")
                            } else {
                                print("fetched user: \(result)")
                                
                                //******Start*****By Roswalt*****************

                                self.ref.child("users").child(user!.uid).child("userInfo").setValue([
                                    "facebookData": ["userFirstName": result.valueForKey("first_name") as! String!,
                                                     "userLastName": result.valueForKey("last_name") as! String!,
                                                     "gender": result.valueForKey("gender") as! String!,
                                                     "email": result.valueForKey("email") as! String!],
                                    "location":["lat":CommonUtils.sharedUtils.lat, "long":CommonUtils.sharedUtils.long],
                                    "userFirstName": result.valueForKey("first_name") as! String!,
                                    "userLastName": result.valueForKey("last_name") as! String!,
                                    "email": result.valueForKey("email") as! String!])
                                
                                //******End*****By Roswalt*****************

                                if let picture = result.objectForKey("picture") {
                                    if let pictureData = picture.objectForKey("data"){
                                        if let pictureURL = pictureData.valueForKey("url") {
                                            print(pictureURL)
                                            self.ref.child("users").child(user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                        }
                                    }
                                }
                                let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
                                self.navigationController?.pushViewController(photoViewController, animated: true)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func createProfile(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        if email != "" && password != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                    
                    //*****Start******By Roswalt*****************
                    
                    // Save user data to local
                    let currentUser = User()
                    currentUser.setData(email, firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, password: password)
                    
                    // Save data to Firebase
                    self.ref.child("users").child(user!.uid).child("userInfo").setValue([
                        "userFirstName": self.firstNameField.text!,
                        "userLastName": self.lastNameField.text!,
                        "email": email,
                        "location":["lat":CommonUtils.sharedUtils.lat, "long":CommonUtils.sharedUtils.long],
                        "userData": self.profileData])
                    //******End*****By Roswalt*****************

                    CommonUtils.sharedUtils.hideProgress()
                    let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
                    self.navigationController?.pushViewController(photoViewController, animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
        }
    }
}