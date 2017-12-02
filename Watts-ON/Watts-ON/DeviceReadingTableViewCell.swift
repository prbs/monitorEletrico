//
//  DeviceReadingTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/29/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DeviceReadingTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var readingImgLabel: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var value: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
