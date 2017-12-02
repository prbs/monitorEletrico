//
//  SystemInitializationViewController.swift
//  x
//
//  Created by Diego Silva on 10/29/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class SystemInitializer: BaseViewController {

    
    // VARIABLES AND CONSTANTS
    internal let dbu:DBUtils   = DBUtils()
    internal var lui:LoadInfoViewController? = nil
    internal var loadingWithOldSession:Bool  = false
    
    internal let entitiesToLoad         = ["datafiles","goals","devices"]
    internal var numLocations:Int       = 0
    internal var numDevices:Int         = 0
    
    internal var locationFilesCount:Int = 0
    internal var locationGoalsCount:Int = 0
    internal var devicesCounter:Int     = 0
    
    internal var totalNumAssets:Int     = 0
    internal var loadedAssets:Int       = 0
    
    internal var doneWithDatafiles:Bool = false
    internal var doneWithGoals:Bool     = false
    internal var doneWithDevices:Bool   = false
    internal var done:Bool              = false
    
    // make sure the page is going be presented at least for n seconds
    internal let MINIMUM_LOADING_TIME:Int   = 2
    internal var secsCounter:Int            = 0
    
    // variables related to the datafile server
    internal let DATA_UPDATE_INTERVAL:Double = 100000 // in seconds
    
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    /*
        Gather system global variables sequencially, and redirect the user to the home page.
    */
    internal func initSystem(){
        print("Starting initializer ...")
        
        // check if the user is bypassing the login screen
        if(self.lui != nil){
            self.loadingWithOldSession = true
            self.lui?.loadingPercentage.text = "0%"
            self.lui?.startLoadingAnimation()
        }
        
        // start counting the loading time
        self.loadingTimer = Timer.scheduledTimer(
            timeInterval: 2,
            target   : self,
            selector : Selector("count"),
            userInfo : nil,
            repeats  : true
        )
        
        // start the initialization sequence for locations
        self.getAllUserLocations()
        
        // start initialization process for user devices
        self.getUserDevices()
    }
    
    // Loading time controller methods
    internal func count(){
        self.secsCounter += 1
        self.finishInitialization()
    }
    
    internal func stopCounting(){
        self.loadingTimer.invalidate()
        self.secsCounter = 0
    }
    
    
    
    
    // UI
    internal func updateLoadingStatus(_ asset:String){
        print("\nupdating loading process to the UI ...")
        
        self.loadedAssets += 1
        
        if(self.lui != nil){
            let perc = Int(Float(Float(self.loadedAssets)/Float(self.totalNumAssets)) * 100.0)
            
            if(perc == 100){
                self.lui?.setLoadingPercentage(perc, isLast:true, loadedAsset:asset)
            }else{
                self.lui?.setLoadingPercentage(perc, isLast:false, loadedAsset:asset)
            }
        }
    }
    
    
    
    
    // LOCATIONS AND DEPENDENCIES
    /*
        Get pointers to all locations related to the current user and start the loading process 
        of its dependencies
    */
    internal func getAllUserLocations(){
        
        print("\ngetting all user locations ...")
        
        PFCloud.callFunction(inBackground: "getAllUserLocations", withParameters: [
            "userId": PFUser.current()!.objectId!
        ]){
            (locs, error) in
            
            if (error == nil){
                if let locationIds:Array<AnyObject> = locs as? Array<AnyObject>{
                    print("found locations: \(locationIds)")
                    
                    if(locationIds.count > 0){
                        
                        // initialize the locations counter
                        self.numLocations = locationIds.count
                    
                        // create a estimative of the number of assets to load, used to let the user know what is happening
                        self.totalNumAssets += (locationIds.count * 4)
                    
                        // load each location into the userLocations list
                        for i in 0...(locationIds.count - 1) {
                            
                            if let locId = locationIds[i] as? String{
                                
                                self.loadUserLocation(locId)
                            }else{
                                print("weird, could not get location id as String")
                            }
                        }
                    }else{
                        
                        self.totalNumAssets += (1)
                        
                        // initialize the locations counter
                        self.doneWithDatafiles = true
                        self.doneWithDevices   = true
                        self.doneWithGoals     = true
                        
                        self.finishInitialization()
                    }
                }else{
                    print("problems converting cloud query result")
                }
            }else{
                print("\nunknown error: \(error)")
            }
        }
    }
    
    /*
        Get all locations pointed by the User_Location Relationship
    */
    internal func loadUserLocation(_ locationId:String){
        print("\ntrying to get location object by id ...")
        
        let query = Location.query()
        
        query?.getObjectInBackground(withId: locationId){
            (object, error) -> Void in
            
            if(error == nil){
                
                if let obj:PFObject = object{
                    
                    // update loading process status
                    if(self.locationFilesCount == 0){
                        self.updateLoadingStatus("locais")
                    }
                    
                    let location:Location = Location(location: obj)
                    
                    // only valid locations (locations that have an admin user are accepted)
                    if let adm = location.getLocationAdmin(){
                        
                        if let admId = adm.objectId{
                            self.getLocationAdmin(admId, location:location)
                        }else{
                            print("problems to get location adm id as a String")
                        }
                    }else{
                        print("location admin wasn't found, ignoring this location")
                        
                        self.locationFilesCount += 1
                        self.isEntityDoneLoadingObjects(self.entitiesToLoad[0])
                        
                        self.locationGoalsCount += 1
                        self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
                    }
                }else{
                    print("error, invalid location object")
                    
                    self.locationFilesCount += 1
                    self.isEntityDoneLoadingObjects(self.entitiesToLoad[0])
                    
                    self.locationGoalsCount += 1
                    self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
                }
            }else{
                print("error getting location object")
                
                self.locationFilesCount += 1
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[0])
                
                self.locationGoalsCount += 1
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
            }
        }
        
    }

    
    /*
        Get location admin information
    */
    internal func getLocationAdmin(_ userId:String, location:Location){
        print("\ngetting location admin ...")
        
        // get location admin
        let query:PFQuery = User.query()!
        
        query.getObjectInBackground(withId: userId){
            (user: PFObject?, error: NSError?) -> Void in
            
            if(error == nil && user != nil){
                
                if let admin:PFUser = user as? PFUser {
                    
                    self.updateLoadingStatus("")
                    
                    // set location admin
                    let user:User = User(user:admin)
                    location.setLocationAdmin(user)
                    
                    // check if the location isn't already loaded in the user locations (bug fix for repeated locations problem)
                    var checkEqual = false
                    
                    for i in 0...DBHelpers.userLocations.count{
                        
                        if(DBHelpers.userLocations[i]?.getObId() == location.getObId()){
                            
                            print("trying to load location twice ...")
                            checkEqual = true
                        }
                    }
                    
                    // if everything is ok, start initialization of location dependencies
                    if(!checkEqual){
                        
                        print("location being loaded \(location.getObId()) ...")
                        DBHelpers.userLocations[DBHelpers.userLocations.count] = location
                    
                        print("setting alert message controller for location \(location.getObId()) ...")
                        DBHelpers.alertMsgController[location.getObId()] = false
                        
                        print("\ninitializing location \(location.getObId()) datafile ...")
                        self.initializeLocalDatafile(location)
                    
                        print("\nloading location \(location.getObId()) goals ...")
                        self.loadOpennedGoal(location)
                    }
                    
                }else{
                    print("problems unwrapping admin user PFObject")
                    
                    self.locationFilesCount++
                    self.isEntityDoneLoadingObjects(self.entitiesToLoad[0])
                    
                    self.locationGoalsCount++
                    self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
                }
            } else {
                print("problems to get location admin \(error)")
                
                self.locationFilesCount++
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[0])
                
                self.locationGoalsCount++
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
            }
        }
        
    }
    
    
    
    
    // INITIALIZE LOCAL DATAFILE
    /*
        Initialize local datafile
    */
    internal func initializeLocalDatafile(_ location:Location){
        
        // update loading process status
        if(self.locationFilesCount == 0){
            self.updateLoadingStatus("arquivos de dados")
        }
        
        // initialize a new datafile manager
        DBHelpers.locationDataObj[location.getObId()] = Readings(locationId: location.getObId())
        
        // create a new history file if the file doesn't exist
        if(DBHelpers.locationDataObj[location.getObId()]!!.isFileOk() == false){
            
            print("history file does not exist, creating a new file ...")
            DBHelpers.locationDataObj[location.getObId()]!!.save()
        }
        
        // try to update the local datafile with content from the cloud datafile
        if(location.getLocationData() != nil){
            print("trying to update the local datafile ...")
            
            location.getLocationData()!.getDataInBackground(block: {
                (data, error) -> Void in
                    
                if let data = data, error == nil{
                    
                    print("found datafile for this location")
                    DBHelpers.locationDataObj[location.getObId()]!!.replaceCurrentHistoryFile(data)
                }else{
                    print("error getting updated datafile from app backend")
                }
            })
        }else{
            print("cloud datafile for this location is null.")
        }
        
        self.locationFilesCount += 1
        self.isEntityDoneLoadingObjects(self.entitiesToLoad[0])
    }
    
    
    
    // LOAD OPENED LOCATION GOALS
    /*
        Checks the existency of an openned goal, the device and the current user, if there is
        call method to initilize the fields
    */
    internal func loadOpennedGoal(_ location:Location){
        print("\nchecking for opened goal-location relationship ...")
        
        let aux:Goal = Goal()
        let query = aux.openedGoalForLocation(location)
        
        query.findObjectsInBackground{
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if(error == nil){
                
                if(objects!.count > 0){
                    
                    if let goalObj:PFObject = objects!.first as? PFObject{
                        
                        let goalId:PFObject =  goalObj[self.dbu.DBH_REL_USER_GOALS_GOAL] as! PFObject
                        
                        print("found opened goal ...")
                        self.locationGoalsCount++
                        
                        self.getGoal(goalId.objectId!, location:location)
                    }
                }else{
                    
                    // update UI
                    if(self.locationGoalsCount == 0){
                        self.updateLoadingStatus("objetivos")
                    }
                    
                    print("no opened goal relationship found for this location")
                    self.locationGoalsCount++
                    
                    // check if the goals loading process is done
                    self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
                }
            }else{
                print("there was a connection error \(error?.description)")
                self.locationGoalsCount++
                
                // check if the goals loading process is done
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
            }
        }
    }
    
    
    /*
        Get a goal from the backend by using a pointer from the user-goal-device relationship
    */
    internal func getGoal(_ goalId:String, location:Location){
        
        print("\ngetting goal object \(goalId) from backend ...")
        
        let aux:Goal = Goal()
        let query = aux.selectGoalQuery()
        
        query?.getObjectInBackground(withId: goalId){
            (object, error) -> Void in
            
            if(error == nil){
                print("loading goal \(object) ...")
                
                // insert goal for location
                DBHelpers.locationGoals[location.getObId()] = Goal(goal: object!)
                
                // update UI
                self.updateLoadingStatus("")
                
                // check if the goals loading process is done
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
            }else{
                print("error performing query to get goal")
                
                // check if the goals loading process is done
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[1])
            }
        }
    }

    
    // LOAD USER DEVICES
    /*
        Loading user devices
    */
    internal func getUserDevices(){
        print("\ngetting user devices ...")
        
        let query:PFQuery = Device.getAllUserDevices(PFUser.current()!)!
        
        query.findObjectsInBackground{
            (objects, error) -> Void in
            
            if(error == nil){
                
                if(objects!.count > 0){
                    
                    print("user devices: \(objects)")
                    
                    // set the total number of devices
                    self.numDevices = objects!.count
                    self.totalNumAssets += objects!.count
                    
                    for i in 0...(self.numDevices - 1){
                        
                        if let userDevObj = objects![i] as? PFObject{
                            
                            if let dev:PFObject = userDevObj[self.dbu.DBH_REL_USER_ENVIR_DEVICE] as?PFObject{
                                
                                self.getDevice(dev.objectId!)
                            }else{
                                print("problem getting PFObject out of User_Device relation obj")
                            }
                        }
                    }
                }else{
                    print("no device found, finishing device initialization process ...")
                    
                    self.doneWithDevices = true
                    self.finishInitialization()
                }
            }else{
                print("Error getting a list of your devices.")
                
                self.doneWithDevices = true
                self.finishInitialization()
            }
        }
    }
    
    
    /*
        Get user devices
    */
    internal func getDevice(_ deviceId:String){
        
        print("\ntrying to get user device ...")
        
        self.devicesCounter += 1
        
        let query = Device.query()
        query?.getObjectInBackground(withId: deviceId){
            (device: PFObject?, error: NSError?) -> Void in
            
            if(error == nil){
                print("loading device \(device) ...")
                
                // update loading process status
                if(self.devicesCounter == 0){
                    self.updateLoadingStatus("dispositivos")
                }
                
                // unwrap server values and check ownership
                if let dev = device{
                    
                    if let devAdmin = dev["admin"]{
                        
                        if(devAdmin.objectId == PFUser.current()!.objectId){
                            DBHelpers.userDevices[DBHelpers.userDevices.count] = Device(device:device!)
                        }
                    }else{
                        print("error getting device admin")
                    }
                }else{
                    print("error converting device to PFObject")
                }
                
                // check if the user devices loading process is done
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[2])
            }else{
                print("\nerror performing query to get device")
                
                // check if the user devices loading process is done
                self.isEntityDoneLoadingObjects(self.entitiesToLoad[2])
            }
        }
        
    }
    
    
    
    /*
        Finish condition block for entity X. Check if the entity X is done loading its objects from
        the database.
    
        input:
            * The entity, ('datafiles' or 'locationGoals' or 'userDevices')
    */
    internal func isEntityDoneLoadingObjects(_ entity:String) -> Void{
        
        switch entity{
            
            // datafiles
            case self.entitiesToLoad[0]:
                
                print("\nchecking if it is done loading location files ...")
                print("\(self.locationFilesCount)")
                print("\(self.numLocations)")
                
                if((self.numLocations == self.locationFilesCount) && !self.doneWithDatafiles){
                    self.doneWithDatafiles = true
                    self.finishInitialization()
                }else{
                    print("We still have to load more datafile managers ...")
                }
            
            // goals
            case self.entitiesToLoad[1]:
                
                print("\nchecking if it is done loading location goals ...")
                print("\(self.locationGoalsCount)")
                print("\(self.numLocations)")
                
                if((self.numLocations == self.locationGoalsCount) && !self.doneWithGoals){
                    self.doneWithGoals = true
                    self.finishInitialization()
                }else{
                    print("We still have to load more goals ...")
                }
            
            // devices
            case self.entitiesToLoad[2]:
                
                print("\nchecking if it is done loading user devices ...")
                print("\(self.devicesCounter)")
                print("\(self.numDevices)")
                
                if((self.numDevices == self.devicesCounter) && !self.doneWithDevices){
                    self.doneWithDevices = true
                    self.finishInitialization()
                }else{
                    print("We still have to load more devices ...")
                }
            
            default:
                print("unrecognized entity.")
        }
    }
    
    
    
    /*
        Finish the initialization process by setting the current location, isAdmin, device, and 
        redirecting the user to the home screen
    */
    internal func finishInitialization(){
        
        print("\n\n\n >>>>>>>>> here \n\n\n")
        
        // if the loading process has passed the lower time limit
        if(self.secsCounter > self.MINIMUM_LOADING_TIME){
            
            // stop loading process seconds counter
            self.stopCounting()
        
            // if all global variables were properly initialized proceed to dashboard screen
            if(self.doneWithDevices && self.doneWithDatafiles && self.doneWithGoals && !self.done){
            
                
                // user without data
                if(self.locationFilesCount > 0){
                 
                    // choose current location
                    DBHelpers.currentLocation = DBHelpers.userLocations[0]
                    
                    // load isAdmin flag for current location
                    DBHelpers.updateCurUserLocAdminStatus()
                    
                    // get current location datafile manager
                    if let curLocData = DBHelpers.locationDataObj[DBHelpers.currentLocation!.getObId()]{
                        
                        DBHelpers.currentLocationData = curLocData
                        
                        if(DBHelpers.currentLocationData!.loadDataStructure()){
                            print("data structure for current datafile is initialized.")
                        }else{
                            print("problems building datastructure for current datafile.")
                        }
                    }
                    
                    // load goal for current location if there is one
                    if(DBHelpers.locationGoals[DBHelpers.currentLocation!.getObId()] != nil){
                        
                        DBHelpers.currentGoal = DBHelpers.locationGoals[DBHelpers.currentLocation!.getObId()]!
                    }
                    
                    // select the location device if there is one, and set the current device
                    if(DBHelpers.currentLocation!.getLocationDevice() != nil){
                        
                        // get the device pointer in the device variable of the location object
                        if let locDev:Device = DBHelpers.currentLocation!.getLocationDevice(){
                            
                            // select the location devices from the list of user's devices
                            if(DBHelpers.getDeviceByIdFromDevicesList(locDev.getObId()) != nil){
                                
                                DBHelpers.currentDevice = DBHelpers.getDeviceByIdFromDevicesList(locDev.getObId())
                            }else{
                                print("weird, the device pointed by current location is not in the list of user devices :( .")
                            }
                        }
                    }else{
                        print("current location doens't have a monitoring device attached to it.")
                    }
                    
                    // unlock the system
                    DBHelpers.lockedSystem = false
                }else{
                
                    // this is an empty initialization, lock the system
                    DBHelpers.lockedSystem = true
                }
                
                
                // set a timer to repeat the download data operation from dataserver for active devices
                DBHelpers.timer = Timer.scheduledTimer(
                    timeInterval: self.DATA_UPDATE_INTERVAL,
                    target: DBHelpers.self,
                    selector: "insertIntoDatafileWithCloudData",
                    userInfo: nil,
                    repeats: true
                )
                
                // finishes operation
                self.done = true
                
                // update user interface
                if(self.lui != nil){
                    self.updateLoadingStatus("quase pronto ...")
                    self.lui?.stopSpinner((self.lui?.spinner!)!)
                }
                
                // send user to the home page
                self.feu.goToSegueX(self.feu.ID_HOME, obj: PFUser.current()!)
                
            }else{
            
                if(self.doneWithDevices){
                    print("devices already loaded.")
                }
                if(self.doneWithDatafiles){
                    print("datafiles already loaded.")
                }
                if(self.doneWithGoals){
                    print("user goals already loaded.")
                }
            
                print("at the finish line waiting everybody :( ...\n\n")
            }
        }
    }
    
    
}
