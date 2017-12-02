//
//  Location.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/22/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class Location: PFObject {

    
    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    fileprivate var admin: PFUser?
    fileprivate var name: String?
    fileprivate var coordinates: PFGeoPoint?
    fileprivate var address: String?
    fileprivate var device: Device?
    fileprivate var data: PFFile?
    fileprivate var type: String?
    fileprivate var sharing_id: String?
    
    
    // CONSTRUCTORS
    convenience init(location:PFObject){
        let dbu:DBUtils = DBUtils()
        
        var id:String = ""
        if let auxId:String = location.objectId{
            id = auxId
        }
        
            var admin:PFUser? = nil
            if let adm = location[dbu.DBH_LOCATION_ADMIN] as? PFUser{
                admin = adm
            }
            
            var name:String? = nil
            if let n = location[dbu.DBH_LOCATION_NAME] as? String{
                name = n
            }
            
            var coordinates:PFGeoPoint? = nil
            if let cor = location[dbu.DBH_LOCATION_COORD] as? PFGeoPoint{
                coordinates = cor
            }
            
            var address:String? = nil
            if let a = location[dbu.DBH_LOCATION_ADDRESS] as? String{
                address = a
            }
            
            var device:Device? = nil
            if let dev = location[dbu.DBH_LOCATION_DEVICE] as? PFObject{
                device = Device(devicePointer: dev)
            }
            
            var data:PFFile? = nil
            if let dt = location[dbu.DBH_LOCATION_DATA] as? PFFile{
                data = dt
            }
            
            var type:String? = nil
            if let tp = location[dbu.DBH_LOCATION_TYPE] as? String{
                type = tp
            }
            
            self.init(
                objectId    :id,
                admin       :admin,
                name        :name,
                coordinates :coordinates,
                address     :address,
                device      :device,
                data        :data,
                type        :type
            )
        
        
    }
    
    
    init(objectId:String?,admin:PFUser?, name:String?, coordinates:PFGeoPoint?, address:String?, device:Device?,
        data:PFFile?, type:String?){
        super.init()
        
        self.setObId(objectId)
        self.setLocationAdmin(admin)
        self.setLocationName(name)
        self.setLocationDevice(device)
        self.setLocationAddress(address)
        self.setLocationCoordinates(coordinates)
        self.setLocationData(data)
        self.setLocationType(type)
        self.setLocationSharedId()
    }
    
    override init() {
        super.init()
    }
    
    internal func initWithDictionary(_ location:[String:AnyObject]){
        if let id = location[self.dbu.DBH_GLOBAL_ID] as? String{
            self.setObId(id)
            
            var name:String? = nil
            if let n = location[dbu.DBH_LOCATION_NAME] as? String{
                name = n
            }
            
            var admin:PFUser? = nil
            if let adm = location[dbu.DBH_LOCATION_ADMIN] as? PFUser{
                admin = adm
            }
            
            var type:String? = nil
            if let tp = location[dbu.DBH_LOCATION_TYPE] as? String{
                type = tp
            }
           
            self.setObId(id)
            self.setLocationName(name)
            self.setLocationAdmin(admin)
            self.setLocationType(type)
            self.setLocationSharedId()
        }else{
            print("problem getting location, could not get its id")
        }
    }
    
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        //print("location id is now: \(id)")
        self.objId = id
    }
    
    internal func setLocationAdmin(_ admin:PFUser?){
        //print("location admin is now: \(admin)")
        self.admin = admin
    }
    
    internal func setLocationName(_ name:String?){
        //print("location name is now: \(name)")
        self.name = name
    }
    
    internal func setLocationCoordinates(_ coordinates:PFGeoPoint?){
        //print("location coordinates is now: \(coordinates)")
        self.coordinates = coordinates
    }
    
    internal func setLocationAddress(_ address:String?){
        //print("location address is now: \(address)")
        self.address = address
    }
    
    internal func setLocationDevice(_ device:Device?){
        //print("location device is now: \(device)")
        self.device = device
    }
    
    internal func setLocationData(_ data:PFFile?){
        //print("location data is now: \(data)")
        self.data = data
    }
    
    internal func setLocationType(_ type:String?){
        //print("location type is now: \(type)")
        self.type = type
    }
    
    internal func setLocationSharedId(){
        //print("location shared id is now: \(self.getObId())")
        self.sharing_id = self.getObId()
    }
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getLocationAdmin() -> PFUser?{
        if let admin:PFUser = self.admin{
            return admin
        }else{
            return nil
        }
    }
    
    internal func getLocationName() -> String{
        if let name:String = self.name{
            return name
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getLocationCoordinates() -> PFGeoPoint?{
        if let coord:PFGeoPoint = self.coordinates{
            return coord
        }else{
            return PFGeoPoint()
        }
    }
    
    internal func getLocationAddress() -> String?{
        if let address:String = self.address{
            return address
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getLocationDevice() -> Device?{
        if let device:Device = self.device{
            return device
        }else{
            return nil
        }
    }
    
    internal func getLocationData() -> PFFile?{
        if let data:PFFile = self.data{
            return data
        }else{
            return nil
        }
    }
    
    internal func getLocationType() -> String?{
        if let type:String = self.type{
            return type
        }else{
            return nil
        }
    }
    
    internal func getLocationSharedId() -> String?{
        if let sharing_id:String = self.sharing_id{
            return sharing_id
        }else{
            return nil
        }
    }
    
    internal func getLocationAsDictionary() -> [String:AnyObject]{
        var locDict:[String:AnyObject] = [String:AnyObject]()
        
        locDict[self.dbu.DBH_GLOBAL_ID]        = self.objId as AnyObject?
        locDict[self.dbu.DBH_LOCATION_ADDRESS] = self.getLocationAddress() as AnyObject?
        locDict[self.dbu.DBH_LOCATION_ADMIN]   = self.getLocationAdmin()?.objectId as AnyObject?
        locDict[self.dbu.DBH_LOCATION_COORD]   = self.getLocationCoordinates()
        locDict[self.dbu.DBH_LOCATION_DATA]    = self.getLocationData()
        locDict[self.dbu.DBH_LOCATION_DEVICE]  = self.getLocationDevice()?.getObId() as AnyObject?
        locDict[self.dbu.DBH_LOCATION_NAME]    = self.getLocationName() as AnyObject?
        locDict[self.dbu.DBH_LOCATION_TYPE]    = self.getLocationType() as AnyObject?
        
        return locDict
    }
    
    
    internal func getPointerToLocationTable() -> PFObject{
        print("creating pointer to location with id: \(self.getObId())")
        
        let locPointer = PFObject(outDataWithClassName:self.dbu.DB_CLASS_LOCATION, objectId: self.getObId())
        
        return locPointer
    }
    
    
    // OTHER METHODS
    /*
        Returns a new Location PFObject. OBS: you cannot pass unsaved PFFile objects to new PFObjects
        that's why you dont't have the location data here.
    */
    internal func getNewLocationObject(_ withDevice:Bool) -> PFObject{
    
        let newLocation:PFObject = PFObject(className: self.dbu.DB_CLASS_LOCATION)
        
        print("admin \(self.getLocationAdmin())")
        print("name \(self.getLocationName())")
        print("address \(self.getLocationAddress())")
        print("type \(self.getLocationType())")
        
        newLocation[self.dbu.DBH_LOCATION_ADMIN]   = self.getLocationAdmin()
        newLocation[self.dbu.DBH_LOCATION_NAME]    = self.getLocationName()
        newLocation[self.dbu.DBH_LOCATION_ADDRESS] = self.getLocationAddress()
        newLocation[self.dbu.DBH_LOCATION_TYPE]    = self.getLocationType()
        
        if(withDevice){
            newLocation[self.dbu.DBH_LOCATION_DEVICE]  = self.getLocationDevice()!.getPointerToDatabaseTable()
        }
        
        return newLocation
    }
    
    
    
    /*
        Updates PFObject that is going to be saved on the server side with the current 
        Location object information
    */
    internal func getUpdatedLocationObject(_ auxLocation:PFObject){
        
        // flawless variables
        auxLocation[self.dbu.DBH_LOCATION_ADMIN]   = self.getLocationAdmin()
        auxLocation[self.dbu.DBH_LOCATION_NAME]    = self.getLocationName()
        auxLocation[self.dbu.DBH_LOCATION_ADDRESS] = self.getLocationAddress()
        auxLocation[self.dbu.DBH_LOCATION_COORD]   = self.getLocationCoordinates()
        auxLocation[self.dbu.DBH_LOCATION_TYPE]    = self.getLocationType()
        
        // inserts this variable for update only if it is valid
        if let device:Device = self.getLocationDevice(){
            auxLocation[self.dbu.DBH_LOCATION_DEVICE]  = device.getPointerToDatabaseTable()
        }
    }
    
    
    // QUERIESs
    override class func query() -> PFQuery? {
        let query = PFQuery(className: Location.parseClassName())
        
        return query
    }
    
    
    
    /*
        Returns a query to get all the devices associated within an user
    */
    internal func getAllUserLocations(_ user:PFUser) -> PFQuery? {
        
        let userLocationQuery = PFQuery(className: self.dbu.DB_CLASS_LOCATION)
        userLocationQuery.includeKey(self.dbu.DBH_LOCATION_ADMIN)
        userLocationQuery.whereKey(self.dbu.DBH_LOCATION_ADMIN, equalTo: user)
        
        return userLocationQuery
    }
    
    
    /*
        Returns an object to create a relationship between a user and a location
    */
    internal func getUserLocationRelObject(_ user:PFUser) -> PFObject {
        
        let userLocationObject = PFObject(className: self.dbu.DB_REL_USER_LOCATION)
        let locPointer = self.getPointerToLocationTable()
        
        userLocationObject[self.dbu.DBH_REL_USER_LOCATION_USER]     = user
        userLocationObject[self.dbu.DBH_REL_USER_LOCATION_LOCATION] = locPointer
        
        return userLocationObject
    }
    
    
    /*
        Get a all ocurrences of a user related to a location
    */
    internal func getUserLocationQuery(_ user:PFUser) -> PFQuery? {
        let userLocationQuery = PFQuery(className: self.dbu.DB_REL_USER_LOCATION)
        
        userLocationQuery.includeKey(self.dbu.DBH_REL_USER_LOCATION_USER)
        userLocationQuery.whereKey(self.dbu.DBH_REL_USER_LOCATION_USER, equalTo: user)
        
        return userLocationQuery
    }
}


// Respect the PFSubclassing protocol
extension Location: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Location"
    }
    
    override class func initialize() {
        // Let Parse know that you intend to use this subclass for all objects with class type Location.
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}
