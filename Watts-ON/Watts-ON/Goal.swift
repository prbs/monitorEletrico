//
//  Goal.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class Goal: PFObject {

    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    @NSManaged var starting_date: Date?
    @NSManaged var updated_date: Date?
    @NSManaged var ending_date: Date?
    @NSManaged var des_val: NSNumber?
    @NSManaged var act_val: NSNumber?
    @NSManaged var init_watts: NSNumber?
    @NSManaged var des_watts: NSNumber?
    @NSManaged var act_watts: NSNumber?
    @NSManaged var distance: NSNumber?
    @NSManaged var real_bill: NSNumber?
    @NSManaged var reward: String?
    @NSManaged var kwh: NSNumber?
    
    
    // CONSTRUCTORS
    convenience init(goal:PFObject){
        
        let dbu:DBUtils = DBUtils()
        
        if let id:String = goal.objectId{
            
            var init_watts = NSNumber()
            if let iw = goal[dbu.DBH_GOAL_INI_WATT] as? NSNumber{
                init_watts = iw
            }

            var des_val = NSNumber()
            if let dv = goal[dbu.DBH_GOAL_DES_VAL] as? NSNumber{
                des_val = dv
            }
            
            var des_watts = NSNumber()
            if let dw = goal[dbu.DBH_GOAL_DES_WATT] as? NSNumber{
                des_watts = dw
            }
            
            var starting_date = Date?()
            if let sd = goal.createdAt{
                starting_date = sd
            }else{
                starting_date = nil
            }
                    
            var updated_date = Date?()
            if let ud = goal.updatedAt{
                updated_date = ud
            }else{
                updated_date = nil
            }
                    
            var end_date = Date?()
            if let ed = goal[dbu.DBH_GOAL_END_DAT] as? Date{
                end_date = ed
            }else{
                end_date = nil
            }
                    
            var act_val = NSNumber()
            if let av = goal[dbu.DBH_GOAL_ACT_VAL] as? NSNumber{
                act_val = av
            }
            
            var act_watts = NSNumber()
            if let aw = goal[dbu.DBH_GOAL_ACT_WATT] as? NSNumber{
                act_watts = aw
            }
                    
            var distance = NSNumber()
            if let d = goal[dbu.DBH_GOAL_DISTANCE] as? NSNumber{
                distance = d
            }
                    
            var real_bill = NSNumber()
            if let rb = goal[dbu.DBH_GOAL_REAL_BIL] as? NSNumber{
                real_bill = rb
            }
                    
            var kww = NSNumber()
            if let k = goal[dbu.DBH_GOAL_KWH] as? NSNumber{
                kww = k
            }
            
            var reward:String = dbu.STD_UNDEF_STRING
            if let rew = goal[dbu.DBH_GOAL_REWARD] as? PFObject{
                if(rew.objectId != ""){
                    reward = rew.objectId!
                }
            }
            
            self.init(
                objectId   :id,
                createdAt  :starting_date,
                updatedAt  :updated_date,
                end_date   :end_date,
                des_val    :des_val,
                act_val    :act_val,
                init_watts :init_watts,
                des_watts  :des_watts,
                act_watts  :act_watts,
                distance   :distance,
                real_bill  :real_bill,
                reward     :reward,
                kwh        :kww
            )
            
        }else{
            self.init()
        }
    }
    
    init(objectId:String?, createdAt:Date?, updatedAt:Date?, end_date:Date?, des_val:NSNumber?, act_val:NSNumber?, init_watts:NSNumber?, des_watts:NSNumber?, act_watts:NSNumber?, distance:NSNumber?, real_bill:NSNumber?, reward:String, kwh:NSNumber?) {
        super.init()
        
        self.setObId(objectId)
        self.setStartingDate(createdAt)
        self.setLastUpdatedDate(updatedAt)
        self.setEndDate(end_date)
        self.setDesiredValue(des_val)
        self.setActualValue(act_val)
        self.setInitialWatts(init_watts)
        self.setDesiredWatts(des_watts)
        self.setActualWatts(act_watts)
        self.setDistanceFromGoal(distance)
        self.setRealBill(real_bill)
        self.setGoalReward(reward)
        self.setKWH(kwh)
    }
    
    override init() {
        super.init()
    }
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        //print("goal id is now: \(id)")
        self.objId = id
    }
    
    internal func setStartingDate(_ date:Date?){
        //print("goal start date is now: \(date)")
        self.starting_date = date
    }
    
    internal func setLastUpdatedDate(_ date:Date?){
        //print("goal last updated date is now: \(date)")
        self.updated_date = date
    }
    
    internal func setEndDate(_ date:Date?){
        //print("goal end date is now: \(date)")
        self.ending_date = date
    }
    
    internal func setDesiredValue(_ val:NSNumber?){
        //print("goal desired value is now: \(val)")
        self.des_val = val
    }
    
    internal func setActualValue(_ val:NSNumber?){
        //print("goal actual value is now: \(val)")
        self.act_val = val
    }
    
    internal func setDesiredWatts(_ watts:NSNumber?){
        //print("goal desired watts is now: \(watts)")
        self.des_watts = watts
    }
    
    internal func setInitialWatts(_ watts:NSNumber?){
        //print("goal initial watts is now: \(watts)")
        self.init_watts = watts
    }
    
    
    internal func setActualWatts(_ watts:NSNumber?){
        //print("goal actual watts is now: \(watts)")
        self.act_watts = watts
    }
    
    internal func setDistanceFromGoal(_ distance:NSNumber?){
        //print("goal distance is now: \(distance)")
        self.distance = distance
    }
    
    internal func setRealBill(_ bill:NSNumber?){
        //print("goal real bill is now: \(bill)")
        self.real_bill = bill
    }
    
    internal func setGoalReward(_ reward:String?){
        //print("reward id is now: \(reward)")
        self.reward = reward
    }
    
    internal func setKWH(_ kwh:NSNumber?){
        //print("kwh is now: \(kwh)")
        self.kwh = kwh
    }
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getStartingDate() -> Date?{
        if let date:Date = self.starting_date{
            return date
        }else{
            return nil
        }
    }
    
    internal func getLastUpdatedDate() -> Date?{
        if let date:Date = self.updated_date{
            return date
        }else{
            return nil
        }
    }
    
    internal func getEndDate() -> Date?{
        if let date:Date = self.ending_date{
            return date
        }else{
            return nil
        }
    }
    
    internal func getDesiredValue() -> NSNumber{
        if let val:NSNumber = self.des_val{
            return val
        }else{
            return -1
        }
    }
    
    internal func getActualValue() -> NSNumber{
        if let val:NSNumber = self.act_val{
            return val
        }else{
            return -1
        }
    }
    
    internal func getInitialWatts() -> NSNumber{
        if let watts:NSNumber = self.init_watts{
            return watts
        }else{
            return -1
        }
    }
    
    internal func getDesiredWatts() -> NSNumber{
        if let watts:NSNumber = self.des_watts{
            return watts
        }else{
            return -1
        }
    }
    
    internal func getActualWatts() -> NSNumber{
        if let watts:NSNumber = self.act_watts{
            return watts
        }else{
            return -1
        }
    }
    
    internal func getDistanceFromGoal() -> NSNumber{
        if let distance:NSNumber = self.distance{
            return distance
        }else{
            return -1
        }
    }
    
    internal func getRealBill() -> NSNumber{
        if let bill:NSNumber = self.real_bill{
            return bill
        }else{
            return -1
        }
    }
    
    internal func getReward() -> AnyObject?{
        if let reward:String = self.reward{
            let rewPointer = PFObject(outDataWithClassName:self.dbu.DB_CLASS_REWARD, objectId: reward)
            
            return rewPointer
        }else{
            return NSNull()
        }
    }
    
    internal func getRewardId() -> String?{
        if let reward:String = self.reward{
            return reward
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getKWH() -> NSNumber{
        if let kwh:NSNumber = self.kwh{
            return kwh
        }else{
            return -1
        }
    }
    
    /*
        Extract the days left by the current goal object
    */
    internal func getDaysLeft() -> Int?{
        
        if let start = self.getStartingDate(){
            if let end = self.getEndDate(){
                
                return Date.getDaysLeft(start, endDate: end)
            }
            return nil
        }
        return nil
    }
    
    
    
    
    // OTHER METHODS
    /*
        Get new Goal PFObject, ready to be saved in background
    */
    internal func getNewGoalPFObj() -> PFObject{
        let goal = PFObject(className:self.dbu.DB_CLASS_GOAL)
        
        goal[self.dbu.DBH_GOAL_DES_VAL]  = self.getDesiredValue()
        goal[self.dbu.DBH_GOAL_ACT_VAL]  = 0.0
        goal[self.dbu.DBH_GOAL_INI_WATT] = self.getInitialWatts()
        goal[self.dbu.DBH_GOAL_DES_WATT] = self.getDesiredWatts()
        goal[self.dbu.DBH_GOAL_ACT_WATT] = 0.0
        goal[self.dbu.DBH_GOAL_DISTANCE] = 0.0
        goal[self.dbu.DBH_GOAL_END_DAT]  = self.getEndDate()
        goal[self.dbu.DBH_GOAL_KWH]      = self.getKWH()
        goal[self.dbu.DBH_GOAL_REWARD]   = self.getReward()
        goal[self.dbu.DBH_GOAL_REAL_BIL] = -1
        
        return goal
    }
    
    
    /*
        Update the attributes of a PFObject with the attributes of a Goal object
    */
    internal func updateGoal(_ goalObj:PFObject){
        goalObj[self.dbu.DBH_GOAL_KWH]      = self.getKWH()
        goalObj[self.dbu.DBH_GOAL_END_DAT]  = self.getEndDate()
        goalObj[self.dbu.DBH_GOAL_DES_VAL]  = self.getDesiredValue()
        goalObj[self.dbu.DBH_GOAL_DES_WATT] = self.getDesiredWatts()
        goalObj[self.dbu.DBH_GOAL_REWARD]   = self.getReward()
        goalObj[self.dbu.DBH_GOAL_DISTANCE] = self.getDistanceFromGoal()
        
        goalObj[self.dbu.DBH_GOAL_ACT_VAL]  = self.getActualValue()
        goalObj[self.dbu.DBH_GOAL_ACT_WATT] = self.getActualWatts()
        goalObj[self.dbu.DBH_GOAL_REAL_BIL] = self.getRealBill()
    }
    
    
    /*
        Update the attributes of a Goal PFObject and archive it, change the status attribute
    */
    internal func closeGoal(_ goalObj:PFObject){
        
    }
    
    
    
    // QUERIES
    /*
        Returns a query to get the user goals, the processing of the incoming data is done on 
        the controller layer
    */
    class func UserGoalsQuery(_ user:PFUser, device:PFObject) -> PFQuery? {
        
        let userGoalsQuery = PFQuery(className: "User_Goals")
        userGoalsQuery.includeKey("username")
        userGoalsQuery.includeKey("goal")
        userGoalsQuery.includeKey("location")
        userGoalsQuery.whereKey("username", equalTo: user)
        userGoalsQuery.whereKey("location", equalTo: device)
        
        return userGoalsQuery
    }
    
    
    /*
        Selects a goal by its id on the Goal table
    */
    internal func selectGoalQuery() -> PFQuery? {
        let query = PFQuery(className:Goal.parseClassName())
        
        return query
    }

    
    
    /*
        Update the selected goal and send a status information back to the controller
    */
    internal func updateGoalQuery() -> PFQuery? {
        
        print("\nUpdating goal ...")
        let query = PFQuery(className:Goal.parseClassName())
        
        return query
    }
    
    
    /*
        Delete a given goal and send a status message back to the controller which called this method
    */
    internal func deleteGoalQuery() -> PFQuery?{
        
        print("\nDeleting goal ...")
        let query = PFQuery(className:Goal.parseClassName())
        
        return query
    }
    
    
    /*
        Return a PFQuery that checks if there isn't an opened goal for the current device
    */
    internal func openedGoalForLocation(_ location:Location) -> PFQuery{
        
        let userGoalsQuery = PFQuery(className: self.dbu.DB_REL_USER_GOALS)
        
        let locationPointer = location.getPointerToLocationTable()
        
        userGoalsQuery.includeKey(self.dbu.DBH_REL_USER_GOALS_LOCATION)
        
        userGoalsQuery.whereKey(self.dbu.DBH_REL_USER_GOALS_LOCATION, equalTo: locationPointer)
        
        userGoalsQuery.whereKey(
            self.dbu.DBH_REL_USER_GOALS_STATUS,
            equalTo: self.dbu.DBH_REL_USER_GOALS_POS_STAT[0] // opened
        )
        
        return userGoalsQuery
    }
    
    
    /*
        Returns a PFObject of the user-goal-location
    */
    internal func getUserGoalLocationObj(_ user:PFUser, location:PFObject, goal:PFObject) -> PFObject{
        
        let userGoalsDeviceRel = PFObject(className: self.dbu.DB_REL_USER_GOALS)
        
        userGoalsDeviceRel[self.dbu.DBH_REL_USER_GOALS_USER]     = user
        userGoalsDeviceRel[self.dbu.DBH_REL_USER_GOALS_LOCATION] = location
        userGoalsDeviceRel[self.dbu.DBH_REL_USER_GOALS_GOAL]     = goal
        userGoalsDeviceRel[self.dbu.DBH_REL_USER_GOALS_STATUS]   = self.dbu.DBH_REL_USER_GOALS_POS_STAT[0]
        // opened
        
        return userGoalsDeviceRel
    }
}


// Respect the PFSubclassing protocol
extension Goal: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Goal"
    }
    
    override class func initialize() {
        // Let Parse know that you intend to use this subclass for all objects with class type Goal.
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}


