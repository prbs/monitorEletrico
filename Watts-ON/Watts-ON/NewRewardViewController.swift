//
//  NewRewardViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/13/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//


import UIKit



class NewRewardViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // VARIABLES
    
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var imageSizeWarning: UILabel!
    @IBOutlet weak var selectPicture: UIButton!
    
    @IBOutlet weak var rewardTitle: UITextField!
    @IBOutlet weak var rewardPicture: UIImageView!
    @IBOutlet weak var rewardDescription: UITextView!
    @IBOutlet weak var selectedPicture: UIImageView!
    @IBOutlet weak var pictureSelectorBar: UIView!
    
    
    
    
    
    internal let dbu:DBUtils = DBUtils()
    internal var reward:Reward? = nil
    internal var task:String? = "create"
    
    internal let IMAGE_SIZE = 900000
    internal let ACTION_NAV_BACK = "back"
    internal let ACTION_NAV_STAY = "stay"
    internal let selector:Selector = #selector(NewRewardViewController.back)
    
    internal var imagePicker = UIImagePickerController()
    internal let imgPicController:ImagePickerViewController = ImagePickerViewController()
    internal var selectedPictureFile:PFFile? = nil
    
    
    // INITIALIZERS
    
    override func viewDidAppear(_ animated: Bool) {
       // do something
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("reward on Reward Upsert: \(self.reward) selected task: \(self.task)")
        
        // UI
        
        self.setScroller()
        
        // keyboard animation
        self.rewardTitle.delegate = self
        self.rewardDescription.delegate = self
        
        
        
        // load reward information
        
        if(self.reward != nil){
            self.rewardTitle.text = self.reward?.getRewardTitle()
            if let image = self.reward?.getRewardPictureImg(){
                self.rewardPicture.image = image
            }else{
                print("could not get reward image")
            }
            self.rewardDescription.text = self.reward?.getRewardInfo()
        }
        
        
        
        // set image size warning label
        
        self.imageSizeWarning.isHidden = true
        
        
        // customize the appearence of the picture selector
        
        self.feu.roundCorners(self.selectedPicture, color: self.feu.SUPER_LIGHT_WHITE)
        self.feu.roundCorners(self.pictureSelectorBar, color: self.feu.DARK_GREY)
        self.feu.applyHoverShadow(self.pictureSelectorBar)
        
        //assign button to navigationbar
        
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(
            self.selector,
            parentVC: self,
            labelText: "<"
        )
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
    // IMAGE SELECTOR METHODS
    /*
    Initializer the image picker controller, to obey to the PerfilViewController class
    */
    
    @IBAction func selecteProfilePicture(_ sender: AnyObject) {
        
        print("\nselecting new profile picture ...")
        self.imgPicController.setCallerVC(self, source: self.feu.ID_NEW_REWARD)
        self.imgPicController.selectPictureFromRoll(sender)
        
    }
    
    /*
    Set the picture selector btn with the chosen image
    */
    
    internal func setChosenImg(_ img:UIImage){
        
        print("\nsetting chosen image \(img)")
        self.rewardPicture.image = img
        self.customizeNavBar(self)
        
    }
    
    /*
    Set the selected picture file target with the selected file
    */
    
    internal func setChosenImgFile(_ file:PFFile){
        
        self.selectedPictureFile = file
        
    }
    
    /*
    Save updaated reward information
    */
    
    @IBAction func updateRewardInfo(_ sender: AnyObject) {
        
        print("\nUpsert reward info")
        
        
        
        self.upsertRewardInfoOnBackend(sender)
        
    }
    
    // LOGIC
    /*
    Update reward info
    */
    
    internal func upsertRewardInfoOnBackend(_ sender:AnyObject){
        
        
        
        if(self.task == "update"){
            // Start of update Reward process
            if let image:UIImage = self.selectedPicture.image{
                if let imageFile:PFFile = self.feu.imageToFile(image){
                    self.reward?.setRewPicture(imageFile)
                }else{
                    print("could not get reward image")
                }
                
            }else{
                print("could not get reward image")
            }
            
            self.reward?.setRewInfo(self.rewardDescription.text)
            self.reward?.setRewTitle(self.rewardTitle.text)
            
            // validate new reward title
            if(self.reward?.getRewardTitle() == ""){
                self.infoWindow("Por favor insira um título para sua recompensa", title: "Título é obrigatório", vc: self)
            }else{
                if(self.reward?.getRewardInfo() == ""){
                    self.infoWindow("Por favor insira uma descrição para sua recompensa", title: "Descrição é obrigatória", vc: self)
                }else{
                    print("updated reward info: \(self.reward)")
                    if let id = self.reward?.getObId(){
                        
                        // start loading process
                        self.feu.fadeIn(self.screenLocker, speed: 0.6)
                        self.startLoadingAnimation(self.spinner)
                        
                        let query = Reward.query()
                        query!.getObjectInBackground(withId: id) {
                            (rewardObj: PFObject?, error: NSError?) -> Void in
                            if error != nil {
                                
                                print(error)
                                // unlock the screen
                                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                                self.stopSpinner(self.spinner)
                                
                            } else if let reward = rewardObj {
                                self.reward?.updateReward(reward)
                                reward.saveInBackground{
                                    (success, error) -> Void in
                                    if(error == nil){
                                        print("updated successfully")
                                        self.back()
                              
                                        // unlock the screen
                                        self.feu.fadeOut(self.screenLocker, speed: 0.6)
                                        self.stopSpinner(self.spinner)
                                        
                                    }else{
                                        
                                        print("failed to update Reward")
                                        self.infoWindow("Falha ao criar nova recompensa", title: "Falha na operação", vc: self)
                                        
                                        // unlock the screen
                                        self.feu.fadeOut(self.screenLocker, speed: 0.6)
                                        self.stopSpinner(self.spinner)
                                   
                                    }
                                }
                            }
                        }
                        
                    }else{
                        
                        print("could not get reward id")
                        
                        // unlock the screen
                        self.feu.fadeOut(self.screenLocker, speed: 0.6)
                        self.stopSpinner(self.spinner)
                        
                    }
                }
            }
            
            // end of update reward process
            
        
        }else{
            
            // Start of new reward process
            // load data
            
            self.reward = Reward()
            self.reward?.setRewOwner(PFUser.current())
            self.reward?.setRewPicture(self.selectedPictureFile)
            self.reward?.setRewInfo(self.rewardDescription.text)
            self.reward?.setRewTitle(self.rewardTitle.text)
            
            print("reward \(reward)")
            
            // validate new reward title
            
            if(self.reward?.getRewardTitle() == ""){
                self.infoWindow("Por favor insira um título para sua recompensa", title: "Título é obrigatório", vc: self)
            }else{
                
                if(self.reward?.getRewardInfo() == ""){
                    self.infoWindow("Por favor insira uma descrição para sua recompensa", title: "Descrição é obrigatória", vc: self)
                }else{
        
                    if let _ = self.reward?.getRewardPicture() {
                        
                        // start loading process
                        self.feu.fadeIn(self.screenLocker, speed: 0.6)
                        self.startLoadingAnimation(self.spinner)
                        
                        // create query to check if the reward alredy exists
                        let checkRewardExist:PFQuery = (self.reward?.checkIfRewardExistQuery())!
                        checkRewardExist.findObjectsInBackground{
                            (objectFound, error) -> Void in
                            
                            
                            // if there is already a Reward with the same name and description, interrupts the operation
                            if(error == nil){
                                if(objectFound?.count == 0){
                                    self.createReward(self.reward!)
                                }else{
                                    
                                    print("\nthere is already a reward with the same title and description, cancelling operation ...")
                                    // unlock the screen
                                    self.feu.fadeOut(self.screenLocker, speed: 0.6)
                                    self.stopSpinner(self.spinner)
                                    
                                    self.infoWindow("Já existe uma recompensa com o mesmo título e descrição, por favor escolha mude alguma destas informações", title: "Recompensa já existe", vc: self)
                                    
                                }
                                
                            }else{
                                
                                // unlock the screen
                                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                                self.stopSpinner(self.spinner)
                                self.infoWindow("Houve uma falha de comunicação com o servidor", title: "Falha na operação", vc: self)
                                
                            }
                        }
                        
                    } else {
                        self.infoWindow("Por favor insira uma imagem para sua recompensa", title: "Imagem é obrigatória", vc: self)
                        
                    }
                }
            }
            
            // End of new reward process
            
        }
        
        
        
    }
    
    /*
    
    Get a loaded and valid Reward object and save it.
    
    */
    
    internal func createReward(_ reward:Reward){
        
        let rewardObj:PFObject = PFObject(className:self.dbu.DB_CLASS_REWARD)
        self.reward?.getNewRewardPFobj(rewardObj)
        print("\nreward \(rewardObj)")
        rewardObj.saveInBackground{
            (success, error) -> Void in
       
            if(error == nil){
                
                print("created successfully")
                
                // update the class reward object
                self.reward = Reward(reward: rewardObj)
                
                // unlock the screen
                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                self.stopSpinner(self.spinner)
                
                //self.back()
                self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_NEW_REW, sender: nil)
                
            }else{
                
                print("failed to create new Reward")
                // unlock the screen
                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                self.stopSpinner(self.spinner)
                
            }
            
        }
        
    }
    
    
    
    // NAVIGATION
    
    internal func back(){
        
        if(self.task == "create"){
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_UDT_REW, sender: nil)
        }
        
    }
    

    
    // MANDATORY METHODS
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

