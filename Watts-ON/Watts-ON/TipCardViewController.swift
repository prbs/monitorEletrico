//
//  TipCardViewController.swift
//  x
//
//  Created by Diego Silva on 11/5/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class TipCardViewController: UIViewController {

    
    // VARIABLES
    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var tipTitle: UILabel!
    @IBOutlet weak var observation: UITextView!
    
    @IBOutlet weak var outterContainer: UIView!
    @IBOutlet weak var innerContainer: UIView!
    
    
    internal let bvc:BaseViewController = BaseViewController()
    internal let dbh:DBHelpers = DBHelpers()
    internal let feu:FrontendUtilities = FrontendUtilities()
    
    internal var callerViewController: HomeViewController = HomeViewController()
    internal var afterFailure:Bool = false
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TipCardViewController.dismissViewOnBackgroundTap))
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
            
            // customize container borders
            self.feu.roundCorners(self.outterContainer, color: self.feu.MEDIUM_GREY)
            self.feu.verticallyCentralizeElement(self.outterContainer, parentView: self.view, speed: 0.6)
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
                if(self.afterFailure){
                    self.callerViewController.displayFinishedGoalMessage()
                }
                
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
