//
//  AlertViewController.swift
//  x
//
//  Created by Diego Silva on 11/3/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class AlertViewController: BaseViewController {
    
        
    // VARIABLES
    @IBOutlet weak var msg: UITextView!
    @IBOutlet weak var tipBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    
    internal let dbh:DBHelpers = DBHelpers()
    internal var callerViewController:HomeViewController = HomeViewController()
        
    
    
    // INITIALIZERSx
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AlertViewController.dismissViewOnBackgroundTap))
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
            height: UIScreen.main.bounds.size.height
        )
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    
    /*
        Close input dialog view
    */
    @IBAction func closePopupFromCloseBtn(_ sender: AnyObject) {
        self.removeAnimate()
    }
        
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
                    
            // prevent the system of showing this alert again on this session
            DBHelpers.alertMsgController[(DBHelpers.currentLocation?.getObId())!] = true
            self.view.removeFromSuperview()
        });
            
    }
        
    
    
    /*
        Redirects the user to the tip's page
    */
    @IBAction func goTips(_ sender: AnyObject) {
        print("load a tip that matches the user needs.")
        
        self.callerViewController.openTipDialog(false)
        self.removeAnimate()
    }
    
    
    
    
    // LOGIC
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

