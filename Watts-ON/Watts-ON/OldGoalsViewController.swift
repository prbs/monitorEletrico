//
//  OldGoalsViewController.swift
//  x
//
//  Created by Diego Silva on 10/28/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class OldGoalsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    // VARIABLES
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIView!
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils   = DBUtils()
    
    internal var canSave:Bool = false
    internal var userGoals:Array<Goal?> = Array<Goal?>()
    internal var userGoalsStatus:Array<String> = Array<String>()
    internal var reports:Array<Report?> = Array<Report?>()
    internal var cells:[IndexPath:OldGoalTableViewCell] = [IndexPath:OldGoalTableViewCell]()
    //internal var timer: NSTimer? = nil
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        
        // UI initialization
        self.customizeNavBar(self)
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        self.customizeMenuBtn(self.homeBtn, btnIdentifier: self.feu.ID_HOME)
        
        // Logic
        if(!DBHelpers.lockedSystem){
            self.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI customizations
        self.customizeNavBar(self)
        self.customizeAddBtn(self.saveBtn)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // binds the show menu toogle action implemented by SWRevealViewController to the menu button
        if self.revealViewController() != nil {
            self.menuBtn.target = self.revealViewController()
            self.menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    
    
    
    // UI
    /*
        Table methods
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userGoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "OldGoalCell") as! OldGoalTableViewCell
        
        self.cells[indexPath] = cell
        
        // get goal out of array of goals
        if let goal = self.userGoals[indexPath.row]{
            
            // load the new cell with data
            cell.parentController = self
            cell.index = indexPath
            
            // get period of the old goal
            let startDate:String = goal.getStartingDate()!.formattedWith(self.feu.DATE_FORMAT)
            let endDate:String   = goal.getEndDate()!.formattedWith(self.feu.DATE_FORMAT)
            cell.period.text = startDate + " até " + endDate
            
            cell.desiredValue.text = "R$ " + String(goal.getDesiredValue().doubleValue.format("0.2"))
            
            print("goal status \(userGoalsStatus[indexPath.row])")
            
            // check if the goal is closed on the reports list or opened on the current goals, if it if lock the field, otherwise allow editing
            if(userGoalsStatus[indexPath.row] == "archived"){
                cell.valuePaidLabel.text = "VALOR PAGO"
                cell.oldGoalStatus.image = UIImage(named:"archive-2.png")
                cell.actualValue.delegate = self
                cell.actualValue.keyboardType = .numberPad
                cell.actualValue.isEnabled = true
                
            }else if(userGoalsStatus[indexPath.row] == "closed"){
                cell.valuePaidLabel.text = "VALOR PAGO"
                cell.oldGoalStatus.image = UIImage(named:"closed.png")
                cell.actualValue.isEnabled = false
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
            }else{
                cell.valuePaidLabel.text = "VALOR PAGO ATÉ AGORA"
                cell.oldGoalStatus.isHidden = true
                cell.actualValue.isEnabled = false
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
            
            cell.actualValue.text = "R$ " + String(goal.getActualValue().doubleValue.format("0.2"))
        }
        
        return cell
    }
    
    
    /*
        Delete a table row
    */
    func deleteRowAtIndexPath(_ indexPath: IndexPath) {
        
        // delete row from datasource
        self.cells.removeValue(forKey: indexPath)
        
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        
        // if the user confirmed the deletion of all readings of a day return to the previous screen
        if(self.cells.count == 0){
            self.updateReadingsOfSelectedDay()
            self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_TO_DAILY_R, sender:self)
        }
    }
    
    
    /*
        Modified version of the method above with the cancel option
    */
    internal func infoWindowWithCancelToDelete(_ txt:String, title:String, vc:UIViewController, indexPath:IndexPath) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            
            self.deleteRowAtIndexPath(indexPath)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            print("user canceled the operation")
        }))
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    /*
        Text field methods
    */
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text{
            let fullNameArr = text.components(separatedBy: " ")
            
            var value:String = ""
            if(fullNameArr.count == 1){
                value = fullNameArr[0]
            }else if(fullNameArr.count == 2){
                value = fullNameArr[1]
            }
                
            textField.text = value
        }else{
            print("problem converting textinput field in a text. Whattt")
        }
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("shouldChangeCharactersInRange")
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: Selector("dismissKeyboard:"), userInfo: textField, repeats: false)
        return true
    }
    
    override func dismissKeyboard(_ timer: Timer) {
        print("dismiss keyboard for textField: \(timer.userInfo!)")
        if let textField = timer.userInfo as? UITextField{
           textField.resignFirstResponder()
            
            if let value = textField.text{
                textField.text = "R$ " + value
            }else{
                print("problem unwrapping value")
            }
        }else{
            print("problem getting textfield out of the userInfo variable of the timer object")
        }
    }
    
    
    
    
    
    /*
        Save current data
    */
    @IBAction func save(_ sender: AnyObject) {
        print("saving daily readings ...")
    }
    
    
    
    
    // LOGIC
    /*
        Load old goals (archived and opened goals) into the array of old goals
    */
    internal func loadData(){
        print("getting list of the user goals ...")
        
        // request data from the app backend
        PFCloud.callFunction(inBackground: "getUserGoals", withParameters:[
            "userId":PFUser.current()!.objectId!,
            "locationId":DBHelpers.currentLocation!.getObId()
        ]) {
            (goalsObjs, error) in
                
            if (error == nil){
                // get list of user_goal relationships
                if let goalsPointersArray:Array<AnyObject> = goalsObjs as? Array<AnyObject> {
                    
                    if(goalsPointersArray.count > 0){
                    
                    // iterate though each relationship object to get the actual goal object
                    for i in 0...(goalsPointersArray.count - 1){
                            
                        // get a goal_user relationship object
                        if let userGoalObj = goalsPointersArray[i] as? PFObject{
                            
                            // get goal status
                            if let status = userGoalObj[self.dbu.DBH_REL_USER_GOALS_STATUS] as? String{
                                self.userGoalsStatus.append(status)
                            }else{
                                print("problem getting goal status")
                            }
                            
                            // get goal object out of user_goal relationshiop object
                            if let goalPointer = userGoalObj[self.dbu.DBH_REL_USER_GOALS_GOAL]{
                                    
                                // get goal id
                                if let goalId:String = (goalPointer as AnyObject).objectId{
                                    print("goalId \(goalId)")
                                        
                                    // get the actual goal object
                                    if(i == (goalsPointersArray.count - 1)){
                                        self.getGoalById(goalId, isLast:true)
                                    }else{
                                        self.getGoalById(goalId, isLast:false)
                                    }
                                }else{
                                    print("error getting goal if out of goal pointer")
                                }
                            }else{
                                print("error getting goal out of user_goal relationship object")
                            }
                        }else{
                            print("problem unwraping tip object from array")
                        }
                    }
                    }
                }else{
                    print("problems converting results into array of tips.")
                }
            }else{
                print("\nerror: \(error)")
            }
        }
    }
    
    
    
    /*
        Get pointed Goals
    */
    internal func getGoalById(_ goalId:String, isLast:Bool){
        
        let query = PFQuery(className: self.dbu.DB_CLASS_GOAL)
        query.getObjectInBackground(withId: goalId) {
            (goal, error) -> Void in
            
            if(error == nil){
                print("goal \(goal)")
                
                if let goal:PFObject = goal{
                    self.userGoals.append(Goal(goal:goal))
                    
                    if(isLast){
                        print("reloading table view ...")
                        self.tableView.reloadData()
                    }else{
                        print("still have to load more goals ...")
                    }
                }else{
                    print("error converting PFObject into goal")
                }
            } else {
                print("error getting data from backend \(error)")
            }
        }
    }
    
    
    
    
    /*
        Get values current values and update the readings of the selected day
    */
    internal func updateReadingsOfSelectedDay(){
        print("Updating readings of the selected day ...")
        
        if(self.canSave){
            
            print("cells count: \(self.cells.count)")
            if(self.cells.count == 0){
                // perform database operations in case the table is empty
            }else{
                // perform database operations
            }
        }else{
            self.infoWindow("Falha ao atualizar os dados de leitura", title: "Falha operacional", vc: self)
        }
    }
    
    
    
    // NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == self.feu.SEGUE_UNWIND_TO_DAILY_R {
            
            // get an instance of the previous controller
            let sourceVC = segue.destinationViewController as! DailyReadingsViewController
            
            // save current data
            self.updateReadingsOfSelectedDay()
            
            // if the number of readings is empty return a flag to delete day from list
            if(self.cells.count == 0){
                sourceVC.deletedSelectedDay = true
            }
        }*/
    }
    
    
    
    // NAVIGATION
    /*
        Send the user to the home page
    */
    @IBAction func goHome(){
        self.feu.goToSegueX((self.feu.ID_HOME), obj: self)
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
