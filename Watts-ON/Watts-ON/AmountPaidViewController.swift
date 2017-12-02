//
//  AmountPaidViewController.swift
//  x
//
//  Created by Diego Silva on 11/4/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class AmountPaidViewController: UIViewController {

    
    
    // VARIABLES
    // containers
    @IBOutlet weak var outterContainer: UIView!
    @IBOutlet weak var innerContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    
    // other outlets
    @IBOutlet weak var amountPaid: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    // helpers
    internal let bvc:BaseViewController = BaseViewController()
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()
    internal let feu:FrontendUtilities = FrontendUtilities()
    
    internal var callerViewController: HomeViewController = HomeViewController()
    internal var closedGoal:Bool = false
        
        
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.amountPaid.keyboardType = .numberPad
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AmountPaidViewController.dismissViewOnBackgroundTap))
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
            self.feu.roundCorners(self.outterContainer, color: self.feu.MEDIUM_GREY)
            
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
            
            if(!self.closedGoal){
                self.callerViewController.archiveGoal()
            }
            
            self.view.removeFromSuperview()
        });
    }
        
        
    /*
        Confirm that the event is going to happen
    */
    @IBAction func save(_ sender: AnyObject) {
        self.closeGoal()
    }
        
        
        
    // LOGIC
    /*
        Get the actual amount paid by the user and update the current goal, save it on the app backend end.
    
        Change the status of the current location-goal relationship to closed, blocking this goal from being 
        visualized again.
    */
    internal func closeGoal(){
        print("\nclosing current goal ...")
        
        // update current goal
        if let paidAmount = Float(self.amountPaid.text!){
            
            // set the value paid by the user for the current goal
            DBHelpers.currentGoal?.setRealBill(paidAmount)
            
            // update current goal locally and on the app backend
            self.dbh.updateCurrentGoal()
           
            // serach for a user-location-goal relationship with the status 'opened'
            let findOpenedGoalQuery:PFQuery = DBHelpers.currentGoal!.openedGoalForLocation(
                DBHelpers.currentLocation!
            )
            
            findOpenedGoalQuery.findObjectsInBackground(block: {
                (goals:[AnyObject]?, error:NSError?) -> Void in
                
                if(error == nil){
                    if let goalRelObj = goals?.first as? PFObject{
                        
                        goalRelObj[self.dbu.DBH_REL_USER_GOALS_STATUS] = self.dbu.DBH_REL_USER_GOALS_POS_STAT[2] // closed
                        
                        goalRelObj.saveInBackground {
                            (success, error) -> Void in
                            
                            if(success){
                                print("display input to get the actual amount paid, in order to finish goal. Or show the archive it message")
                                self.callerViewController.infoWindow("O valor informado foi salvo com sucesso", title:"Muito obrigado pelo feedback (:", vc: self.callerViewController)
                                
                                self.closedGoal = true
                                
                                // erase any trace of the old goal from the datafile manager
                                DBHelpers.eraseGoalTraceFromDatafile()
                                
                                // reset current goal on the system variables
                                DBHelpers.locationGoals[(DBHelpers.currentLocation?.getObId())!] = nil
                                
                                DBHelpers.currentGoal = nil
                                
                                // create a new report object for archived goal
                                self.createReportOutOfOldGoal()
                            }else{
                                print("there was a problem archiving the current goal")
                                self.callerViewController.infoWindow("Houve um erro ao arquivar o objetivo atual", title:"Falha na operação", vc: self.callerViewController)
                            }
                        }
                    }else{
                        print("problem getting user-location object")
                    }
                }else{
                    print("problem getting user-location object \(error!.description)")
                }
            })
            
        }else{
            print("invalid input, try again")
            self.callerViewController.infoWindow("Valor inválido, tente novamente", title: "Atenção", vc: self.callerViewController)
        }
        
    }
    

    
    /*
        Create a new report object with the closed goal data
    */
    internal func createReportOutOfOldGoal(){
        
        print("\ntrying to create a new report about the closed goal ...")
        
        // get current month and year to set new report
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: date)
        let year =  components.year
        let month = components.month
        
        let report = Report()
        
        report.setReportLocation(DBHelpers.currentLocation)
        report.setReportMonth(month)
        report.setReportYear(year)
        report.setDistanceFromGoal(self.dbh.getDistanceOfGoal())
        report.setPredWatts(DBHelpers.currentGoal?.getDesiredWatts())
        report.setRealWatts(self.dbh.getWattsSpentForCurrentGoal())
        report.setPredBill(DBHelpers.currentGoal?.getDesiredValue())
        
        if(Float(self.amountPaid.text!) != nil){
            report.setRealBill(
                NSNumber(value: Float(self.amountPaid.text!)! as Float)
            )
        }
        
        let newReport = report.getNewReport()
        print("new report \(newReport)")
        
        newReport.saveInBackground(block: {
            (success, error:NSError?) -> Void in
            
            if(success){
                print("success on saving new report.")
     
                // reset the home page
                self.removeAnimate()
                
                self.callerViewController.resetUI()
                self.callerViewController.loadData()
                
            }else{
                print("problem saving new report")
            }
        })
    }
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

