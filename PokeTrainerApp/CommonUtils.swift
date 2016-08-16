//
//  CommonUtils.swift
//  What2Watch
//
//  Created by Dustin Allen 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class CommonUtils: NSObject {
    static let sharedUtils = CommonUtils()
    var progressView : MBProgressHUD = MBProgressHUD.init()
    
    var lat: Double = 0
    var long: Double = 0
    
    
    //
    
    // show alert view
    func showAlert(controller: UIViewController, title: String, message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        controller.presentViewController(ac, animated: true){}
    }
    
    // show progress view
    func showProgress(view : UIView, label : String) {
        progressView = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressView.labelText = label
    }
    
    // hide progress view
    func hideProgress(){
        progressView.removeFromSuperview()
        progressView.hide(true)
    }
    
    func decodeImage(base64String : String) -> UIImage {
        let decodedData = NSData(base64EncodedString: base64String, options:  NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let image = UIImage(data: decodedData!)
        return image!
    }
}

// UIView Extension

extension UIView {
    
    func setBorder() {
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        //        self.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue:0.5, alpha: 0.8 ).CGColor
        self.layer.borderColor = UIColor.yellowColor().CGColor
        self.clipsToBounds = true
    }
    
    func removeBorder() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clearColor().CGColor
    }
    
}