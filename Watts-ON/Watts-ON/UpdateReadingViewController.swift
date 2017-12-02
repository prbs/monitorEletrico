//
//  UpdateReadingViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/22/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class UpdateReadingViewController: UIViewController {

    
    
    // VARIABLES
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var reading: UITextField!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lastReading: UILabel!
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    internal let dbh:DBHelpers = DBHelpers()
    internal var callerViewController: BaseViewController = BaseViewController()
    internal var savedValue:Bool     = false
    
    internal var isFirstReading:Bool    = false
    internal var value:Double           = -1.0
    internal let STD_READING_VAL:Double = -1.0
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UpdateReadingViewController.dismissViewOnBackgroundTap))
        
        self.view.addGestureRecognizer(tapGesture)
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        // Do any additional setup after loading the view.
        self.reading.keyboardType = .numberPad
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    // UI
    /*
        Customize view
    */
    internal func customizeView(){
        self.feu.roundCorners(self.container, color:self.feu.MEDIUM_GREY)
    }
    
    
    /*
        Pop up dialog
    */
    func showInView(_ aView: UIView!, withImage image : UIImage!, withMessage message: String!, animated: Bool){
        
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
        });
        
        // set last reading to facilitate new input
        if let curLocData = DBHelpers.currentLocationData{
            self.lastReading.text = String(curLocData.getLastSumReadingVal().format(".0"))
        }else{
            print("could not get current location data")
        }
    }
    
    
    /*
        Save input
    */
    @IBAction func save(_ sender: AnyObject) {
        
        if let val:Double = Double(self.reading.text!){
            self.saveReading(val)
        }else{
            print("only numeric values are accepted")
        }
    }

    
    /*
        Dismiss view
    */
    @IBAction func closePopupFromCloseBtn(_ sender: AnyObject) {
        self.removeAnimate(-1)
    }
    
    func dismissViewOnBackgroundTap(){
        self.removeAnimate(-1)
    }
    
    func removeAnimate(_ value:Double){
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
            
            // update the caller view controller with the inserted value
            self.callerViewController.setReadingValue(self.value)
            
            self.view.removeFromSuperview()
        });
        
    }

    
    
    // LOGIC
    /*
        Try to add a new reading in the local history file, and upload the updated file to 
        the app backend
    */
    internal func saveReading(_ newReading:Double){
        
        // if it is the first reading of a goal and the user is inserting the readings without a 'Bolt' monitoring device
        if(self.isFirstReading){
            print("\nthis is a reading made for a new goal, reseting sumLastReadingsVal ...")
            
            self.value = newReading
            self.removeAnimate(newReading)
        }else{
            print("\nmanual reading, getting lastSumReadingVal to operate ...")
            
            let lastReadingVal = DBHelpers.currentLocationData?.getLastSumReadingVal()
            
            // check if the last reading value is valid 'for manual reading'
            if(lastReadingVal >= 0){
                
                // insert a new value into the location datafile, considering whether the user is using a 'Bolt' monitoring device or not.
                if(DBHelpers.currentDevice == nil){
                    
                    // check if the value being inserted is bigger than the last one
                    if(newReading > lastReadingVal){
                        
                        // update current datafile manager locally
                        DBHelpers.currentLocationData!.addReading(newReading)
                        DBHelpers.currentLocationData!.save()
                        
                        // update datafile on the app backend
                        DBHelpers.updateLocationData(
                            (DBHelpers.currentLocation?.getObId())!,
                            dataManager: DBHelpers.currentLocationData!
                        )
                        
                        // update goal with new values
                        self.dbh.updateCurrentGoal()
                        
                        // set flag to avoid redundance
                        self.savedValue = true
                        
                        // dismiss dialog
                        self.removeAnimate(newReading)
                    }else{
                        print("input is smaller than last reading value")
                        self.showInvalidDialog()
                    }
                }else{
                    print("user has a device attached to this location and is trying to make a manual reading")
                }
            }else{
                print("negative input")
                self.showInvalidDialog()
            }
        }
    }
    
    

    /*
        Let the user know that the input wasn't good. A valid input must be bigger than the last one.
    */
    internal func showInvalidDialog(){
        self.view.removeFromSuperview()
        
        let title = "O valor inserido não é válido"
        let msg = "O valor informado é menor do que o último valor de leitura do seu relógio."
        
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Tentar novamente", style: .default, handler: { (action: UIAlertAction) in
            
            print("showing input dialog again")
            self.showInView(
                self.callerViewController.view,
                withImage: UIImage(named: ""),
                withMessage: "",
                animated: true
            )
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction) in
            
            print("user canceled the operation.")
        }))
        
        self.callerViewController.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
