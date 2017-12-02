//
//  TipCardView.swift
//  x
//
//  Created by Diego Silva on 11/15/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class TipCardView: UIView {

    
    @IBOutlet weak var cardOutterContainer: UIView!
    @IBOutlet weak var cardInnerContainer: UIView!
    @IBOutlet weak var tipView: UIImageView!
    @IBOutlet weak var tipTitle: UILabel!
    @IBOutlet weak var tipDescription: UITextView!
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    internal var parentVC:DicasViewController? = DicasViewController()
    internal var cardIdx:Int = -1
    
    
    
    // INITIALIZERS
    override func draw(_ rect: CGRect) {
        
        self.tipView.isHidden = true
        
        self.feu.fadeIn(self.tipView, speed: 0.7)
        self.feu.fadeIn(self.cardOutterContainer, speed: 0.7)
    }
    
}
