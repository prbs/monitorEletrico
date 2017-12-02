//
//  RewardForSelectionTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/29/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class RewardForSelectionTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var cellFilter: UIView!
    
    @IBOutlet weak var selectedImg: UIImageView!
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
    
    
}
