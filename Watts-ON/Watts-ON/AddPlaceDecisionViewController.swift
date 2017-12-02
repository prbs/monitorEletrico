//
//  CadastroDecisionViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/23/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class AddPlaceDecisionViewController: BaseViewController {

    
    // VARIABLES
    @IBOutlet weak var doubtBtn:UIButton!
    @IBOutlet weak var info: UILabel!
    
    // CONSTANTS
    internal let selector:Selector = #selector(AddPlaceDecisionViewController.goHome)
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getHomeNavbarBtn(self.selector, parentVC: self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.customizeNavBar(self)
    }

    
    
    // UI
    /*
        Show information outlet
    */
    @IBAction func showInfo(_ sender: AnyObject) {
        if(self.info.isHidden){
            self.feu.fadeIn(self.info, speed: 0.6)
        }else{
            self.feu.fadeOut(self.info, speed: 1.0)
        }
    }
    
    
    
    // NAVIGATION
    /*
        Send the user back to the home screen by dismissing the current page from the pages stack
    */
    internal func goHome(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    /*
        Get response from "user create location"
    */
    @IBAction func unwindAfterLocationCreation(_ segue:UIStoryboardSegue) {
        if let upsertVC:UpsertPlaceViewController = segue.source as? UpsertPlaceViewController{
            print("came back from new location ...")
            
            self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_NEW_LOC, sender: upsertVC)
        }
    }
    
    
    /*
        Get response from the "user joined location"
    */
    @IBAction func unwindAfterLocationJoinOperation(_ segue:UIStoryboardSegue) {
        if let joinPlaceVC:AddPlaceAsGuestViewController = segue.source as? AddPlaceAsGuestViewController{
            print("came back from join location ...")
            
            self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_NEW_LOC, sender: joinPlaceVC)
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
