//
//  TutoPage.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/24/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class TutoPage: UIView {

    // VARIABLES
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var tutoView: UIImageView!
    @IBOutlet weak var tutoInfo: UILabel!

    
    let SIX_SPLUS_X:CGFloat = 414 - 736
    let SIX_PLUS_X:CGFloat  = 414 - 736
    let SIX_S_X:CGFloat     = 375 - 667
    let SIX_X:CGFloat       = 375 - 667
    let FIVE_S_X:CGFloat    = 320 - 568
    let FIVE_X:CGFloat      = 320 - 568
    let FOUR_S_X:CGFloat    = 320 - 480
    

    
    
    
    
    
    // INITIALIZERS
    override func draw(_ rect: CGRect) {
        
        self.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        )
        
        
        
        var marginX:CGFloat = 0.0
        var marginY:CGFloat = 0.0
        
        print(">>>>>>>>> largura \(UIScreen.main.bounds.size.width)")
        print(">>>>>>>>> altura \(UIScreen.main.bounds.size.height)")
        
        
        let valor = UIScreen.main.bounds.size.width - UIScreen.main.bounds.size.height
        
        switch (valor) {
            case SIX_SPLUS_X:
                marginX = -93.0
                marginY = 68.0
            
            case SIX_PLUS_X:
                marginX = -93.0
                marginY = 68.0
            
            case SIX_S_X:
                marginX = -112.5
                marginY = 33.5
            
            case SIX_X:
                marginX = -112.5
                marginY = 33.5
            
            case FIVE_S_X:
                print("here")
                marginX = -140.0
                marginY = -16.0
            
            case FIVE_X:
                marginX = -140.0
                marginY = -16.0
            
            case FOUR_S_X:
                marginX = -140.0
                marginY = -60.0
            
            default:
                marginX = 0.0
                marginY = 0.0
        }
        
        self.bounds = CGRect(
            x: UIScreen.main.bounds.origin.x + marginX,
            y: UIScreen.main.bounds.origin.y + marginY,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        );
    }
}
