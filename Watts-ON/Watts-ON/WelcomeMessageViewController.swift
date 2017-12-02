//
//  WelcomeMessageViewController.swift
//  x
//
//  Created by Diego Silva on 11/19/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class WelcomeMessageViewController: UIViewController {

    
    // VARIABLES
    // containers
    @IBOutlet weak var outterContainer: UIView!
    @IBOutlet weak var innerContainer: UIView!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var boltContainer: UIView!
    
    // other outlets
    @IBOutlet weak var boltImage: UIImageView!
    @IBOutlet weak var pointer: UIImageView!
    @IBOutlet weak var viewMsg: UILabel!
    @IBOutlet weak var viewTitle:UILabel!
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    internal let dbh:DBHelpers = DBHelpers()
    internal var callerViewController:HomeViewController = HomeViewController()
    
    

    // CONSTANTS
    internal let VIEW_TYPE_WELCOME = 0
    internal let VIEW_NEW_LOCATION = 1
    internal let WELCOME_IMG       = "bolt-baloon.png"
    internal let NEW_LOCATION_IMG  = "bolt-key.png"
    
    
    
        
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
        
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
        
        
        
    // UI
    /*
        Pop up dialog
    */
    func showInView(_ aView: UIView!, animated: Bool, title:String, msg:String, type:Int){
        aView.addSubview(self.view)
        
        if animated{
            
            // customize UI
            self.viewTitle.text = title
            self.viewMsg.text   = msg
            self.customizeUI(type)
            
            // show it
            self.showAnimate()
        }
    }
    
    func customizeUI(_ viewType:Int){
        
        self.feu.roundIt(self.boltContainer, color:self.feu.LIGHT_WHITE)
        self.feu.changeAlphaLoop(self.pointer, times: 100)
        self.feu.roundCorners(self.outterContainer, color: self.feu.DARK_GREY)
        
        if(viewType == self.VIEW_TYPE_WELCOME){
            self.boltImage.image = UIImage(named:self.WELCOME_IMG)
        }else if(viewType == self.VIEW_NEW_LOCATION){
            self.boltImage.image = UIImage(named:self.NEW_LOCATION_IMG)
        }else{
            print("view type not found")
        }
    }
    
    func showAnimate(){
        
        self.view.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        )
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    
    func removeAnimate(){
        UIView.animate(withDuration: 0.5, animations: {
            // perform action on a separeted thread
            self.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.view.alpha = 0;
            
            self.view.frame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y + 600,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height
            )
        }, completion:{
            (finished : Bool)  in
                
            // prevent the system of showing this alert again on this session
            self.feu.stopChangeAlphaLoop()
            self.view.removeFromSuperview()
        })
    }
    
        
        
        
    // LOGIC
        
        
        
        
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
}

