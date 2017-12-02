//
//  DaysTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/2/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    
    // VARIABLES
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var deleteDailyReadings: UIButton!
    
    
    
    internal var showing: Bool = false
    internal var index:IndexPath = IndexPath()
    internal var parentController: DailyReadingsViewController = DailyReadingsViewController()
    
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    // UI
    /*
        Deletes the current day cell
    */
    @IBAction func deleteDay(_ sender: AnyObject) {
        print("Delete day cell")
        
        self.parentController.infoWindowWithCancelToDelete("Os dados não poderão ser recuperados", title: "Tem certeza?", vc: self.parentController, indexPath: index)
    }
    
    
}
