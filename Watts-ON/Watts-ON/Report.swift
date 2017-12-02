//
//  Report.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

/*
    Report

    This class build reports based on established goals, creating information about the current day and week, both reports are based directly on a current Goal, that still opened.

    This class also build reports based on months and years, in this case the values used to build the report are closed Goals related to a Device
*/

import UIKit

class Report: PFObject {
    
    
    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    @NSManaged var location: Location?
    @NSManaged var year: NSNumber?
    @NSManaged var month: NSNumber?
    @NSManaged var pred_watts: NSNumber?
    @NSManaged var real_watts: NSNumber?
    @NSManaged var pred_bill: NSNumber?
    @NSManaged var real_bill: NSNumber?
    @NSManaged var distance: NSNumber?
    
    
    // CONSTRUCTORS
    convenience init(report:PFObject, location:Location){
        
        let dbu:DBUtils = DBUtils()
        
        if let id:String = report.objectId{
            
            var year:NSNumber = NSNumber()
            if let yr:NSNumber = report[dbu.DBH_REPORT_YEAR] as? NSNumber{
                year = yr
            }
            
            var month:NSNumber = NSNumber()
            if let mth:NSNumber = report[dbu.DBH_REPORT_MONTH] as? NSNumber{
                month = mth
            }
            
            var pred_watts = NSNumber()
            if let pw = report[dbu.DBH_REPORT_PRED_WAT] as? NSNumber{
                pred_watts = pw
            }
            
            var real_watts = NSNumber()
            if let rw = report[dbu.DBH_REPORT_REAL_WAT] as? NSNumber{
                real_watts = rw
            }
            
            var pred_bill = NSNumber()
            if let pb = report[dbu.DBH_REPORT_PRED_BILL] as? NSNumber{
                pred_bill = pb
            }
            
            var real_bill = NSNumber()
            if let rb = report[dbu.DBH_REPORT_REAL_BILL] as? NSNumber{
                real_bill = rb
            }
            
            var distance = NSNumber()
            if let d = report[dbu.DBH_REPORT_DISTANCE] as? NSNumber{
                distance = d
            }
            
            self.init(
                objectId   :id,
                device     :location,
                year       :year,
                month      :month,
                pred_watts :pred_watts,
                real_watts :real_watts,
                pred_bill  :pred_bill,
                real_bill  :real_bill,
                distance   :distance
            )
            
        }else{
            self.init()
        }
    }

    init(objectId:String?, device:Location?, year:NSNumber?, month:NSNumber?, pred_watts:NSNumber?, real_watts:NSNumber?, pred_bill:NSNumber?, real_bill:NSNumber?, distance:NSNumber?) {
        super.init()
        
        self.setObId(objectId)
        self.setReportLocation(location)
        self.setReportYear(year)
        self.setReportMonth(month)
        self.setPredWatts(pred_watts)
        self.setRealWatts(real_watts)
        self.setPredBill(pred_bill)
        self.setRealBill(real_bill)
        self.setDistanceFromGoal(distance)
    }
    
    override init() {
        super.init()
    }
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        print("report id is now: \(id)")
        self.objId = id
    }

    internal func setReportLocation(_ location:Location?){
        print("report  location is now: \(location)")
        self.location = location
    }
    
    internal func setReportYear(_ year:NSNumber?){
        print("report year \(year)")
        self.year = year
    }
    
    internal func setReportMonth(_ month:NSNumber?){
        print("report month is now \(month)")
        self.month = month
    }
    
    internal func setPredWatts(_ pred_watts:NSNumber?){
        print("report pred watts is now: \(pred_watts)")
        self.pred_watts = pred_watts
    }
    
    internal func setRealWatts(_ real_watts:NSNumber?){
        print("report real watts is now: \(real_watts)")
        self.real_watts = real_watts
    }
    
    internal func setPredBill(_ pred_bill:NSNumber?){
        print("report pred bill is now: \(pred_bill)")
        self.pred_bill = pred_bill
    }
    
    internal func setRealBill(_ real_bill:NSNumber?){
        print("report real bill is now: \(real_bill)")
        self.real_bill = real_bill
    }
    
    internal func setDistanceFromGoal(_ distance:NSNumber?){
        print("report distance is now: \(distance)")
        self.distance = distance
    }
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getLocation() -> Location?{
        if let location:Location = self.location{
            return location
        }else{
            return nil
        }
    }
    
    internal func getYear() -> NSNumber?{
        if let year:NSNumber = self.year{
            return year
        }else{
            return nil
        }
    }
    
    internal func getMonth() -> NSNumber?{
        if let month:NSNumber = self.month{
            return month
        }else{
            return nil
        }
    }
    
    internal func getPredWatts() -> NSNumber{
        if let pred_watts:NSNumber = self.pred_watts{
            return pred_watts
        }else{
            return -1
        }
    }
    
    internal func getRealWatts() -> NSNumber{
        if let real_watts:NSNumber = self.real_watts{
            return real_watts
        }else{
            return -1
        }
    }
    
    internal func getPredBill() -> NSNumber{
        if let pred_bill:NSNumber = self.pred_bill{
            return pred_bill
        }else{
            return -1
        }
    }
    
    internal func getRealBill() -> NSNumber{
        if let real_bill:NSNumber = self.real_bill{
            return real_bill
        }else{
            return -1
        }
    }
    
    internal func getDistance() -> NSNumber{
        if let distance:NSNumber = self.distance{
            return distance
        }else{
            return -1
        }
    }
    
    
    // QUERIES
    /*
        Return a new Report PFObject, ready to be saved on the backend table
    */
    internal func getNewReport() -> PFObject{
        let report:PFObject = PFObject(className: self.dbu.DB_CLASS_REPORT)
    
        report[self.dbu.DBH_REPORT_DISTANCE]  = self.getDistance()
        report[self.dbu.DBH_REPORT_LOCATION]  = self.getLocation()?.getPointerToLocationTable()
        report[self.dbu.DBH_REPORT_YEAR]      = self.getYear()
        report[self.dbu.DBH_REPORT_MONTH]     = self.getMonth()
        report[self.dbu.DBH_REPORT_PRED_BILL] = self.getPredBill()
        report[self.dbu.DBH_REPORT_REAL_BILL] = self.getRealBill()
        report[self.dbu.DBH_REPORT_PRED_WAT]  = self.getPredWatts()
        report[self.dbu.DBH_REPORT_REAL_WAT]  = self.getRealWatts()

        return report
    }
    
    
    /*
        Returns a query to get the device reports, the processing of the incoming data is done 
        on the controller layer
    */
    class func DeviceReportQuery(_ device:PFObject) -> PFQuery? {
        
        let DeviceReportQuery = PFQuery(className: Report.parseClassName())
        DeviceReportQuery.includeKey("device")
        DeviceReportQuery.whereKey("device", equalTo: device)
        
        return DeviceReportQuery
    }
    
    
    /*
        Update the selected report and send a status information back to the controller
    */
    internal func upsertDeviceReportQuery(_ device:PFObject) -> PFQuery? {
        
        let query = PFQuery(className:Report.parseClassName())
        query.includeKey(self.dbu.DBH_REPORT_LOCATION)
        query.whereKey(self.dbu.DBH_REPORT_LOCATION, equalTo: device)
        
        return query
    }
    
}


// Respect the PFSubclassing protocol
extension Report: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Report"
    }
    
    override class func initialize() {
        // Let Parse know that you intend to use this subclass for all objects with class type Report.
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}
