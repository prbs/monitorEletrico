//
//  BeaconViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class BeaconViewController: BaseViewController {

    
    
    // VARIABLES
    @IBOutlet weak var beaconId: UITextField!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var minor: UITextField!
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var connectingOpResult: UILabel!
    @IBOutlet weak var connectingOpProgress: UIProgressView!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var toolBar: UIView!
    
    internal var location:Location?  = Location()
    internal var savedBeacon:Beacon? = Beacon()
    
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        // Data
        self.loadBeacons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconId.delegate = self
        self.major.delegate = self
        self.minor.delegate = self
        
        if(self.location != nil){
            print("location \(location?.getObId())")
            print("name \(location?.getLocationName())")
        }
    }

    
    
    // UI
    @IBAction func activateBeacon(_ sender: AnyObject) {
        print("activating beacons ...")
    }

    
    
    // LOGIC
    /* 
        Get all beacons that belong to the current device on the backend and load them into a set 
        of beacons
    */
    internal func loadBeacons(){
        print("\ntrying to load beacon data ...")
        
        if let device:Device = self.location?.getLocationDevice(){
            
            // create query to get all beacons attached to a device
            let query:PFQuery = Beacon.DeviceBeaconQuery(device)!
            query.findObjectsInBackground {
                (objects, error) -> Void in
                
                if(error == nil){
                    if let objects = objects as? [PFObject] {
                        print("found beacons \(objects)")
                    }
                }
            }
        }else{
            print("selected location doesn't have a device.")
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
