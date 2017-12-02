//
//  Device.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/4/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import Foundation


class Device: PFObject {
    
    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    @NSManaged var admin: PFUser
    @NSManaged var activation_key: String?
    @NSManaged var type: String?
    @NSManaged var info: String?
    @NSManaged var location: String?
    fileprivate var status:Bool?
    fileprivate var isPaymentOk:Bool?
    
    
    
    // CONSTRUCTORS
    /*
        Initialize a device with all the attributes of the PFObject in the database
    */
    convenience init(device:PFObject){
        let dbu:DBUtils = DBUtils()
        
        var id:String = ""
        if let auxId:String = device.objectId{
            id = auxId
        }else{
            id = dbu.STD_UNDEF_STRING
        }
        
        var activation_key:String
        if let act_k = device[dbu.DBH_DEVICE_ACT_K] as? String{
            activation_key = act_k
        }else{
            activation_key = dbu.STD_UNDEF_STRING
        }
        
        var type = ""
        if let t = device[dbu.DBH_DEVICE_TYPE] as? String{
            type = t
        }else{
            type = dbu.STD_UNDEF_STRING
        }
                        
        var info = ""
        if let i = device[dbu.DBH_DEVICE_INFO] as? String{
            info = i
        }else{
            info = dbu.STD_UNDEF_STRING
        }
                        
        var location = ""
        if let l = device[dbu.DBH_DEVICE_LOCATE] as? String{
            location = l
        }else{
            location = dbu.STD_UNDEF_STRING
        }
                        
        var status = false
        if let s = device[dbu.DBH_DEVICE_STATUS] as? Bool{
            status = s
        }
                        
        var paymentStatus = false
        if let ps = device[dbu.DBH_DEVICE_PAYMEN] as? Bool{
            paymentStatus = ps
        }
                        
        self.init(
            objectId:       id,
            activation_key: activation_key,
            type:           type,
            info:           info,
            location:       location,
            status:         status,
            isPaymentOk:    paymentStatus
        )

    }
    
    /*
        Initialize a device with its attributes
    */
    init(objectId:String?, activation_key:String?, type:String?, info:String?, location:String?, status:Bool?, isPaymentOk:Bool?) {
        super.init()
        
        self.setObId(objectId)
        self.setActivationKey(activation_key)
        self.setDeviceType(type)
        self.setDeviceInfo(info)
        self.setDeviceLocation(location)
        self.setStatus(status)
        self.setPaymentStatus(isPaymentOk)
    }
    
    /*
        Initialize a device only with a pointer to the PFObject in the database
    */
    init(devicePointer:PFObject){
        super.init()
        
        var id:String = ""
        if let auxId:String = devicePointer.objectId{
            id = auxId
        }else{
            id = dbu.STD_UNDEF_STRING
        }
        
        self.setObId(id)
    }
    
    override init() {
        super.init()
    }
    
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        //print("device id is now: \(id)")
        self.objId = id
    }
    
    internal func setAdminUser(_ user:PFUser){
        //print("device user is now: \(user)")
        self.admin = user
    }
    
    internal func setDeviceInfo(_ info:String?){
        //print("device info is now: \(info)")
        self.info = info
    }
    
    internal func setActivationKey(_ key:String?){
        //print("device act key is now: \(key)")
        self.activation_key = key
    }
    
    internal func setDeviceType(_ type:String?){
        //print("device type is now: \(type)")
        self.type = type
    }
    
    internal func setDeviceLocation(_ location:String?){
        //print("device location is now: \(location)")
        self.location = location
    }
    
    internal func setStatus(_ status:Bool?){
        //print("device status is now: \(status)")
        self.status = status
    }
    
    internal func setPaymentStatus(_ status:Bool?){
        //print("device payment status is now: \(status)")
        self.isPaymentOk = status
    }
    
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getAdmin() -> PFUser?{
        return self.admin
    }
    
    internal func getDeviceInfo() -> String{
        if let info:String = self.info{
            return info
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getActivationKey() -> String{
        if let key:String = self.activation_key{
            return key
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getType() -> String{
        if let type:String = self.type{
            return type
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getLocation() -> String{
        if let location:String = self.location{
            return location
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }

    
    internal func getPointerToLocationTable() -> PFObject{
        print("creating pointer to location with id: \(self.location)")
        let locPointer = PFObject(outDataWithClassName:self.dbu.DB_CLASS_LOCATION, objectId: self.getObId())
        
        return locPointer
    }
    
    
    internal func getStatus() -> Bool{
        if let status:Bool = self.status{
            return status
        }else{
            return false
        }
    }
    
    internal func getPaymentStatus() -> Bool{
        if let status:Bool = self.isPaymentOk{
            return status
        }else{
            return false
        }
    }
    
    internal func getPointerToDatabaseTable() -> PFObject{
        let devicePointer = PFObject(
            outDataWithClassName:self.dbu.DB_CLASS_DEVICE,
            objectId: self.getObId()
        )
        
        return devicePointer
    }
    
    
    
    // OTHER METHODS
    /*
        Updates PFObject that is going to be saved on the server side with a loaded Device information
    */
    internal func getUpdatedDeviceObject(_ auxDevice:PFObject){
        auxDevice[self.dbu.DBH_DEVICE_ACT_K]  = self.getActivationKey()
        auxDevice[self.dbu.DBH_DEVICE_TYPE]   = self.getType()
        auxDevice[self.dbu.DBH_DEVICE_INFO]   = self.getDeviceInfo()
        auxDevice[self.dbu.DBH_DEVICE_PAYMEN] = self.getPaymentStatus()
        auxDevice[self.dbu.DBH_DEVICE_STATUS] = self.getStatus()
        
        if let adm:PFUser = self.getAdmin(){
            auxDevice[self.dbu.DBH_DEVICE_ADMIN]  = adm
        }
        
        if(self.getLocation() != self.dbu.STD_UNDEF_STRING){
            auxDevice[self.dbu.DBH_DEVICE_LOCATE] = self.getPointerToLocationTable()
        }
    }
    
    
    /*
        Disengages device from user and point device to company again
    */
    internal func disengageDeviceFromUser(_ deviceToDesingage:PFObject, companyUser:PFObject){
        deviceToDesingage[dbu.DBH_DEVICE_ADMIN]  = companyUser
        deviceToDesingage[dbu.DBH_DEVICE_ACT_K]  = ""
        deviceToDesingage[dbu.DBH_DEVICE_TYPE]   = ""
        deviceToDesingage[dbu.DBH_DEVICE_INFO]   = ""
        deviceToDesingage[dbu.DBH_DEVICE_LOCATE] = ""
        deviceToDesingage[dbu.DBH_DEVICE_PAYMEN] = false
        deviceToDesingage[dbu.DBH_DEVICE_STATUS] = false
    }
    
    
    
    /*
        Get a new relationship object between a user and a device
    */
    internal func getNewUserDevRelObject(_ user:PFUser, device:PFObject) -> PFObject{
        
        let userDevObj:PFObject = PFObject(className: self.dbu.DB_REL_USER_DEVICE)
        
        userDevObj[self.dbu.DBH_REL_USER_ENVIR_USER]   = user
        userDevObj[self.dbu.DBH_REL_USER_ENVIR_DEVICE] = device
        
        return userDevObj
    }
    
    
    
    
    // QUERIES
    /*
        Returns a query to get all the devices associated within an user
    */
    class func getAllUserDevices(_ user:PFUser) -> PFQuery? {
        
        // check if the provided device activation id exists on the table of available devices
        let userDevicesQuery = PFQuery(className: "User_Envir")
        userDevicesQuery.includeKey("username")
        userDevicesQuery.includeKey("envir_id")
        
        userDevicesQuery.whereKey("username", equalTo: user)
        let null = NSNull()
        userDevicesQuery.whereKey("envir_id", notEqualTo:null)
        
        return userDevicesQuery
    }
    
    
    /*
        Returns a query to get only the devices managed by the user, the processing of the incoming data is done on the controller layer
    */
    class func getDevicesOwnedByUserQuery(_ user:PFUser) -> PFQuery? {
        
        // check if the provided device activation id exists on the table of available devices
        let userDevicesQuery = PFQuery(className: Device.parseClassName())
        userDevicesQuery.includeKey("admin")
        userDevicesQuery.whereKey("admin", equalTo: user)
        
        return userDevicesQuery
    }
    
    
    /*
        Update the selected device and send a status information back to the controller
    */
    internal func updateDeviceQuery() -> PFQuery? {
        
        print("\nUpdating device ...")
        let query = PFQuery(className:Device.parseClassName())
        
        return query
    }
    
    
    /*
        Returns query to disengage the user from the device
    */

    internal func deleteDeviceQuery() -> PFQuery?{
        print("\nDeleting device ...")
        
        let query = PFQuery(className:Device.parseClassName())

        return query
    }
    
    
    /*
        Returns query to delete the relationship between the user and the device
    */
    internal func deleteUserDeviceRelQuery(_ deviceId:String, user:PFUser) -> PFQuery? {
        print("\ndeleting user/device relationship ...")
        
        print("\(self.dbu.DB_REL_USER_DEVICE)")
        print("\(self.dbu.DBH_REL_USER_ENVIR_USER)")
        print("\(self.dbu.DBH_REL_USER_ENVIR_DEVICE)")
        print("\(self.dbu.DB_CLASS_DEVICE)")
        
        let userDevicesQuery = PFQuery(className: self.dbu.DB_REL_USER_DEVICE)
        
        userDevicesQuery.includeKey(self.dbu.DBH_REL_USER_ENVIR_USER)
        userDevicesQuery.includeKey(self.dbu.DBH_REL_USER_ENVIR_DEVICE)
        userDevicesQuery.whereKey(self.dbu.DBH_REL_USER_ENVIR_USER, equalTo: user)
        
        let pointer = PFObject(outDataWithClassName:self.dbu.DB_CLASS_DEVICE, objectId: deviceId)
        print("\(pointer)")
        userDevicesQuery.whereKey(self.dbu.DBH_REL_USER_ENVIR_DEVICE, equalTo: pointer)
        
        return userDevicesQuery
    }
    
}



// Respect the PFSubclassing protocol
extension Device: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Envir_brain"
    }
    
    override class func initialize() {
        // Let Parse know that you intend to use this subclass for all objects with class type WallPost.
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}


