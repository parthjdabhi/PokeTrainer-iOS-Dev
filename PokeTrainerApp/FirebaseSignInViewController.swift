//
//  FirebaseSignInViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKShareKit
import Google
import GoogleSignIn

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

@objc(FirebaseSignInViewController)
class FirebaseSignInViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate, UITextViewDelegate {
    
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var login: UIButton!
    @IBOutlet var google: GIDSignInButton!
    @IBOutlet var emailWord: UIImageView!
    @IBOutlet var emailIcon: UIImageView!
    @IBOutlet var passwordWord: UIImageView!
    @IBOutlet var passwordIcon: UIImageView!
    
    
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
            print(configureError)
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let button = GIDSignInButton(frame: CGRectMake(0, 0, 100, 100))
        button.center = view.center
        emailField.text = "Email"
        emailField.textColor = UIColor.whiteColor()
        let paddingForSecond = UIView(frame: CGRectMake(0, 0, 35, self.passwordField.frame.size.height))
        //Adding the padding to the second textField
        emailField.leftView = paddingForSecond
        emailField.leftViewMode = UITextFieldViewMode .Always
        emailField.font = UIFont(name: emailField.font!.fontName, size: 20)
        passwordField.text = "Password"
        passwordField.textColor = UIColor.whiteColor()
        let paddingForFirst = UIView(frame: CGRectMake(0, 0, 35, self.passwordField.frame.size.height))
        //Adding the padding to the second textField
        passwordField.leftView = paddingForFirst
        passwordField.leftViewMode = UITextFieldViewMode .Always
        passwordField.font = UIFont(name: passwordField.font!.fontName, size: 20)
        
        //view.addSubview(button)
    }
    
    override func viewDidAppear(animated: Bool) {
                //try! FIRAuth.auth()?.signOut()
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
        ref = FIRDatabase.database().reference()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func googleSignIn(sender: AnyObject) {
        CommonUtils.sharedUtils.showProgress(self.view, label: "Signing in...")
      GIDSignIn.sharedInstance().signIn()
    }
    
    func authenticateWithGoogle(sender:UIButton){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        //print(user.profile.email)
        //print(user.profile.imageURLWithDimension(400))
        if let error = error {
            print ("\(error.localizedDescription)")
            CommonUtils.sharedUtils.hideProgress()
            //self.showMessagePrompt(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print ("\(error!.localizedDescription)")
            }else{
            
            let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
                self.navigationController?.pushViewController(mainScreenViewController, animated: true)            }
        }
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    @IBAction func EmailTextBox(sender: AnyObject) {
    }
    
    @IBAction func passwordTextBox(sender: AnyObject) {
    }
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        
        // Sign In with credentials.
        let email = emailField.text!
        let password = passwordField.text!
        if email.isEmpty || password.isEmpty {
            CommonUtils.sharedUtils.showAlert(self, title: "Error", message: "Email or password is missing.")
        }
        else{
            CommonUtils.sharedUtils.showProgress(self.view, label: "Signing in...")
            FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    CommonUtils.sharedUtils.hideProgress()
                })
                
                if let error = error {
                    CommonUtils.sharedUtils.showAlert(self, title: "Error", message: error.localizedDescription)
                    print(error.localizedDescription)
                }
                else
                {
                    PDGlobalTimer.sharedInstance().restartCounting()
                    //                    self.signedIn(user!)
                    let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
                    self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                }
            }
        }
    }
    @IBAction func didTapSignUp(sender: AnyObject) {
        let signupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController!
        self.navigationController?.pushViewController(signupViewController, animated: true)
        
    }
    
    func setDisplayName(user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    @IBAction func didRequestPasswordReset(sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextFieldWithConfigurationHandler(nil)
        prompt.addAction(okAction)
        presentViewController(prompt, animated: true, completion: nil);
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        
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
                        PDGlobalTimer.sharedInstance().restartCounting()
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
                                let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
                                self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                            }
                        })
                    }
                })
            }
        }
        
    }

    func signedIn(user: FIRUser?) {
        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
    }
}
