//
//  NewPlaceViewController.swift
//  x
//
//  Created by Diego Silva on 11/14/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class UpsertPlaceViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    
    // VARIABLES
    // Containers
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    // Regular outlets
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var activateBeaconsBtn: UIButton!
    @IBOutlet weak var businessSwitch: UISwitch!
    @IBOutlet weak var residencialSwitch: UISwitch!
    @IBOutlet weak var availableDevices: UIPickerView!
    
    // Managed variables, variables the page creates or updates along with regular outlets
    internal var locationType:String         = ""
    internal var location:Location?          = Location()
    internal var configuredBeacon:Beacon?    = nil
    internal var selectedDeviceInfo:String   = ""
    internal var availableDevs:Array<String> = Array<String>()
    internal var checkedDevices:Int          = 0
    
    // Page mode controllers
    internal var isCreating:Bool          = false
    internal var hasDevice:Bool           = false
    internal var justCreated:Bool         = false
    internal var source                   = "home"
    
    
    // COSNTANTS
    internal let SOURCE_HOME              = "home"
    internal let SOURCE_DETAILS           = "details"
    internal let selector:Selector = #selector(UpsertPlaceViewController.back)
    
    // Helpers
    internal let dbh:DBHelpers = DBHelpers()
    
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        // UI
        // self.setScroller()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\nNEW LOCATION SCREEN")
        
        
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(
            self.selector, parentVC: self, labelText: "<"
        )
        
        // if the user is coming from the details page or just created a new goal, switch the screen to the update mode
        if((source == self.SOURCE_DETAILS) || (self.justCreated)){
            self.switchToUpdateMode()
        }else{
            self.switchToCreateMode()
        }
        
        // get other available devices on the backend to provide a complete list
        self.getAllAvailableDevices()
        
        // keyboard movement distance
        self.kbHeight = 0
        
        // text inputs
        self.locationName.delegate = self
        self.address.delegate = self
        
        // devices picker
        self.availableDevices.dataSource = self
        self.availableDevices.delegate = self
    }

    internal func switchToUpdateMode(){
        print("\nscreen mode: update")
        self.title = "Atualizar Local"
        
        self.isCreating = false
        
        // cheks if the current location has a device attached to it
        if(source == self.SOURCE_DETAILS){
            if let currentDevice:Device = DBHelpers.currentDevice{
                print("current location has a device, id: \(currentDevice.getObId())")
                self.hasDevice = true
            }else{
                print("current location doesn't have a device")
                self.hasDevice = false
            }
        }
        
        self.activateBeaconsBtn.isEnabled = true
        
        // get data from the current location and insert into the UI
        self.loadLocationToUIForUpdates()
    }
    
    internal func switchToCreateMode(){
        print("\nscreen mode: create")
        self.title = "Novo Local"
        
        self.isCreating = true
        self.hasDevice = false
        self.activateBeaconsBtn.isEnabled = false
        self.setLocationTypeResidencial(self)
    }
    
    
    
    // UI
    /*
        Get the data of the currently selected location and load it into the UI for updates
    */
    internal func loadLocationToUIForUpdates(){
        print("\nloading location info for updates ...")
        
        self.locationName.text = self.location?.getLocationName()
        self.address.text = self.location?.getLocationAddress()
        
        if(self.location?.getLocationType() == self.feu.LOCATION_TYPES[0]){
            self.setLocationTypeResidencial(self)
        }else{
            self.setLocationTypeBusiness(self)
        }
        
        if let locDev = self.location?.getLocationDevice(){
            if(self.availableDevs.index(of: locDev.getDeviceInfo()) == nil){
                self.availableDevs.append(locDev.getDeviceInfo())
            }
        }
    }
    
    
    /*
        Reset the UI elements after the creation of a new location
    */
    internal func resetUI(){
        self.locationName.text = ""
        self.address.text = ""
        self.activateBeaconsBtn.isEnabled = false
    }
    
    
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
        Picker view delegate methods
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(self.availableDevs.count > 0){
            return self.availableDevs.count
        }else{
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var msg:String = "Nenhum dispositivo disponível"
        msg = self.getDeviceLabel(row, msg: msg)
        
        let formatedDeviceLabel = NSAttributedString(
            string: msg,
            attributes: [
                NSFontAttributeName:UIFont(name: self.feu.SYSTEM_FONT, size: 9.0)!,
                NSForegroundColorAttributeName:self.feu.DARK_WHITE
            ]
        )
        
        return formatedDeviceLabel
    }
    
    internal func getDeviceLabel(_ row:Int, msg:String) -> String{
        if(self.availableDevs.count > 0){
            return self.availableDevs[row]
        }else{
            return msg
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.availableDevs.count > 0){
            self.selectedDeviceInfo = self.availableDevs[row]
        }
    }

    
    /*
        Define the location type
    */
    @IBAction func setLocationTypeResidencial(_ sender: AnyObject) {
        self.businessSwitch.setOn(false, animated: true)
        self.residencialSwitch.setOn(true, animated:true)
        self.locationType = self.feu.LOCATION_TYPES[0] // residencial
    }
    
    @IBAction func setLocationTypeBusiness(_ sender: AnyObject) {
        self.businessSwitch.setOn(true, animated: true)
        self.residencialSwitch.setOn(false, animated:true)
        self.locationType = self.feu.LOCATION_TYPES[1] // business
    }
    
    
    /*
        Try to create a new place with information currently on the screen
    */
    @IBAction func saveLocation(_ sender: AnyObject) {
        print("\ntrying to save data to a new or a existing place ...")
        self.validateInputs()
    }
    
    
    
    /*
        Validate de user input and return true if everything is ok or false, otherwise
    */
    internal func validateInputs(){
        print("validating data ...")
        
        // validate location name (created to mark where any further validation msut be done)
        if let locationName = self.locationName.text{
            
            if(isCreating){
                
                // check if the location name is valid
                PFCloud.callFunction(inBackground: "isLocationNameValid", withParameters: [
                    "locationName": locationName,
                    "userId"      : PFUser.current()!.objectId!
                ]) {
                    (answer, error) in
                        
                    if (error == nil){
                        if let result:Bool = answer as? Bool{
                            if(result){
                                    
                                // name is valid, continue validation process
                                // validate location address (created to mark where any further validation msut be done)
                                if let _ = self.address.text{
                                        
                                    // validate location type
                                    for i in 0...(self.feu.LOCATION_TYPES.count - 1){
                                        
                                        if(self.locationType == self.feu.LOCATION_TYPES[i]){
                                            
                                            // data is valid, start saving process
                                            self.save()
                                        }
                                    }
                                }else{
                                    self.infoWindow("Por favor insira um endereço válido", title: "Endereço inválido", vc: self)
                                }
                            }else{
                                print("location name is invalid.")
                                self.infoWindow("Você já possui um local com o nome '\(locationName)', escolha outro nome.", title: "Nome inválido", vc: self)
                            }
                        }else{
                            print("backend error.")
                        }
                    }else{
                        print("\nerror: \(error)")
                    }
                }
            }else{
                
                // validate location address (created to mark where any further validation msut be done)
                if let _ = self.address.text{
                    
                    // validate location type
                    for i in 0...(self.feu.LOCATION_TYPES.count - 1){
                        if(self.locationType == self.feu.LOCATION_TYPES[i]){
                            // data is valid, start saving process
                            self.save()
                        }
                    }
                    
                }else{
                    self.infoWindow("Por favor insira um endereço válido", title: "Endereço inválido", vc: self)
                }
            }
            
        }else{
            self.infoWindow("Por favor insira um nome válido para o local", title: "Nome inválido", vc: self)
        }
    }
    
    
    
    // DIALOGS
    /*
        Dialog to ask the user to continue without a device
    */
    override internal func infoWindowWithCancel(_ txt:String, title:String, vc:UIViewController) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction) in
            
            print("user has confirmed new location without a device")
            self.location?.setLocationAdmin(PFUser.current())
            self.location?.setLocationName(self.locationName.text)
            self.location?.setLocationAddress(self.address.text)
            self.location?.setLocationType(self.locationType)
           
            // create associations on the backend
            self.upsertLocation("")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            print("user cancelled operation without device")
        }))
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }

    
    /*
        Show Successful place creation operation dialog
    */
    internal func showUpsertedLocationDialog(_ msg:String){
        
        // refresh the UI
        self.resetUI()
        
        // show a dialog to confirm the successful o operation
        let refreshAlert = UIAlertController(title: "Operação concluída", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction) in
            
            if(self.source == self.SOURCE_DETAILS){
                self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_UPT_LOC, sender: nil)
            }else{
                // if this is the first location of the user, unlock the system
                if(DBHelpers.lockedSystem){
                    DBHelpers.lockedSystem = false
                }
                
                self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_NEW_LOC, sender: nil)
            }
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    /*
        Show the add beacons dialog to let the user know that he/she can configure beacons to track
        who is in the created place
    */
    internal func showBeaconsDialog(){
        //self.activateBeaconsBtn.enabled = true
        print("\nshowing configure beacon dialog ...")
    }
    
    
    
    
    // LOGIC
    /*
        Once data from the UI is validated starts the upserting process. I.E. deciding whether the 
        user is creating or updating a location, and if the location is going to have a device.
    */
    internal func save(){
        print("\ntrying location upsert process ...")
        
        // call the upsert method with a device
        if(self.selectedDeviceInfo != ""){
            
            print("upserting location with device ...")
            self.hasDevice = true
            
            self.location?.setLocationAdmin(PFUser.current())
            self.location?.setLocationName(self.locationName.text)
            self.location?.setLocationAddress(self.address.text)
            self.location?.setLocationType(self.locationType)
                
            // create or update place with the specified data
            if let devId = self.getIdOfSelectedDevice(){
                self.upsertLocation(devId)
            }
            
        // call the upsert method without a device
        }else{
            
            self.hasDevice = false
            
            if(isCreating){
                
                print("creating location without a device ...")
                self.infoWindowWithCancel(
                    "Confirma a criação do local?",
                    title: "Atenção",
                    vc: self
                )
            }else{
                
                print("updating selected location without a device ...")
                self.location?.setLocationAdmin(PFUser.current())
                self.location?.setLocationName(self.locationName.text)
                self.location?.setLocationAddress(self.address.text)
                self.location?.setLocationType(self.locationType)
                    
                self.upsertLocation("")
            }
        }
    }
    
    
    
    /*
        Get the id of a device by serching a device that matches its info
    */
    internal func getIdOfSelectedDevice() -> String?{
        print("\ngetting user device's id by the device info ...")
        
        if(DBHelpers.userDevices.count > 0){
            for i in 0...(DBHelpers.userDevices.count - 1){
                if let userDev = DBHelpers.userDevices[i]{
                    if let devInfo = userDev?.getDeviceInfo(){
                        if(devInfo == self.selectedDeviceInfo){
                            return userDev?.getObId()
                        }
                    }else{
                        print("problem getting device id")
                    }
                }else{
                    print("problem getting user device")
                }
            }
        }else{
            print("user has no device")
        }
        
        return nil
    }
    
    
    /*
        Tries to create or update a location, with or without a device. It tries to get the selected
        device from the backend and start an upsert with it. Otherwise do the upsert wihtout it.
    */
    fileprivate func upsertLocation(_ deviceId:String){
        print("\ntrying to get the selected device if there is one ...")
        
        DBHelpers.isUserLocationAdmin = true
        
        // upsert with or without a device
        if(deviceId != ""){
            
            // upsert location with device
            let query:PFQuery = Device.query()!
            
            query.getObjectInBackground(withId: deviceId){
                (deviceObj, error) -> Void in
                
                if(error == nil){
                    if let device:PFObject = deviceObj{
                        
                        // update location device object
                        self.location?.setLocationDevice(
                            Device(device: device)
                        )
                        
                        // create place with a pointer to the selected device
                        if(self.isCreating){
                            if let loc:PFObject = self.location!.getNewLocationObject(true){
                                self.saveLocationObject(loc, device: device)
                            }else{
                                print("problem getting PFObject out of getNewLocationObject(true)")
                            }
                            
                        // update the selected place with the selected device information
                        }else{
                            self.getLocationPFObjectForUpdate(device)
                        }
                    }else{
                        print("problem converting deviceObj into PFObject")
                    }
                }else{
                    print("problem getting device object by its id")
                }
            }
            
        // upsert location without a device
        }else{
            
            // create a new place with the inserted information
            if(self.isCreating){
                
                if let loc:PFObject = self.location!.getNewLocationObject(false){
                    
                    self.saveLocationObject(loc, device: nil)
                }else{
                    print("problem getting PFObject out of getNewLocationObject(true)")
                }
                
            // update the current place without a device object
            }else{
                self.getLocationPFObjectForUpdate(nil)
            }
        }
    }
    
    
    /*
        Get the selected location PFObject from the backend to the update method
    */
    internal func getLocationPFObjectForUpdate(_ device:PFObject?){
        print("\ntrying to get location PFObject for update ...")
        
        let query:PFQuery = Location.query()!
        query.getObjectInBackground(withId: self.location!.getObId()){
            (location, error) -> Void in
            
            if(error == nil){
                if let oldLocation:PFObject = location{
                    if let updatedLocation = self.location{
                        updatedLocation.getUpdatedLocationObject(oldLocation)
                        
                        // check if the user is updating with or without a device
                        if let dev = device{
                            print("updating location object with a device ...")
                            self.saveLocationObject(
                                oldLocation,
                                device: dev
                            )
                        }else{
                            print("updating location object without a device ...")
                            self.saveLocationObject(
                                oldLocation,
                                device: nil
                            )
                        }
                    }else{
                        print("problems getting location object out of self.location")
                    }
                }else{
                    print("problem converting object from backend into PFObject")
                }
            }else{
                print("error getting location PFObject from app backend")
            }
        }
    }
    
    
    /*
        Save new place on the app backend
    */
    internal func saveLocationObject(_ loc:PFObject, device:PFObject?){
        print("\nsaving location asynchronously on the app backend ... \(loc)")
        
        // save Location object asynchronously
        loc.saveInBackground{
            (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                var msg = ""
                
                // create location
                if(self.isCreating){
                    
                    DBHelpers.reinitializeGlobalVariables(loc)
                    
                    // create with or without a device
                    if let dev = device{
                        msg = "Local criado com sucesso, você agora é o administrador do local '\(self.locationName.text!)'. \n\nEle será monitorado pelo dispositivo '\(self.selectedDeviceInfo)'."
                        
                        self.createUserLocationRelationship(loc, device:dev, msg:msg)
                    }else{
                        msg = "Local criado com sucesso, você agora é o administrador do local '\(self.locationName.text!)'"
                        
                        self.createUserLocationRelationship(loc, device:nil, msg:msg)
                    }
                    
                // update location
                }else{
                    msg = "Local atualizado com sucesso."
                    
                    self.updateGlobalVaribles(loc)
                    self.showUpsertedLocationDialog(msg)
                    
                    self.location = Location(location:loc)
                    if let dev = device{
                        self.location?.setLocationDevice(Device(device:dev))
                    }else{
                        
                    }
                    
                    // reload the page
                    self.viewDidLoad()
                }
                
            } else {
                print("error saving location object \(error)")
                self.infoWindow("Houve um erro ao salvar o novo ambiente", title: "Erro operacional", vc: self)
            }
        }
        
    }
    
    
    /*
        Create a new relationship between the current user and the created location
    */
    internal func createUserLocationRelationship(_ location:PFObject, device:PFObject?, msg:String){
        print("\ntrying to create User_Location relationship ...")
        
        if let locationId = location.objectId{
            if let userId = PFUser.current()?.objectId{
                
                // perform operations on the app backend
                PFCloud.callFunction(inBackground: "createUserLocationRelationship", withParameters: [
                    "locationId": locationId,
                    "userId"    :userId
                ]) {
                    (answer, error) in
                        
                    if (error == nil){
                        if let result:Int = answer as? Int{
                            if(result == 0){
                                print("created relationship successfuly.")
                                
                                self.isCreating = false
                                self.justCreated = true
                                self.location = Location(location:location)
                                if let dev = device{
                                    self.location?.setLocationDevice(Device(device:dev))
                                }
                                
                                self.showUpsertedLocationDialog(msg)
                            }else{
                                print("failed to create relationship.")
                            }
                        }else{
                            print("problems converting cloud query result")
                        }
                    }else{
                        print("\nerror: \(error)")
                    }
                }
                
            }else{
                print("problem getting user id")
            }
        }else{
            print("problems getting location id")
        }
    }
    
    
    /*
        Get a list of all the 'available' devices I.E. Devices that are not allocated to any
        location and have a relationship on the User_Device table.
    */
    internal func getAllAvailableDevices(){
        
        // if the user has at least one device
        if(DBHelpers.userDevices.count > 0){
            
            // get each device object
            for i in 0...(DBHelpers.userDevices.count - 1){
                
                // check if the selected device is not allocated to any other location
                if let dev:Device = DBHelpers.userDevices[i]!{
                    self.isDeviceAllocatedAnyLocation(dev.getObId())
                }else{
                    print("problem getting found device pointer")
                }
            }
        }else{
            print("the user has no device")
        }
    }
    
    
    /*
        Check if a device is allocated to any location
    */
    internal func isDeviceAllocatedAnyLocation(_ deviceId:String){
        
        self.checkedDevices += 1
        
        // perform operations on the app backend
        PFCloud.callFunction(inBackground: "isDeviceAllocated", withParameters: [
            "deviceId":deviceId
        ]) {
            (answer, error) in
                
            if (error == nil){
                
                // get result from server
                if let result:Int = answer as? Int{
                    if(result == -1){
                        print("\nunkwon error")
                    }else if(result == 0){
                        print("\ndevice is allocated, discarding it ...")
                    }else{
                        print("\ndevice isn't allocated, inserting into list of available devices ...")
                        
                        let query:PFQuery = Device.query()!
                        query.getObjectInBackground(withId: deviceId){
                            (object, error) -> Void in
                                
                            if(error == nil){
                                if let dev:PFObject = object{
                                    let device = Device(device:dev)
                                    
                                    // ensures the element doesn't exist in the list already
                                    if(self.availableDevs.index(of: device.getDeviceInfo()) == nil){
                                        self.availableDevs.append(device.getDeviceInfo())
                                    }
                                    
                                    if(device.getObId() == DBHelpers.currentDevice?.getObId()){
                                        self.isDevicesLoadingDone(true)
                                    }else{
                                        self.isDevicesLoadingDone(false)
                                    }
                                }else{
                                    print("error converting device AnyObject into PFObject")
                                    self.isDevicesLoadingDone(false)
                                }
                            }else{
                                print("error getting device by its id")
                            }
                        }
                    }
                }else{
                    print("problems converting cloud query result")
                }
                
            }else{
                print("error: \(error)")
            }
        }
    }
    
    
    /*
        Check if the device loading process is done
    */
    internal func isDevicesLoadingDone(_ isCurrentDevice:Bool){
        
        if(DBHelpers.userDevices.count == self.checkedDevices){
            print("loading process is done.")
            
            self.availableDevices.reloadAllComponents()
            
            // if the user has a device change the device picker selected element to the current device
            if(isCurrentDevice){
                self.availableDevices.selectRow(
                    (self.availableDevs.count - 1),
                    inComponent: 0,
                    animated: true
                )
            }
            
            // if the device's list has only one device, set it as the default option
            if(self.availableDevs.count == 1){
                self.selectedDeviceInfo = self.availableDevs[0]
            }
        }else{
            print("still have more devices to check ...")
        }
    }



    /*
        Update global controllers with the updated location object and dependencies
    */
    internal func updateGlobalVaribles(_ location:PFObject){
        print("\nupdating global controller variables with new location and dependencies ...")
        
        // create a new Location object with the PFObject
        let loc = Location(location:location)
        
        // insert location in the array of locations of the user
        DBHelpers.userLocations[DBHelpers.userLocations.count] = loc
    }
    
    
    
    // NAVIGATION
    internal func back(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    /*
        Go to the beacons configuration screen
    */
    @IBAction func configureBeacons(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_SET_BEACONS, sender: self.location)
    }
    
    
    /*
        Get selected object from rewards
    */
    @IBAction func unwindWithSelectedBeacon(_ segue:UIStoryboardSegue) {
        print("\ncame back from beacons configuration page")
        
        // get operation result back form the beacon's configuration page
        if let beaconVC:BeaconViewController = segue.source as? BeaconViewController{
            if let beacon = beaconVC.savedBeacon{
                self.configuredBeacon = beacon
                print("beacon has been configured to the location \(self.locationName.text!)")
            }else{
                print("No beacon was configured")
            }
        }
    }
    
    
    
    /*
        Prepare data to next screen
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // prepare data for the available locations screen
        if(segue.identifier == self.feu.SEGUE_SET_BEACONS){
            let destineVC = (segue.destination as! BeaconViewController)
                
            if let location = sender as? Location{
                destineVC.location = location
            }else{
                print("problem converting sender into locations array")
            }
        }
    }
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
