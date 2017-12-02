//
//  DeviceCardView.swift
//  x
//
//  Created by Diego Silva on 11/15/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DeviceCardView: UIView {

    
    // VARIABLES
    @IBOutlet weak var outterContainer: UIView!
    @IBOutlet weak var innerContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var activationKey: UILabel!
    
    @IBOutlet weak var monitoredPlaceImgType: UIImageView!
    @IBOutlet weak var monitoredPlace: UILabel!
    @IBOutlet weak var deviceStatus: UILabel!
    @IBOutlet weak var paymentStatus: UILabel!
    @IBOutlet weak var devicePlaceLabel: UILabel!
    
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    
    
    // INITIALIZERS
    override func draw(_ rect: CGRect) {
        // do something
    }
    
}
