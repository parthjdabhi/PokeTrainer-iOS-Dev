//
//  SearchViewController.swift
//  PokeTrainerApp
//
//  Created by Blue on 7/25/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Koloda
import Firebase
import FirebaseAuth
import CoreLocation
import Alamofire

let DefaultDistance:Double = 10 //Mile
private var numberOfCards: UInt = 5

class SearchViewController: UIViewController {
    
    @IBOutlet var swipeView: KolodaView!
    
    var timer:NSTimer!
    var ref:FIRDatabaseReference!
    
    var arrUsers = NSMutableArray()
    var userReference:NSDictionary!
    
    let MyUserID = FIRAuth.auth()?.currentUser?.uid
    
    private var dataSource: Array<UIImage> = {
        var array: Array<UIImage> = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        
        self.getCurrentUserReference()
        
    }
    
    @IBAction func homeButton(sender: AnyObject) {
        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //get currentUser reference
    
    func getCurrentUserReference() {
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Searching People...")
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).child("profileData").child("gameDetails").observeEventType(.Value, withBlock: { (snapshot) in
            
            self.userReference = snapshot.valueInExportFormat() as! NSDictionary
            
            self.searchPeopleMatched()
            
        }) { (error) in
            
            CommonUtils.sharedUtils.hideProgress()
            CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: error.localizedDescription)
        }
        
    }
    //
    
func searchPeopleMatched() {
    
    self.arrUsers.removeAllObjects()
    
    self.ref.child("users").child(MyUserID!).child("userInfo").child("friendRequestStatus").observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
        
        let FriendRequestStatus = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
        let FriendRequestStatusAllKeys = FriendRequestStatus.allKeys as? [String] ?? []
        
        //Search people
        
        self.ref.child("users").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            let firstGroup = dispatch_group_create()
            
                CommonUtils.sharedUtils.hideProgress()
                
                let count = snapshot.childrenCount
                print ("user count : \(count)")
                for child in snapshot.children {
                    let ccc = child.childrenCount
                    print ("child count : \(ccc)")
                    if (FIRAuth.auth()?.currentUser?.uid != (child as! FIRDataSnapshot).key) {
                        dispatch_group_enter(firstGroup)
                        self.ref.child("users").child((child as! FIRDataSnapshot).key).child("userInfo").child("friendRequestStatus").observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                            
                            let myFriendRequestStatus = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
                            let myFriendRequestStatusAllKeys = myFriendRequestStatus.allKeys as? [String] ?? []
                            
                            if ((FIRAuth.auth()?.currentUser?.uid != (child as! FIRDataSnapshot).key) && (myFriendRequestStatusAllKeys.count == 0 || (myFriendRequestStatusAllKeys.count > 0 && myFriendRequestStatus[self.MyUserID!] == nil)))
                                //&& !((myFriendRequestStatus[(child as! FIRDataSnapshot).key] as? String ?? "") == "0")))
                            {
                                if self.isMatchedUser(child as! FIRDataSnapshot) {
                                    
                                    self.arrUsers.addObject(child)
                                    
                                }
                            } else if (myFriendRequestStatusAllKeys.count > 0
                                && (myFriendRequestStatus[(child as! FIRDataSnapshot).key] as? String ?? "") == "1") {
                                print("Its already matched \((child as! FIRDataSnapshot).key)")
                            }
                            
                            dispatch_group_leave(firstGroup)
                        })
                    }
                }
            
                dispatch_group_notify(firstGroup, dispatch_get_main_queue()) {
                    if self.arrUsers.count == 0 {
                        CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: "Can't find any people.")
                    } else {
                        self.initializeSwipeView(self.arrUsers)
                    }
                }
            }
        })
    
    }
    
    func initializeSwipeView(userArray:NSArray) {
        
        swipeView.dataSource = self
        swipeView.delegate = self
        
    }
    
    //Query :Match
    private func isMatchedUser(snapshot:FIRDataSnapshot) -> Bool {
        
        /*
         profileData
         gameDetails
         userHowToHunt:
         "In A Group"
         userHuntMost:
         "All Day"
         userPlayerKind:
         "Serious"
         userWhenWantToHunt:
         "Now"
         */
        
        let dic = snapshot.childSnapshotForPath("userInfo/location").valueInExportFormat() as? NSDictionary
        
        if !self.isInNearBy(dic)
        {
            return false
        }
        else
        {
            let gameDetailsDic = snapshot.childSnapshotForPath("profileData/gameDetails").valueInExportFormat() as? NSDictionary
            print(gameDetailsDic)
            
            if gameDetailsDic != nil {
                
                print("gameDetails --- \(gameDetailsDic)")
                print("userReference --- \(userReference)")
                
                if ((gameDetailsDic!["type_team"]?.stringValue == userReference["type_team"]?.stringValue) &&
                    (gameDetailsDic!["type_play"]?.stringValue == userReference["type_play"]?.stringValue) &&
                    (gameDetailsDic!["type_hunt"]?.stringValue == userReference["type_hunt"]?.stringValue))
                {
                    return true
                }
                else if ((gameDetailsDic!["userHowToHunt"]?.stringValue == userReference["userHowToHunt"]?.stringValue) &&
                    (gameDetailsDic!["userHuntMost"]?.stringValue == userReference["userHuntMost"]?.stringValue) &&
                    (gameDetailsDic!["userPlayerKind"]?.stringValue == userReference["userPlayerKind"]?.stringValue) &&
                    (gameDetailsDic!["userWhenWantToHunt"]?.stringValue === userReference["userWhenWantToHunt"]?.stringValue))
                {
                    return true
                }
            }
        }
        return false
    }
    
    //Query :in 10 miles Distance
    
    private func isInNearBy(pointDic:NSDictionary?) -> Bool {
        
        let firstPoint = CLLocationCoordinate2DMake(CommonUtils.sharedUtils.lat, CommonUtils.sharedUtils.long)
        let secondPoint = CLLocationCoordinate2DMake(pointDic?["lat"]?.doubleValue ?? 0, pointDic?["long"]?.doubleValue ?? 0)
        let distance = Global.getDistanceFromCoordinate(firstPoint, secondPoint: secondPoint)
        print("distance  is  \(distance)")
        return (distance < DefaultDistance)
    }
    
    //Timer Stop
    
    func finishedSearching() {
        
        CommonUtils.sharedUtils.hideProgress()
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        swipeView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        swipeView?.swipe(SwipeResultDirection.Right)
    }
    
}

//MARK: KolodaViewDelegate
extension SearchViewController: KolodaViewDelegate {
    
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        let Usnapshot = self.arrUsers.objectAtIndex(Int(index)) as! FIRDataSnapshot
        //let userID = FIRAuth.auth()?.currentUser?.uid
        
        let arrLikers = Usnapshot.childSnapshotForPath("userInfo/friendRequest").value as? NSMutableArray ?? NSMutableArray()
        //make dictionary key = uid values = 0/Dislike 1/(Like)Req sent 2/Friends
        
        //***** ADDED FOR FRIEND STATUS ****
        
        let friendRequestStatus = Usnapshot.childSnapshotForPath("userInfo/friendRequestStatus").value as? NSMutableDictionary ?? NSMutableDictionary()
        
        
        if direction == .Left || direction == .BottomLeft || direction == .TopLeft {
            
            if arrLikers.containsObject(MyUserID!){
                arrLikers.removeObject(MyUserID!)
            }
            //save as UID key:0 DISLIKE
            self.ref.child("users").child(Usnapshot.key).child("userInfo").updateChildValues(["friendRequest":arrLikers]) { (error, reference) in
                //save as key:1 (like)
                if error == nil {
                    print("updateChildValues success Remove friendRequest")
                }else  {
                    CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: (error?.localizedDescription)!)
                }
            }
            
            if friendRequestStatus.objectForKey(MyUserID!) != nil
            {
                //friendRequestStatus.removeObjectForKey(userID!)
            }
            friendRequestStatus[MyUserID!] = "0"
            //save as UID key:0 DISLIKE
            self.ref.child("users").child(Usnapshot.key).child("userInfo").child("friendRequestStatus").updateChildValues(friendRequestStatus as [NSObject : AnyObject]) { (error, reference) in
                if error == nil {
                    print("updateChildValues success friendRequestStatus")
                }else  {
                    CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: (error?.localizedDescription)!)
                }
            }
        } else if  direction == .Right || direction == .BottomRight || direction == .TopRight {
            
            //save as UID key:1 LIKE
            //Also Check for opp user has My UID key : 1, then set UID = 2 and in Opp Users My UDID = 2 (Request sent for Friend)
            if !arrLikers.containsObject(MyUserID!) {
                arrLikers.addObject(MyUserID!)
            }
            
            
            //save as UID key:1 LIKE
            //Also Check for opp user has My UID key : 1, then set UID = 2 and in Opp Users My UDID = 2 (Request sent for Friend)
            if friendRequestStatus.objectForKey(MyUserID!) != nil {
                friendRequestStatus[MyUserID!] = "1"
            }
            friendRequestStatus[MyUserID!] = "1"
            
            self.ref.child("users").child(MyUserID!).child("userInfo").observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                
                friendRequestStatus
                let myFriendRequestStatus = snapshot.childSnapshotForPath("friendRequestStatus").valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
                
                let userInfo = snapshot.valueInExportFormat() as? NSMutableDictionary ?? NSMutableDictionary()
                let token = userInfo["deviceToken"] as? String ?? ""
                
                if myFriendRequestStatus[Usnapshot.key] as? String ?? "" == "1" {
                    // Send Requset - Match founds with both
                    myFriendRequestStatus[Usnapshot.key] = "2"
                    //update values myFriendRequestStatus
                    //update values FriendRequestStatus
                    
                    friendRequestStatus[self.MyUserID!] = "2"
                    self.ref.child("users").child(Usnapshot.key).child("userInfo").child("friendRequestStatus").updateChildValues(friendRequestStatus as [NSObject : AnyObject]) { (error, reference) in
                        if error == nil {
                            print("updateChildValues success myFriendRequestStatus")
                        }else  {
                            CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: (error?.localizedDescription)!)
                        }
                    }
                    self.ref.child("users").child(self.MyUserID!).child("userInfo").child("friendRequestStatus").updateChildValues(myFriendRequestStatus as [NSObject : AnyObject]) { (error, reference) in
                        if error == nil {
                            print("updateChildValues success friendRequestStatus")
                        }else  {
                            CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: (error?.localizedDescription)!)
                        }
                    }
                    
                    //i request to be friend to opp user
                    self.ref.child("users").child(Usnapshot.key).child("userInfo").updateChildValues(["friendRequest":arrLikers]) { (error, reference) in
                        //save as key:1 (like)
                        if error == nil {
                            print("updateChildValues success Match friendRequest")
                        }else  {
                            CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: (error?.localizedDescription)!)
                        }
                    }
                    
                    if token.characters.count > 1 {
                        Alamofire.request(.GET, "http://trainersmatchapp.com/poketrainerapp/api/notifications.php", parameters: ["token": token,"message":"You have a friend request!","type":"friendRequest","data":"friendRequest"])
                            .responseJSON { response in
                                switch response.result {
                                case .Success:
                                    print("Notification sent successfully")
                                case .Failure(let error):
                                    print(error)
                                }
                        }
                    }
                    
                    
                    //You have a friend request!
                    //http://trainersmatchapp.com/poketrainerapp/api/notifications.php?token=25229d664e272484a11dc71519ea6d31959614a689adec3bd4e2f00abe69803c&message=test%20notification&type=test&data=sampledata
                    
                } else {
                    //not found matches - i only like him
                    myFriendRequestStatus[self.MyUserID!] = "1"
                    self.ref.child("users").child(Usnapshot.key).child("userInfo").child("friendRequestStatus").updateChildValues(friendRequestStatus as [NSObject : AnyObject]) { (error, reference) in
                        if error == nil {
                            print("updateChildValues success friendRequestStatus")
                        }else  {
                            CommonUtils.sharedUtils.showAlert(self, title: "Oops!", message: (error?.localizedDescription)!)
                        }
                    }
                }
                
//                if snapshot.exists() {
//                    print(snapshot.childrenCount)
//                    let enumerator = snapshot.children
//                }
                
            })
        }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        let position = swipeView.currentCardIndex
        //        swipeView.insertCardAtIndexRange(position...position, animated: true)
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        //UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
}

//MARK: KolodaViewDataSource
extension SearchViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        return UInt(self.arrUsers.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        //        return UIImageView(image: UIImage(named: "cards_\(index + 1)"))
        
        let cardView = NSBundle.mainBundle().loadNibNamed("CardView", owner: self, options: nil)[0] as? CardView
        cardView?.displayUserProfilePiture(self.arrUsers.objectAtIndex(Int(index)) as! FIRDataSnapshot)
        
        return cardView!
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        
        let overlayView = NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? ExampleOverlayView
        
        return overlayView
    }
}
