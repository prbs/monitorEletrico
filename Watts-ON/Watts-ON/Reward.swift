//
//  Reward.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class Reward: PFObject {

    
    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    @NSManaged var rewardTitle: String?
    @NSManaged var info: String?
    @NSManaged var pictureFile: PFFile?
    fileprivate var pictureImg: UIImage?
    @NSManaged var audience: String?
    @NSManaged var likes: NSNumber?
    @NSManaged var owner: PFUser?
    
    
    // CONSTRUCTORS
    convenience init(reward:PFObject){
        let dbu:DBUtils = DBUtils()
        
        if let id:String = reward.objectId{
            
            var title:String? = nil
            if let ti = reward[dbu.DBH_REWARD_TITLE] as? String{
                title = ti
            }
            
            var info:String? = nil
            if let i = reward[dbu.DBH_REWARD_INFO] as? String{
                info = i
            }
            
            var audience:String? = nil
            if let aud = reward[dbu.DBH_REWARD_AUDIENCE] as? String{
                audience = aud
            }
            
            var likes:NSNumber? = nil
            if let lik = reward[dbu.DBH_REWARD_LIKES] as? NSNumber{
                likes = lik
            }
            
            var picture:PFFile? = nil
            if let pic = reward[dbu.DBH_REWARD_PICTURE] as? PFFile{
                picture = pic
            }

            var owner:PFUser? = nil
            if let ow = reward[dbu.DBH_REWARD_CREATED_BY] as? PFUser{
                owner = ow
            }
            
            self.init(
                objectId    :id,
                rewardTitle :title,
                info        :info,
                picture     :picture,
                audience    :audience,
                likes       :likes,
                owner       :owner
            )
        }else{
            self.init()
        }
    }
    
    init(objectId:String?, rewardTitle:String?, info:String?, picture:PFFile?, audience:String?, likes:NSNumber?, owner:PFUser?) {
        super.init()
        
        self.setObId(objectId)
        self.setRewTitle(rewardTitle)
        self.setRewInfo(info)
        self.setRewPicture(picture)
        self.setRewAudience(audience)
        self.setRewLikes(likes)
        self.setRewOwner(owner)
    }
    
    override init() {
        super.init()
    }
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        //print("reward id is now: \(id)")
        self.objId = id
    }
    
    internal func setRewTitle(_ rewardTitle:String?){
        //print("reward title is now: \(rewardTitle)")
        self.rewardTitle = rewardTitle
    }
    
    internal func setRewInfo(_ info:String?){
        //print("reward info is now: \(info)")
        self.info = info
    }
    
    internal func setRewPicture(_ picture:PFFile?){
        //print("reward pitcure is now: \(picture)")
        self.pictureFile = picture
    }
    
    internal func setRewPictureImg(_ picture:UIImage?){
        //print("reward pitcure is now: \(picture)")
        self.pictureImg = picture
    }
    
    internal func setRewAudience(_ audience:String?){
        //print("reward audience is now: \(audience)")
        self.audience = audience
    }
    
    internal func setRewLikes(_ likes:NSNumber?){
        //print("reward likes is now: \(likes)")
        self.likes = likes
    }
    
    internal func setRewOwner(_ owner:PFUser?){
        //print("reward owner is now: \(owner)")
        self.owner = owner
    }
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getRewardTitle() -> String{
        if let title:String = self.rewardTitle{
            return title
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getRewardInfo() -> String{
        if let info:String = self.info{
            return info
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getRewardPicture() -> PFFile?{
        if let picture:PFFile = self.pictureFile{
            return picture
        }else{
            return nil
        }
    }
    
    internal func getRewardPictureImg() -> UIImage?{
        if let picture:UIImage = self.pictureImg{
            return picture
        }else{
            return nil
        }
    }
    
    internal func getRewardAudience() -> String{
        if let audience:String = self.audience{
            return audience
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getRewardLikes() -> NSNumber{
        if let likes:NSNumber = self.likes{
            return likes
        }else{
            return 0
        }
    }
    
    internal func getRewardOwner() -> PFUser?{
        if let owner:PFUser = self.owner{
            return owner
        }else{
            return nil
        }
    }
    
    internal func getPointerToDatabaseTable() -> PFObject{
        let rewPointer = PFObject(outDataWithClassName:self.dbu.DB_CLASS_REWARD, objectId: self.getObId())
        
        return rewPointer
    }
    
    
    
    // OTHER METHODS
    internal func incrementLikes(){
        self.setRewLikes(self.getRewardLikes().intValue + 1)
    }
    
    
    // QUERIES
    /*
        Gets objets in the relation user like rewards
    */
    internal func checkIfRewardExistQuery() -> PFQuery{
        
        let rewWithTitleDescQuery = PFQuery(className: self.dbu.DB_CLASS_REWARD)
        
        rewWithTitleDescQuery.whereKey(self.dbu.DBH_REWARD_TITLE, hasPrefix: self.getRewardTitle())
        rewWithTitleDescQuery.whereKey(self.dbu.DBH_REWARD_INFO, hasPrefix: self.getRewardInfo())
        
        return rewWithTitleDescQuery
    }
    
    
    /*
        Get new Reward PFObject
    */
    internal func getNewRewardPFobj(_ reward:PFObject) -> PFObject{
        
        reward[self.dbu.DBH_REWARD_TITLE] = self.getRewardTitle()
        reward[self.dbu.DBH_REWARD_INFO] = self.getRewardInfo()
        
        if let pictureFile = self.getRewardPicture(){
            reward[self.dbu.DBH_REWARD_PICTURE] = pictureFile
        }else{
            print("could not get reward image file")
        }
        
        if(self.getRewardOwner() != nil){
            reward[self.dbu.DBH_REWARD_CREATED_BY] = self.getRewardOwner()
        }
        
        return reward
    }
    
    
    
    /*
        Update a reward PFObject that was gathered from the server
    */
    internal func updateReward(_ rewardObj:PFObject){
        rewardObj[self.dbu.DBH_REWARD_TITLE] = self.getRewardTitle()
        rewardObj[self.dbu.DBH_REWARD_INFO] = self.getRewardInfo()
        
        if let pictureFile:PFFile = self.getRewardPicture(){
            rewardObj[self.dbu.DBH_REWARD_PICTURE] = pictureFile
        }else{
            rewardObj[self.dbu.DBH_REWARD_PICTURE] = PFFile()
        }
        
        rewardObj[self.dbu.DBH_REWARD_LIKES] = self.getRewardLikes()
    }
    
    
    /*
        Returns a query to get a reward, the processing of the incoming data is done on the controller layer
    */
    override class func query() -> PFQuery? {
        
        let query = PFQuery(className: Reward.parseClassName())
        
        return query
    }
    
    
    /*
        Update a selected reward and send a status information back to the controller
    */
    internal func updateRewardQuery() -> PFQuery? {
        
        let query = PFQuery(className:Reward.parseClassName())
        
        return query
    }
    
    
    /*
        Delete a given goal and send a status message back to the controller which called this method
    */
    internal func deleteRewardQuery() -> PFQuery?{
        
        let query = PFQuery(className:Reward.parseClassName())
        
        return query
    }
    
    
    /*
        Get the Reward created by the user
    */
    internal func rewardsCreatedByUser(_ user:PFUser) -> PFQuery{
        print("building query, rewards created by user ...")
        
        let query = PFQuery(className:Reward.parseClassName())
        
        query.includeKey(self.dbu.DBH_REWARD_CREATED_BY)
        query.whereKey(self.dbu.DBH_REWARD_CREATED_BY, equalTo: user)
        query.order(byDescending: self.dbu.DBH_GLOBAL_UPD_DAT)
        
        return query
    }
    
    
    /*
        Get the Reward objects liked by a User object
    */
    internal func getRewardsLikedByUser(_ user:PFUser) -> PFQuery{
        print("building query, rewards liked by user ...")
        
        let query = PFQuery(className:self.dbu.DB_REL_USER_REWARD)
        
        query.includeKey(self.dbu.DBH_REL_USER_REWARD_USER)
        query.whereKey(self.dbu.DBH_REL_USER_REWARD_USER, equalTo: user)
        query.order(byDescending: self.dbu.DBH_GLOBAL_UPD_DAT)
        
        return query
    }
    
    
    /*
        Gets objets in the relation user like rewards
    */
    internal func getUserLikeRewardsNewObj(_ user:PFUser) -> PFObject{
        
        // increment likes counter
        self.incrementLikes()
        
        let rewaRelObj = PFObject(className: self.dbu.DB_REL_USER_REWARD)
        
        rewaRelObj[self.dbu.DBH_REL_USER_REWARD_USER] = user
        
        // converts an object id "String" into a pointer to a Reward object
        let rewPointer = PFObject(outDataWithClassName:self.dbu.DB_CLASS_REWARD, objectId: self.getObId())
        rewaRelObj[self.dbu.DBH_REL_USER_REWARD_REWARD] = rewPointer
        
        return rewaRelObj
    }
    
}


// Respect the PFSubclassing protocol
extension Reward: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Reward"
    }
    
    override class func initialize() {
        // Let Parse know that you intend to use this subclass for all objects with class type Reward.
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}

