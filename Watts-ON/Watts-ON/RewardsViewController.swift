//
//  RewardsViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/14/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class RewardsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    // VARIABLES
    // Containers
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    
    @IBOutlet var contentContainer: UIView!
    @IBOutlet weak var header: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var footer: UIView!
    
    // triggers
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var rewardsType: UISegmentedControl!
    @IBOutlet weak var newRewardBtn: UIView!
    
    
    // other variables and constants
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()
    
    internal var rewards            = [Int: Reward?]() // list of all rewards
    internal var userRewards        = [Int: Reward?]() // list of all rewards
    internal var displayingRewards  = [Int: Reward?]() // list of all rewards (the index is the index that was removed)
    
    internal var likedRewards     = [String]()    // list the ids of the user's liked rewards
    internal var selectedReward:Reward? = nil
    
    internal let CURRENT_REW_TYPE_ALL  = "all"
    internal let CURRENT_REW_TYPE_USER = "user"
    internal var currentRewardType     = "all"
    
    internal let DEFAULT_SOURCE_VAL = "inside"
    internal var navigationSource   = "inside"
    
    internal let CELL_FILTER_FOR_SELECTION = UIColor.black.withAlphaComponent(0.6)
    internal let CELL_FILTER_FOR_SELECTION_DARKER = UIColor.black.withAlphaComponent(0.001)
    
    
    
    // INITIALIZERS
    override func viewWillAppear(_ animated: Bool) {
        
        // UI initialization
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        self.customizeMenuBtn(self.homeBtn, btnIdentifier: self.feu.ID_HOME)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.customizeNavBar(self)
        
        // initilize the tableview
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // binds the show menu toogle action implemented by SWRevealViewController to the menu button
        if self.revealViewController() != nil {
            self.menuBtn.target = self.revealViewController()
            self.menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Data initialization
        if(!DBHelpers.lockedSystem){
            self.loadData()
            self.footer.isHidden = false
        }else{
            self.footer.isHidden = true
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as! RewardTableViewCell
        
        // create a new reward object with values from server
        if let reward:Reward = self.displayingRewards[indexPath.row]!{
        
            // pass a reference to this view controller and insert the reward object inside of its cell in order to make the possible to use the method perfom segue with identifier within the table view cell
            cell.cellReward = reward
            cell.cellIndex = indexPath.row
            
            // user likes
            cell.likeBtn.isEnabled = true
            
            // disable the like button if user already liked the reward
            if(self.checkIfUserLikeReward(reward.getObId())){
                cell.likeBtn.isEnabled = false
            }
            
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
            let position = indexPath!.row
            
            // try to get the reward from the list
            if let reward:Reward = self.displayingRewards[position]!{
                
                // update the selected reward (used on data transportation) variable
                self.selectedReward = reward
                
                self.performSegue(withIdentifier: self.feu.SEGUE_REWARD_SHOW, sender: self)
            }else{
                print("failed to get reward from list")
            }
        }else{
            print("displaying rewards list is empty")
        }
    }

    
    
    /*
        Initialize cell for the creation of a new goal
    */
    internal func initilizeCellDetailsForNewGoal(_ cell:RewardTableViewCell, reward:Reward, indexPath:IndexPath){
        
        // change filter
        cell.cellFilter.backgroundColor = self.CELL_FILTER_FOR_SELECTION
    }
    
    
    
    // LOGIC
    internal func loadData(){
        print("\ngetting data for the rewards table ...")
        
        self.rewards = [Int: Reward?]()
        self.userRewards = [Int: Reward?]()
        self.displayingRewards = [Int: Reward?]()
        
        
        
        // start loading process
        self.feu.fadeIn(self.screenLocker, speed: 0.6)
        self.startLoadingAnimation(self.spinner)
        
        // get a list of all users connected to a location
        if let id = PFUser.current()?.objectId{
            self.getLikedRewards(id)
        }else{
            print("weird, coulg not get current user id")
            self.getLocationUsers()
        }
    }
    
    
    /*
        Get list of rewards liked by current user
    */
    internal func getLikedRewards(_ userId:String){
        
        // request data from the app backend
        PFCloud.callFunction(inBackground: "rewardsLikedByUser", withParameters:[
            "userId":userId
        ]) {
            (userRews, error) in
                
            if (error == nil){
                    
                // get list of user_location relationships
                if let userRewards:Array<AnyObject> = userRews as? Array<AnyObject> {
                    
                    // get the list of the rewards liked by the user
                    if(userRewards.count > 0){
                        
                        // get each relationship object
                        for i in 0...(userRewards.count - 1){
                            
                            // get relationship object
                            if let rewardRelObj:PFObject = userRewards[i] as? PFObject{
                                
                                // get reward pointer
                                if let rewardPointer = rewardRelObj.object(forKey: "reward") {
                                    
                                    // get the reward id
                                    if let rewardId:String = (rewardPointer as AnyObject).objectId{
                                        print("reward id \(rewardId)")
                                        
                                        self.likedRewards.append(rewardId)
                                    }else{
                                        print("failed to convert reward id into String object")
                                    }
                                }else{
                                    print("could not get reward pointer")
                                }
                            }else{
                                print("could not get user-reward relationship object")
                            }
                        }
                    }else{
                        print("there are no rewards liked by the user")
                    }
                }else{
                    print("problems converting results into array of user_location objects.")
                }
                
                print("\n\nList of ids of the liked rewards \(self.likedRewards)\n\n")
                
                // get user locations
                self.getLocationUsers()
                
            }else{
                print("\nerror: \(error)")
            }
        }
    }
    
    
    
    
    /*
        Get the list of users related to a location
    */
    internal func getLocationUsers(){
        print("getting list of all the users of the current location ...")
        
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
    
    
    
    
    /*
        Check if a user already like a reward
    */
    internal func checkIfUserLikeReward(_ rewardId:String) -> Bool{
        
        if(self.likedRewards.count > 0){
            for i in 0...(self.likedRewards.count - 1){
                if(self.likedRewards[i] == rewardId){
                    return true
                }
            }
        }else{
            print("rewards list is empty")
        }
        
        return false
    }
    
    
    
    
    // NAVIGATION
    /*
        Perform actions after the user visualized the reward
    */
    @IBAction func unwindAfterRewardVisualization(_ segue:UIStoryboardSegue) {
        print("\ncame back from reward details ...")
    }
    
    
    
    /*
        Get results from the new reward screen
    */
    @IBAction func unwindAfterNewReward(_ segue:UIStoryboardSegue) {
        
        print("\ncame back from new reward ...")
        
        if let newRewVC:NewRewardViewController = segue.source as? NewRewardViewController{
            
            if let newReward = newRewVC.reward{
                print("newRewVC.reward \(newReward)")
                
                // reload datasources
                self.userRewards[self.userRewards.count] = newReward
                self.rewards[self.rewards.count] = newReward
                
                // reload the list displaying list of rewards
                if(self.currentRewardType == self.CURRENT_REW_TYPE_ALL){
                    self.displayingRewards = self.rewards
                }else{
                    self.displayingRewards = self.userRewards
                }
                
                // reload table view data
                self.tableView.reloadData()
            }else{
                print("no reward was created on the new reward page")
            }
        }
    }
    
    
    /*
        Get results from the new reward screen
    */
    @IBAction func unwindAfterRewardDeletion(_ segue:UIStoryboardSegue) {
        
        print("\nprocessing reward deletion ...")
        self.loadData()
//        if let rewDetailsVC:RewardViewController = segue.sourceViewController as? RewardViewController{
//            
//            if let reward:Reward = rewDetailsVC.reward{
//        
//                // remove deleted reward from the list of liked rewards, if it is still there
//                if(self.likedRewards.count > 0){
//                    
//                    for i in 0...(self.likedRewards.count - 1){
//                        
//                        if(self.likedRewards[i] == reward.getObId()){
//                            self.likedRewards.removeAtIndex(i)
//                        }
//                    }
//                }else{
//                    print("user liked rewards list is empty")
//                }
//                
//                // remove the deleted reward from all possible data sources
//                print("\ntrying to remove reward from full list")
//                var rewardPos = self.getRewardPositionById(reward, list:self.rewards)
//                if(rewardPos != -1){
//                    self.rewards.removeValueForKey(rewardPos)
//                }else{
//                    print("reward is not in the list")
//                }
//                
//                // remove the deleted reward from the user's list of rewards
//                print("\ntrying to remove reward from user's rewards list")
//                rewardPos = self.getRewardPositionById(reward, list:self.userRewards)
//                if(rewardPos != -1){
//                    self.userRewards.removeValueForKey(rewardPos)
//                }else{
//                    print("reward is not in the list")
//                }
//                
//                // reload the list displaying list of rewards
//                if(self.currentRewardType == self.CURRENT_REW_TYPE_ALL){
//                    self.displayingRewards = self.rewards
//                }else{
//                    self.displayingRewards = self.userRewards
//                }
//                
//                // reload table view data
//                self.tableView.reloadData()
//            }else{
//                print("no reward was created on the new reward page")
//            }
//        }
    }
    
    
    
    //unwindAfterRewardUpdate
    /*
        Get results from the new reward screen
    */
    @IBAction func unwindAfterRewardUpdate(_ segue:UIStoryboardSegue) {
        
        print("\ncame back from reward update ...")
        
        if let rewDetailsVC:NewRewardViewController = segue.source as? NewRewardViewController{
        
            if let reward:Reward = rewDetailsVC.reward{
            
                print("\ntrying to remove reward from full list")
                var rewardPos = self.getRewardPositionById(reward, list:self.rewards)
                if(rewardPos != -1){
                    self.rewards[rewardPos] = reward
                }else{
                    print("reward is not in the list")
                }
            
                // remove the deleted reward from the user's list of rewards
                print("\ntrying to remove reward from user's rewards list")
                rewardPos = self.getRewardPositionById(reward, list:self.userRewards)
                if(rewardPos != -1){
                    self.userRewards[rewardPos] = reward
                }else{
                    print("reward is not in the list")
                }
            
                // reload the list displaying list of rewards
                if(self.currentRewardType == self.CURRENT_REW_TYPE_ALL){
                    self.displayingRewards = self.rewards
                }else{
                    self.displayingRewards = self.userRewards
                }
            
                // reload table view data
                self.tableView.reloadData()
        
            }else{
                print("no reward was created on the new reward page")
            }
                
        }
    }
    
    
    
    /*
        Go to new reward screen
    */
    @IBAction func goNewReward(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_REWARD_ADD, sender: nil)
    }
    
    
    
    /*
        Go home
    */
    @IBAction func goHome(){
        self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
    }
    
    
    /*
        Prepare data to next screen
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == self.feu.SEGUE_REWARD_SHOW){
            let destineVC = (segue.destination as! RewardViewController)
            destineVC.reward = self.selectedReward
            
        }else if (segue.identifier == self.feu.SEGUE_REWARD_ADD){
            
            let destineVC = (segue.destination as! NewRewardViewController)
            destineVC.reward = sender as? Reward
            
            print("\ntrying to create a reward")
            destineVC.task = "create"
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
