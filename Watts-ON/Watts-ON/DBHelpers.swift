//
//  AccessControllUtilities.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/26/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit



class DBHelpers: BaseViewController {

    
    // VARIABLES AND CONSTANTS
    internal static var userRegType:String = ""
    internal static let USER_REG_TYPE_FACE:String = "REG_TYPE_FACE"
    internal static let USER_REG_TYPE_REGU:String = "REG_TYPE_REG"
    
    // Variables used to control the main user attributes
    internal static var userLocations:[Int:Location]       = [Int:Location]()
    internal static var locationDataObj:[String:Readings?] = [String:Readings?]()
    internal static var locationGoals:[String:Goal?]       = [String:Goal?]()
    internal static var alertMsgController:[String:Bool]   = [String:Bool]()
    internal static var userDevices:[Int:Device?]          = [Int:Device?]()

    // Variables used to control the main attributes of the entities currently loaded
    internal static var currentLocatinIdx:Int            = 0
    internal static var currentLocation:Location?        = nil
    internal static var isUserLocationAdmin:Bool         = false
    internal static var currentLocationData:Readings?    = nil
    internal static var currentDevice:Device?            = nil
    internal static var currentGoal:Goal?                = nil
    
    // Switches
    internal static var lockedSystem:Bool = false
    internal static var firstTime:Bool    = false
    
    // Temporary variables
    internal static var timer:Timer = Timer()
    
    // CONSTANTS
    internal static let SERV_ADDR:String  = "https://bolts-arduino-pedroclericuzi.c9users.io/"
    
    // Other stuff
    internal let dbu:DBUtils = DBUtils()
    
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    /*
        Initialize global variables with data gathered from 3 entry points of the system:
            # Register screen, (regular user)
            # Register screen, (admin user)
            # Login screen,    (user is only allowed to login with a location)
    
        Variables that must be initialized:
            // Current user is carried by PFUser.currentUser()
            * Load user locations
            * Pick a location to be the current location (first one)
            * Load the location data from the cloud, if initializing from login or create datafile 
              it is a new location
            * Load current Goal for current location, if there is one
            * Load 'isAdmin' tag to fastly say if the user is the admin of the current location or a regular user
    
    */
    class func initializeGlobalVariables(){
        print("initializing global variables ...")
        
        let initializer:SystemInitializer = SystemInitializer()
        initializer.initSystem()
    }
    
    
    /*
        Initialize the system activating the locked mode, this use mode allows only the creation of
        a new location
    */
    class func initializeInLockedMode(){
        DBHelpers.lockedSystem = true
        
        let feu:FrontendUtilities = FrontendUtilities()
        feu.goToSegueX(feu.ID_HOME, obj: NSObject())
    }
    
    
    /*
        Perform changes on the global variables considerating the newly created place
    */
    class func reinitializeGlobalVariables(_ location:PFObject){
        print("\ninitializing global controller variables with new location and dependencies ...")
        
        // create a Location object with the PFObject
        let loc = Location(location:location)
        
        // insert location into the user's locations array
        DBHelpers.userLocations[DBHelpers.userLocations.count] = loc
        
        // initialize a local datafile manager object
        DBHelpers.createDatafileManager(loc)
        
        // initializer the alert message controller
        DBHelpers.alertMsgController[loc.getObId()] = false
        
        // initialize a goal object
        DBHelpers.locationGoals[loc.getObId()] = nil
        
        // if this is the only user's location
        if(DBHelpers.userLocations.count == 1){
            
            //DBHelpers.currentLocatinIdx = DBHelpers.userLocations.count
            if let locIdx = DBHelpers.getLocationIndex(location){
                
                DBHelpers.currentLocatinIdx = locIdx
                
                DBHelpers.initializeCurrentInstanceVariables()
            }else{
                print("error, could not get location index")
            }
        }
    }
    
    
    /*
        Given a location object, this method returns the id of that location in the list of the user's locations
    */
    class func getLocationIndex(_ location:PFObject) -> Int?{
        
        let indexes = Array(DBHelpers.userLocations.keys)
        
        for idx in indexes{
            
            if let loc = DBHelpers.userLocations[idx]{
            
                if let locId = location.objectId{
                    
                    if(loc.getObId() == locId){
                        return idx
                    }
                }else{
                    print("could not get location id")
                }
            }else{
                print("could not get user location as a Location object")
            }
        }
        
        return nil
    }
    
    
    
    /*
        Set the global variables being manipulated by the system
    */
    class func initializeCurrentInstanceVariables(){
        print("\ninitializing current instance variables ...")
        
        // choose current location
        DBHelpers.currentLocation = DBHelpers.userLocations[DBHelpers.currentLocatinIdx]
        
        // unwrap current location object for safety
        if let curLoc = DBHelpers.currentLocation{
            
            // load isAdmin flag for current location
            let curLocAdmId = curLoc.getLocationAdmin()?.objectId
            
            // check if current user is the current location admin
            if(curLocAdmId == PFUser.current()?.objectId){
                DBHelpers.isUserLocationAdmin = true
            }
            
            // try to get current location data
            if let curLocData = DBHelpers.locationDataObj[curLoc.getObId()]{
                
                DBHelpers.currentLocationData = curLocData
            }
            
            // load goal for current location if there is one
            if let locationGoal = DBHelpers.locationGoals[curLoc.getObId()]{
                DBHelpers.currentGoal = locationGoal
            }
            
            // select the location device if there is one, and set the current device
            if(curLoc.getLocationDevice() != nil){
                
                print("current location device \(curLoc.getLocationDevice())")
                
                // get the device pointer in the device variable of the location object
                if let locDev:Device = curLoc.getLocationDevice(){
                    
                    // select one of the available devices to load its data in the system
                    if let locDevFromList = DBHelpers.getDeviceByIdFromDevicesList(locDev.getObId()){
                        
                        DBHelpers.currentDevice = locDevFromList
                    }else{
                        print("weird, the device pointed by current location is not in the list of user devices :( .")
                    }
                }
            }else{
                print("current location doens't have a monitoring device attached to it.")
            }
        }else{
            print("could not unwrap current location object")
        }
    }
    
    
    /*
        Reset the global variables to their initial state
    */
    class func resetGlobalVariables(){
        print("\nreseting global variables ...")
        
        DBHelpers.userLocations       = [Int:Location]()
        
        // unload current datafile structure to release memory
        if let _ = DBHelpers.currentLocation{
            DBHelpers.currentLocationData!.unloadDataStructure()
            DBHelpers.currentLocationData = nil
        }
        
        DBHelpers.currentLocation     = nil
        
        DBHelpers.isUserLocationAdmin = false
        
        DBHelpers.currentGoal         = nil
        
        DBHelpers.userDevices         = [Int:Device]()
        DBHelpers.currentDevice       = Device()
        
        // reset the user registration type to Facebook
        DBHelpers.userRegType  = ""
        
        // stop recursive datarequest for dataserver
        DBHelpers.timer.invalidate()
    }
    
    
    /*
        Show the status of the current location and dependencies
    */
    class func showCurrentLocationVariables(){
        print("\n\n\nCURRENT LOCATION VARIABLES")
        print("\nis user location adm? \(DBHelpers.isUserLocationAdmin)")
        print("\nlocation index:       \(DBHelpers.currentLocatinIdx)")
        print("\nlocation object:      \(DBHelpers.currentLocation)")
        
        if let loc = DBHelpers.currentLocation{
            print("\nlocation name \(loc.getLocationName())")
        }
        
        print("\nlocation datafile content:")
        if let locDataManager = DBHelpers.currentLocationData{
            locDataManager.showAllReadings()
        }else{
            print("current location data manager is null")
        }
        
        print("\nuser devices:    \(DBHelpers.userDevices)")
        print("\nlocation device: \(DBHelpers.currentDevice)")
        print("\nlocation goal:   \(DBHelpers.currentGoal)")
    }
    
    
    
    
    // LOGIC
    // User
    //-----
    /*
        Checks if a given user exists
    */
    internal func userExists(_ objectId:String) -> Bool{
        
        let queryUser = PFUser.query()
        queryUser!.whereKey("objectId", equalTo:objectId)
        
        if let users = queryUser!.findObjects(){
            
            if(users.count > 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    
    /*
        Create a free user account
    */
    class func freeAccountRegistration(_ email:String, name:String, password:String, profilePicture:PFFile?, sender:UIViewController){
        print("\nloading UI value into User Object ...")
        
        let dbu:DBUtils = DBUtils()
        let feu:FrontendUtilities = FrontendUtilities()
        
        // Parse threats the username variable as the primary key of the users table
        let user                    = User()
        user.username               = email
        user.email                  = email
        user.password               = password
        user[dbu.DBH_USER_NAME]     = name
        user[dbu.DBH_USER_ACC_TYPE] = feu.ACCOUNT_TYPES[1] // free
        
        if(profilePicture != nil) {
            user[dbu.DBH_USER_PICTURE] = profilePicture
        }
        
        print("user \(user)")
        
        user.signUpInBackground {
            (succeeded: Bool, error: NSError?) -> Void in
            
            if (succeeded && error == nil) {
                
                //feu.goToSegueX(feu.ID_HOME, obj: PFUser.currentUser()!)
                feu.goToSegueX(feu.ID_TUTORIAL, obj: NSObject())
                
                // initialize user global variables and redirect it to the tutorial screen
                DBHelpers.userRegType  = DBHelpers.USER_REG_TYPE_REGU
                DBHelpers.firstTime    = true
                DBHelpers.lockedSystem = true
            } else {
                print("Parse signup error: \(error) \n\(error!.userInfo)")
                
                let title = "Não foi possível cadastrar o usuário"
                let msg = "O usuário com o email informado já existe. \nEscolha outro email caso deseje criar uma nova conta."
                
                let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                
                sender.present(refreshAlert, animated: true, completion: nil)
                
                // remove facebook access token if there is one
                FBSDKAccessToken.setCurrent(nil)
                FBSDKProfile.setCurrent(nil)
            }
        }
    }
    
    
    /*
        Logout out from Facebook, Parse, and place the current screen to the LoginViewController
    */
    internal func logout(){
        
        // clean system variables for next user
        DBHelpers.resetGlobalVariables()
        
        // logout from Parse
        PFUser.logOut()
        
        // logout from Facebookx
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // go to login view
        self.feu.goToSegueX(self.feu.ID_LOGIN, obj: NSObject())
        
        print("logged out.")
    }
    
    
    
    /*
        Update the location admin status between the current user and the current location
    */
    class func updateCurUserLocAdminStatus(){
        print("\nupdateCurUserLocAdminStatus \(DBHelpers.currentLocation?.getLocationAdmin())")
        
        // check if the current user is the location admin
        if let locAdm:User = DBHelpers.currentLocation?.getLocationAdmin() as? User{
            
            if(locAdm.getObId() == PFUser.current()!.objectId){
                
                print("current user is location admin")
                DBHelpers.isUserLocationAdmin = true
            }else{
                print("current user isn't location admin")
                DBHelpers.isUserLocationAdmin = false
            }
        }else{
            print("problems to get location admin, weird, this location wasn't supposed to be loaded")
        }
    }
    
    
    
    /*
        Deletes admin status from devices
    */
    fileprivate func deleteAdminStatus(_ sender:UIViewController){
        
        print("\ndeleting session for current user ...")
        
        let querySessions:PFQuery = PFQuery(className: "_Session")
        querySessions.whereKey("user", equalTo: PFUser.current()!)
        querySessions.findObjectsInBackground {
            (objects, error) -> Void in
            
            // if search operaton succeds, checks the results
            if error == nil {
                print("\nSessions active for current user: \(objects!.count)")
                
                // if the device exists creates a relationship between the user and the device
                if(objects!.count > 0){
                    
                    for i in 1 ... objects!.count {
                        if let obj:PFObject = objects!.popLast() as? PFObject{
                            print("deleting session \(i): \(obj)")
                            
                            obj.deleteInBackground()
                            
                            // deletes the user data files
                            self.deleteLocalDataFiles()
                        }
                    }
                    
                    self.deleteCurrentUser(self)
                }else{
                    print("\nNo session available")
                    self.deleteCurrentUser(self)
                }
            }else{
                print("\nThere was an error connecting to the database")
            }
        }
    }

    
    /*
        Delete user, deletes all the relationships of the current user to all the other classes of the system and then deletes the user
    */
    internal func deleteAccount(_ sender:UIViewController){
        
        // reset the user registration type to Facebook
        DBHelpers.userRegType  = ""
        
        // Starts the chain of events of the deletion process
        self.deleteRelsToDevices(sender)
    }
    
    
    /*
        Deletes the current user from backend
    */
    fileprivate func deleteCurrentUser(_ sender:UIViewController){
        PFUser.current()!.deleteInBackground {
            (objects, error) -> Void in
            
            if(error ==  nil){
                self.feu.goToSegueX(self.feu.ID_LOGIN_SIGNUP, obj: NSObject())
            }else{
                print("Error deleting user")
            }
        }
    }
    
    
    /*
        Delete temporary users created in the registration process
    */
    internal func deleteTempUsers(){
        print("trying to delete temporary users ...")
        
        let auxUser = User()
        let query = auxUser.deleteTempUsersQuery()
        query.findObjectsInBackground {
            (objects, error) in
            
            print("temp users \(objects)")
            
            if(error == nil){
                for obj in objects!{
                    if let o:PFObject = obj as? PFObject{
                        if let user:PFUser = o as? PFUser{
                            
                            PFUser.logInWithUsername(inBackground: user.username!, password: "tempPass"){
                                object, error in
                                
                                if error == nil {
                                    print("deleting temp user: \(user)")
                                    
                                    user.deleteInBackground()
                                } else if let error = error {
                                    print("problem deleting temp user \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }else{
                print("problem getting temp users")
            }
        }
    }
    
    
    
    
    // Devices
    //--------
    /*
        Checks if the selected device is in the list of devices owned by the user
    */
    internal func isDeviceOwnedByUser(_ deviceAdmin:PFUser, user:PFUser) -> Bool{
        
        if(deviceAdmin.objectId == user.objectId){
            return true
        }else{
            return false
        }
    }
    
    
    /*
        Return the device specified by deviceId argument from the user devices list, or return nil
        if the device isn't in the list.
    */
    class func getDeviceByIdFromDevicesList(_ deviceId:String) -> Device?{
        
        for i in 0...DBHelpers.userDevices.count{
            
            // is in the user devices list?
            if(DBHelpers.userDevices[i] != nil){
                
                // is really a device?
                if let dev = DBHelpers.userDevices[i]{
                    
                    // the device you're looking for is really here?
                    if(dev?.getObId() == deviceId){
                        return dev
                    }
                }
            }
        }
        
        return nil
    }
    
    
    /*
        Deletes possible relationships between current user and devices
    */
    fileprivate func deleteRelsToDevices(_ sender:UIViewController){
        
        print("\ndeleting relationships between user and devices ...")
        
        let queryDevicesRels:PFQuery = PFQuery(className: "User_Envir")
        queryDevicesRels.whereKey("username", equalTo: PFUser.current()!)
        queryDevicesRels.findObjectsInBackground {
            (objects, error) -> Void in
            
            // if search operaton succeds, checks the results
            if error == nil {
                print("\nRelationships found for current user and devices: \(objects!.count)")
                
                // if the device exists creates a relationship between the user and the device
                if(objects!.count > 0){
                    
                    for i in 1 ... objects!.count {
                        if let obj:PFObject = objects!.popLast() as? PFObject{
                            print("relation \(i): \(obj)")
                            
                            obj.deleteInBackground()
                            
                            // deletes local datafiles
                            self.deleteLocalDataFiles()
                        }
                    }
                    
                    self.deleteRelsToGoals(sender)
                }else{
                    print("\nno relationships for current user")
                    self.deleteRelsToGoals(sender)
                }
            }else{
                print("\nthere was an error connecting to the database")
            }
        }
    }
    
    
    /*
        Delete the Relantionship User_Envir (user/device) of a given user
    */
    internal func deleteUserDeviceRelationship(_ user:PFUser, deviceId:String, vc:UIViewController){
        print("\ndeleting user/device relationship")
        print("user: \(user)")
        print("device id: \(deviceId)")
        
        let aux:Device = Device()
        let query = aux.deleteUserDeviceRelQuery(deviceId, user:PFUser.current()!)
        query!.findObjectsInBackground {
            (objects, error) -> Void in
            
            if(error == nil){
                if let obj:PFObject = objects!.first as? PFObject{
                    print("a relationship was found: \(obj)")
        
                    obj.deleteInBackground{
                        (success, error) -> Void in
        
                        if(error == nil){
                            
                            // get the device admin object
                            let query = Device.query()
                            query!.getObjectInBackground(withId: deviceId){
                                (fetDev, error) -> Void in
                                
                                if(error == nil){
                                    if let device:PFObject = fetDev{
                                        
                                        // try to get the admin user of the selected device
                                        if let pointerAdmin:PFUser = device[self.dbu.DBH_DEVICE_ADMIN] as? PFUser{
                                            
                                            // if user is admin of pointed object also changes the ownership of the device
                                            if(self.isDeviceOwnedByUser(pointerAdmin, user: user)){
                                                self.returnDeviceOwnershipToCompany(device, vc: vc)
                                            }else{
                                                if let deviceInfo = device[self.dbu.DBH_BEACON_INFO]{
                                                    self.infoWindow("Você não está mais ligado ao dispositivo '\(deviceInfo)'", title: "Operação concluída", vc: vc)
                                                }else{
                                                    self.infoWindow("Você não está mais ligado ao este dispositivo com o id \(device.objectId)", title: "Operação concluída", vc: vc)
                                                }
                                                
                                                self.feu.goToSegueX(self.feu.ID_SETTINGS, obj:self.feu.ID_SETTINGS)
                                            }
                                        }else{
                                            if let deviceInfo = device[self.dbu.DBH_BEACON_INFO]{
                                                self.infoWindow("Você não está mais ligado ao dispositivo '\(deviceInfo)'", title: "Operação concluída", vc: vc)
                                            }else{
                                                self.infoWindow("Você não está mais ligado ao este dispositivo com o id \(device.objectId)", title: "Operação concluída", vc: vc)
                                            }
                                            
                                            self.feu.goToSegueX(self.feu.ID_SETTINGS, obj:self.feu.ID_SETTINGS)
                                        }
                                    }
                                }
                            }
                            // end of inner query
                            
                        }else{
                            print("error, the was a connection problem and user still related to device")
        
                            self.infoWindow("Você ainda está associado ao dispositivo", title: "Falha operacional", vc: vc)
                        }
                    }
                }
            }else{
                print("There was a connection error getting the relationship object")
        
                self.infoWindow("Houve um erro de conexão, você ainda está associado ao dispositivo", title: "Falha operacional", vc: vc)
            }
        }
        
    }
    
    
    /*
        If an user whom is admin of a device, decides to delete it, the method below modify the device admin to a unique account which belongs to the company, the status is going to have now the status of 'innactive'.
    */
    fileprivate func returnDeviceOwnershipToCompany(_ device:PFObject, vc:UIViewController){
        print("\nadmin user is trying to delete the device")
        print("returning device ownership to company ...")
        print("selected device: \(device)")
        
        let aux:Device = Device()
        let userPointer = PFObject(outDataWithClassName:"_User", objectId: self.dbu.DB_INNACTIVE_USER)
        
        // changes the device's ownership
        aux.disengageDeviceFromUser(device, companyUser: userPointer)
        
        device.saveInBackground {
            (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                print("ownership successfuly changed")
                
                if let deviceInfo = device[self.dbu.DBH_BEACON_INFO]{
                    self.infoWindow("Você não está mais ligado ao dispositivo '\(deviceInfo)'", title: "Operação concluída", vc: vc)
                }else{
                    self.infoWindow("Você não está mais ligado ao este dispositivo com o id \(device.objectId)", title: "Operação concluída", vc: vc)
                }
                
                self.feu.goToSegueX(self.feu.ID_SETTINGS, obj:self.feu.ID_SETTINGS)
            } else {
                print("error saving changes on modified device")
            }
        }
    }
    
    
    
    // Goals
    //------
    /*
        Get a goal from the backend by using a pointer from the user-goal-device relationship
    */
    internal func getGoal(_ goalId:String){
        
        let aux:Goal = Goal()
        let query = aux.selectGoalQuery()
        query?.getObjectInBackground(withId: goalId){
            (object, error) -> Void in
            
            if(error == nil){
                print("loading current goal for update ...")
                
                DBHelpers.currentGoal = Goal(goal: object!)
                print("current goal: \(object)")
               
            }else{
                print("\nerror performing query to get goal")
                self.infoWindow("Houve um erro ao tentar obter o objetivo atual para este local", title: "Falha operacional", vc: self)
            }
        }
    }
    
    

    /*
        Calculate the distance between the current data and the current goal. The output is a
        normalized value between 0 and 1, being 0 excelent and 1 horrible.
    */
    internal func getDistanceOfGoal() -> Float? {
        
        if let curLocData = DBHelpers.currentLocationData{
            
            if(curLocData.getDays().count > 0){
                
                // get amount of watts spent
                let wattsSpent = self.getWattsSpentForCurrentGoal()
                
                // get perfect amount of watts should have been spent so far to achieve current goal
                if(self.getDesiredWattsForCurrentGoal() != -1){
                    
                    let desiredWatts = self.getDesiredWattsForCurrentGoal()
                    let distance:Float = Float(wattsSpent/desiredWatts)
                    
                    return distance
                }else{
                    print("error getting perfect amount of watts for current goal.")
                    return nil
                }
            }else{
                print("readings array is empty")
                return nil
            }
        }else{
            print("could not get current location data")
            return nil
        }
    }
    
    
    /*
        Get sum of watts spent from the first day of the goal until now
    */
    internal func getWattsSpentForCurrentGoal() -> Float{
        
        print("\ngetting watts spent for current goal")
        
        if(DBHelpers.currentLocationData!.getDays().count > 0){
            
            if let startDate:Date = DBHelpers.currentGoal?.getStartingDate() as Date?{
            
                if let endDate:Date = DBHelpers.currentGoal?.getEndDate() as Date?{
                    
                    // get the sum of the watts that were spent since the first day of the goal until now
                    let watts:Float = Float(DBHelpers.currentLocationData!.getWattsSpentInRange(
                        startDate, endDate:endDate
                        ))
                    
                    print("\nwatts spent for current goal \(watts)")
                    
                    return watts
                }else{
                    print("error, current goal doesn't have a due date")
                }
            }else{
                print("error, current goal doesn't have a start date")
            }
        }else{
            print("there are no readings on the datafile")
        }
        
        
        return -1
    }
    
    
    /*
        Get the amount of days to the end of the goal
    */
    internal func daysLeftEndOfGoal() -> Int{
        let startDate = Date()
        let endDate   = DBHelpers.currentGoal?.getEndDate()!
        
        return Date.getDaysLeft(startDate, endDate: endDate!)
    }
    
    
    /*
        Return the percentage of the amount defined by the current goal that was already spent
    */
    internal func getGoalPercentageSpent() -> NSNumber?{
        
        if(DBHelpers.currentGoal != nil){
            let plannedAmount  = DBHelpers.currentGoal?.getDesiredValue()
            
            if let estimatedValue:NSNumber = self.getEstimatedAmountToPay(){
                
                print("plannedAmount \(plannedAmount)")
                print("estimatedValue \(estimatedValue)")
                
                return NSNumber(value: (estimatedValue.doubleValue * 100.0)/plannedAmount!.doubleValue as Double)
            }else{
                print("problems getting estimated value")
                return nil
            }
        }else{
            print("current location has no active goal")
            return nil
        }
    }
    
    
    /*
        Return the amount of watts that should have been spent so far based on the current goal.
    
        The idea is to calculate the value by getting the average amount of watts per day, then
        multiplying that daily amount of watts per N days, since the start date until now.
    */
    internal func getDesiredWattsForCurrentGoal() -> Float{
        print("\ngetting the perfect consumption ...")
        
        // get the necessary dates to perform the operation
        if let startDate:Date = DBHelpers.currentGoal?.getStartingDate() as Date?{
            
            if let endDate:Date = DBHelpers.currentGoal?.getEndDate() as Date?{
            
                if let curDate:Date = Date(){
                    
                    let totalDays  = Float(Date.getDaysLeft(startDate, endDate: endDate))
                    let nDaysToday = Float(Date.getDaysLeft(startDate, endDate: curDate))
                    
                    // amount of watts the user defined for the current goal
                    if let desWatts:Float = Float((DBHelpers.currentGoal?.getDesiredWatts())!){
                        
                        // if startDate and endDate are the same
                        if(totalDays == 0.0){
                            return Float(desWatts)
                        }else{
                            var perfDailyAmount = Float(0)
                            
                            // if this is the first day of the current goal
                            if(nDaysToday == 0){
                                perfDailyAmount = Float((desWatts/totalDays) * 1.0)
                            }else{
                                perfDailyAmount = Float((desWatts/totalDays) * Float(nDaysToday))
                            }
                            
                            return perfDailyAmount
                        }
                    }else{
                        print("error getting desired amount of watts.")
                    }
                }else{
                    print("error getting current date")
                }
            }else{
                print("error getting end date")
            }
        }else{
            print("error getting start date")
        }
        
        return -1
    }
    
    
    /*
        Get estimated amount to pay
    */
    internal func getEstimatedAmountToPay() -> NSNumber{
        
        let wattsSpent = self.getWattsSpentForCurrentGoal()
        
        if(wattsSpent != -1){
            if let kwh = DBHelpers.currentGoal?.getKWH(){
                let result = Float(kwh) * Float(wattsSpent)
                
                return NSNumber(value: result as Float)
            }
        }
        
        return 0.0
    }
    
    
    /*
        Is goal finished?
    
        Check if the current goal is finished by looking at it endDate. Return true if is done,
        otherwise return false
    */
    internal func isCurrentGoalFinished() -> Bool{
    
        if(DBHelpers.currentGoal != nil){
            
            // get current date and the current goal due date and check the condition
            if let endDate:Date = DBHelpers.currentGoal?.getEndDate() as Date?{
                
                if let curDate:Date = Date(){
                  
                    if(Date.getDaysLeft(curDate, endDate: endDate) <= 0){
                        return true
                    }else{
                        return false
                    }
                }else{
                    print("error getting current date")
                }
            }else{
                print("error getting end date")
            }
        }else{
            print("current goal is null")
        }
        
        return false
    }
    
    
    /*
        Check if the current goal would finish with new values for dates
    */
    internal func isItToday(_ date:Date) -> Bool{
        print("\nchecking if the current goal would finish with new definitions ...")
        
        if let curDate:Date = Date(){
            let totalDays  = Float(Date.getDaysLeft(curDate, endDate: date))
            
            if(totalDays == 0){
                return true
            }
        }else{
            print("error getting current date")
        }
        
        return false
    }
    
    
    
    
    /*
        Deletes possible relationships between the current user and Goals
    */
    fileprivate func deleteRelsToGoals(_ sender:UIViewController){
        print("\ndeleting relationships between user and goals ...")
        
        /*
        let queryGoalsRels:PFQuery = PFQuery(className: self.dbu.DB_REL_USER_GOALS)
        
        // delete all goals that are related to the user
        queryGoalsRels.whereKey(
            self.dbu.DBH_REL_USER_GOALS_USER,
            equalTo: PFUser.currentUser()!
        )
        
        queryGoalsRels.findObjectsInBackgroundWithBlock {
            (var objects, error) -> Void in
            
            // if search operaton succeds, checks the results
            if error == nil {
                print("\nRelationships found for current user and goals: \(objects!.count)")
                
                if(objects!.count > 0){
                    for i in 1 ... objects!.count {
                        if let obj:PFObject = objects!.popLast() as? PFObject{
                            print("relation \(i): \(obj)")
                            
                            obj.deleteInBackground()
                        }
                    }
                    
                    self.deleteAdminStatus(self)
                }else{
                    print("\nNo relationships for current user")
                    self.deleteAdminStatus(self)
                }
            }else{
                print("\nThere was an error connecting to the database")
            }
        }*/
    }
    
    
    // Locations
    //----------
    /*
        Create a user Location
    */
    internal func createUserLocation(_ source:String){
        
        let location = PFObject(className:self.dbu.DB_CLASS_LOCATION)
        location.saveInBackground {
            (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                print("location successfully created ...")
                self.createRelationUserLocation(Location(location: location), source:source)
            } else {
                print("error creating new location")
                self.infoWindow("Houve um erro ao criar novo ambiente", title: "Erro operacional", vc: self)
            }
        }
    }
    
    
    /*
        Delete a user Location
    */
    internal func deleteUserLocation(_ location:Location){
        print("\ndeleting location object ...")
        
        // check if the location name is valid
        PFCloud.callFunction(inBackground: "deleteLocation", withParameters: [
            "locationId": location.getObId()
        ]) {
            (answer, error) in
            
            if (error == nil){
                if let result:Int = answer as? Int{
                    self.handleLocationRelationshipDeletion(result)
                }else{
                    print("unkown error: \(error)")
                }
            }
        }
    }

    
    /*
        Created the relationship between the current user and the device
    */
    internal func createRelationUserLocation(_ location:Location, source:String){
        print("\ntrying to create a relation between the user and the new location...")
        print("\(location.getObId())")
        
        let relObj = location.getUserLocationRelObject(PFUser.current()!)
        relObj.saveInBackground{
            (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                print("relationship between location and user was successfully created ...")
                
                if(source == self.feu.ID_CAD_KEY){
                    DBHelpers.initializeGlobalVariables()
                }
            } else {
                print("error creating relationshiop between user and new location")
                self.infoWindow("Houve um erro ao criar novo ambiente", title: "Erro operacional", vc: self)
            }
        }
    }

    
    /*
        Delete a relationship between the current user and a location
    */
    internal func deleteUserLocationRels(_ location:Location){
        print("\ntrying to delete a relationship between the current user and a location...")
        
        // check if the location name is valid
        PFCloud.callFunction(inBackground: "deleteUserLocationRelationship", withParameters: [
            "locationId": location.getObId(),
            "userId"    : PFUser.current()!.objectId!
        ]) {
            (answer, error) in
                
            if (error == nil){
                if let result:Int = answer as? Int{
                    self.handleLocationRelationshipDeletion(result)
                }else{
                    print("unkown error: \(error)")
                }
            }
        }
    }
    
    internal func deleteGoalLocationRel(_ location:Location){
        print("\ntrying to delete all relationships between a location and goals...")
        
        // check if the location name is valid
        PFCloud.callFunction(inBackground: "deleteLocationGoalsRelationships", withParameters: [
            "locationId": location.getObId(),
            "userId"    : PFUser.current()!.objectId!
        ]) {
            (answer, error) in
                
            if (error == nil){
                if let result:Int = answer as? Int{
                    self.handleLocationRelationshipDeletion(result)
                }else{
                    print("unkown error: \(error)")
                }
            }
        }
    }
    
    internal func deleteReportLocationRel(_ location:Location){
        print("\ntrying to delete all relationships between a location and reports...")
        
        // check if the location name is valid
        PFCloud.callFunction(inBackground: "deleteLocationReporstRelationships", withParameters: [
            "locationId": location.getObId(),
            "userId"    : PFUser.current()!.objectId!
        ]) {
            (answer, error) in
                
            if (error == nil){
                if let result:Int = answer as? Int{
                    self.handleLocationRelationshipDeletion(result)
                }else{
                    print("unkown error: \(error)")
                }
            }
        }
    }
    
    internal func deleteDeviceLocationRel(_ location:Location){
        print("\ntrying to delete all relationships between a location and devices...")
        
        // check if the location name is valid
        PFCloud.callFunction(inBackground: "deleteLocationDevicesRelationships", withParameters: [
            "locationId": location.getObId(),
            "userId"    : PFUser.current()!.objectId!
        ]) {
            (answer, error) in
            
            if (error == nil){
                if let result:Int = answer as? Int{
                    self.handleLocationRelationshipDeletion(result)
                }else{
                    print("unkown error: \(error)")
                }
            }
        }
    }
    
    internal func deleteBeaconLocationRel(_ location:Location){
        print("\ntrying to delete all relationships between a location and beacons...")
     
        // check if the location name is valid
        PFCloud.callFunction(inBackground: "deleteLocationBeaconsRelationships", withParameters: [
            "locationId": location.getObId()
        ]) {
            (answer, error) in
                
            if (error == nil){
                if let result:Int = answer as? Int{
                    self.handleLocationRelationshipDeletion(result)
                }else{
                    print("unkown error: \(error)")
                }
            }
        }
    }
    
    
    /*
        Location relationships deletion handling
    */
    internal func handleLocationRelationshipDeletion(_ result:Int){
        if(result <= 0){
            print("\ndeleted at least one relationship between the selected objects.")
        }else if(result == 1){
            print("no relationship was found.")
        }else if(result == 2){
            print("found relationship, but failed to delete it.")
        }else{
            print("unkown error.")
        }
    }
    
    
    /*
        Check if the current location has a device
    */
    internal func currentLocationHasDevice() -> Bool{
        print("\ncheking if the current location has a device ...")
        
        if let dev = DBHelpers.currentLocation?.getLocationDevice(){
            print("device id: \(dev.getObId())")
            
            return true
        }else{
            print("there is no device for this location.")
            
            return false
        }
    }
    
    
    /*
        Is an user's location
    */
    class func isUserLocation(_ locationId:String) -> Bool{
        
        for i in 0...(DBHelpers.userLocations.count - 1){
            
            if let location = DBHelpers.userLocations[i]{
            
                if(location.getObId() == locationId){
                    return true
                }
            }else{
                print("problem getting user location from DBHelpers.userLocations")
            }
        }
        
        return false
    }
    
    
    
    /*
        Execute the changes made by the user on the current goal, locally and on the app backend
    */
    internal func updateCurrentGoal(){
        print("\nupdate current goal locally and on the app backend ...")
        
        // update the current goal variables, related to the add reading operation
        DBHelpers.currentGoal?.setActualValue(self.getEstimatedAmountToPay())
        DBHelpers.currentGoal?.setActualWatts(self.getWattsSpentForCurrentGoal())
        DBHelpers.currentGoal?.setDistanceFromGoal(self.getDistanceOfGoal())
        
        // update current goal
        let aux:Goal = Goal()
        let query = aux.selectGoalQuery()
        
        query?.getObjectInBackground(withId: DBHelpers.currentGoal!.getObId()){
            (object, error) -> Void in
            
            if(error == nil){
                if let currentGoalObj = object{
                    
                    // update the newly created goal PFObject with the current goal information and save it on the app backend
                    DBHelpers.currentGoal?.updateGoal(currentGoalObj)
                    
                    currentGoalObj.saveInBackground {
                        (success, error) -> Void in
                        
                        if(success){
                            print("goal successfully updated")
                        }else{
                            print("error updating goal")
                        }
                    }
                }else{
                    print("problems converting found goal into PFObject")
                }
            }else{
                print("\nerror performing query to get goal")
            }
        }
    }
    
    
    
    /*
        Erase any data related to the current goal from the local datafile.
    */
    class func eraseGoalTraceFromDatafile(){
        
        
        if let goal = DBHelpers.currentGoal{
        
            // delete readings
            DBHelpers.currentLocationData?.deleteAllReadingsInPeriod(goal.getStartingDate()!, endDate:goal.getEndDate()!)
            
            // reset the goal for current location on the goals controller
            DBHelpers.locationGoals[(DBHelpers.currentLocation?.getObId())!] = nil
            
            // reset the 'sumReadingsVal' on the datafile manager of the current location
            DBHelpers.currentLocationData?.resetLastSumReadingVal()
            
            // erase current goal
            DBHelpers.currentGoal = nil
        }else{
            print("could not get current goal")
        }
    }
    
    
    
    // Files
    //------
    /*
        Initialize local datafile
    */
    internal func initializeLocalDatafile(_ location:Location){
        print("initializing local datafile ...")
        
        // initialize a new datafile manager
        DBHelpers.currentLocationData = Readings(locationId: location.getObId())
        
        // create a new history file if the file doesn't exist
        if(DBHelpers.currentLocationData!.isFileOk() == false){
            
            print("history file does not exist")
            DBHelpers.currentLocationData!.save()
        }else{
            print("history file already exist")
        }
        
        // try to update the local datafile with content from the cloud datafile
        if(location.getLocationData() != nil){
            
            location.getLocationData()!.getDataInBackground(block: {
                (data, error) -> Void in
                
                if let data = data, error == nil{
                    DBHelpers.currentLocationData!.replaceCurrentHistoryFile(data)
                }
            })
        }else{
            print("Cloud datafile for this location is null.")
        }
    }
    
    
    /*
        Create local datafile manager object
    */
    class func createDatafileManager(_ location:Location){
      
        // initialize system variable that controls all datafile manager with a new manager
        DBHelpers.locationDataObj[location.getObId()] = Readings(locationId: location.getObId())
        
        // create a new history file if the file doesn't exist
        if(DBHelpers.locationDataObj[location.getObId()]!!.isFileOk() == false){
            
            print("history file does not exist, creating a new file ...")
            DBHelpers.locationDataObj[location.getObId()]!!.save()
        }
        
        print("\ntrying to get datafile of the location that was just added ...")
        
        // trye to get the location data object
        if let locData = location.getLocationData(){
        
            // try get datafile object from the app backend
            locData.getDataInBackground(block: {
                (data, error) -> Void in
        
                if let data = data, error == nil{
                    print("found datafile for this location")
        
                    // try to get the location data object
                    if let locDataManager:Readings = DBHelpers.locationDataObj[location.getObId()]!{
        
                        // update the initialized data file with updated data for the added location that was get on the app backend
                        locDataManager.replaceCurrentHistoryFile(data)
        
                        // update system variable
                        DBHelpers.locationDataObj[location.getObId()] = locDataManager
        
                    }else{
                        print("could not get location data object")
                    }
                }else{
                    print("error getting updated datafile from app backend")
                }
            })
            
        }else{
            print("could not get added location data")
        }
    }
    

    
    /*
        Update the data attribute of location with the newly created data file
    */
    class func updateLocationData(_ locationId:String, dataManager:Readings){
        print("\ntrying to update location data...")
        
        let dbu:DBUtils = DBUtils()
        
        // get the location object from the app backend
        let query = Location.query()
        
        query?.getObjectInBackground(withId: locationId){
            (object, error) -> Void in
            
            if(error == nil){
                
                if let location:PFObject = object{
                    
                    // get local datafile
                    if let datafile:PFFile = dataManager.getDataFile(){
                    
                        // update the location object with the local datafile
                        location[dbu.DBH_LOCATION_DATA] = datafile
                        location.saveInBackground{
                            (success: Bool, error: NSError?) -> Void in
                            
                            if (success) {
                                print("data file successfully saved in app backend.")
                                
                                // update the local data file
                                dataManager.save()
                            } else {
                                print("error uploading datafile")
                            }
                        }
                    }else{
                        print("error getting local history datafile as PFFile")
                    }
                    
                }else{
                    print("error, invalid location object")
                }
            }else{
                print("error getting location object")
            }
        }
        
    }
    
    
    
    /*
        Deletes the current location datafile
    */
    internal func deleteLocalDataFiles(){
        
        if(DBHelpers.currentLocationData!.isFileOk()){
            DBHelpers.currentLocationData!.deleteDeviceHistoryFile()
        }else{
            print("Error deleting file, history file not found.")
        }
    }
    
    
    
    // DEVICE-DATASERVER METHODS
    /*
        Insert readings into local datafile with cloud data, by
    
            * Verify each user location for the existence of a device.
            * If the location has a device, call method 'downloadFromDataserver'
    */
    class func insertIntoDatafileWithCloudData(){
        print("\nTrying to insert dataserver content into datafiles...")
        
        // get each location object from the user locations array
        for i in 0...(DBHelpers.userLocations.count - 1){
                
            // get one of the user locations
            if let location:Location = DBHelpers.userLocations[i]{
                print("\nPlace: \(location.getLocationName())")
                
                if let locDataManager:Readings = DBHelpers.locationDataObj[location.getObId()]!{
                    
                    if let locDevice:Device = location.getLocationDevice(){
                        
                        // download file from dataserver and perform operations
                        DBHelpers.downloadFromDataserver(
                            locDevice,
                            location:location,
                            locDataManager: locDataManager
                        )
                        
                    }else{
                        print("\(location.getLocationName()) doesn't have an active monitoring device")
                    }
                }else{
                    print("problem converting a locationDataObj into a Readings object")
                }
            }else{
                print("location object from DBHelpers.userLocations[i], is null")
            }
        }
    }

    
    
    /*
        Call the url that build the updated json file in the dataserver
    */
    class func downloadFromDataserver(_ locDevice:Device, location:Location, locDataManager: Readings){
        
        // call this address to build json datafile of the selected device
        let url = URL(string: DBHelpers.SERV_ADDR + "estrutura.php/?id=" + locDevice.getObId())
        
        print("\nBuilding json file with the url: \(url) ...")
        
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main){
            (response, data, error) in
            
            if(error == nil){
                
                // get the file that was structure from the datafile server
                DBHelpers.getJsonFileFromDataserver(locDevice, location:location, locDataManager: locDataManager)
                
            }else{
                print("failed to update json file for device \(locDevice.getObId()).")
            }
        }
        
    }
    
    
    
    /*
        Download data from the dataserver for the location specified by the input id, try convert
        the datafile and insert it into a dictionary to a better manipulation.
    
        Return:
            * a dictionary, with the data structure contained in the datafile donwload from
            the dataserver.
            * nil, if the download or convertion failed.
    */
    class func getJsonFileFromDataserver(_ locDevice:Device, location:Location, locDataManager: Readings){
        
        // get updated json datafile from server
        let url = URL(string: DBHelpers.SERV_ADDR + locDevice.getObId() + ".json")
        
        
        print("\nDownloading updated json file from url: \(url) ...")
        
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main){
            (response, data, error) in
            
            if(error == nil){
                
                // get raw json file
                if let rawData:String = String(data: data!, encoding: String.Encoding.utf8)!{
                    
                    // serialize json file into a better data structure
                    let data = rawData.data(using: String.Encoding.utf8)
                    
                    do {
                        
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                            
                            if let structuredJson = jsonResult as? Dictionary<String, AnyObject> {
                                print("readings for device \(locDevice) \n\(structuredJson)")
                                
                                // insert data from dataserver file into local datafile and app backend
                                DBHelpers.appendReadingsToDatafile(
                                    structuredJson,
                                    location:location,
                                    locDataManager: locDataManager
                                )
                            }
                        }
                    } catch {
                        print("error trying to convert NSData into structured json dictionary")
                    }
                }else{
                    print("error getting raw json file")
                }
            }else{
                print("failed while getting reading data from dataServer")
            }
        }
    }
    
    
    
    
    /*
        Get a dictionary with the readings that came from the dataserver and insert into the local
        datafile, also upload the uptated file to the app backend
    */
    class func appendReadingsToDatafile(_ structuredJson:[String:AnyObject], location:Location, locDataManager:Readings){
    
        print("\nAppending readings to datafile ...")
        
        // get the day the file was sent to the dataserver
        if let updateDate = structuredJson["date"] as? String{
            
            // get the inputs in the datafile
            if let readings = structuredJson["readings"] as? [String: Double]{
                
                // insert the new inputs into the location datastructure
                if(locDataManager.appendReadingsOfDay(updateDate, newReadings: readings)){
                
                    print("here ...")
                    
                    // upload updated location datafile to app backend
                    DBHelpers.updateLocationData(location.getObId(), dataManager: locDataManager)
                    
                }else{
                    print("no need to update, there weren't new inputs")
                }
            }else{
                print("problem getting inputs from the datafile")
            }
        }else{
            print("problem getting update date from datafile")
        }
        
    }


    
    
    
    
    
    
    
    /*
    Reading file:
    
    This is the file that comes from the server with readings of a specific device
    
    File example:
    {
        "deviceToken": "asdf1234",
        "date": "02-10-2015",
        "time": "06:04",
        "readings": {
            "06:00": 30,
            "06:01": 26,
            "06:02": 29
        }
    }
    */
    
    
    
    /*
        Example of how to read the structure download from the dataserver.
    
        internal func readDataFromJsonServer(json:Dictionary<String, AnyObject>){
    
            if let token = json["deviceToken"] as? String{
                print("\ndevice token: \(token)")
            }
    
            if let updateDate = json["date"] as? String{
                print("file sent from device on: \(updateDate)")
            }
    
            if let updateTime = json["time"] as? String{
                print("at: \(updateTime)")
            }
    
            if let readings = json["readings"] as? [String: Int]{
                print("readings: \(readings)")
            }
    
        }
    */
    
    
}
