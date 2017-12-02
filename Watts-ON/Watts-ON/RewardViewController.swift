//
//  RewardViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/13/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class RewardViewController: BaseViewController {

    
    // VARIABLES
    // containers
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    
    
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentContainer: UIView!
    
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var rewardImage: UIImageView!
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var rewardDescription: UITextView!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    internal var reward:Reward? = nil
    
    internal let selector:Selector = #selector(RewardViewController.back)
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        
        // check if the reward object is initialized and load it
        if(self.reward != nil){
            print("selected reward on Reward/Details \(reward)")
            
            // load UI if values of loaded reward
            self.rewardTitle.text = self.reward?.getRewardTitle()
            self.rewardDescription.text = self.reward?.getRewardInfo()
            
            let pic = reward!.getRewardPicture()
            if(pic != nil){
                pic!.getDataInBackground(block: {
                    (imageData: Data?, error: NSError?) -> Void in
                    
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        self.rewardImage.image = image
                    }
                })
            }else{
                self.rewardImage.image = UIImage(named:"imgres.jpg")
            }
        }else{
            print("selected reward is nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        self.setScroller()
        
        // check if the user is the owner of the reward
        if let ownerId = self.reward?.getRewardOwner()?.objectId{
        
            if let userId = PFUser.current()?.objectId{
            
                if(ownerId == userId){
                    // enable delete and update options to reward admin
                    self.updateBtn.isEnabled = true
                    self.updateBtn.isHidden = false
                    
                    self.deleteBtn.isEnabled = true
                    self.deleteBtn.isHidden = false
                }else{
                    // block delete and update options to regular users
                    self.updateBtn.isEnabled = false
                    self.updateBtn.isHidden = true
                    
                    self.deleteBtn.isEnabled = false
                    self.deleteBtn.isHidden = true
                }
            }else{
                print("weird, could not get current user id")
            }
        }else{
            print("could not get reward owner id")
        }
        
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(self.selector, parentVC: self, labelText: "<")
        
        self.customizeNavBar(self)
    }

    
    
    // UI
    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
        self.scroller.isUserInteractionEnabled = true
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = self.contentContainer.frame.size.height
        self.scroller.contentSize.width = self.contentContainer.frame.size.width
    }
    
    
    /*
        Deletes the reward currently set in this cell
    */
    @IBAction func deleteReward(_ sender: AnyObject) {
        print("\ndeleting reward ...")
        
        if let id = self.reward?.getObId(){
            self.infoWindowWithCancel("Uma recompensa deletada não poderá ser recuperada.", title: "Tem certeza?", objId: id)
        }else{
            print("could not get reward id")
        }
    }
    
    
    /*
        Send the admin user to the new reward page on the update mode
    */
    @IBAction func updateReward(_ sender: AnyObject) {
        print("updating reward ...")
        
        self.performSegue(withIdentifier: self.feu.SEGUE_REWARD_UPDATE, sender: nil)
    }
    
    
    
    
    // LOGIC
    /*
        Show an information window allowing the user to cancel his/her choice
    */
    internal func infoWindowWithCancel(_ txt:String, title:String, objId:String) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Confirmar", style: .default, handler: { (action: UIAlertAction) in
            
            // start loading process
            self.feu.fadeIn(self.screenLocker, speed: 0.6)
            self.startLoadingAnimation(self.spinner)
            
            self.deleteRewardFromBackend(objId)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            
            print("\nuser canceled operation")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    /*
        Deletes a reward from the app backend
    */
    internal func deleteRewardFromBackend(_ rewardId:String){
        
        let query = Reward.query()
        query!.getObjectInBackground(withId: rewardId){
            (rewardObj, error) -> Void in
            
            print("Reward that is going to be deleted: \(rewardObj)")
            
            if(error == nil){
                
                rewardObj?.deleteInBackground{
                    (success, error) -> Void in
                    
                    if(error == nil){
                        
                        // unlock the screen
                        self.feu.fadeOut(self.screenLocker, speed: 0.6)
                        self.stopSpinner(self.spinner)
                        
                        // send user back to the rewards list page
                        self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_DEL_REW, sender: nil)
                    }else{
                        print("failed to create new Reward")
                        self.infoWindow("Falha ao deletar recompensa", title: "Falha na operação", vc:self)
                        
                        // unlock the screen
                        self.feu.fadeOut(self.screenLocker, speed: 0.6)
                        self.stopSpinner(self.spinner)
                    }
                }
            }else{
                print("error, no reward found for the id \(rewardId)")
                self.infoWindow("Erro de conexão com o servidor", title: "Erro de conexão", vc:self)
                
                // unlock the screen
                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                self.stopSpinner(self.spinner)
            }
        }
    }
    
    
    
    
    
    // NAVIGATION
    /*
        Go back to the rewards list page
    */
    internal func back(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    /*
        Prepare data to next screen
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == self.feu.SEGUE_REWARD_UPDATE){
            let destineVC = (segue.destination as! NewRewardViewController)
            
            print("\ntrying to update selected reward object: \(sender)")
            destineVC.task = "update"
            destineVC.reward = self.reward
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
