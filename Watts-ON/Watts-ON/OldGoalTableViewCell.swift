//
//  OldGoalTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/3/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class OldGoalTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var desiredValue: UILabel!
    @IBOutlet weak var actualValue: UITextField!
    @IBOutlet weak var oldGoalStatus: UIImageView!
    @IBOutlet weak var valuePaidLabel: UILabel!
    
    internal var parentController:OldGoalsViewController? = nil
    internal var index:IndexPath? = nil
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
