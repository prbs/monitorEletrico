//
//  ProfileTableViewCell.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!

    internal let feu:FrontendUtilities = FrontendUtilities()
    
    
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // customize the highlighted state of the cell
        self.selectionStyle = .none
    }

    
    
    // UI
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if(!highlighted){
            self.backgroundColor = self.feu.SIDEBAR_HEADER_NORMAL_COLOR
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
}
