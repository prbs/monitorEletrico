//
//  TutoLastPage.swift
//  x
//
//  Created by Diego Silva on 11/20/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class TutoLastPage: UIView {

    
    
    // VARIABLES
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet weak var incentiveMessage: UILabel!
    
    
    var parentVC:TutorialViewController = TutorialViewController()
    let feu:FrontendUtilities = FrontendUtilities()
    
    
    
    // INITIALIZERS
    override func draw(_ rect: CGRect) {
        self.feu.roundIt(self.startBtn, color:self.feu.SUPER_LIGHT_WHITE)
    }
    
    
    
    // NAVIGATION
    @IBAction func goHome(_ sender: AnyObject) {
        parentVC.goHome(sender)
    }

}
