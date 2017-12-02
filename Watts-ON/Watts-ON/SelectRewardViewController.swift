//
//  SelectRewardViewController.swift
//  x
//
//  Created by Diego Silva on 11/29/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class SelectRewardViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    // VARIABLES
    // Containers
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    
    @IBOutlet weak var header: UIView!
    @IBOutlet var tableView: UITableView!
    
    // triggers
    @IBOutlet weak var rewardsType: UISegmentedControl!
        
    // other variables and constants
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()
        
    internal var rewards            = [Int: Reward?]() // list of all rewards
    internal var userRewards        = [Int: Reward?]() // list of all rewards
    internal var displayingRewards  = [Int: Reward?]() // list of all rewards (the index is the index that was removed)
    
    internal let selector:Selector = #selector(SelectRewardViewController.back)
    
    internal var selectedReward:Reward? = nil
    
    internal var currentRewardType     = "all"
    internal let CURRENT_REW_TYPE_ALL  = "all"
    internal let CURRENT_REW_TYPE_USER = "user"
        
    internal let CELL_FILTER_FOR_SELECTION = UIColor.black.withAlphaComponent(0.6)
    internal let CELL_FILTER_FOR_SELECTION_DARKER = UIColor.black.withAlphaComponent(0.001)
        
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.automaticallyAdjustsScrollViewInsets = false
        self.customizeNavBar(self)
            
        // initilize the tableview
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(self.selector, parentVC: self, labelText: "<")
        
        // Data initialization
        self.loadData()
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        // do something ...
    }
        
        
        
    // UI
    /*
        Defines the sort of Reward was selected
    */
    @IBAction func selectRewardsType(_ sender: AnyObject) {
            
        switch self.rewardsType.selectedSegmentIndex{
            case 0:
                print("show all rewards")
                
                self.currentRewardType = self.CURRENT_REW_TYPE_ALL
                self.displayingRewards = self.rewards
                self.tableView.reloadData()
            case 1:
                print("show only user's")
                
                self.currentRewardType = self.CURRENT_REW_TYPE_USER
                self.displayingRewards = self.userRewards
                self.tableView.reloadData()
            default:
                break;
        }
    }
        
        
        
    /*
        Table methods
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.displayingRewards.count > 0){
            return self.displayingRewards.count
        }else{
            return 0
        }
    }
        
    /*
        Fetch a cell of type RewardCell into the table with data from the backend
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        // creates a new regular cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RewardForSelectionCell", for: indexPath) as! RewardForSelectionTableViewCell
            
        // create a new reward object with values from server
        if let reward:Reward = self.displayingRewards[indexPath.row]!{
                
            // pass a reference to this view controller and insert the reward object inside of its cell in order to make the possible to use the method perfom segue with identifier within the table view cell
            cell.cellReward = reward
            cell.cellIndex = indexPath.row
            
            // user likes
            cell.rewardNumLikes.text = reward.getRewardLikes().stringValue
                
            // load values from object that came from server into the prototype cell Outlets
            cell.rewardTitle.text = reward.getRewardTitle()
                
            let rew_pic = reward.getRewardPicture()
            if(rew_pic != nil){
                rew_pic!.getDataInBackground(block: {
                    (imageData: Data?, error: NSError?) -> Void in
                        
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        cell.rewardImage.image = image
                        reward.setRewPictureImg(image)
                    }
                })
            }else{
                cell.rewardImage.image = UIImage(named:"imgres.jpg")
            }
                
            // set the reward owner
            if let rewOwner = reward.getRewardOwner(){
                let query:PFQuery = User.query()!
                    
                query.getObjectInBackground(withId: rewOwner.objectId!){
                    (user, error) -> Void in
                        
                    if(error == nil){
                            
                        if let user:PFUser = user as? PFUser{
                            let u:User = User(user:user)
                                
                            // load the user picture for this object
                            if(u.getUserPicture() != nil){
                                u.getUserPicture()!.getDataInBackground(block: {
                                        (imageData: Data?, error: NSError?) -> Void in
                                        
                                    if (error == nil) {
                                        let image = UIImage(data:imageData!)
                                        cell.rewardOwnerPic.image = image
                                    }else{
                                        print("failed to get user picture")
                                        cell.rewardOwnerPic.image = UIImage(named: self.feu.IMAGE_USER_PLACEHOLDER)
                                    }
                                })
                            }else{
                                cell.rewardOwnerPic.image = UIImage(named: self.feu.IMAGE_USER_PLACEHOLDER)
                            }
                        }else{
                            print("could not get PFUser out of backend object")
                        }
                    }else{
                        print("failed to get user from backend")
                    }
                }
            }else{
                print("weird, this reward doesn't have an owner")
            }
        }else{
            print("problems to get Reward object out of the list of Rewards")
        }
            
        return cell
    }
        
    /*
        Overrides the table row height, it specifies the height of the profile table view cell
    */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 167.0
    }
        
    /*
        Row selection event
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let indexPath = tableView.indexPathForSelectedRow
            
        if(self.displayingRewards.count > 0){
            let keys = Array(self.displayingRewards.keys)
                
            let position = keys[indexPath!.row]
                
            // try to get the reward from the list
            if let reward:Reward = self.displayingRewards[position]!{
                    
                // update the selected reward (used on data transportation) variable
                self.selectedReward = reward
                
                // get tableview cell to animate the selection
                if let cell:RewardForSelectionTableViewCell = tableView.cellForRow(at: indexPath!) as? RewardForSelectionTableViewCell{
                    
                    UIView.animate(withDuration: 0.1, animations:{
                        cell.cellFilter.layer.opacity = 0.5
                        
                        self.feu.fadeIn(cell.selectedImg,speed:0.4)
                    }, completion: {
                        (value: Bool) in
                            
                        UIView.animate(withDuration: 0.6, animations:{
                            cell.cellFilter.layer.opacity = 1.0
                        }, completion :{
                            (value: Bool) in
                            
                            // send the user back to the goals definition page
                            self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_SCT_REW , sender: self)
                        })
                    })
                }else{
                    print("could not get table cell")
                }
            }else{
                print("failed to get reward from list")
            }
        }else{
            print("displaying rewards list is empty")
        }
    }
        
        
        
    // LOGIC
    internal func loadData(){
        print("\ngetting data for the rewards table ...")
            
        // start loading process
        self.feu.fadeIn(self.screenLocker, speed: 0.6)
        self.startLoadingAnimation(self.spinner)
            
        // get a list of all users connected to a location
        self.getLocationUsers()
    }
    
    
    /*
        Get the list of users related to a location
    */
    internal func getLocationUsers(){
        print("\ngetting list of all the users of the current location ...")
                
        // request data from the app backend
        PFCloud.callFunction(inBackground: "getAllLocationUsers", withParameters:[
            "locationId":DBHelpers.currentLocation!.getObId()
        ]) {
            (userObjs, error) in
            
            if (error == nil){
                            
                // get list of user_location relationships
                if let usersPointersArray:Array<AnyObject> = userObjs as? Array<AnyObject> {
                    
                    if(usersPointersArray.count > 0){
                                    
                        // get list of all rewards created by the users of a location
                        for i in 0...(usersPointersArray.count - 1){
                                        
                            if let userId = usersPointersArray[i] as? String{
                                            
                                if(i == (usersPointersArray.count - 1)){
                                    self.getUserSuggestedRewards(userId, isLast: true)
                                }else{
                                    self.getUserSuggestedRewards(userId, isLast: false)
                                }
                            }else{
                                print("could not get user id out of list of ids")
                            }
                        }
                    }
                }else{
                    print("problems converting results into array of user_location objects.")
                                
                    // unlock the screen
                    self.feu.fadeOut(self.screenLocker, speed: 0.6)
                    self.stopSpinner(self.spinner)
                }
            }else{
                print("\nerror: \(error)")
                            
                // unlock the screen
                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                self.stopSpinner(self.spinner)
            }
        }
    }
            
            
    /*
        Get a list of all rewards suggested by an user
    */
    internal func getUserSuggestedRewards(_ userId:String, isLast:Bool){
        print("\ngetting rewards suggested by the user with id \(userId) ...")
                
        // request data from the app backend
        PFCloud.callFunction(inBackground: "getUserRewards", withParameters:[
            "userId":userId
        ]) {
            (userRews, error) in
                        
            if (error == nil){
                
                // get list of user_location relationships
                if let userRewards:Array<AnyObject> = userRews as? Array<AnyObject> {
                    
                    if(userRewards.count > 0){
                                    
                        for i in 0...(userRewards.count - 1){
                            
                            // try to get the user reward as a PFObject
                            if let rew = userRewards[i] as? PFObject{
                                            
                                // insert a new Reward into the full list of rewards
                                let reward:Reward = Reward(reward: rew)
                                            
                                // insert reward into the full list
                                self.rewards[self.rewards.count] = reward
                                            
                                // insert reward into the user's rewards list
                                if(PFUser.current()?.objectId == userId){
                                    self.userRewards[self.userRewards.count] = reward
                                }else{
                                    print("user is not the owner of this reward")
                                }
                            }else{
                                //print("failed to convert suggested reward into PFObject")
                            }
                        }
                    }else{
                        //print("there are no suggested rewards made by the users of this place")
                    }
                }else{
                    //print("problems converting results into array of user_location objects.")
                }
                            
                // check if the process is over and call the user liked rewards query
                self.isDoneDownloadingRewards(isLast)
            }else{
                print("\nerror: \(error)")
                            
                // check if the process is over and call the user liked rewards query
                self.isDoneDownloadingRewards(isLast)
            }
        }
    }
            
            
    /*
        Check if the system is done with the rewards downloading process
    */
    internal func isDoneDownloadingRewards(_ isLast:Bool){
        if(isLast){
            print("this was the last iteration")
                    
            // check the list of rewards that must be displayed
            if(self.currentRewardType == self.CURRENT_REW_TYPE_ALL){
                self.displayingRewards = self.rewards
            }else{
                self.displayingRewards = self.userRewards
            }
                    
            // reload cells
            self.tableView.reloadData()
                    
            // unlock the screen
            self.feu.fadeOut(self.screenLocker, speed: 0.6)
            self.stopSpinner(self.spinner)
                    
            // this location has no suggested rewards yet, send message.
            if(self.displayingRewards.count == 0){
                self.infoWindow("Nenhum usuário deste local criou um sugestão de recompensa até o momento", title: "Crie uma recompensa", vc:self)
            }
        }
    }

            
    /*
        Get the reward position on the full list of rewards by serching for a match on the reward id
    */
    internal func getRewardPositionById(_ reward:Reward, list:[Int:Reward?]) -> Int{
        print("trying to get the reward position by its id ...")
                
        let listKeys = Array(list.keys)
                
        if(listKeys.count > 0){
                    
            for i in 0...(listKeys.count - 1){
                        
                if let key:Int = listKeys[i]{
                            
                    if let rewObj = list[key]{
                                
                        if let rew:Reward = rewObj{
                            
                            if(rew.getRewardTitle() == reward.getRewardTitle()){
                                print("got it")
                                        
                                return key
                            }
                        }
                    }else{
                        print("could not get reward object out of displaying rewards for id \(key)")
                    }
                }else{
                    print("could not get reward key in the displaying list")
                }
            }
        }else{
            print("list of displaying rewards is empty")
        }
                
        return -1
    }
    
    
    
    // NAVIGATION
    /*
        Go back to the rewards list page
    */
    internal func back(){
        
        // send the user back to the goals definition page
        self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_SCT_REW , sender: self)
    }
    
    
    
            
            
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
            
}
