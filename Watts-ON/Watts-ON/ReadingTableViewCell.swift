//
//  ReadingTableViewCell.swift
//  x
//
//  Created by Diego Silva on 11/2/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class ReadingTableViewCell: UITableViewCell, UITextFieldDelegate {

    
    // VARIABLES
    @IBOutlet weak var readingImgLabel: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var sumOfReadings: UILabel!
    
    @IBOutlet weak var deleteReadingBtn: UIButton!
    
    
    
    internal var kbHeight: CGFloat!
    internal var index:IndexPath = IndexPath()
    internal var parentController:ReadingsViewController = ReadingsViewController()
    
    
    
    // INITIALIZERS
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add gesture recognizer to enable the dismiss keyboard action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ReadingTableViewCell.dismissKeyboard))
        self.addGestureRecognizer(tapGesture)
    }

    
    
    //UI
    /*
        Delete the current readings from the table
    */
    @IBAction func deleteReading(_ sender: AnyObject) {
        print("delete cell from table")
        self.parentController.infoWindowWithCancelToDelete("Os dados não poderão ser recuperados", title: "Tem certeza?", vc: self.parentController, indexPath: index)
    }
    
    
    /*
        Dismiss keyboard when the user taps outside of the text field
    */
    func dismissKeyboard() {
        self.value.endEditing(true)
    }


}
