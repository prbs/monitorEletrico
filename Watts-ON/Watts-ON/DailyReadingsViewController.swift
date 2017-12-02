//
//  DailyReadingsViewController.swift
//  x
//
//  Created by Diego Silva on 11/1/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DailyReadingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    // VARIABLES
    @IBOutlet weak var tableView: UITableView!
    
    internal let dbh:DBHelpers         = DBHelpers()
    internal let selector:Selector     = #selector(DailyReadingsViewController.goHome)
    
    internal var days:Array<AnyObject>        = []
    internal var selectedDay:String           = ""
    internal var selectedDayIndex:IndexPath = IndexPath()
    internal var deletedSelectedDay:Bool      = false
    internal var indexPaths:[Int:IndexPath] = [Int:IndexPath]()
    
    internal var hasDevice:Bool = false
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        // UI
        self.customizeNavBar(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // check if the current location has a device
        if let _:Device = DBHelpers.currentDevice{
            self.hasDevice = true
        }else{
            print("current location doesn't have a device.")
        }
        
        self.navigationItem.leftBarButtonItem = self.feu.getHomeNavbarBtn(self.selector, parentVC: self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    
    
    // UI
    // Table methods
    /*
        Number of rows
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
        Number of rows in table
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.days.count
    }
    
    /*
        Build table cells
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // insert the index path on rows controller
        self.indexPaths[indexPath.row] = indexPath
        
        // create and load a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") as! DayTableViewCell
        
        // load cell content
        cell.parentController = self
        cell.index = indexPath
        
        if let dayLabel:String = self.days[indexPath.row] as? String{
            cell.day.text = dayLabel
        }
        
        // enable/disable the delete readings button if the user has a monitoring device for the current location
        if(self.hasDevice){
            cell.deleteDailyReadings.isHidden = true
        }else{
            cell.deleteDailyReadings.isHidden = false
        }
        
        
        return cell
    }

    /*
        Send user to details screen
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell != nil {
            print("selected day cell \(self.days[indexPath.row])")
            if let dayLabel:String = self.days[indexPath.row] as? String{
                self.selectedDay = dayLabel
                self.selectedDayIndex = indexPath
            }
            
            self.performSegue(withIdentifier: self.feu.SEGUE_READINGS, sender: self)
        }
    }
    
    /*
        Delete a table row
    */
    func deleteRowAtIndexPath(_ indexPath: IndexPath) {
        /*  Está dando erro ao deletar um dia automaticamente da interface */
        
        // selected day
        let day = self.days[indexPath.row]
        
        // update the lastSumReadingVal variable
        if let lastSumReadVal = DBHelpers.currentLocationData?.getLastSumReadingVal(){
            
            if let sumOfWattsPerDay = DBHelpers.currentLocationData?.getSumOfWattsForDay(day as! String){
            
                DBHelpers.currentLocationData?.setLastSumReadingVal(
                    lastSumReadVal - sumOfWattsPerDay
                )
                
                // reset the animation controller to allow a new execution of the progress animation on the home screen
                FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT] = false
            }else{
                print("problem getting sum of watts for selected day")
            }
        }else{
            print("problem getting sum of reading values")
        }
        
        // delete day from the currentLocationData 'datafile'
        DBHelpers.currentLocationData?.removeReadingsOfDay(day as! String)
        
        // update app backend file
        DBHelpers.updateLocationData(
            (DBHelpers.currentLocation?.getObId())!,
            dataManager: DBHelpers.currentLocationData!
        )
        
        
        // delete row from datasource
        self.days.remove(at: indexPath.row)
        self.indexPaths.removeValue(forKey: indexPath.row)
        
        // remove cell from table view
        self.tableView.deleteRows(
            at: [indexPath],
            with: UITableViewRowAnimation.automatic
        )
        
        
        // if the user confirmed the deletion of all readings of a day return to the previous screen
        if(self.days.count == 0){
            self.goHome()
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
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            print("user canceled the operation.")
        }))
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    
    // LOGIC
    
    
    
    
    
    // NAVIGATION
    /*
        Send the user back to the home screen by dismissing the current page from the pages stack
    */
    internal func goHome(){
        self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_RD_CHK, sender: self)
    }
    
    
    
    /*
        Get something out of the Readings Details page
    */
    @IBAction func saveReadingDetail(_ segue:UIStoryboardSegue) {
        
        if let _ = segue.source as? ReadingsViewController {
            
            // send the user back to the home page
            if(self.deletedSelectedDay){
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    /*
        Prepare data to next page
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == self.feu.SEGUE_READINGS){
            
            let destineVC = (segue.destination as! ReadingsViewController)
            destineVC.day = self.selectedDay
           
            if let dailyReadings = DBHelpers.currentLocationData?.getDailyReadings(self.selectedDay){
                
                destineVC.times = Array(dailyReadings.keys).sorted()
                destineVC.dailyReadings = dailyReadings
            }else{
                print("problem getting daily readings for location")
            }
            
            // get the position of the clock making a regression from the 'lastSumReadingsVal' until the last input of the selected day
            let sumLastReadingForDay:Double = (
                DBHelpers.currentLocationData?.getSumLastReadingForDay(self.selectedDay)
            )!
            
            destineVC.sumRdgsForLastInpOfDay = sumLastReadingForDay
        }
    }
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
