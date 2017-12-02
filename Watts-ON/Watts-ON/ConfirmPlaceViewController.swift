//
//  ConfirmPlaceViewController.swift
//  x
//
//  Created by Diego Silva on 11/20/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class ConfirmPlaceViewController: BaseViewController {

    
    // VARIABLES
    // containers
    @IBOutlet weak var confirmOutterCont: UIView!
    @IBOutlet weak var confInnerCont: UIView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var addedContainer: UIView!
    
    // admin confirmation
    @IBOutlet weak var adminImg: UIImageView!
    @IBOutlet weak var adminName: UILabel!
    
    // place info
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeTypeImg: UIImageView!
    
    @IBOutlet weak var confirmRelationship: UIButton!
    
    
    internal var location:Location? = nil
    internal var locObj:PFObject? = nil
    internal var callerViewController:AddPlaceAsGuestViewController? = nil
    internal var confirmed:Bool = false
    
    internal let dbu:DBUtils = DBUtils()
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    // UI
    /*
        Pop up dialog
    */
    func showInView(_ aView: UIView!, animated: Bool, location:Location, locObj:PFObject, admin:User){
        aView.addSubview(self.view)
        
        if animated{
            
            print("\ninitializing confirmation dialog ...")
            
            // customize UI
            self.location = location
            self.locObj   = locObj
            self.customizeUI(admin)
            
            // show it
            self.showAnimate()
        }
    }
    
    func customizeUI(_ admin:User){
        
        // customize containers
        self.feu.roundCorners(self.confInnerCont, color: self.feu.LIGHT_WHITE)
        self.feu.roundCorners(self.confirmOutterCont, color: self.feu.MEDIUM_GREY)
        
        // admin name
        var admName = ""
        if(admin.getUserName() != self.dbu.STD_UNDEF_STRING){
            admName = admin.getUserName()!
        }else{
            print("problems getting admin name")
        }
        self.adminName.text = admName
        
        // location name
        self.placeName.text = self.location!.getLocationName()
        
        // insert the location type image (Business or Residencial)
        if let locType:String = self.location!.getLocationType(){
            
            if(locType == self.feu.LOCATION_TYPES[0]){
                self.placeTypeImg.image = UIImage(named:self.feu.IMAGE_LOC_TYPE_RESIDENCIAL)
                
            }else if(locType == self.feu.LOCATION_TYPES[1]){
                self.placeTypeImg.image = UIImage(named:self.feu.IMAGE_LOC_TYPE_BUSINESS)
            }
        }else{
            print("problems getting location type")
        }
        
        // get the admin image
        if let picture:UIImage = admin.getUserPicUIImage(){
            self.adminImg.image = picture
        }else{
            self.adminImg.image = UIImage(named: "user.png")
        }
        self.feu.roundItBordless(self.adminImg)
        
        // initialize the fadeOut animation
        self.feu.fadeOut(self.infoContainer, speed: 0.1)
        self.feu.fadeOut(self.addedContainer, speed: 0.1)
    }
    
    func showAnimate(){
        self.view.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        )
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion:{
            (value:Bool) in
            
            self.feu.fadeIn(self.infoContainer, speed: 0.8)
        });
    }
    
    
    func removeAnimate(){
        
        UIView.animate(withDuration: 0.5, animations: {
            
            // perform action on a separeted thread
            self.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.view.alpha = 0;
            
            self.view.frame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y + 600,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height
            )
        }, completion:{
            (finished : Bool)  in
                
            // prevent the system of showing this alert again on this session
            self.view.removeFromSuperview()
        })
    }

    
    
    
    /*
        User cancelled the operation and closed the confirmation dialog
    */
    @IBAction func closeDialog(_ sender: AnyObject) {
        self.removeAnimate()
    }
    
    
    
    /*
        User has confirmed the location, starts backend operation
    */
    @IBAction func confirmLocation(_ sender: AnyObject) {
        print("user has confirmed location")
        
        if(!self.confirmed){
            
            self.addUserToLocationAsGuest()
        }else{
            print("reinitializing global variable and sending user back home ...")
            
            // unwind segue, and return user back to the home screen
            if let caller:AddPlaceAsGuestViewController = self.callerViewController{
                
                caller.sendUserHomeAfterJoinOp()
            }else{
                print("problems while getting caller object, cannot close dialog")
            }
        }
    }
    
    
    
    
    // LOGIC
    /*
        Add user to location as guest
    */
    internal func addUserToLocationAsGuest(){
        print("\ntrying to add user to location as guest")
        
        if let location:PFObject = self.locObj{
            
            PFCloud.callFunction(inBackground: "createUserLocationRelationship", withParameters: [
                "locationId":location.objectId!,
                "userId"    :PFUser.current()!.objectId!
            ]) {
                (result, error) in
                    
                if (error == nil){
                    print("location \(location)")
                    
                    if let result:Int = result as? Int {
                        print("user was added to the location)")
                        
                        if(result == 0){
                            
                            // try to load added location goal
                            self.getLocationOpennedGoal(location)
                            
                        }else{
                            self.infoWindow("Não foi possível adicionar o usuário como visitante do local selecionado devido a uma falha do sistema", title: "Erro operacional", vc: self)
                        }
                    }else{
                        print("problems converting results into array of locations.")
                        self.finalizeLocationJoinProcess(false, locationId: "", goal: nil)
                    }
                }else{
                    print("\nerror: \(error)")
                }
            }
            
        }else{
            print("problem gettin user location out of selected location obj")
            self.infoWindow("Não foi possível adicionar o usuário como visitante do local selecionado devido a uma falha do sistema", title: "Erro operacional", vc: self)
        }
    }
    
    
    
    /*
        Get added location goal
    */
    internal func getLocationOpennedGoal(_ location:PFObject){
        print("\ntrying to get openned goal for location \(location.objectId) ...")
        
        PFCloud.callFunction(inBackground: "getLocationOpennedGoalById", withParameters: [
            "locationId":location.objectId!
        ]) {
            (locGoalRel, error) in
                
            if (error == nil){
                
                print("location goal relationship \(locGoalRel)")
                
                if let goalLocRelObj:PFObject = locGoalRel as? PFObject{
                    
                    if let goalPointer:PFObject = goalLocRelObj[self.dbu.DBH_REL_USER_GOALS_GOAL] as? PFObject{
                        
                        // get the actual goal
                        self.getGoalById(goalPointer.objectId!)
                        
                    }else{
                        print("could not get goal id")
                        self.finalizeLocationJoinProcess(false, locationId:"", goal:nil)
                    }
                }else{
                    print("could not convert goal to PFObject")
                    self.finalizeLocationJoinProcess(false, locationId:"", goal:nil)
                }
            }else{
                print("\nerror: \(error)")
                self.infoWindow("Não foi possível adicionar o usuário como visitante do local selecionado devido a uma falha do sistema", title: "Erro operacional", vc: self)
                self.finalizeLocationJoinProcess(false, locationId:"", goal:nil)
            }
        }
    }
    
    
    
    /*
        Get goal by its id
    */
    internal func getGoalById(_ id:String){
        
        print("\ngetting goal object ...")
        
        PFCloud.callFunction(inBackground: "getGoalById", withParameters: [
            "goalId":id
        ]) {
            (goal, error) in
                
            if (error == nil){
                print("found goal \(goal) for added location \(self.location), loading it ...")
                    
                if let locGoal:PFObject = goal as? PFObject {
                        
                    // unwrap PFObject into a model object
                    let locationGoal:Goal = Goal(goal:locGoal)
                        
                    if let locId:String = self.location?.getObId(){
                            
                        // insert the new location and its dependencies into the global variables
                        self.finalizeLocationJoinProcess(true, locationId:locId, goal:locationGoal)
                        
                    }else{
                        print("problem getting location id as String")
                    }
                }else{
                    print("problems converting results into array of locations.")
                }
            }else{
                print("\nerror: \(error)")
                self.infoWindow("Não foi possível adicionar o usuário como visitante do local selecionado devido a uma falha do sistema", title: "Erro operacional", vc: self)
            }
        }
    }
    
    
    /*
        Finalize locatino join process
    */
    internal func finalizeLocationJoinProcess(_ withGoal:Bool, locationId:String, goal:Goal?){
        
        // update the status of the global controller variables
        DBHelpers.reinitializeGlobalVariables(self.locObj!)
        
        // insert the openned goal into the list of goals
        if(withGoal){
            if let locationGoal:Goal = goal{
                
                // get added location goal
                DBHelpers.locationGoals[locationId] = locationGoal
                
            }else{
                print("problems getting location goal")
            }
        }
        
        // change the view dialog
        self.feu.fadeOut(self.infoContainer, speed: 0.3)
        self.feu.fadeIn(self.addedContainer, speed: 0.7)
        
        self.confirmRelationship.setTitle("Voltar para a Home", for: UIControlState())
        
        // allow the user to go to the home screen
        self.confirmed = true
    }
    
    
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
