//
//  HardwareSetupViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/26/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class HardwareSetupViewController: BaseViewController {

    
    // VARIABLES
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var activationKey: UITextField!
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var businessSwitch: UISwitch!
    @IBOutlet weak var residencialSwitch: UISwitch!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()
    
    internal var currentUser:User? = nil
    internal var location:Location? = Location()
    internal var locationType:String = ""
    internal var hasDevice:Bool = false
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.currentUser != nil){
            print("\(self.currentUser)")
        }
        
        // set UI input elements
        self.kbHeight = 70
        self.activationKey.delegate = self
        self.locationName.delegate  = self
        self.setScroller()
        self.businessSwitch.setOn(false, animated: true)
        self.locationType = self.feu.LOCATION_TYPES[0]  //residencial
    }
    
    
    
    // UI
    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
        self.scroller.userInteractionEnabled = true
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = self.contentView.frame.size.height
        self.scroller.contentSize.width = self.contentView.frame.size.width
    }
    
    
    /*
        Define the location type
    */
    @IBAction func setLocationTypeResidencial(sender: AnyObject) {
        print("set to residencial")
        
        self.businessSwitch.setOn(false, animated: true)
        self.residencialSwitch.setOn(true, animated:true)
        self.locationType = self.feu.LOCATION_TYPES[0] // residencial
    }
    
    @IBAction func setLocationTypeBusiness(sender: AnyObject) {
        print("set to business")
        
        self.businessSwitch.setOn(true, animated: true)
        self.residencialSwitch.setOn(false, animated:true)
        self.locationType = self.feu.LOCATION_TYPES[1] // business
    }
    

    /*
        Perform the registration once the user clicks on the register button,
        If the user said that he/she is the owner of the product the association is tried focued on
        the activation key. Otherwise the activation is tried with the sharing key.
    */
    @IBAction func registerNewAdminUser(sender: AnyObject) {
        print("\nTry to register device to current user")
        
        if(self.locationName.text != ""){
            if(self.activationKey.text != ""){
                self.hasDevice = true
                
                self.location?.setLocationName(self.locationName.text)
                self.location?.setLocationType(self.locationType)
                self.createUserLocation()
            }else{
                self.hasDevice = false
                self.infoWindowWithCancel("Confirma a criação de um novo ambiente sem um dispositivo?", title: "Atenção", vc: self)
            }
        }else{
            print("problem empty location name")
            self.infoWindow("Um local monitorado precisa de um nome, por favor dê um nome para o seu ambiente", title: "Atenção", vc: self)
        }
    }
    
    
    /*
        Dialog to ask the user to continue without a device
    */
    override internal func infoWindowWithCancel(txt:String, title:String, vc:UIViewController) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            
            print("User has confirmed new location without a device")
            self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: true)
            self.location?.setLocationName(self.locationName.text)
            self.location?.setLocationType(self.locationType)
            
            // create associations on the backend
            self.createUserLocation()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("User cancelled operation without device")
        }))
        
        vc.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    // LOGIC
    /*
        Associate user to a location and at the end of the method associate the user to a device 
        or not, depending on the hasDevice variables.
    
        If the user has a device: validates it and add the user as admin, associate the device
        to the location, update location, create relationship between user and location.
    
        Otherwise: only update location, create relationship between user and location.
    */
    private func createUserLocation(){
        if(self.hasDevice){
            self.addUserAsDeviceAdmin()
        }else{
            self.createLocation(nil)
        }
    }
    
    
    /*
        Update location variable in background with the new values
    */
    private func createLocation(device:PFObject?){
        print("\ntrying to create user, create location, associate then, and associate device to location if needed ...")
        
        self.currentUser!.signUpInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            
            if(success){
                
                // set location admin as newly created user
                self.location?.setLocationAdmin(self.currentUser)
                
                var loc:PFObject? = nil
                
                // adds a valid device to the new location
                if(device != nil){
                    self.location?.setLocationDevice(
                        Device(device: device!)
                    )
                    
                    loc = self.location!.getNewLocationObject(true)
                }else{
                    loc = self.location!.getNewLocationObject(false)
                }
                
                loc!.saveInBackgroundWithBlock{
                    (success: Bool, error: NSError?) -> Void in
                        
                    if(success){
                        if(device != nil){
                            print("user registration with device ...")
                            
                            self.registerUserWithDevice(
                                self.currentUser!.getObId()!,
                                locationId:loc!.objectId!,
                                deviceId:device!.objectId!
                            )
                        }else{
                            print("registration without a device ..")
                            
                            self.registerUserWithoutDevice(self.currentUser!.getObId()!,locationId:loc!.objectId!)
                        }
                    }else{
                        print("error saving location object")
                        self.infoWindow("Houve um erro ao salvar o novo ambiente", title: "Erro operacional", vc: self)
                        self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
                    }
                }
                
            }else{
                print("error on user signup")
                self.infoWindow("Erro ao criar conta, este email já pertence a alguém", title: "Aviso ", vc: self)
                self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
            }
        }
        
    }
    
    
    /*
        Register user with device
    */
    internal func registerUserWithDevice(userId:String, locationId:String, deviceId:String){

        PFCloud.callFunctionInBackground("adminRegistration", withParameters: [
                                            "user"       : userId,
                                            "location"   : locationId,
                                            "withDevice" : true,
                                            "deviceId"   : deviceId
                                        ]){
                                        (opCode, error) in
                
                if (error == nil){
                    if let result = opCode as? Int{
                        self.processRegistrationResult(result)
                    }else{
                        print("problems converting cloud query result")
                        self.infoWindow("Erro ao ler dados do servidor", title: "Erro operacional", vc: self)
                    }
                }else{
                    print("\nerror: \(error)")
                    self.infoWindow("Falha na conexão", title: "Erro operacional", vc: self)
                    self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
                }
        }

    }
    
    
    /*
        Register user without a device
    */
    internal func registerUserWithoutDevice(userId:String, locationId:String){

        PFCloud.callFunctionInBackground("adminRegistration",
                                          withParameters: [
                                                "user"       : userId,
                                                "location"   : locationId,
                                                "withDevice" : false,
                                                "deviceId"   : "undefined"
                                            ]){
                                            (opCode, error) in
            
                if (error == nil){
                    if let result = opCode as? Int{
                        self.processRegistrationResult(result)
                    }else{
                        print("problems converting cloud query result")
                        self.infoWindow("Erro ao ler dados do servidor", title: "Erro operacional", vc: self)
                    }
                }else{
                    print("\nerror: \(error)")
                    self.infoWindow("Falha na conexão", title: "Erro operacional", vc: self)
                }
        }

    }
    
    
    /*
        Process the registration activity result
    */
    internal func processRegistrationResult(result:Int){
        
        switch result{
            case 0:
                print("success, completed the operation without errors.")
                self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
                self.dbh.initializeGlobalVariables(self.location!)
            
            case 1:
                print("error creating user-location relationship.")
                self.infoWindow("Erro ao criar relação usuário ambiente", title: "Erro operacional", vc: self)
            
            case 2:
                print("error finding informed device.")
                self.infoWindow("Erro inesperado, ambiente não encontrado.", title: "Erro operacional", vc: self)
            
            case 3:
                print("error updating user as device admin.")
                self.infoWindow("Erro ao definir usuário administrador do dispositivo", title: "Erro operacional", vc: self)
            
            case 4:
                print("error creating user-device relationship.")
                self.infoWindow("Erro ao criar relação usuário dispositivo", title: "Erro operacional", vc: self)
                    
            default:
                print("unknow error.")
        }
    }

    
    
    /*
        Validates the user information and associate his/her account to a device as admin
    */
    private func addUserAsDeviceAdmin() -> Void{
        
        // check if the provided device activation id exists on the table of available devices
        let query = PFQuery(className: self.dbu.DB_CLASS_DEVICE)
        query.whereKey(self.dbu.DBH_DEVICE_ACT_K, equalTo: self.activationKey.text!)
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            print("\(objects)")
            
            // if search operaton succeds, checks the results
            if(error == nil) {
                
                // if the device exists
                if(objects?.count > 0){
                    if let device:PFObject = objects?.first as? PFObject{
                        self.checkIfDeviceIsSomeoneElse(device)
                    }else{
                        print("failed to unwrap object: \(objects?.first)")
                    }
                } else {
                    self.infoWindow("Chave de ativação não encontrada. \n\nInforme a chave correta e aperte o botão de confirmação novamente ou crie um novo ambiente sem o dispositivo.", title:"Aviso", vc:self)
                }

            }else{
                if let userInfo = error?.userInfo{
                    print("\nError: \(error) \(userInfo)")
                }
                
                self.infoWindow("Erro de conexão com o servidor. Por favor tente realizar a operação novamente.", title:"Aviso", vc:self)
            }
        }
        
    }
    
    
    /*
        Check if the informed activation key isn't active to another admin user
    */
    internal func checkIfDeviceIsSomeoneElse(device:PFObject){
        
        if(device[self.dbu.DBH_DEVICE_ADMIN] != nil){
            let currAdmin:PFObject = device[self.dbu.DBH_DEVICE_ADMIN] as! PFObject
            
            let queryUser = User.query()
            queryUser!.whereKey("objectId", equalTo:currAdmin.objectId!)
            if let users = queryUser!.findObjects(){
                
                if(users.count > 0){
                    print("\nThere is an admin, you're not the owner, go away")
                    self.infoWindow("Esta chave já está ativa para outro ambiente, verifique atentamente cada caracter da chave ou entre em contato com a assistência técnica.", title:"Aviso", vc:self)
                }else{
                    print("\nOk the user pointer was null")
                    self.createLocation(device)
                }
            }else{
                print("\nNo admin user is attached to this device.")
                self.createLocation(device)
            }
        }else{
            print("\nNo admin user is attached to this device.")
            self.createLocation(device)
        }
    
    }
    
    
    
    /*
        Initilize system global variables
    
        At this point what is supposed to be set?
            current user,
            current location,
            current device if there is one,
            local datafile (file with the history of readings)
    */
    internal func initializeSystemVariables(){
        print("Initializing system variables ...")
        
        self.dbh.initializeGlobalVariables(self.location!)
    }

    
    
    // NAVIGATION
    @IBAction func backToUserRegistration(sender: AnyObject) {
        print("goes back to the login or register screen")
        
        self.feu.goToSegueX(self.feu.ID_LOGIN_SIGNUP, obj:NSObject())
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
