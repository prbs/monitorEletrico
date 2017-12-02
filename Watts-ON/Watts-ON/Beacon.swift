//
//  Beacon.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class Beacon: PFObject {
    

    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    @NSManaged var identifier: String?
    @NSManaged var major: String?
    @NSManaged var minor: String?
    @NSManaged var info: String?
    @NSManaged var location: Location?
    
    
    // CONSTRUCTORS
    convenience init(beacon:PFObject, beaconDevice:Device){
        
        let dbu:DBUtils = DBUtils()
        
        if let id:String = beacon.objectId{
            
            var identifier = dbu.STD_UNDEF_STRING
            if let idt = beacon[dbu.DBH_BEACON_IDENTI] as? String{
                identifier = idt
            }
            
            var major = dbu.STD_UNDEF_STRING
            if let mj = beacon[dbu.DBH_BEACON_MAJOR] as? String{
                major = mj
            }
            
            var minor = dbu.STD_UNDEF_STRING
            if let mn = beacon[dbu.DBH_BEACON_MINOR] as? String{
                minor = mn
            }
            
            var info:String = dbu.STD_UNDEF_STRING
            if let i = beacon[dbu.DBH_BEACON_INFO] as? String{
                info = i
            }
            
            var location:Location? = nil
            if let l = beacon[dbu.DBH_BEACON_LOCATI] as? Location{
                location = l
            }
            
            self.init(
                objectId   :id,
                identifier :identifier,
                major      :major,
                minor      :minor,
                info       :info,
                location   :location
            )

            
            
        }else{
            self.init()
        }
    }
    
    init(objectId:String?, identifier: String?, major: String?, minor: String?, info: String?, location: Location?) {
        super.init()
        
        self.setObId(objectId)
        self.setBeaconIdentifier(identifier)
        self.setBeaconMajor(major)
        self.setBeaconMinor(minor)
        self.setBeaconInfo(info)
        self.setBeaconLocation(location)
    }
    
    override init() {
        super.init()
    }
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        print("beacon id is now: \(id)")
        self.objId = id
    }
    
    internal func setBeaconIdentifier(_ identifier:String?){
        print("beacon identifier is now: \(identifier)")
        self.identifier = identifier
    }
    
    internal func setBeaconMajor(_ major:String?){
        print("beacon major is now: \(major)")
        self.major = major
    }
    
    internal func setBeaconMinor(_ minor:String?){
        print("beacon minor is now: \(minor)")
        self.minor = minor
    }
    
    internal func setBeaconInfo(_ info:String?){
        print("beacon info is now: \(info)")
        self.info = info
    }
    
    internal func setBeaconLocation(_ location:Location?){
        print("beacon location is now: \(location)")
        self.location = location
    }
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getBeaconIdentifier() -> String?{
        if let identifier:String = self.identifier{
            return identifier
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getBeaconMajor() -> String?{
        if let major:String = self.major{
            return major
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getBeaconMinor() -> String?{
        if let minor:String = self.minor{
            return minor
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getBeaconInfo() -> String?{
        if let info:String = self.info{
            return info
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getBeaconLocation() -> Location?{
        if let location:Location = self.location{
            return location
        }else{
            return nil
        }
    }
    
    
    // QUERIES
    /*
        Returns a query to get a device's beacons, the processing of the incoming data is done on the controller layer
    */
    class func DeviceBeaconQuery(_ device:PFObject) -> PFQuery? {
        print("\ngetting current device's beacon ...")
        
        let deviceBeaconQuery = PFQuery(className: Beacon.parseClassName())
        deviceBeaconQuery.includeKey("envir_id")
        deviceBeaconQuery.whereKey("envir_id", equalTo: device)
        
        return deviceBeaconQuery
    }
    
    
    /*
        Returns a query to update the object that called this method, in this case a Beacon object
    */
    internal func updateBeaconQuery() -> PFQuery? {
        print("\nUpdating beacon ...")
        
        let query = PFQuery(className:Goal.parseClassName())
        
        return query
    }
    
    
    /*
        Returns a query to delete the object that called this method, in this case a Beacon object
    */
    internal func deleteBeaconQuery() -> PFQuery?{
        print("\nDeleting beacon ...")
        
        let query = PFQuery(className:Beacon.parseClassName())
        
        return query
    }
    
}


// Respect the PFSubclassing protocol
extension Beacon: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Beacon"
    }
    
    
    // Let Parse know that you intend to use this subclass for all objects with class type Beacon.
    override class func initialize() {
        
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}


