//
//  SettingQuesViewController.swift
//  PokeTrainerApp
//
//  Created by iParth on 8/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class SettingQuesViewController: UIViewController {

    @IBOutlet var profileInfo: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    var ref: FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //login-screen_0000s_0002s_0001_Rounded-Rectangle-1
        //login-screen_0000s_0004s_0002_Rounded-Rectangle-1
        //
        
        // Do any additional setup after loading the view.
        
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        
        let userFirstName = AppState.sharedInstance.currentUser?.value?["userFirstName"] as? String ?? ""
        let userLastName = AppState.sharedInstance.currentUser?.value?["userLastName"] as? String ?? ""
        self.profileInfo.text = "  Welcome, \(userFirstName) \(userLastName)!  "
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).child("profileData").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            if let base64String = snapshot.value!["userPhoto"] as? String {
                // decode image
                self.profilePicture.image = CommonUtils.sharedUtils.decodeImage(base64String)
            } else {
                if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
                    if let image_url = facebookData["profilePhotoURL"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.profilePicture.sd_setImageWithURL(url)
                    }
                }
            }})
        self.ref.child("users").child(userID!).child("userInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            AppState.sharedInstance.currentUser = snapshot
            self.profileInfo.text = "  Welcome,  "
            let userFirstName = AppState.sharedInstance.currentUser?.value?["userFirstName"] as? String ?? ""
            let userLastName = AppState.sharedInstance.currentUser?.value?["userLastName"] as? String ?? ""
            self.profileInfo.text = "  Welcome, \(userFirstName) \(userLastName)!  "
            AppState.sharedInstance.displayName = "\(userFirstName) \(userLastName)"
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
