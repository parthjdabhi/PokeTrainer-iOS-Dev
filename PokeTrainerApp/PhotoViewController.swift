//
//  PhotoViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PhotoViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet var profileInfo: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var btn_UpdatePhoto: UIButton!
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
    var imgTaken = false
    var nowTime = false
    
    let clr_Border = UIColor.yellowColor().CGColor
    let border_Width = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        self.view.layoutIfNeeded()
        
        btn_UpdatePhoto.setTitle("Add Photo", forState: .Normal)
        
        btn_Team_MYSTIC.setBorder()
        btn_Team_MYSTIC.tag = 1
        btn_Play_CASUAL.setBorder()
        btn_Play_CASUAL.tag = 1
        btn_Hunt_TRAINER.setBorder()
        btn_Hunt_TRAINER.tag = 1
        
        photo.layer.borderWidth = 1
        photo.layer.masksToBounds = true
        photo.layer.borderColor = UIColor.whiteColor().CGColor
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        btn_UpdatePhoto.layer.masksToBounds = true
        btn_UpdatePhoto.layer.cornerRadius = 4
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        //        FIRDatabase.database().reference().child("users").child(userID!).child("profileData").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        //            AppState.sharedInstance.currentUser = snapshot
        //            if let base64String = snapshot.value!["userPhoto"] as? String {
        //                // decode image
        //                self.photo.image = CommonUtils.sharedUtils.decodeImage(base64String)
        //            } else {
        //                if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
        //                    if let image_url = facebookData["profilePhotoURL"]  {
        //                        print(image_url)
        //                        let image_url_string = image_url
        //                        let url = NSURL(string: "\(image_url_string)")
        //                        self.photo.sd_setImageWithURL(url)
        //                    }
        //                }
        //            }})
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photo.layer.cornerRadius = photo.frame.height/2
    }
    
    //    override func viewDidAppear(animated: Bool) {
    //        super.viewDidAppear(animated)
    //        photo.layer.cornerRadius = photo.frame.height/2
    //    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        // 1
        view.endEditing(true)
        
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .Default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .Camera
                                                self.presentViewController(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 4
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .Default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .PhotoLibrary
                                            self.presentViewController(imagePicker,
                                                                       animated: true,
                                                                       completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 5
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        // 6
        presentViewController(imagePickerActionSheet, animated: true,
                              completion: nil)
    }
    
    @IBAction func nextButton(sender: AnyObject) {
        
        if imgTaken == false {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
            return
        }
        
        let uploadImage : UIImage = photo.image!
        let base64String = self.imgToBase64(uploadImage)
        let userID = FIRAuth.auth()?.currentUser?.uid
        CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading image...")
        self.ref.child("users").child(user!.uid).child("profileData").setValue(["gameDetails":["type_team": Selected_type_team, "type_play": Selected_type_play, "type_hunt": Selected_type_hunt]])
        ref.child("users").child(userID!).child("profileData").child("userPhoto").setValue(base64String) { (error, firebase) in
            CommonUtils.sharedUtils.hideProgress()
            if error == nil {
                let youreSetViewController = self.storyboard?.instantiateViewControllerWithIdentifier("YoureSetViewController") as! YoureSetViewController!
                self.navigationController?.pushViewController(youreSetViewController, animated: true)
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Failed uploading profile image")
            }
        }
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    // Activity Indicator methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //photo.contentMode = .ScaleAspectFit
            photo.image = self.scaleImage(pickedImage, maxDimension: 300)
        }
        
        self.imgTaken = true
        dismissViewControllerAnimated(true, completion: nil)
        btn_UpdatePhoto.setTitle("Update Photo", forState: .Normal)
    }
    
    func imgToBase64(image: UIImage) -> String {
        let imageData:NSData = UIImagePNGRepresentation(image)!
        let base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(base64String)
        
        return base64String
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



