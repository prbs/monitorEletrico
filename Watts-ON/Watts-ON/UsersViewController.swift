//
//  UsersViewController.swift
//  x
//
//  Created by Diego Silva on 11/22/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class UsersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    // VARIABLES
    @IBOutlet weak var tableView: UITableView!
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils   = DBUtils()
    
    internal var locationUsers:Array<User?> = Array<User?>()
    internal var cells:[IndexPath:UserTableViewCell] = [IndexPath:UserTableViewCell]()
    internal let selector:Selector = #selector(UsersViewController.goHome)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getHomeNavbarBtn(self.selector, parentVC: self)
        
        // get the current location name
        let locName = DBHelpers.currentLocation?.getLocationName()
        
        if(locName == self.dbu.STD_UNDEF_STRING){
            self.navigationItem.title = "Local"
        }else{
            self.navigationItem.title = DBHelpers.currentLocation?.getLocationName()
        }
        
        self.loadData()
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
        return self.locationUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell
        
        self.cells[indexPath] = cell
        
        // get goal out of array of goals
        if let user = self.locationUsers[indexPath.row]{
            
            // load the new cell with data
            cell.parentController = self
            cell.index = indexPath
            
            cell.userName.text  = user.getUserName()
            cell.userEmail.text = user.username
            
            // fill in the user status variables
            if(user.getAtHomeStatus()){
                cell.userAtHomeStatusImg.image = UIImage(named:"atHome.png")
                
                if(DBHelpers.currentLocation?.getLocationType() == self.feu.LOCATION_TYPES[0]){
                    cell.userAtHomeStatLabel.text  = "Em casa"
                }else{
                    cell.userAtHomeStatLabel.text  = "Na empresa"
                }
            }else{
                cell.userAtHomeStatusImg.image = UIImage(named:"out.png")
                if(DBHelpers.currentLocation?.getLocationType() == self.feu.LOCATION_TYPES[0]){
                    cell.userAtHomeStatLabel.text  = "Fora de casa"
                }else{
                    cell.userAtHomeStatLabel.text  = "Não está no trabalho"
                }
            }
            self.feu.roundItBordless(cell.userAtHomeStatusImgContainer)
            
            // user picture
            let picture = user.getUserPicture()
            if(picture != nil){
                picture!.getDataInBackground(block: {
                    (imageData: Data?, error: NSError?) -> Void in
                    
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        
                        cell.userImg.image = image
                    }
                })
            }else{
                cell.userImg.image = UIImage(named: "user.png")
            }
            self.feu.roundItBordless(cell.userImg)
        }
        
        return cell
    }

    /*
        
    */
    
    
    
    
    
    /*
        Logic
    */
    internal func loadData(){
        self.getLocationUsers()
    }
    
    
    /*
        Get list of user ids' of the current location
    */
    internal func getLocationUsers(){
        print("getting list of the user goals ...")
        
        // request data from the app backend
        PFCloud.callFunction(inBackground: "getAllLocationUsers", withParameters:[
            "locationId":DBHelpers.currentLocation!.getObId()
        ]) {
            (userObjs, error) in
                
            if (error == nil){
                print("user_obj \(userObjs)")
                
                // get list of user_location relationships
                if let usersPointersArray:Array<AnyObject> = userObjs as? Array<AnyObject> {
                        
                    // iterate though each relationship object to get the actual user object
                    for i in 0...(usersPointersArray.count - 1){
                            
                        // get a user_location relationship object
                        if let userId = usersPointersArray[i] as? String{
                            if(i == (usersPointersArray.count - 1)){
                                self.getUserById(userId, isLast:true)
                            }else{
                                self.getUserById(userId, isLast:false)
                            }
                        }else{
                            print("problem unwraping user object from array")
                        }
                    }
                }else{
                    print("problems converting results into array of user_location objects.")
                }
            }else{
                print("\nerror: \(error)")
            }
        }
    }
    
    
    
    /*
        Get pointed Users
    */
    internal func getUserById(_ userId:String, isLast:Bool){
        
        let query = PFQuery(className: self.dbu.DB_CLASS_USER)
        query.getObjectInBackground(withId: userId) {
            (userObj, error) -> Void in
            
            if(error == nil){
                print("user \(userObj)")
                
                if let user:PFUser = userObj as? PFUser{
                    self.locationUsers.append(User(user: user))
                }else{
                    print("error converting PFObject into user")
                }
                
                // check if the iteration is over and reload table view.
                self.isDoneLoading(isLast)
            }else{
                print("error getting data from backend \(error)")
                self.isDoneLoading(isLast)
            }
        }
    }

    
    
    internal func isDoneLoading(_ isLast:Bool){
        
        // check if the iteration is over and reload table view.
        if(isLast){
            print("reloading table view ...")
            self.tableView.reloadData()
        }else{
            print("still have to load more users ...")
        }
    }
    
    
    
    
    // NAVIGATION
    /*
        Send the user back to the home screen by dismissing the current page from the pages stack
    */
    internal func goHome(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    

}
