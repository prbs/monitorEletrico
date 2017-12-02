//
//  FinishedWithSucessViewController.swift
//  x
//
//  Created by Diego Silva on 11/3/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class FinishedWithSucessViewController: UIViewController {

    
    // VARIABLES AND CONSTANTS
    // containers
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundInnerView: UIView!
    @IBOutlet weak var rewardTitleContainer: UIView!
    
    // reward related outlets
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var rewardImage: UIImageView!
    
    // no reward outlet
    @IBOutlet weak var noRewardImage: UIImageView!
    
    // information labels
    @IBOutlet weak var successMsg: UILabel!
    
    // helpers
    internal let bvc:BaseViewController = BaseViewController()
    internal let dbh:DBHelpers = DBHelpers()
    internal let feu:FrontendUtilities = FrontendUtilities()
    
    internal var callerViewController: HomeViewController = HomeViewController()

        
        
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FinishedWithSucessViewController.dismissViewOnBackgroundTap))
        self.view.addGestureRecognizer(tapGesture)
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
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
    func showInView(_ aView: UIView!, animated: Bool){
            
        aView.addSubview(self.view)
        if animated{
            self.showAnimate()
        }
    }
    
        
    func showAnimate(){
        
        self.view.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height - self.feu.getNavbarHeight()
        )
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            self.feu.roundCorners(self.backgroundView, color: self.feu.MEDIUM_GREY)
        });
    }
    
    
    
    
    /*
        Close input dialog view
    */
    @IBAction func closePopup(_ sender: AnyObject) {
        
        self.removeAnimate()
    }
    
    
    /*
        Close input dialog view
    */
    func dismissViewOnBackgroundTap(){
        self.removeAnimate()
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
                    
                // inform the caller view controller that the operation went wrong
                self.callerViewController.displayFinishedGoalMessage()
                self.view.removeFromSuperview()
        });
            
    }

        
    
    
    // LOGIC
        
        
        
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
        
}

