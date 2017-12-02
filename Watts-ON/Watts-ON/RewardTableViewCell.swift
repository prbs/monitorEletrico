//
//  RewardTableViewCell.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/15/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class RewardTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    
    // VARIABLES
    @IBOutlet weak var cellFilter: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var rewardImage: UIImageView!
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var rewardNumLikes: UILabel!
    @IBOutlet weak var rewardOwnerPic: UIImageView!
    
    @IBOutlet weak var ownerLabel: UILabel!
    
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    internal let dbu:DBUtils = DBUtils()
    
    internal var cellReward:Reward? = nil
    internal var cellIndex:Int = -1
    
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // do something
        self.feu.roundItBordless(self.rewardOwnerPic)
        
        // customize the highlighted state of the cell
        self.selectionStyle = .none
        
        self.rewardImage.isHidden = true
        self.ownerLabel.isHidden = true
        self.rewardOwnerPic.isHidden = true
        self.rewardNumLikes.isHidden = true
        
        self.feu.fadeIn(self.rewardImage, speed: 0.8)
        self.feu.fadeIn(self.ownerLabel, speed: 0.8)
        self.feu.fadeIn(self.rewardOwnerPic, speed: 0.8)
        self.feu.fadeIn(self.rewardNumLikes, speed: 0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // todo
    }
    
    
        
    // UI
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.cellFilter.layer.opacity = 1.0
    }
    
    
    /*
        Upvote a reward
    */
    @IBAction func likeIt(_ sender: AnyObject) {
        print("like it")
        
        self.userLikeReward()
    }
    
    
   
    /*
        Increment likes' counter
    */
    internal func incrementLikesCounter(){
        if var nl:Int = Int.init(self.rewardNumLikes.text!){
            nl += 1
            
            self.rewardNumLikes.text = String(nl)
            self.likeBtn.isEnabled = false
        }
    }
    
    

    // LOGIC
    /*
        Create a relationship of kind like between an User and a Reward
    */
    internal func userLikeReward(){
        
        // if cell reward is valid
        if(self.cellReward != nil){
            
            // create user like reward relationship
            let rewaRelObj = self.cellReward?.getUserLikeRewardsNewObj(PFUser.current()!)
            
            rewaRelObj!.saveInBackground {
                (success: Bool, error: NSError?) -> Void in
                    
                if (success) {
                    print("\ncreated relationship user like reward ...")
                    
                    // update UI
                    self.incrementLikesCounter()
                        
                    // update backend
                    self.updateRewardCounter()
                } else {
                    print("\nerror, there was a problem creating the user reward relatioship")
                }
            }
        }
    }
    
    
    /*
        Update likes counter on selected Reward object
    */
    internal func updateRewardCounter(){
        
        let query = PFQuery(className:self.dbu.DB_CLASS_REWARD)
        
        query.getObjectInBackground(withId: (self.cellReward?.getObId())!) {
            (rew: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print("Error changing num of likes on reward object \(error)")
            } else if let reward = rew {
                print("\nupdated reward object likes counter.")
                
                self.cellReward?.updateReward(reward)
                print("reward object after update \(reward)")
                
                reward.saveInBackground()
            }
        }
    }
    

}
