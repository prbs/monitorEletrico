//
//  LocationsViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/22/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DevicesViewController: BaseViewController, iCarouselDataSource, iCarouselDelegate {

    
    
    // VARIABLES
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var carousel: iCarousel!
    
    @IBOutlet weak var newDeviceBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()
    
    internal var allUserDevices   = [Int: Device?]()
    internal var devicesLocations = [Int: Location?]()
    
    internal var selectedDeviceIdx:Int = 0
    internal var selectedDevice: Device? = nil
    
    internal let CROWD_FUND_ADDR = "http://www.kickante.com.br/"
    internal let WEB_PAGE = "www.iothinking.com"
    internal let PRICE = "\n\nR$xxx,xx\n\n"
    
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        
        // UI initialization
        self.customizeNavBar(self)
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        self.customizeMenuBtn(self.homeBtn, btnIdentifier: self.feu.ID_HOME)
    }
    
    /*
        Load items into the carousel
    */
    override func awakeFromNib(){
        super.awakeFromNib()
        
        print("\nInitializing devices list ...")
        self.allUserDevices =  DBHelpers.userDevices
        
        if(self.allUserDevices.count > 0){
            if let device = self.allUserDevices[0]{
                
                self.selectedDeviceIdx = 0
                self.selectedDevice = device
            }else{
                print("could not get device from devices list")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // binds the show menu toogle action implemented by SWRevealViewController to the menu button
        if self.revealViewController() != nil {
            self.menuBtn.target = self.revealViewController()
            self.menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if(DBHelpers.userDevices.count > 0){
            
            // initializes carousel
            self.carousel.dataSource = self
            self.carousel.delegate = self
            self.carousel.type = .linear
            self.carousel.decelerationRate = 0.6
            self.carousel.bounces = false
            self.carousel.isUserInteractionEnabled = true
            
            // get device locations from app backend
            self.getDevicesLocations()
        }else{
            
            let title = "Você ainda não possui um dispositivo de monitoramento"
            let msg = "Acesse '\(self.WEB_PAGE)' e adquira seu dispositivo por apenas \(self.PRICE) Obtenha o máximo do que Bolt tem a oferecer."
            
            self.infoWindow(msg, title: title, vc: self)
        }
        
        
    }

    
    // UI
    // Carousel
    //---------
    /*
        Number of items in the carousel
    */
    func numberOfItems(in carousel: iCarousel) -> Int{
        if(self.allUserDevices.count == 0){
            return 1
        }else{
            return self.allUserDevices.count
        }
    }
    
    
    /*
        Load nib into carousel
    */
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView{
        
        // if current user already has at least one device
        if(self.allUserDevices.count != 0){
            
            print("\ncreating device card ...")
            
            var itemView: DeviceCardView
        
            // initialize UI elements
            self.newDeviceBtn.isHidden = false
            
            self.nextBtn.isHidden = false
            self.nextBtn.isEnabled = true
            
            self.prevBtn.isHidden = false
            self.prevBtn.isEnabled = true
            
            itemView = UIView.loadFromNibNamed("DeviceCard") as! DeviceCardView
        
            //create new view if no view is available for recycling
            if (view == nil){
            
                if let dev = self.allUserDevices[index]{
                    
                    if let device:Device =  dev{
                    
                        // insert device status
                        if(device.getStatus()){
                            itemView.deviceStatus.text = "Ativo"
                        }else{
                            itemView.deviceStatus.text = "Inativo"
                        }
                    
                        // insert payment status
                        if(device.getPaymentStatus()){
                            itemView.paymentStatus.text = "Em dia"
                        }else{
                            itemView.paymentStatus.text = "Em atraso"
                        }
                    
                        // get device activation key
                        if(device.getActivationKey() != self.dbu.STD_UNDEF_STRING){
                            itemView.activationKey.text = device.getActivationKey()
                        }else{
                            print("Very weird, this device has no activation key")
                        }
                
                        // get location id
                        if let loc = self.devicesLocations[index]{
                            
                            if let location:Location = loc{
                                
                                if(location.getLocationName() != self.dbu.STD_UNDEF_STRING){
                                    itemView.monitoredPlace.text = device.getLocation()
                                    
                                }else{
                                    print("this device isn't monitoring any location")
                                    itemView.monitoredPlace.text = "Dispositivo não alocado"
                                }
                                
                                // get location type image
                                print("location type: \(location.getLocationType())")
                                
                                if(location.getLocationType() == self.feu.LOCATION_TYPES[0]){
                                    itemView.monitoredPlaceImgType.isHidden = true
                                    itemView.monitoredPlaceImgType.image = UIImage(named: self.feu.IMAGE_LOC_TYPE_RESIDENCIAL)
                                    self.feu.fadeIn(itemView.monitoredPlaceImgType, speed: 0.7)
                                    
                                }else if(location.getLocationType() == self.feu.LOCATION_TYPES[1]){
                                    itemView.monitoredPlaceImgType.isHidden = true
                                    itemView.monitoredPlaceImgType.image = UIImage(named: self.feu.IMAGE_LOC_TYPE_BUSINESS)
                                    self.feu.fadeIn(itemView.monitoredPlaceImgType, speed: 0.7)
                                    
                                }else{
                                    self.setLocationTypeImgToDefault(itemView)
                                }
                            }else{
                                print("this device isn't monitoring any location")
                                itemView.monitoredPlace.text = "Dispositivo não alocado"
                                itemView.devicePlaceLabel.text = ""
                                
                                self.setLocationTypeImgToDefault(itemView)
                            }
                        }else{
                            print("this device isn't monitoring any location")
                            itemView.monitoredPlace.text = "Dispositivo não alocado"
                            itemView.devicePlaceLabel.text = ""
                            
                            self.setLocationTypeImgToDefault(itemView)
                        }
                    }else{
                        print("problems to get user device out of list of devices")
                    }
                }else{
                    print("problem unwrapping device")
                }
            }
            
            // customize buy btn
            self.buyBtn.setBackgroundImage(UIImage(named:self.feu.BTN_BLUE), for: UIControlState())
            self.buyBtn.setTitleColor(self.feu.NAVBAR_BACKGROUND_COLOR, for: UIControlState())
            
            self.newDeviceBtn.setBackgroundImage(UIImage(named:self.feu.BTN_BLUE), for: UIControlState())
            self.newDeviceBtn.setTitleColor(self.feu.NAVBAR_BACKGROUND_COLOR, for: UIControlState())
            
            return itemView
            
        // user desn't have a device yet
        }else{
            print("the user doesn't have a monitoring device yet")
         
            // initialize UI elements
            self.feu.fadeIn(self.newDeviceBtn, speed:1.0)
            
            self.nextBtn.isHidden = true
            self.nextBtn.isEnabled = false
            
            self.prevBtn.isHidden = true
            self.prevBtn.isEnabled = false
            
            let itemView = UIView.loadFromNibNamed("NoDevice") as! NoDevice
            
            // customize buy btn
            self.buyBtn.setBackgroundImage(UIImage(named:self.feu.BTN_WHITE), for: UIControlState())
            self.buyBtn.setTitleColor(UIColor.white, for: UIControlState())
            
            self.newDeviceBtn.setBackgroundImage(UIImage(named:self.feu.BTN_WHITE), for: UIControlState())
            self.newDeviceBtn.setTitleColor(UIColor.white, for: UIControlState())
            
            return itemView
        }
    }

    
    
    /*
        Set location type image to default
    */
    internal func setLocationTypeImgToDefault(_ itemView:DeviceCardView){
        
        itemView.monitoredPlaceImgType.isHidden = true
        itemView.monitoredPlaceImgType.image = UIImage(named: self.feu.IMAGE_LOC_TYPE_UNDEFINED)
        self.feu.fadeIn(itemView.monitoredPlaceImgType, speed: 0.7)
    }
    
    
    
    /*
        Controls the space between the views
    */
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat{
        
        if (option == .spacing){
            return value * 1.0;
        }
        
        return value
    }

   
    /*
        Identify when the current view changes
    */
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let currentItem = self.carousel.currentItemIndex + 1
        
        // get selected device
        if let dev = self.allUserDevices[currentItem]{
            if let device:Device =  dev{
                
                self.selectedDeviceIdx = self.carousel.currentItemIndex
                self.selectedDevice = device
            }else{
                print("problems to get user device out of list of devices")
            }
        }else{
            print("problem unwrapping device")
        }
    }

    /*
        Selects an item from the carousel
    */
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        print("selected location...")
        
        if(self.selectedDevice != nil){
            
            self.selectedDeviceIdx =  self.carousel.currentItemIndex
            self.performSegue(withIdentifier: self.feu.SEGUE_UPSERT_DEVICE, sender: self.feu.PAGE_MODE_UPDATE)
        }else{
            print("could not go to the device details screen because the selected device is null")
        }
    }
    
    
    /*
        Start the process of buying a device in app
    */
    @IBAction func buyDevice(_ sender: AnyObject) {
        self.infoWindow("Ajude nossa campanha de crowdfunding em \(self.CROWD_FUND_ADDR)", title: "Contribua com este projeto, para mais informações acesse \(self.WEB_PAGE))", vc: self)
    }
    
    
    /*
        Display the previous item
    */
    @IBAction func showPrevious(_ sender: AnyObject) {
        var selectedItem = self.carousel.currentItemIndex - 1
        
        // get the previous item
        if(selectedItem < 0){
            selectedItem = self.allUserDevices.count - 1
        }
        
        self.carousel.scrollToItem(at: selectedItem, animated: true)
    }
    
    
    /*
        Display the next item on the carousel
    */
    @IBAction func showNext(_ sender: AnyObject) {
        var selectedItem = self.carousel.currentItemIndex + 1
        
        // get the next item
        if(selectedItem > self.allUserDevices.count - 1){
            selectedItem = 0
        }
        
        self.carousel.scrollToItem(at: selectedItem, animated: true)
    }
    
    
    
    
    // LOGIC
    /*
        Get the locations of all devices that have a location currently being monitored
    */
    internal func getDevicesLocations(){
        print("\ngetting locations of all devices that currently have monitoring a device ...")
        
        // check all the devices for places being monitored
        for i in 0...(self.allUserDevices.count - 1){
            
            // try to get a device
            if let dev:Device = self.allUserDevices[i]!{
                
                let locPointer = dev.getLocation()
                
                // if it is a valid pointer
                if(locPointer != self.dbu.STD_UNDEF_STRING){
                    
                    // get the device form the app backend
                    if(i == self.allUserDevices.count - 1){
                        self.getLocationById(locPointer, isLast:true)
                    }else{
                        self.getLocationById(locPointer, isLast:false)
                    }
                }else{
                    print("device isn't monitoring a location")
                }
            }else{
                print("invalid device object")
            }
        }
    }
    
    
    
    /*
        Get location by id
    */
    internal func getLocationById(_ locId:String, isLast:Bool){
        
        // check if the user isn't already related to the location
        PFCloud.callFunction(inBackground: "getLocationById", withParameters: [
            "locationId":locId
        ]) {
            (locObj, error) in
                
            if (error == nil){
                print("location \(locObj)")
                    
                if let loc:PFObject = locObj as? PFObject {
                    let location:Location = Location(location:loc)
                    
                    self.devicesLocations[self.devicesLocations.count] = location
                }else{
                    print("problems converting getting device location.")
                    self.devicesLocations[self.devicesLocations.count] = nil
                }
                    
                if(isLast){
                    self.carousel.reloadData()
                }
            }else{
                print("\nconnection error: \(error)")
            }
                
            if(isLast){
                self.carousel.reloadData()
            }
        }
    }
    
    
    
    // NAVIGATION
    /*
        Go home
    */
    @IBAction func goHome(){
        self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
    }
    
    
    /*
        Send the user to the new device screen
    */
    @IBAction func goToNewDeviceScreen(_ sender: AnyObject) {
        print("sending user to new device screen ...")
        self.performSegue(withIdentifier: self.feu.SEGUE_UPSERT_DEVICE, sender: self.feu.PAGE_MODE_CREATE)
    }
    
    
    /*
        Trheat the devices list with update data from the upsert operation
    */
    @IBAction func unwindAfterDeviceUpsert(_ segue:UIStoryboardSegue) {
        
        if let newDeviceVC:UpsertDispositivoViewController = segue.source as? UpsertDispositivoViewController{
            
            if let upsertedDevice = newDeviceVC.upsertedDevice{
                print("insert device \(upsertedDevice) into list")
                
                self.allUserDevices =  DBHelpers.userDevices
                
                if(self.allUserDevices.count > 0){
                    if let device = self.allUserDevices[0]{
                        self.selectedDevice = device
                    }else{
                        print("could not get device from devices list")
                    }
                }
                
                self.carousel.reloadData()
            }else{
                print("No beacon was configured")
            }
        }
    }
    
    
    /*
        Get deleted device from the delete device operation
    */
    @IBAction func unwindAfterDeviceDeletion(_ segue:UIStoryboardSegue) {
        
        self.allUserDevices =  DBHelpers.userDevices
        self.carousel.reloadData()
        
    }
    
    /*
        Prepare data to next screen, if the selected operation is the details or update, send the 
        selected device along, otherwise, doesn't send anything
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get the page mode operation out of the sender object
        if let pageMode:String = sender as? String{
            
            // update device
            if(segue.identifier == self.feu.SEGUE_UPSERT_DEVICE){
                
                if let destineVC:UpsertDispositivoViewController = segue.destination as? UpsertDispositivoViewController{
           
                    // change the page behavior for a device update
                    if(pageMode == self.feu.PAGE_MODE_UPDATE){
                        
                        destineVC.deviceIdx = self.selectedDeviceIdx
                        destineVC.upsertedDevice = self.selectedDevice
                        destineVC.pageMode = self.feu.PAGE_MODE_UPDATE
                    
                    // change the page behavior for a new device
                    }else if(pageMode == self.feu.PAGE_MODE_CREATE){
                        destineVC.pageMode = self.feu.PAGE_MODE_CREATE
                        
                    }else{
                        print("unkown page mode")
                    }
                }else{
                    print("could not get segue destination")
                }
            }
        }else{
            print("could not get selected page mode, cancelling operation ...")
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension UIView {
    
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
