//
//  SettingsViewController.swift
//  PokeTrainerApp
//
//  Created by Dustin Allen on 8/9/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    //Q1
    @IBOutlet var btn_Team_MYSTIC: UIButton!
    @IBOutlet var btn_Team_INSTINCT: UIButton!
    @IBOutlet var btn_Team_VALOR: UIButton!
    //Q2
    @IBOutlet var btn_Play_CASUAL: UIButton!
    @IBOutlet var btn_Play_SEMIPRO: UIButton!
    @IBOutlet var btn_Play_DIEHARD: UIButton!
    //Q3
    @IBOutlet var btn_Hunt_TRAINER: UIButton!
    @IBOutlet var btn_Hunt_GROUP: UIButton!
    
    //    var playerKindArray = ["Serious", "For Fun", "Other", "PokeWhat?"]
    //    var howToHuntArray = ["In A Group", "Pair", "Alone"]
    //    var whenHuntMostArray = ["All Day", "Mornings", "Afternoons", "Evenings"]
    //    var whenWantToHuntArray = ["Now", "Morning", "Afternoon", "Evening"]
    
    var type_team = ["MYSTIC","INSTINCT","VALOR"]
    var type_play = ["CASUAL","SEMI-PRO","DIE HARD"]
    var type_hunt = ["TRAINER","GROUP"]
    
    var Selected_type_team = "MYSTIC"
    var Selected_type_play = "CASUAL"
    var Selected_type_hunt = "TRAINER"
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    var profileData = "profileData"
    var userData: NSDictionary?
    var primaryEmail: String?
    var primaryPassword: String?
    @IBOutlet weak var questionScrollView: UIScrollView!
    @IBOutlet weak var questionView: UIView!
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Set Lable Texts
        userData = NSUserDefaults.standardUserDefaults().objectForKey("userData") as! NSDictionary!
        let userEmail = userData?.valueForKey("email") as! String!
        let firstName = userData?.valueForKey("firstName") as! String!
        let lastName = userData?.valueForKey("lastName") as! String!
        let userPassword = userData?.valueForKey("password") as! String!
        primaryEmail = userData?.valueForKey("primaryEmail") as! String!
        primaryPassword = userData?.valueForKey("primaryPassword") as! String!
        self.firstNameField.text = firstName
        self.lastNameField.text = lastName
        self.emailField.text = userEmail
        self.passwordField.text = userPassword
        
        
        // Set Content size of scroll view
        questionScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 585)
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        let button = GIDSignInButton()
        button.center = view.center
        
        //view.addSubview(button)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            NSUserDefaults.standardUserDefaults().removeObjectForKey("traveledDistanceOnLocal")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("previouslyElapsedSecondsOnLocal")
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! FirebaseSignInViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func updateProfile(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        let user = FIRAuth.auth()?.currentUser
        print(email)
        print(password)
        print(user)
        self.navigationController?.popViewControllerAnimated(true)
        /*
        let credential = FIREmailPasswordAuthProvider.credentialWithEmail(primaryEmail!, password: primaryPassword!)
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
        
        // Prompt the user to re-provide their sign-in credentials
        
        user?.reauthenticateWithCredential(credential) { error in
            if let error = error {
                // An error happened.
                print(error)
            } else {
                // User re-authenticated.
                user!.updateEmail(email) { error in
                    if let error = error {
                        print(error)
                        CommonUtils.sharedUtils.hideProgress()
                        
                    } else {
                        //Email updated.
                        
                        // Save primary email to NSUserDefaults
                        NSUserDefaults.standardUserDefaults().setValue(email, forKey: "primaryEmail")
                        
                        user?.updatePassword(password) { error in
                            if let error = error {
                                print(error)
                                CommonUtils.sharedUtils.hideProgress()
                            } else {
                                // Password updated.
                                // Save primary password to NSUserDefaults
                                NSUserDefaults.standardUserDefaults().setValue(password, forKey: "primaryPassword")
                                
                                self.ref.child("users").child(self.user!.uid).child("userInfo").setValue([
                                    "userFirstName": self.firstNameField.text!,
                                    "userLastName": self.lastNameField.text!,
                                    "email": email])
                                CommonUtils.sharedUtils.hideProgress()
                                
                            }
                        }
                    }
                }
            }
        }*/
        
        
        
        
        //            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
        //                if error == nil {
        //                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
        //
        //                    //*****Start******By Roswalt*****************
        //
        //                    self.ref.child("users").child(user!.uid).child("userInfo").setValue([
        //                        "userFirstName": self.firstNameField.text!,
        //                        "userLastName": self.lastNameField.text!,
        //                        "email": email,
        //                        "location":["lat":CommonUtils.sharedUtils.lat, "long":CommonUtils.sharedUtils.long],
        //                        "userData": self.profileData])
        //                    //******End*****By Roswalt*****************
        //
        //                    CommonUtils.sharedUtils.hideProgress()
        //                    let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        //                    self.navigationController?.pushViewController(mainScreenViewController, animated: true)
        //                } else {
        //                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
        //                        CommonUtils.sharedUtils.hideProgress()
        //                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
        //                    })
        //                }
        //            }
        //        )
    }
    
    @IBAction func btn_select_team(sender: UIButton!) {
        sender.setBorder()
        if sender == btn_Team_MYSTIC {
            Selected_type_team = type_team[0]
            btn_Team_MYSTIC.tag = 1
            btn_Team_INSTINCT.tag = 0
            btn_Team_VALOR.tag = 0
            btn_Team_INSTINCT.removeBorder()
            btn_Team_VALOR.removeBorder()
        } else if sender == btn_Team_INSTINCT {
            Selected_type_team = type_team[1]
            btn_Team_MYSTIC.tag = 0
            btn_Team_INSTINCT.tag = 1
            btn_Team_VALOR.tag = 0
            btn_Team_MYSTIC.removeBorder()
            btn_Team_VALOR.removeBorder()
        } else if sender == btn_Team_VALOR {
            Selected_type_team = type_team[2]
            btn_Team_MYSTIC.tag = 0
            btn_Team_INSTINCT.tag = 0
            btn_Team_VALOR.tag = 1
            btn_Team_MYSTIC.removeBorder()
            btn_Team_INSTINCT.removeBorder()
        }
    }
    
    @IBAction func btn_select_play(sender: UIButton!) {
        sender.setBorder()
        if sender == btn_Play_CASUAL {
            Selected_type_play = type_play[0]
            btn_Play_CASUAL.tag = 1
            btn_Play_SEMIPRO.tag = 0
            btn_Play_DIEHARD.tag = 0
            btn_Play_SEMIPRO.removeBorder()
            btn_Play_DIEHARD.removeBorder()
        } else if sender == btn_Play_SEMIPRO {
            Selected_type_play = type_play[1]
            btn_Play_CASUAL.tag = 0
            btn_Play_SEMIPRO.tag = 1
            btn_Play_DIEHARD.tag = 0
            btn_Play_CASUAL.removeBorder()
            btn_Play_DIEHARD.removeBorder()
        } else if sender == btn_Play_DIEHARD {
            Selected_type_play = type_play[2]
            btn_Play_CASUAL.tag = 0
            btn_Play_SEMIPRO.tag = 0
            btn_Play_DIEHARD.tag = 1
            btn_Play_CASUAL.removeBorder()
            btn_Play_SEMIPRO.removeBorder()
        }
    }
    
    @IBAction func btn_select_hunt(sender: UIButton!) {
        sender.setBorder()
        if sender == btn_Hunt_TRAINER {
            Selected_type_hunt = type_hunt[0]
            btn_Hunt_GROUP.tag = 0
            btn_Hunt_TRAINER.tag = 1
            btn_Hunt_GROUP.removeBorder()
        } else if sender == btn_Hunt_GROUP {
            Selected_type_hunt = type_hunt[1]
            btn_Hunt_GROUP.tag = 1
            btn_Team_INSTINCT.tag = 0
            btn_Hunt_TRAINER.removeBorder()
        }
    }
}
