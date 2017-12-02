//
//  PlaceDetailsViewController.swift
//  x
//
//  Created by Diego Silva on 11/13/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class PlaceDetailsViewController: BaseViewController {

    
    
    // VARIABLES
    // Containers
    @IBOutlet weak var locationTypeImgContainer: UIView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var adminImgContainer: UIImageView!
    
    // Regular outlets
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var visitorInfoBtn: UIButton!
    @IBOutlet weak var qrcodeBtn: UIButton!
    @IBOutlet weak var qrcodeBtnRedu: UIButton!
    
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var adminName: UILabel!
    @IBOutlet weak var locationType: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var deviceInfo: UILabel!
    @IBOutlet weak var locTypeImg: UIImageView!
    
    internal var deleteAsAdmin:Bool = false
    internal var location:Location  = Location()
    internal var key:String = ""
    
    
    // CONSTANTS
    internal let dbu:DBUtils   = DBUtils()
    internal let dbh:DBHelpers = DBHelpers()
    internal let selector:Selector = #selector(PlaceDetailsViewController.goHome)
    


    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        
        // UI
        //self.setScroller()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.key = ""
        
        if let location = DBHelpers.currentLocation{
            
            self.location = location
            
            // UI
            //assign button to navigationbar
            self.navigationItem.leftBarButtonItem = self.feu.getHomeNavbarBtn(self.selector, parentVC: self)
            self.setUI(self.location)
            
            // Data
            self.loadUIWithCurrentLocationData()
        }else{
            print("problem unwrapping current location")
        }
        
        self.feu.roundIt(self.adminImgContainer, color: self.feu.SUPER_LIGHT_WHITE)
    }



    // UI
    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
        self.scroller.isUserInteractionEnabled = true
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = self.contentContainer.frame.size.height
        self.scroller.contentSize.width = self.contentContainer.frame.size.width
    }
    
    
    
    /*
        Go to the QRCode page with an image generated based on the sharedKey of a location
    */
    @IBAction func generateQRCode(_ sender: AnyObject) {
        print("\ngenerating qrcode ...")
        
        self.performSegue(withIdentifier: self.feu.SEGUE_GENERATE_QRCODE, sender: nil)
    }
    
    
    
    
    /*
        Change the UI functionalities and appearence depending on the user location relationship
        if the user is de location admin, allow editing and deletion, otherwise doesn't
    */
    internal func setUI(_ location:Location){
        print("setting UI according to the user location relationship ...")
        
        if let locAdm:PFUser = location.getLocationAdmin(){
            if(locAdm.objectId == PFUser.current()?.objectId){
                print("user is location admin, allowing operations ...")
                
                self.visitorInfoBtn.isHidden  = true
                self.visitorInfoBtn.isEnabled = false
                
                self.deleteBtn.isHidden = false
                self.deleteBtn.isEnabled = true
                
                self.updateBtn.isHidden = false
                self.updateBtn.isEnabled = true
            }else{
                print("current user isn't location admin")
                
                self.visitorInfoBtn.isHidden  = false
                self.visitorInfoBtn.isEnabled = true
                
                self.deleteBtn.isHidden = false
                self.deleteBtn.isEnabled = true
                
                self.updateBtn.isHidden = true
                self.updateBtn.isEnabled = false
            }
        }else{
            print("problem getting location admin")
        }
    }
    
    
    /*
        Load UI with data of the current location
    */
    internal func loadUIWithCurrentLocationData(){
        print("\nloading UI with current location data ...")
        
        // location name
        if let locName:String = self.location.getLocationName(){
            self.locationName.text = locName
        }else{
            self.locationName.text = "Nome do local"
        }
        
        // location type
        if let locType:String = self.location.getLocationType(){
            if(locType != self.dbu.STD_UNDEF_STRING){
                self.locationType.text = locType
                
                if(locType == self.feu.LOCATION_TYPES[0]){
                    self.locTypeImg.image = UIImage(named: self.feu.IMAGE_LOC_TYPE_RESIDENCIAL)
                    self.feu.fadeIn(self.locTypeImg, speed: 0.7)
                }else if(locType == self.feu.LOCATION_TYPES[1]){
                    self.locTypeImg.image = UIImage(named: self.feu.IMAGE_LOC_TYPE_BUSINESS)
                    self.feu.fadeIn(self.locTypeImg, speed: 0.7)
                }
            }else{
                self.locationType.text = "O tipo do local não foi selecionado"
            }
        }else{
            self.locationType.text = "Tipo do local"
        }
        
        // location adm
        print("location admin \(self.location.getLocationAdmin())")
        
        if let locAdmin:PFUser = self.location.getLocationAdmin(){
            
            // create an object that is a lit bit easier to manage
            let locAdm:User = User(user: locAdmin)
            
            // get admin name
            if(locAdm.getUserName() != self.dbu.STD_UNDEF_STRING){
                self.adminName.text = locAdm.getUserName()
            }else{
                self.adminName.text = "Nome do administrador"
            }
                
            // get admin picture
            if let picture = locAdm.getUserPicUIImage(){
                self.adminImgContainer.image = picture
            }else{
                if let picFile = locAdm.getUserPicture(){
                    picFile.getDataInBackground(block: {
                        (imageData: Data?, error: NSError?) -> Void in
                        
                        if (error == nil) {
                            let image = UIImage(data:imageData!)
                            self.adminImgContainer.image = image
                        }
                    })
                }else{
                    print("problem getting user picture file")
                    self.adminImgContainer.image = UIImage(named:self.feu.IMAGE_USER_PLACEHOLDER)
                }
            }
            self.feu.fadeIn(self.adminImgContainer, speed: 1.0)
            
            // show delete btn
            self.deleteBtn.isEnabled = true
            self.feu.fadeIn(self.deleteBtn, speed: 0.5)
            
            // if current user is the location admin
            if(DBHelpers.isUserLocationAdmin){
                
                // set shared key
                if let k = self.location.getLocationSharedId(){
                    self.key = k
                }else{
                    print("could not get shared key")
                }
                
                // show location shared key
                self.feu.fadeIn(self.qrcodeBtn, speed: 1.0)
                self.feu.fadeIn(self.qrcodeBtnRedu, speed: 1.0)
               
                
                // show update btn
                self.updateBtn.isEnabled = true
                self.feu.fadeIn(self.updateBtn, speed: 0.5)
                
                // hide visitor user's info btn
                self.visitorInfoBtn.isEnabled = false
                self.feu.fadeOut(self.visitorInfoBtn, speed: 0.5)
                
                self.deleteAsAdmin = true
            }else{
                // show visitor user's info btn
                self.visitorInfoBtn.isEnabled = true
                self.feu.fadeIn(self.visitorInfoBtn, speed: 0.5)
                
                self.updateBtn.isEnabled = false
                self.feu.fadeOut(self.updateBtn, speed: 0.5)
                
                self.deleteAsAdmin = false
            }
        }
        
        // location address
        if let locAddress:String = self.location.getLocationAddress(){
            if(locAddress != self.dbu.STD_UNDEF_STRING){
                self.locationAddress.text = locAddress
            }else{
                self.locationAddress.text = "Endereço não definido"
            }
        }else{
            self.locationAddress.text = "Endereço"
        }
        
        // location monitoring device
        if let locDev:Device = self.location.getLocationDevice(){
            if let devInfo:String = locDev.getDeviceInfo(){
                if(devInfo != self.dbu.STD_UNDEF_STRING){
                    self.deviceInfo.text = devInfo
                }else{
                    self.deviceInfo.text = "Dispositivo de monitoramento sem nome"
                }
            }else{
                self.deviceInfo.text = "Descrição do dispositivo"
            }
        }else{
            self.deviceInfo.text = "Este local não está usando um dipositivo"
        }
            
        // location creation date
        PFCloud.callFunction(inBackground: "getLocationCreationDate", withParameters: [
            "locationId": location.getObId()
        ]) {
            (date, error) in
                    
            if (error == nil){
                if let date:Date = date as? Date{
                    let dateLabel:String = "Criado em " + date.formattedWith(self.feu.DATE_FORMAT)
                        
                    self.createdAt.text = dateLabel
                }else{
                    print("failed to get location creation date")
                }
            }
        }
    }
    
    
    
    /*
        Explain what the user can do on this page
    */
    @IBAction func showPageInfoForVisitor(_ sender: AnyObject) {
        self.infoWindow("Exemplo de ações que você, como visitante, pode realizar em um local: \n\nDeletá-lo de sua lista de locais\n\nRealizar leituras, caso ele não possua um dispositivo de monitoramento\n\nVisualizar sua lista de moradores e etc.", title: "Informações", vc: self)
    }
    
    
    
    
    /*
        Try to delete the current place
    */
    @IBAction func deletePlace(_ sender: AnyObject) {
        print("\ntrying to delete the selected place ...")
        
        let title = "Atenção"
        let msg = "Deseja realmente apagar este local?"
        
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            
            self.deleteCurrentLocation()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            
            print("User cancelled operation.")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    // LOGIC
    /*
        Delete the current location from the app backend and from the global controller variables,
        after the operation is complete send the user back to the home screen
    */
    internal func deleteCurrentLocation(){
        print("\ndeleting current location trace locally and on the app backend ...")
        
        if let location = DBHelpers.currentLocation{
            
            // delete user location relationship
            if(self.deleteAsAdmin){
                
                // deletes Location trace on the app backend
                self.deleteLocationTrace()
            }else{
                
                // deletes only the User_Location relationship
                self.dbh.deleteUserLocationRels(location)
            }
            
            // deletes location trace from system variables
            DBHelpers.userLocations.removeValue(forKey: DBHelpers.currentLocatinIdx)
            
            if let datafileManager = DBHelpers.locationDataObj[location.getObId()]{
                datafileManager?.deleteDeviceHistoryFile()
            }else{
                print("problem getting location datafile manager")
            }
            
            DBHelpers.locationDataObj.removeValue(forKey: location.getObId())
            
            DBHelpers.locationGoals.removeValue(forKey: location.getObId())
            
            DBHelpers.alertMsgController.removeValue(forKey: location.getObId())
            
            // if the user deleted his/her only location, kick the user out of the system
            if(DBHelpers.userLocations.count == 0){
                print("refreshing system to start point ...")
                
                DBHelpers.currentLocation = nil
                DBHelpers.isUserLocationAdmin = false
                DBHelpers.currentLocationData = nil
                DBHelpers.currentDevice = nil
                DBHelpers.currentGoal = nil
                DBHelpers.currentLocatinIdx = -1
                
                DBHelpers.lockedSystem = true
                
            }else{
                self.selectAnotherLocation()
            }
            
            // redirect user to home screen and reload it
            self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_LOC_DEL, sender: nil)
        }else{
            print("problems getting location out of DBHelpers.currentLocation()")
        }
    }
    
    
    /*
        Delete location trace on the app backend
    */
    internal func deleteLocationTrace(){
        self.dbh.deleteUserLocationRels(location)
        self.dbh.deleteGoalLocationRel(location)
        self.dbh.deleteReportLocationRel(location)
        self.dbh.deleteDeviceLocationRel(location)
        self.dbh.deleteBeaconLocationRel(location)
        self.dbh.deleteUserLocation(location)
    }
    
    
    
    /*
        Select another available location from the user's location list, and load the global 
        controller variables and dependencies with its data
    */
    internal func selectAnotherLocation(){
        print("selecting another available location as current location ...")
    
        // get the position of the remaining available locations
        let availableLocationKeys = Array(DBHelpers.userLocations.keys)
        
        if(availableLocationKeys.count > 0){
            
            if let selLoc:Location = DBHelpers.userLocations[availableLocationKeys[0]]{
                
                // update the current location
                DBHelpers.currentLocation     = selLoc
                
                // set the admin status of the current user for the current location
                DBHelpers.isUserLocationAdmin = true
                
                // get selected location datafile manager
                if let datafileManager:Readings = DBHelpers.locationDataObj[selLoc.getObId()]!{
                    DBHelpers.currentLocationData = datafileManager
                }else{
                    print("problem getting the datafileManger object of the selected location")
                }
                
                // get selected location device, if there is one
                if let device:Device = selLoc.getLocationDevice(){
                    DBHelpers.currentDevice = device
                }else{
                    print("the selected location has no device")
                }
                
                // get selected location goal, if there is one
                if let locationGoals = DBHelpers.locationGoals as? [String:Goal]{
                    if let goal:Goal = locationGoals[selLoc.getObId()]{
                        DBHelpers.currentGoal = goal
                    }else{
                        print("the selected location has no goal")
                    }
                }else{
                    print("list of goals is empty")
                }
                
                // update the available location index
                DBHelpers.currentLocatinIdx = availableLocationKeys[0]
                
            }else{
                print("problems getting selected location")
            }
        }else{
            print("there is no remaining available location")
            self.goHome()
        }
    }
    
    
    
    // NAVIGATION
    /*
        Send the user back to the home screen by dismissing the current page from the pages stack
    */
    internal func goHome(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    /*
        Redirect the user to the updatePlace screen
    */
    @IBAction func goToUpdatePlace(_ sender: AnyObject) {
        print("\ngoing to the new place screen on the update mode ...")
        self.performSegue(withIdentifier: self.feu.SEGUE_LOCATION_UPDATE, sender: nil)
    }
    
    
    /*
        Get updated information back from the update screen
    */
    @IBAction func unwindWithUpdatedLocation(_ segue:UIStoryboardSegue) {
        if let upsertLocationVC:UpsertPlaceViewController = segue.source as? UpsertPlaceViewController{
            
            if let location:Location = upsertLocationVC.location{
                self.location = location
                self.loadUIWithCurrentLocationData()
            }else{
                print("problem getting updated location data from the UpserPlace page")
            }
        }
    }
    
    
    
    /*
        return from a qrcode generation operation
    */
    @IBAction func unwindAfterGenerateQRCode(_ segue:UIStoryboardSegue) {
        
        if let _:QRCodeGenerateViewController = segue.source as? QRCodeGenerateViewController{
            
            print("came back from QRCode generation.")
        }
    }
    
    
    
    /*
        Prepare data to next screen
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == self.feu.SEGUE_LOCATION_UPDATE){
            let destineVC = (segue.destination as! UpsertPlaceViewController)
            destineVC.source   = "details"
            destineVC.location = DBHelpers.currentLocation
            
        }else if(segue.identifier == self.feu.SEGUE_GENERATE_QRCODE){
            
            let destineVC = (segue.destination as! QRCodeGenerateViewController)
            
            if let _ = self.qrcodeBtn.titleLabel{
                destineVC.sharedKey = self.key
            }else{
                print("could not get btn label")
            }
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
