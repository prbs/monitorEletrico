//
//  SharedPlaceTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/14/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class SharedPlaceTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var adminName: UILabel!
    @IBOutlet weak var nUsers: UILabel!
    @IBOutlet weak var placeImgTypeContainer: UIView!
    @IBOutlet weak var placeTypeImage: UIImageView!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var nUsersLabel: UILabel!
    
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    
    internal var index:IndexPath? = nil
    internal var parentController:ListPlacesViewController? = nil
    internal var location:Location? = nil
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.feu.roundItBordless(self.placeImgTypeContainer)
    }
    
}
