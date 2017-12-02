//
//  NewDeviceViewController.swift
//  x
//
//  Created by Diego Silva on 11/15/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class UpsertDispositivoViewController: BaseViewController {
    
    
    
    // VARIABLES
    // Containers
    @IBOutlet var outterContainer: UIView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var keyConfirmationContainer: UIView!
    
    // Activation key
    @IBOutlet weak var activationKey: UITextField!
    
    // Device info
    @IBOutlet weak var deviceInfo: UITextView!
    @IBOutlet weak var deviceWorkingStatus: UILabel!
    @IBOutlet weak var devicePaymentStatus: UILabel!
    
    // Hardware network settings
    @IBOutlet weak var netwokdId: UITextField!
    @IBOutlet weak var netPass: UITextField!
    @IBOutlet weak var networkStatus: UILabel!
    @IBOutlet weak var networkConfigProgress: UIProgressView!
    @IBOutlet weak var configHardBtn: UIButton!
    
    // Upsert methods
    @IBOutlet weak var upsertBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // Controllers
    internal var deviceIdx:Int = 0 // the device position at the system variable that controls all the devices
    internal var upsertedDevice:Device?    = nil
    
    internal var isHardwareConfigured:Bool = false
    internal var pageMode:String           = "create"
    internal var isDeviceRegistered:Bool   = false
    
    internal let selector:Selector = #selector(UpsertDispositivoViewController.back)
    
    internal let dbu:DBUtils = DBUtils()
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(self.selector, parentVC: self, labelText: "<")

        // enable page to create mode
        if(self.pageMode == self.feu.PAGE_MODE_CREATE){
            self.title = "Novo dispositivo"
            
            self.switchToCreateMode()
            self.isDeviceRegistered = false
            
        // enable page to update mode
        }else if(self.pageMode == self.feu.PAGE_MODE_UPDATE){
            self.title = "Atualizar dispositivo"
            
            self.switchToUpdateMode()
            self.isDeviceRegistered = true
            self.loadDeviceInfoIntoUI()
        }
        
        // activate keyboard methods for fields
        self.activationKey.delegate = self
        self.deviceInfo.delegate = self
        self.netwokdId.delegate = self
        self.netPass.delegate = self
        
        self.intervalToHideKeyboard = 1.2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // UI
        self.setScroller()
        self.customizeNavBar(self)
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
        Switch the page outlets to the create mode. I.E, block everything but the activation key container, that is going to be completely showing and activated
    */
    internal func switchToCreateMode(){
        
        // Containers
        self.contentContainer.alpha = 0.8
        
        // Device info
        self.deviceInfo.isEditable = false
        self.deviceWorkingStatus.isEnabled = false
        self.devicePaymentStatus.isEnabled = false
        
        // Hardware network settings
        self.netwokdId.isEnabled = false
        self.netPass.isEnabled = false
        self.networkStatus.isEnabled = false
        self.networkConfigProgress.setProgress(0.0, animated: true)
        self.configHardBtn.isEnabled = false
        
        // Upsert methods
        self.upsertBtn.isEnabled = false
        self.deleteBtn.isEnabled = false
    }
    
    
    /*
        Switch the page outlets to the update mode. I.E, allow the access to all the fields, but hides the activate key btn
    */
    internal func switchToUpdateMode(){
        
        self.activationKey.isEnabled = false
        self.activationKey.textColor = self.feu.LIGHT_GREY
        
        // Containers
        self.contentContainer.alpha = 1.0
        
        // Device info
        self.deviceInfo.isEditable = true
        self.deviceWorkingStatus.isEnabled = true
        self.devicePaymentStatus.isEnabled = true
        
        // Upsert methods
        self.upsertBtn.isEnabled = true
        self.deleteBtn.isEnabled = true
        self.configHardBtn.isEnabled = true
        
        // set the configuration progress status
        if let status = self.upsertedDevice?.getStatus(){
            if(status){
                self.networkConfigProgress.isHidden = true
            }else{
                self.networkConfigProgress.setProgress(0.0, animated: true)
            }
        }else{
            self.networkConfigProgress.setProgress(0.0, animated: true)
        }
        
        self.pageMode = self.feu.PAGE_MODE_UPDATE
    }
    
    
    /*
        Allow the user configure the device internet connection
    */
    internal func unlockNetworkSettings(){
        
        // Hardware network settings
        self.netwokdId.isEnabled = true
        self.netPass.isEnabled = true
        self.networkStatus.isEnabled = true
        self.networkConfigProgress.setProgress(0.0, animated: true)
        self.configHardBtn.isEnabled = false
    }
    
    
    
    /*
        Load selected device information into the UI
    */
    internal func loadDeviceInfoIntoUI(){
        print("\nloading device info into UI ...")
        
        self.activationKey.text = self.upsertedDevice?.getActivationKey()
        self.deviceInfo.text = self.upsertedDevice?.getDeviceInfo()
        
        if((self.upsertedDevice?.getStatus()) != nil){
            self.deviceWorkingStatus.text = "Ativado para o usuário"
        }else{
            self.deviceWorkingStatus.text = "Inativo"
        }
        
        if((self.upsertedDevice?.getPaymentStatus()) != nil){
            self.devicePaymentStatus.text = "Pagamento em dia"
        }else{
            self.devicePaymentStatus.text = "Pagamento atrasado"
        }
    }
    
    
    
    /*
        Start the activation key validation process
    */
    override func keyboardWillHide(_ notification: Notification) {
        
        // move view to initial position when the keyboard is dismissed
        UIView.animate(withDuration: 0.3,
            animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -self.keyboardMovement)
            }, completion:{
                (success:Bool) in
                
                self.keyboardMovement = 0.0
            }
        )
        
        if(!self.isDeviceRegistered){
            
            // call the validation method of the activation key
            if let key:String = self.activationKey.text{
                self.validadeKey(key)
            }else{
                print("problems getting device key as String")
                self.infoWindow("Insira uma chave válida", title: "Atenção", vc: self)
            }
        }
    }
    
    
    
    /*
        Validate network information and try to connect to the device
    */
    @IBAction func configureNetwork(_ sender: AnyObject) {
        self.infoWindow("A funcionalidade de configuração do dispositivo pelo telefone estará disponível em breve.", title: "Funcionalidade em desenvolvimento", vc: self)
        //self.validateNetworkInfo()
    }
    
    
    /*
        Try to delete the device
    */
    @IBAction func deleteDevice(_ sender: AnyObject) {
        
        let title = "Tem certeza?"
        let msg = "Uma vez deletado o dispositivo não enviará mais dados para o local onde estiver conectado."
        
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction) in
            print("\ndeleting association between user and device")
            self.deleteDevice()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            print("\nuser has canceled the delete device operation")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    /*
        Upsert device info
    */
    @IBAction func upsertDevice(_ sender: AnyObject) {
        print("Start device info upsert process ...")
        self.validateInfoForDevice()
    }
    
    
    
    
    
    
    // LOGIC
    /*
        Validate a device activation key. if it is ok, unlock the page fields for creation
    */
    internal func validadeKey(_ key:String){
        print("\nvalidating activation key ...")
        
        // get id
        if let id:String = self.activationKey.text{
        
            // check device in the app backend
            PFCloud.callFunction(inBackground: "isDevActivationKeyValid", withParameters: [
                "actKey":id,
                "userId":PFUser.current()!.objectId!
            ]) {
                (validObj, error) in
        
                if (error == nil){
                
                    if let dev:PFObject = validObj as? PFObject{
                        
                        // create a relationship between the current user and a device, ownership confirmation
                        let aux:Device = Device()
                        let userDevRel:PFObject = aux.getNewUserDevRelObject(PFUser.current()!, device:dev)
                        
                        userDevRel.saveInBackground{
                            (success, error) -> Void in
                            
                            if(error == nil){
                                
                                self.infoWindow("Chave de ativação válida, edite as informações do dispositivo.", title: "Tudo certo", vc: self)
                                
                                // update local variable with user's device
                                self.upsertedDevice = Device(device:dev)
                                
                                // make user the device owner locally
                                self.upsertedDevice?.setAdminUser(PFUser.current()!)
                                
                                // insert device into system variable that control the user devices
                                DBHelpers.userDevices[DBHelpers.userDevices.count] = self.upsertedDevice
                                
                                // allow user to modify a few device attributes
                                self.switchToUpdateMode()
                                self.unlockNetworkSettings()
                                self.loadDeviceInfoIntoUI()
                                
                                self.isDeviceRegistered = true
                            }else{
                                print("could not create user device relationship")
                            }
                        }
                        
                    }else{
                        print("error \(validObj)")
                        self.infoWindow("Chave de ativação inválida, verifique todos os caracteres da chave     atentamente", title: "Chave inválida", vc: self)
                    }
                }else{
                    print("\nerror: \(error)")
                    self.infoWindow("Erro ao validar chave de ativação", title: "Erro operacional", vc: self)
                }
            }
            
        }else{
            print("could not get activation key")
            self.infoWindow("Insira uma chave de ativação válida", title: "Atenção", vc: self)
        }
        
    }
    
    
    
    /*
        Validate the information being insert to a Device object, if the data is valid call the
        upsert function with a valid Device Object, otherwise alert user that the inserted data
        is invalid
    */
    internal func validateInfoForDevice(){
        print("\nvalidating info for a Device object ...")
        
        if(self.pageMode == self.feu.PAGE_MODE_UPDATE){
            self.updateDevice()
        }else{
            print("this command is supposed to be used only after the activation key is valid and the UI is unlocked")
        }
    }
    
    
    /*
        Clean data to the device configuration method
    */
    internal func validateNetworkInfo(){
        print("\nvalidating network data ...")
        
        if((self.netwokdId.text != "") && (self.netPass.text != "")){
            
            if let netId:String = self.netwokdId.text{
                
                if let netPass:String = self.netPass.text{
                    self.networkConfigProgress.isHidden = false
                    self.networkConfigProgress.setProgress(0.0, animated: true)
                    
                    self.saveNetworkInfoOnDevice(netId, pass:netPass)
                }
            }else{
                print("problems to get network id")
            }
        }else{
            self.infoWindow("O identificador de uma rede acessível e senha devem ser informados", title: "Aviso", vc: self)
        }
    }
    
    
    /*
        Try to configure the device with the network credentials
    */
    internal func saveNetworkInfoOnDevice(_ netId:String, pass:String){
        print("\ntrying to configure device with the network credentials 'id'\(netId), 'pass'\(pass) ...")
        
        
    }
    
    
    /*
        Update a device
    */
    internal func updateDevice(){
        print("trying to update a device ...")
        
        // insert data into local device variable
        self.upsertedDevice?.setDeviceInfo(self.deviceInfo.text)
        
        // get the device id
        if let id:String = self.upsertedDevice?.getObId(){
            
            // if the id is valid
            if(id != self.dbu.STD_UNDEF_STRING){
                
                // get the device on the app backend
                let query:PFQuery = Device.query()!
                
                query.getObjectInBackground(withId: id){
                    (deviceObj: PFObject?, error: NSError?) -> Void in
                    
                    if error != nil {
                        print(error)
                    } else if let dev = deviceObj {
                        
                        // pass dev PFObject as reference to the update device method, loading all information from the updated device into the dev PFObject
                        self.upsertedDevice!.getUpdatedDeviceObject(dev)
                        
                        // save device in the app backend
                        dev.saveInBackground{
                            (success, error) -> Void in
                            
                            if(error == nil){
                                
                                // update device locally on the user devices variable
                                if(self.isDeviceRegistered){
                                    DBHelpers.userDevices[self.deviceIdx] = self.upsertedDevice
                                }
                                
                                // if the selected device is the current device, update the current device variable
                                if(DBHelpers.currentDevice?.getObId() == self.upsertedDevice?.getObId()){
                                    DBHelpers.currentDevice = self.upsertedDevice
                                }
                                
                                self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_DEV_UPS, sender: nil)
                            }else{
                                print("got error while saving device information")
                            }
                        }
                    }
                }
                
            }else{
                print("device id is undefined ...")
                self.infoWindow("A operação não pode ser concluída, pois a id do dispositivo é inválida.", title: "Falha operacional", vc: self)
            }
        }else{
            print("weird, could not get upserted device id.")
        }
    }
    
    
    /*
        Delete device
    */
    internal func deleteDevice(){
        print("\ntrying to delete the selected device ...")
        
        if let device:Device = self.upsertedDevice{
            
            // get the device id
            let id = device.getObId()
            
            // if the id is valid
            if(id != self.dbu.STD_UNDEF_STRING){
                
                PFCloud.callFunction(inBackground: "deleteDeviceById", withParameters: [
                    "deviceId":id
                ]) {
                    (answer, error) in
                        
                    if (error == nil){
                            
                        if let result:Int = answer as? Int{
                            print("result \(result)")
                            
                            if(result == 0){
                                
                                // deletes a relationship between a user and the device
                                self.deleteUserDeviceRel(id)
                                    
                            }else if(result == 1){
                                self.infoWindow("Não foi possível deletar o dispositivo selecionado", title: "Falha ao deletar dispositivo", vc: self)
                            }else{
                                self.infoWindow("Erro desconhecido", title: "Falha ao deletar dispositivo", vc: self)
                            }
                        }else{
                            print("unkown error: \(error)")
                        }
                    }else{
                        print("\nerror: \(error)")
                        self.infoWindow("Não foi possível deletar o dispositivo selecionado", title: "Erro operacional", vc: self)
                    }
                }
                
            }else{
                print("device id is undefined")
            }
        }else{
            print("could not get device")
        }
    }
    
    
    
    /*
        Delete the selected device and its dependencies from the system
    */
    internal func deleteUserDeviceRel(_ deviceId:String){
        print("\ndeleting device and dependencies trace from system ...")
        
        print("deviceId \(deviceId)")
        print("userId \(PFUser.current()!.objectId!)")
        
        PFCloud.callFunction(inBackground: "deleteUserDeviceRelationship", withParameters: [
            "deviceId":deviceId,
            "userId": PFUser.current()!.objectId!
        ]) {
            (answer, error) in
                
            if (error == nil){
                print("\(answer)")
                
                if let result:Int = answer as? Int{
                    print("result \(result)")
                        
                    if(result == 0){
                        
                        // delete device trace from system
                        self.deleteDeviceTraceFromSystem(deviceId)
                        
                    }else if(result == 1){
                        self.infoWindow("Não foi possível deletar o dispositivo selecionado", title: "Falha ao deletar dispositivo", vc: self)
                    }else{
                        self.infoWindow("Erro desconhecido", title: "Falha ao deletar dispositivo", vc: self)
                    }
                }else{
                    print("unkown error: \(answer)")
                }
            }else{
                print("\nerror: \(answer)")
                self.infoWindow("Não foi possível deletar o dispositivo selecionado", title: "Erro operacional", vc: self)
            }
        }
    }
    
    
    
    /*
        Delete the selected device and its dependencies from the system
    */
    internal func deleteDeviceTraceFromSystem(_ deviceId:String){
        print("\ndeleting device and dependencies trace from system ...")
        
        print("user devices \(DBHelpers.userDevices)")
        
        //check all the locations and delete the device from any location that might has been using it
        if(DBHelpers.userLocations.count > 0){
            for i in 0...(DBHelpers.userLocations.count - 1){
                
                if let location = DBHelpers.userLocations[i]{
                    
                    if let device = location.getLocationDevice(){
                        
                        // if one of the user locations is using the deleted device, delete the device pointer of
                        // that location
                        if(device.getObId() == self.upsertedDevice?.getObId()){
                            DBHelpers.userLocations[i]?.setLocationDevice(nil)
                        }
                    }else{
                        print("could not get location device")
                    }
                }else{
                    print("could not get user location")
                }
            }
        }
        
        //if the device is the current device, delete it from the currentDevice variable
        // if the selected device is the current device, update the current device variable
        if(DBHelpers.currentDevice?.getObId() == self.upsertedDevice?.getObId()){
            DBHelpers.currentDevice = nil
        }
        
        //delete device from the 'userDevices' variable
        DBHelpers.userDevices.removeValue(forKey: self.deviceIdx)
        
        self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_DEV_DEL, sender: nil)
    }
    
    
    
    
    // NAVIGATION
    internal func back(){
        if(self.isDeviceRegistered){
            self.updateDevice()
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
