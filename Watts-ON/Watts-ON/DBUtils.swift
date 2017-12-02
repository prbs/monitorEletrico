//
//  DBUtilitiesViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/8/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DBUtils: UIViewController {

    // DATASERVER 
    internal let SERVER_URL = "https://troca-dados-pedroclericuzi.c9.io/estrutura.php"
    
    
    // DATABASE FIELDS
    internal let DB_CLASS_USER      = "_User"
    internal let DBH_USER_PICTURE   = "picture"
    internal let DBH_USER_NAME      = "name"
    internal let DBH_USER_EMAIL     = "email"
    internal let DBH_USER_ACC_TYPE  = "account_type"
    internal let DBH_USER_IS_HOME   = "is_athome"
    internal let DBH_USER_USERNAME  = "username"
    internal let DBH_USER_REG_DATE  = "createdAt"
    
    internal let DB_CLASS_LOCATION    = "Location"
    internal let DBH_LOCATION_ADMIN   = "admin"
    internal let DBH_LOCATION_NAME    = "name"
    internal let DBH_LOCATION_COORD   = "coordinates"
    internal let DBH_LOCATION_ADDRESS = "address"
    internal let DBH_LOCATION_DEVICE  = "envir_brain"
    internal let DBH_LOCATION_DATA    = "data"
    internal let DBH_LOCATION_TYPE    = "type"
    
    internal let DB_CLASS_DEVICE   = "Envir_brain"
    internal let DBH_DEVICE_ADMIN  = "admin"
    internal let DBH_DEVICE_ACT_K  = "activation_key"
    internal let DBH_DEVICE_TYPE   = "type"
    internal let DBH_DEVICE_INFO   = "description"
    internal let DBH_DEVICE_LOCATE = "location"
    internal let DBH_DEVICE_STATUS = "status"
    internal let DBH_DEVICE_PAYMEN = "is_paymentok"
    
    internal let DB_CLASS_GOAL     = "Goal"
    internal let DBH_GOAL_END_DAT  = "end_date"
    internal let DBH_GOAL_DES_VAL  = "des_val"
    internal let DBH_GOAL_ACT_VAL  = "act_val"
    internal let DBH_GOAL_INI_WATT = "init_watts"
    internal let DBH_GOAL_DES_WATT = "des_watts"
    internal let DBH_GOAL_ACT_WATT = "act_watts"
    internal let DBH_GOAL_DISTANCE = "distance"
    internal let DBH_GOAL_REAL_BIL = "real_bill"
    internal let DBH_GOAL_REWARD   = "reward"
    internal let DBH_GOAL_KWH      = "kwh"
    
    internal let DB_CLASS_BEACON   = "Beacon"
    internal let DBH_BEACON_IDENTI = "identifier"
    internal let DBH_BEACON_MAJOR  = "major"
    internal let DBH_BEACON_MINOR  = "minor"
    internal let DBH_BEACON_INFO   = "description"
    internal let DBH_BEACON_LOCATI = "location"
    
    internal let DB_CLASS_REPORT      = "Report"
    internal let DBH_REPORT_LOCATION  = "location"
    internal let DBH_REPORT_YEAR      = "year"
    internal let DBH_REPORT_MONTH     = "month"
    internal let DBH_REPORT_PRED_WAT  = "pred_watts"
    internal let DBH_REPORT_REAL_WAT  = "real_watts"
    internal let DBH_REPORT_PRED_BILL = "pred_bill"
    internal let DBH_REPORT_REAL_BILL = "real_bill"
    internal let DBH_REPORT_DISTANCE  = "distance"
    
    internal let DB_CLASS_REWARD       = "Reward"
    internal let DBH_REWARD_CREATED_BY = "createdBy"
    internal let DBH_REWARD_TITLE      = "title"
    internal let DBH_REWARD_INFO       = "description"
    internal let DBH_REWARD_PICTURE    = "picture"
    internal let DBH_REWARD_AUDIENCE   = "audience"
    internal let DBH_REWARD_LIKES      = "likes"
    
    internal let DB_CLASS_TIP      = "Tip"
    internal let DBH_TIP_TITLE     = "title"
    internal let DBH_TIP_INFO      = "description"
    internal let DBH_TIP_COMMENT   = "comment"
    internal let DBH_TIP_PICTURE   = "picture"
    internal let DBH_TIP_MINI_PIC  = "mini_picture"
    
    internal let DB_REL_USER_DEVICE        = "User_Envir"
    internal let DBH_REL_USER_ENVIR_USER   = "username"
    internal let DBH_REL_USER_ENVIR_DEVICE = "envir_id"
    
    internal let DB_REL_USER_GOALS            = "User_Goals"
    internal let DBH_REL_USER_GOALS_USER      = "username"
    internal let DBH_REL_USER_GOALS_GOAL      = "goal"
    internal let DBH_REL_USER_GOALS_LOCATION  = "location"
    internal let DBH_REL_USER_GOALS_STATUS    = "status"
    internal let DBH_REL_USER_GOALS_POS_STAT  = ["opened","archived","closed"]
    
    
    internal let DB_REL_USER_REWARD         = "User_Like_Reward"
    internal let DBH_REL_USER_REWARD_USER   = "user"
    internal let DBH_REL_USER_REWARD_REWARD = "reward"
    
    internal let DB_REL_USER_LOCATION           = "User_Location"
    internal let DBH_REL_USER_LOCATION_USER     = "user"
    internal let DBH_REL_USER_LOCATION_LOCATION = "location"
    
    
    // GLOBAL VALUES (SHARED BETWEEN ALL TABLES AND/OR MODELS)
    internal let DBH_GLOBAL_ID      = "objectId"
    internal let DBH_GLOBAL_STA_DAT = "createdAt"
    internal let DBH_GLOBAL_UPD_DAT = "updatedAt"
    
    internal let STD_UNDEF_STRING   = "undefined"
    internal let DB_INNACTIVE_USER  = "qKcga1lQ5o"
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
    // METHODS
    /*
        compare two time strings that belong to the same day, using a defined separator to split the
        time labels.
    
        Format of the broken time:
        timeX[0] // hour
        timeX[1] // minutes
        timeX[2] // seconds
    
        Return:
            -1 = error
            0  = timeA is later than timeB
            1  = timeB is equal (hh:mm:ss) to timeB
            2  = timeB is later than timeA
    */
    internal func compareTimeLabels(_ timeALabel:String, timeBLabel:String) -> Int{
        
        // break the components of the timeA
        let timeA = timeALabel.characters.split{$0 == ":"}.map(String.init)
        
        // break the components of the timeB
        let timeB = timeBLabel.characters.split{$0 == ":"}.map(String.init)
        
        /*print("timeA[0] \(timeA[0]) - timeB[0] \(timeB[0])")
        print("timeA[1] \(timeA[1]) - timeB[1] \(timeB[1])")
        print("timeA[2] \(timeA[2]) - timeB[2] \(timeB[2])")*/
        
        if(timeA[0] > timeB[0]){
            return 0
        }else{
            // same hour
            if(timeA[0] == timeB[0]){
                
                if(timeA[1] > timeB[1]){
                    return 0
                }else{
                    
                    // same minute
                    if(timeA[1] == timeB[1]){
                        
                        if(timeA[2] > timeB[2]){
                            return 0
                        }else{
                            
                            // timeA is equal to timeB, to the seconds precision
                            if(timeA[2] == timeB[2]){
                                return 1
                            }
                        }
                        
                    }else{
                        return 2
                    }
                }
            }else{
                return 2
            }
        }
        
        return -1
    }
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // BI FILES
    /*
        History of readings: 
    
        The 'history.json' file keeps the readings since the first day the user started receiving
        data from the dataserver, or inserted reading data manually. This is a local file
    
        File example:
    
    {
        "deviceToken": "asdf1234",
        "sentByDeviceAt": "02-10-2015 -> 06:04",
        "readings": [
            {
                "01-10-2015": {
                    "06:00": 30,
                    "06:01": 26,
                    "06:02": 29
                }
            },
            {
                "02-10-2015": {
                    "06:00": 30,
                    "06:01": 27,
                    "06:02": 28
                }
            }
        ]
    }
    */
    
    
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

}
