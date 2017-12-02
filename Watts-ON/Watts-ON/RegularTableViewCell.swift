//
//  RegularTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/12/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class RegularTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var btnImage: UIImageView!
    @IBOutlet weak var btnLabel: UILabel!
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    
    
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // customize the highlighted state of the cell
        self.selectionStyle = .none
    }
    
    
    
    // UI
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if(highlighted){
            self.backgroundColor = self.feu.SIDEBAR_BODY_HIGHLIGHTED_COLOR
        }else{
            self.backgroundColor = self.feu.SIDEBAR_BODY_NORMAL_COLOR
        }
    }
    
    
}
