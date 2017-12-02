//
//  LoadInfoViewController.swift
//  x
//
//  Created by Diego Silva on 11/22/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class LoadInfoViewController: BaseViewController {

    
    
    // VARIABLES AND CONSTANTS
    @IBOutlet weak var assetBeingLoaded: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loadingPercentage: UILabel!
    @IBOutlet weak var spinner: UIImageView!
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // changing UI according to facebook status
        if(FBSDKAccessToken.current() == nil){
            
            // so far user hasn't prove that he/she has a facebook account
            DBHelpers.userRegType = DBHelpers.USER_REG_TYPE_REGU
            
        }else{
            
            // set the user registration type to facebook
            DBHelpers.userRegType = DBHelpers.USER_REG_TYPE_FACE
        }
        
        
        // checks if the user has a saved session
        if let _ = PFUser.current(){
            print("getting user from last session ...")
            
            let initializer:SystemInitializer = SystemInitializer()
            initializer.lui = self
            initializer.initSystem()
        }else{
            print("user doesn't have old session, send him/her login ...")
            self.feu.goToSegueX(self.feu.ID_LOGIN, obj: self)
        }
    }

    
    /*
        Starts the loading animation, by calling the parent's class methods
    */
    internal func startLoadingAnimation(){
        self.startLoadingAnimation(self.spinner)
    }
    
    
    /*
        Stops the loading animation
    */
    internal func stopLoadingAnimation(){
        self.stopSpinner(self.spinner)
    }
    
    
    
    /*
        Set the loading procec
    */
    internal func setLoadingPercentage(_ percentage:Int, isLast:Bool, loadedAsset:String){
        
        self.loadingPercentage.text = String(percentage)
        self.assetBeingLoaded.isHidden = true
        
        // if there is some usefull information about what is being loaded, display it
        if(loadedAsset != ""){
            self.assetBeingLoaded.text = "Carregando " + loadedAsset + " ..."
            self.feu.fadeIn(self.assetBeingLoaded, speed: 0.3)
        }else{
            
            // if the loading process is ending
            if(percentage > 60){
                self.assetBeingLoaded.text = "Finalizando o carregamento das informações ..."
                self.feu.fadeIn(self.assetBeingLoaded, speed: 0.3)
            }else{
                self.assetBeingLoaded.text = "Carregando informações ..."
            }
        }
        
        if(isLast){
            self.feu.fadeOut(self.spinner, speed:3.2)
            self.feu.fadeOut(self.loadingPercentage, speed:3.2)
            self.feu.fadeIn(self.welcomeLabel, speed: 0.8)
        }
    }
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
