//
//  MenuViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    
    // VARIABLES
    let feu:FrontendUtilities = FrontendUtilities()
    let dbh:DBHelpers         = DBHelpers()
    let dbu:DBUtils           = DBUtils()
    
    internal var destination = ""
    internal var menuItems:NSArray = NSArray()
    internal var userPicture:UIImage = UIImage()
    internal var colorForCellUnselected:CGColor? = nil
    internal let CELL_PRESENTATION_SPEED = 0.4
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .black
        
        self.menuItems = self.feu.MAIN_MENU_ITEMS as NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    // UI
    /* 
        Table view method, returns the number of sections
    */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    /*
        Table view method, returns the number of rows in the current section
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    
    /* 
        Customize the menu, defining different prototype cells according to the menu opton
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cellIdentifier:String = self.menuItems.object(at: indexPath.row) as! String
        
        // loads the user profile cell
        if(cellIdentifier == self.feu.MAIN_MENU_ITEMS[0]){
            
            // profile cell
            let cell = tableView.dequeueReusableCell(withIdentifier: self.feu.MAIN_MENU_ITEMS[0], for: indexPath) as! ProfileTableViewCell
            
            // username
            if let name = PFUser.current()?.object(forKey: "name") as? String{
                cell.username.text = name
            }else{
                cell.username.text = PFUser.current()?.username
            }
            
            // picture
            let user = PFUser.current()
            let picture = user?.object(forKey: "picture")
            if(picture != nil){
                (picture! as AnyObject).getDataInBackground(block: {
                    (imageData: Data?, error: NSError?) -> Void in
                    
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        
                        print("Image orientation after saving \(image!.imageOrientation.rawValue)")
                        
                        cell.profilePic.image = image
                        self.feu.roundIt(cell.profilePic, color:self.feu.NAVBAR_BACKGROUND_COLOR)
                    }
                })
            }else{
                cell.profilePic.image = UIImage(named: "user.png")
                self.feu.roundIt(cell.profilePic, color:self.feu.NAVBAR_BACKGROUND_COLOR)
            }
            
            return cell
            
        }else if(cellIdentifier == self.feu.MAIN_MENU_ITEMS[self.feu.MAIN_MENU_ITEMS.count - 1]){
            
            var cell:LogoutTableViewCell = LogoutTableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LogoutTableViewCell
            
            // centralize tableViewCell items
            self.feu.verticallyCentralizeElement(
                cell.btnLabel,
                parentView: cell.contentView,
                speed:self.CELL_PRESENTATION_SPEED
            )
            self.feu.verticallyCentralizeElement(
                cell.btnImage,
                parentView: cell.contentView,
                speed:self.CELL_PRESENTATION_SPEED
            )
            
            return cell
            
        }else{
            
            var cell:RegularTableViewCell = RegularTableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RegularTableViewCell
            
            // centralize tableViewCell items
            self.feu.verticallyCentralizeElement(
                cell.btnLabel,
                parentView: cell.contentView,
                speed:self.CELL_PRESENTATION_SPEED
            )
            self.feu.verticallyCentralizeElement(
                cell.btnImage,
                parentView: cell.contentView,
                speed:self.CELL_PRESENTATION_SPEED
            )
            
            return cell
        }
    }


    /*
        Overrides the table row height, it specifies the height of the profile table view cell
    */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let cellIdentifier:String = self.menuItems.object(at: indexPath.row) as! String
        if(cellIdentifier == "perfil"){
            return 180.0
        }else{
            // get phone height
            let screenSize: CGRect = UIScreen.main.bounds
            let screenHeight = screenSize.height
            
            return (screenHeight - 180.0)/CGFloat(self.menuItems.count - 1)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // if the user selected the logout cell
        if(indexPath.row == 5){
            self.dbh.logout()
        }else{
            
            let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                
            if(indexPath.row != 0){
                self.feu.animationMenuOptionOnSelection(selectedCell)
            }else{
                self.feu.animationMenuOptionONSelectionForHeader(selectedCell)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if(indexPath.row != 0){
            let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
            cellToDeSelect.contentView.layer.backgroundColor = self.feu.SIDEBAR_BODY_NORMAL_COLOR.cgColor
        }
    }
    
    
    
    
    
    
    
    
    
    // NAVIGATION
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
}
