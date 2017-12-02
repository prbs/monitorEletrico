//
//  ListPlacesViewController.swift
//  x
//
//  Created by Diego Silva on 11/25/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit



class ListPlacesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils   = DBUtils()
    internal var availableLocations:Array<Location> = Array<Location>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView initialization
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isUserInteractionEnabled = false
        
        if let u:PFUser = PFUser.current(){
            let user:User = User(user:u)
            
            // load table view data
            self.getAllUserLocations(user)
        }else{
            print("problems to get current user as User object")
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
        Table methods
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharedPlaceTableViewCell") as! SharedPlaceTableViewCell
        
        // load the new cell with data
        cell.parentController = self
        cell.index            = indexPath
        
        // get the location out of the locations array to load the cell variables
        let location = self.availableLocations[indexPath.row]
        cell.location = location
        cell.placeName.text = location.getLocationName()
        
        // get location admin admin's name
        if let admPointer = location.getLocationAdmin(){
            let query:PFQuery = User.query()!
            query.getObjectInBackground(withId: admPointer.objectId!){
                (user, error) -> Void in
                
                if((user != nil) && (error == nil)){
                    if let u = user as? PFUser{
                        cell.adminName.text = u.username
                    }else{
                        print("problems converting user from app backend into PFObject")
                        cell.isOpaque = true
                    }
                }
            }
        }else{
            print("problems getting location admin")
        }
        
        // get number of users of the selected location
        PFCloud.callFunction(inBackground: "getNumberOfUsersLocation", withParameters: ["locationId": location.getObId()]) {
            (nUsers, error) in
            
            if (error == nil){
                if let numberOfUsers = nUsers as? Int {
                    cell.nUsers.text = String(numberOfUsers)
                }else{
                    print("problems getting the number of users connected to this location")
                    cell.nUsersLabel.text = "usuário"
                }
            }else{
                print("\nerror: \(error)")
                print("problems getting the number of users connected to this location")
                cell.nUsersLabel.text = "usuário"
            }
        }
        
        // get the location profile
        cell.placeTypeLabel.text  = location.getLocationType()
        if(location.getLocationType() == self.feu.LOCATION_TYPES[0]){
            cell.placeTypeImage.image = UIImage(named:self.feu.IMAGE_LOC_TYPE_RESIDENCIAL)
        }else{
            cell.placeTypeImage.image = UIImage(named:self.feu.IMAGE_LOC_TYPE_BUSINESS)
        }
        
        return cell
    }
    

    
    
    
    /*
        Get a list of all user locations
    */
    internal func getAllUserLocations(_ user:User){
        
        // Get all available locations
        PFCloud.callFunction(inBackground: "getAllUserLocations", withParameters: [
            "userId": user.getObId()!
        ]) {
            (objects, error) in
                
            if (error == nil){
                if let locIds:Array<AnyObject> = objects as? Array<AnyObject> {
                    print("\nuser location ids: \n\(locIds)")
                        
                    // make sure the loop won't break if the array is empty
                    if(locIds.count > 0){
                        for i in 0...(locIds.count - 1){
                            if let id:String = locIds[i] as? String{
                                    
                                // get the actual location PFObject
                                if(i == (locIds.count - 1)){
                                    self.getLocationById(id, isLast: true)
                                }else{
                                    self.getLocationById(id, isLast: false)
                                }
                            }else{
                                print("problem converting location id into string")
                            }
                        }
                    }
                }else{
                    print("problems converting results into array of locations.")
                }
            }else{
                print("\nerror: \(error)")
            }
        }
    }
    

    /*
        Get location PFObject by id
    */
    internal func getLocationById(_ locId:String, isLast:Bool){
        print("\ngetting location by id ...")
        
        // Get all available locations
        PFCloud.callFunction(inBackground: "getLocationById", withParameters: [
            "locationId": locId
        ]) {
            (locObj, error) in
                
            if (error == nil){
                if let location:PFObject = locObj as? PFObject {
                    print("\nlocation: \(location)")
                    self.availableLocations.append(Location(location:location))
                }else{
                    print("problems converting results into array of locations.")
                }
                    
                self.isDoneLoading(isLast)
            }else{
                print("\nerror: \(error)")
                self.isDoneLoading(isLast)
            }
        }
    }
    
    
    
    internal func isDoneLoading(_ isLast:Bool){
        
        // if this is the last iteration, update the tableview datasource
        if(isLast){
            print("this was the last iteration.")
            self.tableView.reloadData()
        }else{
            print("still have to load more locations")
        }
    }
    
    

    
    
    
}
