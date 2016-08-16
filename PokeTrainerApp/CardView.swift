//
//  CardView.swift
//  PokeTrainerApp
//
//  Created by Blue on 7/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Koloda
import Firebase
import FirebaseAuth
import CoreLocation
class CardView: UIView {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var lblUsername: UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func displayUsername(username:String) {
        
        self.lblUsername.text = username
        
        
    }
    
    func displayUserProfilePiture(snapshot:FIRDataSnapshot) {
        
        print(snapshot.value)
        
        let firstName = snapshot.childSnapshotForPath("userInfo/userFirstName").value!
        let lastName = snapshot.childSnapshotForPath("userInfo/userLastName").value!
       
        self.lblUsername.text = "\(firstName) \(lastName)"
        
        if let base64String = snapshot.childSnapshotForPath("profileData/userPhoto").value as? String {
            // decode image
            self.profileImage.image = CommonUtils.sharedUtils.decodeImage(base64String)
        } else {
            if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
                if let image_url = facebookData["profilePhotoURL"]  {
                    print(image_url)
                    let image_url_string = image_url
                    let url = NSURL(string: "\(image_url_string)")
                    self.profileImage.sd_setImageWithURL(url)
                }
            }
        }

    }
}

