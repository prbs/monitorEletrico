//
//  ReadingsViewController.swift
//  x
//
//  Created by Diego Silva on 11/2/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class ReadingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{

    
    // VARIABLES
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewCell: UITableView!
    
    internal let dbh:DBHelpers     = DBHelpers()
    internal let selector:Selector = #selector(ReadingsViewController.updateReadingsOfSelectedDay)
    
    internal var day:String                               = ""
    internal var times:Array<AnyObject>                   = []
    internal var dailyReadings:[String:Double]            = [String:Double]()
    internal var isItLastestDay:Bool                      = false
    
    internal var sumRdgsForLastInpOfDay:Double            = 0.0
    internal var cells:[IndexPath:ReadingTableViewCell] = [IndexPath:ReadingTableViewCell]()
    internal var canSave:Bool                             = true
    
    internal var hasDevice:Bool = false
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        // get the initial value of watts to present the data based on readings and and not in amount of watts
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI customizations
        self.customizeNavBar(self)
        self.customizeAddBtn(self.saveBtn)
        
        // customize the back button navbar item to save data when leave page
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(self.selector, parentVC: self, labelText:"<")
        
        if(self.day != ""){
            self.dayLabel.text = "Leituras do dia " + self.day
        }else{
            print("day is empty")
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // check if the current location has a device
        if let _:Device = DBHelpers.currentDevice{
            self.hasDevice = true
        }else{
            print("current location doesn't have a device.")
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
        return self.times.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // load cell for readings done with a device
        if(self.hasDevice){
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceReadingCell") as! DeviceReadingTableViewCell
            
            // load the new cell with data
            cell.time.text = String(describing: self.times[indexPath.row])
            
            if let t = self.times[indexPath.row] as? String{
            
                if let val = self.dailyReadings[t]{
                    cell.value.text = String(val.format(".8"))
                }else{
                    print("problem converting value from readings into an integer")
                }
            }else{
                print("problem getting time label")
            }
            
            return cell
          
        // load cells done manually
        }else{
            
            // create a new cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingCell") as! ReadingTableViewCell
            
            self.cells[indexPath] = cell
            
            // load the new cell with data
            cell.parentController   = self
            cell.index              = indexPath
            cell.time.text          = String(describing: self.times[indexPath.row])
            
            if let t = self.times[indexPath.row] as? String{
                
                if let val = self.dailyReadings[t]{
                    cell.value.text = String(val.format(".2"))
                }else{
                    print("problem converting value from readings into an integer")
                }
            }else{
                print("problem getting time label")
            }
            
            var sumReadingForTime = self.sumRdgsForLastInpOfDay
                
         
                
            cell.sumOfReadings.text     = String(sumReadingForTime.format(".2"))
            cell.sumOfReadings.isHidden   = false
            cell.sumOfReadings.isEnabled  = false
            
            cell.readingImgLabel.isHidden = false
            
            // only the user can delete a reading
            if(DBHelpers.isUserLocationAdmin){
                cell.deleteReadingBtn.isHidden = false
            }
                
            return cell
        }
    }
    
    
    /*
        Delete a table row
    */
    func deleteRowAtIndexPath(_ indexPath: IndexPath) {
        
        FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT] = false
        
        // the sumLastReadingVal
        if let cell = self.cells[indexPath]{
            DBHelpers.currentLocationData?.setLastSumReadingVal(
                (DBHelpers.currentLocationData?.getLastSumReadingVal())! - Double(cell.value.text!)!
            )
        }
        
        // delete row from datasource
        if(self.times.count > 0){
            
            if let time = self.times[indexPath.row] as? String{
                self.dailyReadings.removeValue(forKey: time)
            }
            
            self.times.remove(at: indexPath.row)
            self.cells.removeValue(forKey: indexPath)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            // if the user confirmed the deletion of all readings of a day return to the previous screen
            if(self.cells.count == 0){
                self.updateReadingsOfSelectedDay()
                self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_TO_DAILY_R, sender:self)
            }
        }else{
            print("If the time labels dialog is ok")
        }
    }
    
    
    /*
        Normalize data if user screw up
    */
    func textFieldDidChange(_ textField: UITextField) {
        
        // check for empty values
        if(textField.text == ""){
            self.infoWindow("Existe um valor 'vazio' em suas leituras", title: "Leitura vazia (:", vc: self)
            self.canSave = false
        }else{
            
            if(!self.validateReadings()){
                self.canSave = false
            }else{
                self.canSave = true
            }
        }
    }

    
    /*
        Modified version of the method above with the cancel option
    */
    internal func infoWindowWithCancelToDelete(_ txt:String, title:String, vc:UIViewController, indexPath:IndexPath) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            
            if(DBHelpers.isUserLocationAdmin){
                self.deleteRowAtIndexPath(indexPath)
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            print("user canceled the operation")
        }))
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    /*
        Save current data
    */
    @IBAction func save(_ sender: AnyObject) {
        print("saving daily readings ...")
    }
    
    
    
    
    // LOGIC
    /*
        Get current values and update the readings of the selected day
    */
    internal func updateReadingsOfSelectedDay(){
        print("Updating readings of the selected day ...")
        
        // if data is valid
        if(self.canSave){
            
            // if there are no readings for the day, delete the day from the local datafile
            if(self.dailyReadings.count == 0){
                
                // save changes on the local datafile
                DBHelpers.currentLocationData!.removeReadingsOfDay(self.day)
            }
           
            // save changes on the local datafile and on the app backend
            if(DBHelpers.currentLocationData!.updateReadingsByDay(
                self.day, updatedReadings:self.dailyReadings
            )){
                // save data in the app backend
                DBHelpers.updateLocationData(
                    (DBHelpers.currentLocation?.getObId())!,
                    dataManager: DBHelpers.currentLocationData!
                )
            }
            
            // send user back to the list of days with readings
            performSegue(withIdentifier: "SaveReadingDetailSegue", sender: self)
        }else{
            self.infoWindow("Falha ao atualizar os dados de leitura", title: "Falha operacional", vc: self)
        }
    }
    
    
    /*
        Validate all readings for the condition "an older reading must have a higher value"
    */
    internal func validateReadings() -> Bool{
        return true
    }
    
    
    
    
    // NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.feu.SEGUE_UNWIND_TO_DAILY_R {
            
            // get an instance of the previous controller
            let sourceVC = segue.destination as! DailyReadingsViewController
            
            // if the number of readings is empty return a flag to delete day from list
            if(self.cells.count == 0){
                sourceVC.deletedSelectedDay = true
            }
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
