//
//  UserTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/16/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userAtHomeStatusImg: UIImageView!
    @IBOutlet weak var userAtHomeStatLabel: UILabel!
    @IBOutlet weak var userAtHomeStatusImgContainer: UIView!
    
    internal var parentController:UsersViewController? = nil
    internal var index:IndexPath? = nil
    
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
