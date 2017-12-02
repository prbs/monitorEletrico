//
//  HomeViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    
    
    // VARIABLES
    /* Containers */
    @IBOutlet weak var scroller                 : UIScrollView!
    @IBOutlet weak var scrollerChildContainer   : UIView!
    @IBOutlet weak var locationSelectorContainer: UIView!
    @IBOutlet weak var contentContainer         : UIView!
    @IBOutlet weak var infoContainer            : UIView!
    @IBOutlet weak var boltAnimationContainer   : UIView!
    @IBOutlet weak var screenLocker             : UIView!
    
    
    /* Bolt animation */
    @IBOutlet weak var dialog: UITextView!
    
    
    @IBOutlet weak var baBackgroundView: UIView!
    @IBOutlet weak var baProgressView  : UIView!
    @IBOutlet weak var baForegroundView: UIImageView!
    @IBOutlet weak var baLeftEye       : UIImageView!
    @IBOutlet weak var baRightEye      : UIImageView!
    
    
    /* Money Spent progress animation */
    internal var ANIMATION_PROGRESS = ""
    @IBOutlet weak var moneySpent       : UILabel!
    @IBOutlet weak var thoughtContainer: UIView!
    
    
    /* Middle */
    @IBOutlet weak var daysLeft      : UILabel!
    
    
    /* Action buttons */
    @IBOutlet weak var menuBtn     : UIBarButtonItem!
    @IBOutlet weak var newPlaceBtn : UIBarButtonItem!
    
    @IBOutlet weak var choosePlcLeftBtn  : UIButton!
    @IBOutlet weak var choosePlcRightBtn : UIButton!
    @IBOutlet weak var chosenPlace       : UIButton!
    
    @IBOutlet weak var newGoalBtn       : UIButton!
    @IBOutlet weak var usersBtn         : UIButton!
    @IBOutlet weak var newReadingBtn    : UIButton!
    @IBOutlet weak var allReadingsBtn   : UIButton!
    @IBOutlet weak var statsBtn         : UIButton!
    
    
    /* Alerts */
    internal var welcomeMessageController : WelcomeMessageViewController!
    internal var popViewController        : UpdateReadingViewController!
    internal var alertViewController      : AlertViewController!
    internal var successViewController    : FinishedWithSucessViewController!
    internal var failureViewController    : FinishedWithFailureViewController!
    internal var amountPaidViewController : AmountPaidViewController!
    internal var tipCardViewController    : TipCardViewController!
    
    
    /* Helpers */
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils   = DBUtils()
    internal var callerViewController:BaseViewController = BaseViewController()
    
    
    /* Data containers */
    internal var locationNames:Array<String> = Array<String>()
    internal var selectedLocation:String = ""
    internal var areReadingOptShowing:Bool = false
    
    
    /* Constants */
    internal let BTN_MOV_DISTANCE:CGFloat = 70
    internal let BTN_ROT_SPEED:Double = 0.7
    internal let BTN_SHOW_HIDE_SPEED:Double = 1.3
    internal let OPNED_READING_OPT_BTN:String = "plus.png"
    internal let CLOSED_READING_OPT_BTN:String = "close.png"
    
    
    /* Controllers */
    internal var justDeletedLocation:Bool = false
    internal var isChartShowing:Bool = false
    
    
    /* Timers */
    internal var blinkTimer:Timer = Timer()
    
    internal var statsJumpTimer:Timer = Timer()
    internal var statsBtnJumpsCounter:Int = 0
    internal let NUM_STATS_BTN_JUMPS:Int = 3
    
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI customizations
        self.customizeAddBtn(self.newGoalBtn)
        self.customizeAddBtn(self.usersBtn)
        self.customizeAddBtn(self.newReadingBtn)
        self.customizeAddBtn(self.allReadingsBtn)
        
        self.dialog.isSelectable = false
        
        if(DBHelpers.lockedSystem){
            self.lockUI()
            
            // don't allow the user to access the menu
            self.view.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }else{
            
            // unlock the system
            if(self.welcomeMessageController != nil){
                self.unlockUI()
            }
            
            // binds the show menu toogle action implemented by SWRevealViewController to the menu button
            if self.revealViewController() != nil {
                self.menuBtn.target = self.revealViewController()
                self.menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // UI initialization
        self.customizeUI()
        self.customizeNavBar(self)
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        
        // customize the stats button and trigger animation
        self.startKicking()
        
        // start Bolt bliking animation
        self.startBlinking()
        
        // lock system
        if(!DBHelpers.lockedSystem){
            
            // reset the animation controller variable after a successfull input
            FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT]     = false
            FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_PROGRESS] = false
            
            // Initialize data
            self.loadData()
            
            // analyze user data
            self.analyzeUserPerformance()
        }
    }
    
    
    
    // UI
    /**
     * Cutomize the UI
     */
    func customizeUI(){
        self.feu.fadeIn(self.allReadingsBtn, speed: 0.5)
        self.feu.fadeIn(self.newReadingBtn, speed: 0.8)
        self.feu.fadeIn(self.newGoalBtn, speed: 1.0)
        self.feu.fadeIn(self.usersBtn, speed: 1.4)
    }
    
    
    
    /*
        Lock UI
    */
    internal func lockUI(){
        
        self.resetUI()
        self.choosePlcLeftBtn.isHidden = true
        self.choosePlcRightBtn.isHidden = true
        self.chosenPlace.isHidden = true
        self.menuBtn.isEnabled = false
        
        // lock the screen with a specific message
        if(DBHelpers.firstTime){
            self.setInstructionsContainer(0)
        }else{
            self.setInstructionsContainer(1)
        }
    }
    
    
    /*
        Unlock UI
    */
    internal func unlockUI(){
        print("Unlocking UI ...")
        
        self.choosePlcLeftBtn.isHidden = false
        self.choosePlcRightBtn.isHidden = false
        self.chosenPlace.isHidden = false
        self.menuBtn.isEnabled = true
        
        self.welcomeMessageController.removeAnimate()
        DBHelpers.lockedSystem = false
    }
    
    
    /*
        Change UI elemtents to the initial state
    */
    internal func resetUI(){
        print("\nreseting UI ...")
        
        // reset labels
        self.chosenPlace.setTitle("Crie um local", for: UIControlState())
        
        self.dialog.isHidden = false
        self.dialog.text = "Oi :)"
        
        self.moneySpent.text = "R$0,00"
        self.daysLeft.text   = ""
        
        FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT]     = false
        FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_PROGRESS] = false
    }
    
    
    /*
        Set the instruction's container with the correct view, in order to give the user instructions on how to 
        use the system
    
        Input:
            instType - 0 = welcome message view
            instType - 1 = new location message view
    */
    internal func setInstructionsContainer(_ instType:Int){
        
        if(instType == 0){
            print("loading welcome message view ...")
            self.createWelcomeMessageDialog(
                "Bem vindo",
                msg:"Para que Bolt comece monitorar o seu consumo energético, clique no botão apontado pela seta e crie um local.",
                type:instType
            )
        }else{
            print("loading new location message view ...")
            self.createWelcomeMessageDialog(
                "Crie um novo local",
                msg:"Adicione um local para que o restante das funcionalidades do sistema sejam ativadas",
                type:instType
            )
        }
    }
    
    
    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
        self.scroller.isUserInteractionEnabled = true
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = self.scrollerChildContainer.frame.size.height
        self.scroller.contentSize.width = self.scrollerChildContainer.frame.size.width
    }
    
    
    /*
        Circular list methods
    */
    // select item on the left side
    @IBAction func selectPrevious(_ sender: AnyObject){
        var prevIdx = -1
        
        if(self.locationNames.count > 0){
            if((DBHelpers.currentLocatinIdx - 1) < 0){
                prevIdx = self.locationNames.count - 1
            }else{
                prevIdx = DBHelpers.currentLocatinIdx - 1
            }
        }else{
            print("user has no location")
        }
        
        DBHelpers.currentLocatinIdx = prevIdx
        
        self.chosenPlace.setTitle(self.locationNames[prevIdx], for: UIControlState())
        self.switchToLocation(prevIdx)
    }
    
    // select item on the right side
    @IBAction func selectNext(_ sender: AnyObject) {
        var nextIdx = -1
        
        if(self.locationNames.count > 0){
            if((DBHelpers.currentLocatinIdx + 1) > (self.locationNames.count - 1)){
                nextIdx = 0
            }else{
                nextIdx = DBHelpers.currentLocatinIdx + 1
            }
        }else{
            print("user has no location")
        }
        
        DBHelpers.currentLocatinIdx = nextIdx
        
        self.chosenPlace.setTitle(self.locationNames[nextIdx], for: UIControlState())
        self.switchToLocation(nextIdx)
    }
    
    // get the index of the selected item
    internal func getSelectedItemIndex(_ locationName:String) -> Int?{
        
        var i = 0
        for locName in self.locationNames{
            if(locName == locationName){
                return i
            }
            i += 1
        }
        
        return -1
    }
    
    
    
    // ANIMATIONS
    /*
        Present reading options buttons
    */
    internal func showFloatingMenu() {
        print("\nShowing floating menu")
        
        // show allReadingsBtn and newReadingsBtn, only if the user has a goal
        if(DBHelpers.currentGoal != nil){
            
            // show all readings if the user has a goal
            self.allReadingsBtn.isEnabled = true
            
            // show the newReadingsBtn only if current location has a device
            if(DBHelpers.currentDevice == nil){
                self.newReadingBtn.isEnabled = true
            }else{
                self.newReadingBtn.isEnabled = false
            }
        }else{
            print("There isn't an active goal for this location")
            self.newReadingBtn.isEnabled = false
        }
        
        // show the goal button depending on the user location admin relationship
        if(!DBHelpers.isUserLocationAdmin){
            self.newGoalBtn.isEnabled = false
        }else{
            self.newGoalBtn.isEnabled = true
        }
        
        // show the users btn only if the user has a location
        if(DBHelpers.currentLocation == nil){
            self.usersBtn.isEnabled = false
        }else{
            self.usersBtn.isEnabled = true
        }
    }
    
    
    /*
        Bolt percentage animation
    */
    internal func boltPercentageAnimation(_ usedPercentage:Double, status:Double){
        print("\ncreating bolt animation ...")
        
        if let hasAnimated = FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT]{
            
            if(!hasAnimated && (DBHelpers.currentGoal != nil)){
                
                if(usedPercentage <= 100){
                    
                    // animate the KW meter on Bolt
                    self.feu.boltPercentageAnimation(
                        self.baBackgroundView,
                        boltProgressView:self.baProgressView,
                        usedPercentage:usedPercentage,
                        status:status
                    )
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.moneySpent.tintColor = self.feu.SAFE_COLOR
                    })
                }else{
                    print("create funny warning animation to let the user know that he/she exploded the value..")
                    
                    // animate the KW meter on Bolt
                    self.feu.boltPercentageAnimation(
                        self.baBackgroundView,
                        boltProgressView:self.baProgressView,
                        usedPercentage:100.0,
                        status:status
                    )
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.moneySpent.tintColor = self.feu.DANGER_COLOR
                })
                
                // update the Bolt animation status
                FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT] = true
            }
            
        }else{
            print("problems getting the state of the Bolt animation")
        }
    }
    
    
    /*
        Reset Bolt animation
    */
    internal func resetBoltAnimation(){
        print("\nreseting bolt animation ...")
        
        // animate the KW meter on Bolt
        self.feu.boltPercentageAnimation(
            self.baBackgroundView,
            boltProgressView:self.baProgressView,
            usedPercentage:0.0,
            status:0
        )
    }
    
    
    /*
        Bolt blink animation, Create a blink effect on the selected view by increasing and reducing the size of 
        the it
    */
    internal func startBlinking(){
        
        self.blinkTimer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target   : self,
            selector : #selector(HomeViewController.blink(_:)),
            userInfo : nil,
            repeats  : true
        )
    }
    
    func blink(_ timer:Timer){
        
        UIView.animate(withDuration: 0.2, animations:{
            self.baLeftEye.frame = CGRect(
                x: self.baLeftEye.frame.origin.x,
                y: self.baLeftEye.frame.origin.y,
                width: self.baLeftEye.frame.size.width,
                height: self.baLeftEye.frame.size.height
            )
            
            self.baRightEye.frame = CGRect(
                x: self.baRightEye.frame.origin.x,
                y: self.baRightEye.frame.origin.y,
                width: self.baRightEye.frame.size.width,
                height: self.baRightEye.frame.size.height
            )
            
        }, completion: {
            (value: Bool) in
                
            UIView.animate(withDuration: 0.2, animations:{
                self.baLeftEye.frame = CGRect(
                    x: self.baLeftEye.frame.origin.x,
                    y: self.baLeftEye.frame.origin.y + 12,
                    width: self.baLeftEye.frame.size.width,
                    height: self.baLeftEye.frame.size.height - 25
                )
                    
                self.baRightEye.frame = CGRect(
                    x: self.baRightEye.frame.origin.x,
                    y: self.baRightEye.frame.origin.y + 12,
                    width: self.baRightEye.frame.size.width,
                    height: self.baRightEye.frame.size.height - 25
                )
            }, completion:{
                (value:Bool) in
                        
                UIView.animate(withDuration: 0.2, animations:{
                    self.baLeftEye.frame = CGRect(
                        x: self.baLeftEye.frame.origin.x,
                        y: self.baLeftEye.frame.origin.y - 12,
                        width: self.baLeftEye.frame.size.width,
                        height: self.baLeftEye.frame.size.height + 25
                    )
                            
                    self.baRightEye.frame = CGRect(
                        x: self.baRightEye.frame.origin.x,
                        y: self.baRightEye.frame.origin.y - 12,
                        width: self.baRightEye.frame.size.width,
                        height: self.baRightEye.frame.size.height + 25
                    )
                }, completion:{
                    (value:Bool) in
                                
                    // do something here
                })
            })
        })
    }
    
    internal func stopBlinking(){
        self.blinkTimer.invalidate()
    }
    
    
    /*
        Animate the statistics button jump
    */
    internal func startKicking(){
        
        self.statsJumpTimer = Timer.scheduledTimer(
                timeInterval: 3.0,
                target   : self,
                selector : #selector(HomeViewController.kick(_:)),
                userInfo : self.statsBtn,
                repeats  : true
        )
    }
    
    internal func kick(_ timer:Timer){
        
        if(self.statsBtnJumpsCounter < self.NUM_STATS_BTN_JUMPS){
        
            if let view = timer.userInfo as? UIView{
                
                self.feu.kickView(view)
                self.statsBtnJumpsCounter += 1
                
            }else{
                print("could not get element as a UIView")
            }
        }else{
            self.stopKicking()
        }
    }
    
    internal func stopKicking(){
        self.statsJumpTimer.invalidate()
    }
    
    
    
    
    // DIALOGS
    /*
        Welcome animation. This dialog explain what the user has to do to get the system working.
        Basically create a new location
    
        Input:
            title:String - the title of the dialog
            msg:String   - the message of the dialog
            type: the sort of view:
                type 0 = welcome,
                type 1 = new location
    */
    internal func createWelcomeMessageDialog(_ title:String, msg:String, type:Int){
        
        // create a new reading dialog
        self.welcomeMessageController = WelcomeMessageViewController(
            nibName: "WelcomeMessage",
            bundle: nil
        )
        
        // initialize dialog with pointer to this page, in order to get the inserted value
        self.welcomeMessageController.callerViewController = self
        self.welcomeMessageController.title = "This is a popup view"
        self.welcomeMessageController.showInView(
            self.view,
            animated: true,
            title: title,
            msg: msg,
            type: type
        )
    }
    
    
    /*
        Open the new reading dialog
    */
    @IBAction func newReading(_ sender: AnyObject) {
        
        // create a new reading dialog
        self.popViewController = UpdateReadingViewController(
            nibName: "UpdateReadingViewController",
            bundle: nil
        )
        
        // initialize dialog with pointer to this page, in order to get the inserted value
        self.popViewController.callerViewController = self
        self.popViewController.title = "This is a popup view"
        self.popViewController.showInView(
            self.view,
            withImage: UIImage(named: ""),
            withMessage: "",
            animated: true
        )
        
        self.popViewController.customizeView()
    }
    
    
    /*
        Show alert view
    */
    internal func newAlertView(_ msg:String){
        
        // create a new reading dialog
        self.alertViewController = AlertViewController(
            nibName: "AlertViewController",
            bundle: nil
        )
        
        self.alertViewController.showInView(
            self.view,
            animated: true
        )
        
        // initialize dialog with pointer to this page, in order to get the inserted value
        self.alertViewController.callerViewController = self
        self.alertViewController.title = "This is a popup view"
        
        // initialize text appearence
        self.alertViewController.msg.text = msg
        self.alertViewController.msg.isSelectable = false
    }
    
    
    /*
        Show the goal finished dialog, in case of success
    */
    internal func showEndOfGoalSuccess(){
        print("\nshowing end of goal, success dialog ...")
        
        // create a new reading dialog
        self.successViewController = FinishedWithSucessViewController(
            nibName: "GoalDoneSuccess",
            bundle: nil
        )
        
        // start loading view attributes
        self.successViewController.callerViewController = self
        
        self.successViewController.showInView(
            self.view,
            animated: true
        )
        
        // fetch successful goal message
        let msg = "Você gostaria de pagar R$\(DBHelpers.currentGoal!.getDesiredValue().stringValue) por sua conta elétrica, mas vai pagar somente R$\(self.dbh.getEstimatedAmountToPay().stringValue)"
        
        self.successViewController.successMsg.text = msg
        
        // check if the current goal has a reward and insert its information
        if(DBHelpers.currentGoal?.getRewardId() != self.dbu.STD_UNDEF_STRING){
            
            // hide placeholder for no reward case
            self.successViewController.noRewardImage.isHidden = true
            
            let rewardId:String = (DBHelpers.currentGoal?.getRewardId()!)!
            
            let rewardQuery:PFQuery = Reward.query()!
            
            rewardQuery.getObjectInBackground(withId: rewardId){
                (rewardObj: PFObject?, error: NSError?) -> Void in
                
                if(error == nil){
                    if let reward = rewardObj{
                        
                        // start loading reward's attributes
                        if let rewTitle = reward[self.dbu.DBH_REWARD_TITLE] as? String{
                            self.successViewController.rewardTitle.text = rewTitle
                        }
                        
                        if let imageFile = reward[self.dbu.DBH_REWARD_PICTURE] as? PFFile{
                            imageFile.getDataInBackground(block: {
                                (imageData: Data?, error: NSError?) -> Void in
                                
                                
                                // if there is a reward image load it
                                if (error == nil) {
                                    
                                    let image = UIImage(data:imageData!)
                                    
                                    self.successViewController.rewardImage.image = image
                                    self.feu.fadeIn(self.successViewController.rewardImage, speed:0.5)
                                    
                                    // show reward
                                    self.feu.fadeIn(self.successViewController.rewardTitleContainer, speed:0.6)
                                    self.feu.fadeIn(self.successViewController.rewardTitle, speed:0.8)
                                }
                            })
                        }else{
                            print("problem getting reward image PFFile")
                        }
                    }else{
                        print("problem unwrapping reward info")
                    }
                }else{
                    print("problem getting the reward details")
                }
            }
            // end of query
            
        }
            // hide reward fields if there isn't one
        else{
            print("current goal doensn't have a reward")
            
            // set success message label
            self.successViewController.rewardTitle.isHidden     = true
            self.successViewController.rewardImage.isHidden     = true
            self.successViewController.rewardTitleContainer.isHidden = true
            
            self.feu.fadeIn(self.successViewController.noRewardImage, speed:0.4)
        }
    }
    
    
    /*
        Show the end of goal dialog for the case the user have failed achieving the goal
    */
    internal func showEndOfGoalFailure(){
        
        // create a new reading dialog
        self.failureViewController = FinishedWithFailureViewController(
            nibName: "GoalDoneFailure",
            bundle: nil
        )
        
        // initialize the failure view, this instruction must be used before any operation on the VC
        self.failureViewController.showInView(
            self.view,
            animated: true
        )
        
        // start loading view attributes
        self.failureViewController.callerViewController = self
        self.failureViewController.estimatedValue.text = "R$ " + self.dbh.getEstimatedAmountToPay().stringValue
        
        self.failureViewController.desiredValue.text = "R$ " + DBHelpers.currentGoal!.getDesiredValue().stringValue
        
        // animate progress bar
        self.failureViewController.animateProgressBar(
            self.failureViewController.progressBar,
            progressBarTrail:self.failureViewController.progressBarTrail,
            progressPointer :self.failureViewController.movingPointer,
            landmark        :self.failureViewController.landmark,
            finalLandmark   :self.failureViewController.finalLandmark,
            startValue      :0.0,
            landmarkValue   :DBHelpers.currentGoal!.getDesiredValue().floatValue,
            endValue        :self.dbh.getEstimatedAmountToPay().floatValue
        )
    }
    
    
    /*
        Explain that the user should insert the actual value paid for the eletric bill.
        Send the user home, call the process results method, and present the results. This method
        is called when the success or failure dialog is dismissed
    */
    internal func displayFinishedGoalMessage(){
        // create a new reading dialog
        self.amountPaidViewController = AmountPaidViewController(
            nibName: "AmountPaid",
            bundle: nil
        )
        
        // start loading view attributes
        self.amountPaidViewController.callerViewController = self
        
        // show the dialog
        self.amountPaidViewController.showInView(
            self.view,
            animated: true
        )
    }
    
    
    /*
        Show a tip to help the user on improving his current energy comsunption patterns
    */
    internal func openTipDialog(_ afterFailure:Bool){
        print("trying to open tip dialog")
        
        // set default image
        var image:UIImage = UIImage(named:"imgres.jpg")!
        
        // Get a tip from the backend and show it on the failure message
        let tipQuery:PFQuery = Tip.query()!
        
        tipQuery.findObjectsInBackground{
            (objects: [AnyObject]?, error:NSError?) -> Void in
            
            if(error == nil){
                if(objects!.count > 0){
                    
                    // get a random number in the range from 0 to the tips count
                    let selected = Int(arc4random_uniform(UInt32(objects!.count)))
                    
                    if let tipObj = objects![selected] as? PFObject{
                        let tip:Tip = Tip(tip: tipObj)
                        
                        let picture = tip.getTipPicture()
                        
                        if(picture != nil){
                        
                            picture!.getDataInBackground(block: {
                                (imageData: Data?, error: NSError?) -> Void in
                                
                                if (error == nil) {
                                    image = UIImage(data:imageData!)!
                                }
                                
                                self.showTip(tip, image:image, afterFailure: afterFailure)
                            })
                        }else{
                            self.showTip(tip, image:image, afterFailure: afterFailure)
                        }
                    }else{
                        print("problem converting AnyObject to PFObject")
                    }
                }else{
                    print("array of objects is empty")
                }
            }else{
                print("problem getting tip from backend")
            }
        }
    }
    
    
    /*
        Get a tip on the backend and load a new tip dialog
    */
    internal func showTip(_ tip:Tip, image:UIImage, afterFailure:Bool){
        
        // create a new reading dialog
        self.tipCardViewController = TipCardViewController(
            nibName: "TipDialog",
            bundle: nil
        )
        
        // start loading view attributes
        self.tipCardViewController.callerViewController = self
        
        // show the dialog
        self.tipCardViewController.showInView(
            self.view,
            animated: true
        )
        
        // load view data
        self.tipCardViewController.tipTitle.text    = tip.getTipTitle()
        self.tipCardViewController.observation.text = tip.getTipInfo()
        self.tipCardViewController.tipImage.image   = image
        self.tipCardViewController.afterFailure     = afterFailure
    }
    
    
    
    // LOGIC
    /*
        Gather all data associated with the current location and load it on the dashboard UI.
        Important, this method doens't make modifications on the glocal variables.
    */
    internal func loadData(){
        print("\nloading data into home UI ...")
        
        // available locations
        print("user locations: ")
        
        self.locationNames = []
        
        for i in 0...DBHelpers.userLocations.count{
            if let loc = DBHelpers.userLocations[i]{
                print("\(loc.getLocationName())")
                
                self.locationNames.append(loc.getLocationName())
            }
        }
        
        // selected location
        if let name = DBHelpers.currentLocation?.getLocationName(){
            self.selectedLocation = name
            self.chosenPlace.setTitle(name, for: UIControlState())
            print("\nselected location: \(name)\n")
        }else{
            print("\nerror getting location name\n")
        }
        
        // admin status for selected location
        if(DBHelpers.isUserLocationAdmin){
            print("user is location admin\n")
        }else{
            print("user isn't location admin\n")
        }
        
        // if the location has a goal
        if(DBHelpers.currentGoal != nil){
            
            // set days left
            self.daysLeft.text = String(self.dbh.daysLeftEndOfGoal()) + " dias restantes"
            
            // probabily is going to pay
            self.moneySpent.text = "R$" + String(self.dbh.getEstimatedAmountToPay().doubleValue.format(".2"))
            
            // show thought btn
            self.thoughtContainer.isHidden = true
            self.feu.fadeIn(self.thoughtContainer, speed: 0.4)
            
        // if the location doesn't have a goal
        }else{
            print("there is no active goal for this location.")
            
            // inform the user about the goals
            if(DBHelpers.isUserLocationAdmin){
                self.showDialog(2, msg:"crie uma meta de consumo")
            }else{
                self.showDialog(2, msg:"o administrador ainda não definiu um objetivo para este local")
            }
            
            // reset the Bolt animation to 0
            self.resetBoltAnimation()
        }
        
        // show the status of the current location variables
        DBHelpers.showCurrentLocationVariables()
        
        // present the floating menu
        self.showFloatingMenu()
    }
    
    
    /*
        Fetch a message to the user
            
        Input:
            0 - message about the planned value
    */
    internal func showDialog(_ messageOpt:Int, msg:String){
        print("\nfetching a message to the user about:")
        
        // create a more managable version of the current user object
        let user:User = User(user:PFUser.current()!)
        
        var name = ""
        
        if(user.getUserName()! != self.dbu.STD_UNDEF_STRING){
            
            // get the first name of the user
            name = user.getUserName()!.components(separatedBy: " ")[0]
        }
        
        // selected the message
        switch messageOpt{
            case 0:
                print("the planned value")
                
                self.dialog.text = "Você disse que gostaria de gastar, R$" + DBHelpers.currentGoal!.getDesiredValue().stringValue
            
            case 1:
                print("the importance of creating goals")
                
                if(DBHelpers.isUserLocationAdmin){
                    self.dialog.text = "Crie uma meta de consumo e começe a economizar."
                    // \(name),
                    
                }else{
                    self.dialog.text = "O administrador ainda não definiu uma meta para o local."
                }
            
            case 2:
                self.dialog.text = "\(msg)"
            
            default:
                print("option not found")
        }
    }
    
    
    
    /*
        Analise distance from goal and through message
    */
    internal func analyzeUserPerformance(){
        print("\nAnalysing user performance for the current goal ...")
        
        // check if the current goal has passed its due date
        if(self.dbh.isCurrentGoalFinished()){
            
            // check if the user has achieved his/her goal
            let desiredValue = DBHelpers.currentGoal!.getDesiredValue()
            let estimatedValue = self.dbh.getEstimatedAmountToPay()
            
            if(desiredValue.floatValue > estimatedValue.floatValue){
                print("user has achieved goal")
                self.showEndOfGoalSuccess()
            }else{
                print("user failed achieving goal displaying failure message")
                self.showEndOfGoalFailure()
            }
        }else{
            
            if let distanceFromGoal:Float = self.dbh.getDistanceOfGoal(){
                
                print("distance from goal \(distanceFromGoal)")
                
                let daysLeft = self.dbh.daysLeftEndOfGoal()
                
                if let percentageSpent:NSNumber = self.dbh.getGoalPercentageSpent(){
                    
                    // bolt animation
                    self.boltPercentageAnimation(
                        percentageSpent.doubleValue,
                        status:Double(distanceFromGoal)
                    )
                    
                    let percentage = percentageSpent.doubleValue.format(".1")
                    let overload = (percentageSpent.doubleValue - 100.0).format(".1")
                    
                    // executed if the alert hasn't been visualized yet
                    if let curLoc:Location = DBHelpers.currentLocation{
                        
                        let hasVisualizedMsgForLocation:Bool = DBHelpers.alertMsgController[curLoc.getObId()]!
                        
                        var msg = ""
                        
                        if(percentageSpent.doubleValue > 100.0){
                            
                            msg = "Cuidado ainda falta(m) \(daysLeft) dia(s)"
                            //  para terminar o objetivo e o valor predefinido já foi ultrapassado em \(overload)%. Segure os gastos."
                            
                            self.showDialog(2, msg: msg)
                            
                            if(!hasVisualizedMsgForLocation){
                                self.newAlertView(msg)
                                
                            }else{
                                print("user already visualized alert for this location on this session")
                            }
                        }else if(distanceFromGoal > 1.0){
                            
                            msg = "Você ultrapassou seu objetivo diário em \(percentage)%."
                            
                            self.showDialog(2, msg: msg)
                            
                            if(!hasVisualizedMsgForLocation){
                                self.newAlertView(msg)
                                
                                self.showDialog(2, msg: msg)
                            }else{
                                print("user already visualized alert for this location on this session")
                            }
                        }else if((distanceFromGoal > 0.8) && (distanceFromGoal < 1.0)){
                            
                            msg = "Você ultrapassou seu objetivo diário em \(percentage)%."
                            
                            self.showDialog(2, msg:msg)
                            
                            if(!hasVisualizedMsgForLocation){
                                self.newAlertView(msg)
                            }else{
                                print("user already visualized alert for this location on this session")
                            }
                        }else if((distanceFromGoal < 0.8) && (distanceFromGoal > 0.6)){
                           
                            msg = "Fique de olho, \(percentage)% do seu orçamento previsto já foi gasto."
                            //  e ainda temos \(daysLeft) dias até o fim do objetivo."
                            
                            self.showDialog(2, msg:msg)
                            
                            if(!hasVisualizedMsgForLocation){
                                self.newAlertView(msg)
                            }else{
                                print("user already visualized alert for this location on this session")
                            }
                            
                        }else if((distanceFromGoal < 0.6) && (distanceFromGoal > 0.4)){
                            self.showDialog(2, msg:"você está indo muito bem.")
                            
                        }else if((distanceFromGoal < 0.4) && (distanceFromGoal > 0.0)){
                            self.showDialog(2, msg:"você tem tudo sob controle, parabéns.")
                            
                        }else if(distanceFromGoal < 0.0){
                            
                            if(DBHelpers.currentDevice != nil){
                                self.showDialog(2, msg:"adquira um dispositivo de monitoramento e não se preocupe com os gastos")
                            }else{
                                self.showDialog(2, msg:"você ainda não fez nenhuma leitura, sem elas o sistema é ineficaz :(")
                            }
                        }
                    }else{
                        print("current location is null")
                    }
                }else{
                    print("problems getting percentage spent")
                    self.boltPercentageAnimation(0.0, status: 0.0)
                }
            }else{
                print("problems getting distance from goal")
                self.boltPercentageAnimation(0.0, status: 0.0)
            }
        }
    }
    
    
    
    /*
        Switch the current environment and reload UI data with values of global variables
    */
    internal func switchToLocation(_ locationIdx:Int){
        print("\nswitching data from previous location to selected location ...")
        
        if let location = DBHelpers.userLocations[locationIdx]{
            
            self.resetUI()
            
            // update the global location object currently being analysed by the system
            DBHelpers.currentLocation = location
            
            // set admin status for selected location
            print("\nsetting location admin status")
            DBHelpers.updateCurUserLocAdminStatus()
            
            // save current location datastructure to release it, in order to save memory
            print("\nsaving old location data")
            DBHelpers.currentLocationData?.save()
            DBHelpers.currentLocationData?.unloadDataStructure()
            
            // select location data from list of location data managers, every location MUST have a data manager object
            print("\ngetting new location datafile")
            if let locData = DBHelpers.locationDataObj[location.getObId()]{
            
                locData?.loadDataStructure()
                DBHelpers.currentLocationData = locData
            }else{
                print("problem loading selected location data manager")
            }
            
            // select goal for the selected location if there is one
            print("\nselecting goal of the selected location")
            if(DBHelpers.locationGoals[location.getObId()] != nil){
            
                DBHelpers.currentGoal = DBHelpers.locationGoals[location.getObId()]!!
                print("selected goal \(DBHelpers.currentGoal)")
            }else{
                print("location doesn't have goal")
                DBHelpers.currentGoal = nil
            }
            
            // select monitoring device if there
            print("\nselecting device of the new location if there is one")
            if let locDevice = location.getLocationDevice(){
                
                DBHelpers.currentDevice = locDevice
                print("selected location device \(DBHelpers.currentDevice)")
            }else{
                print("location doesn't have a device")
                DBHelpers.currentDevice = nil
            }
            
            // reload data for current screen
            self.loadData()
            
            // analyze user data
            self.analyzeUserPerformance()
        }else{
            print("problems getting the location indicated by the index \(locationIdx)")
        }
    }
    
    
    /*
        Change the status of the current goal to 'archived'
    */
    internal func archiveGoal(){
        print("\narchiving current goal ...")
        
        DBHelpers.eraseGoalTraceFromDatafile()
        
        print("current goal \(DBHelpers.currentLocation)")
        
        if(DBHelpers.currentGoal != nil){
            
            // delete the goal from the user-location-goal relation
            let archiveGoalQuery:PFQuery = DBHelpers.currentGoal!.openedGoalForLocation(
                DBHelpers.currentLocation!
            )
            
            archiveGoalQuery.findObjectsInBackground(block: {
                (goals:[AnyObject]?, error:NSError?) -> Void in
                
                if(error == nil){
                    if let goalRelObj = goals?.first as? PFObject{
                        
                        goalRelObj[self.dbu.DBH_REL_USER_GOALS_STATUS] = self.dbu.DBH_REL_USER_GOALS_POS_STAT[1] // archived
                        
                        goalRelObj.saveInBackground {
                            (success, error) -> Void in
                            
                            if(success){
                                print("display input to get the actual amount paid, in order to finish goal. Or show the archive it message")
                                
                                // Reset current goal
                                DBHelpers.locationGoals[(DBHelpers.currentLocation?.getObId())!] = nil
                                DBHelpers.currentGoal = nil
                                self.loadData()
                                
                                self.infoWindow("O objetivo foi arquivado, você pode inserir o valor real cobrado pela companhia elétrica em \n\n'Objetivos/Objetivos Anteriores'.", title: "Objetivo arquivado", vc: self)
                            }else{
                                print("there was a problem archiving the current goal")
                                
                                self.callerViewController.infoWindow("Houve um erro ao arquivar o objetivo atual", title:"Falha na operação", vc: self.callerViewController)
                            }
                        }
                    }else{
                        print("problem getting user-location object")
                    }
                }else{
                    print("problem getting user-location object \(error!.description)")
                }
            })
            
            // resets the UI independent of the operation result
            self.resetUI()
        }else{
            print("current goal is null")
        }
    }
    
    
    /*
        Get all days within the period of the current goal
    */
    internal func getDaysOfCurrentGoal() -> Array<AnyObject>{
        
        // get the goal's start date
        if let startDate:Date = DBHelpers.currentGoal?.getStartingDate() as Date?{
            
            // get current date
            if let endDate:Date = Date(){
                let days:Array<AnyObject> = DBHelpers.currentLocationData!.getDaysWithReadingForGoal(
                    startDate, endDate:endDate
                )
                
                return days
            }else{
                print("error getting current date")
            }
        }else{
            print("error getting start date")
        }
        
        return []
    }
    
    
    /*
        Callback method executed after a manual reading
    */
    override internal func setReadingValue(_ input:Double){
        // reset the animation controller variable after a successfull input
        FrontendUtilities.hasAnimated[self.feu.HOME_ANIMATION_BOLT] = false
        
        self.loadData()
        self.analyzeUserPerformance()
    }
    
    
    /*
        Get a Location by searching for its name
    */
    internal func getLocactionByName(_ locationName:String) -> Location?{
        
        // protect the for loop
        if(DBHelpers.userLocations.count > 0){
            
            // check on each location for the name
            for i in 0...(DBHelpers.userLocations.count - 1){
                
                // check if the names match
                if let locName = DBHelpers.userLocations[i]?.getLocationName(){
                    if(locationName == locName){
                        if let loc:Location = DBHelpers.userLocations[i]{
                            return loc
                        }else{
                            print("failed to get location id")
                        }
                    }
                }else{
                    print("failed to get location name")
                }
            }
        }
        
        return nil
    }
    
    
    
    // NAVIGATION
    /*
        Go to the new goal screen
    */
    @IBAction func goNewGoal(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_DEFINE_GOAL, sender: self)
    }
    
    
    /*
        Navigate to the readings log page
    */
    @IBAction func showAllReadings(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_DAILY_READINGS, sender: self)
    }
    
    
    /*
        Go to the new location decision screen
    */
    @IBAction func goNewLocation(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_CHOOSE_HOW_ADD_LOC, sender: self)
    }
    
    
    /*
        Redirect the user to the location details page sending the current location data
    */
    @IBAction func goLocationDetails(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_LOCATION_DETAILS, sender: NSObject())
    }
    
    
    /*
        Get response after location deletion on the location details screen
    */
    @IBAction func unwindAfterLocationDeletion(_ segue:UIStoryboardSegue) {
        if let _:PlaceDetailsViewController = segue.source as? PlaceDetailsViewController{
            
            self.justDeletedLocation = true
            self.resetUI()
            self.viewDidLoad()
        }
    }
    
    
    /*
        Get response after location creation
    */
    @IBAction func unwindAfterReadingsCheck(_ segue:UIStoryboardSegue) {
        self.resetUI()
        self.viewDidLoad()
    }
    
    
    /*
        Get response after location creation
    */
    @IBAction func unwindAfterNewLocation(_ segue:UIStoryboardSegue) {
        self.resetUI()
        self.viewDidLoad()
    }
    
    
    /*
        Prepare data to next screen
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // stop the blinking animation
        self.stopBlinking()
        self.feu.stopPulsing()
        
        if(segue.identifier == self.feu.SEGUE_DAILY_READINGS){
            let destineVC = (segue.destination as! DailyReadingsViewController)
            destineVC.days = self.getDaysOfCurrentGoal()
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}






/*
    Extensions
*/
extension UIView {
    func layerGradient() {
        
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPoint(x: 0.0,y: 0.0)
        layer.cornerRadius = CGFloat(frame.width / 20)
        
        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.5).cgColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).cgColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).cgColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).cgColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).cgColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).cgColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).cgColor
        
        layer.colors = [color0,color1,color2,color3,color4,color5,color6]
        self.layer.insertSublayer(layer, at: 0)
    }
}



