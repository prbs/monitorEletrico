//
//  DefinirMetaViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DefinirMetaViewController: BaseViewController {

    
    
    // VARIABLES
    internal let dbh:DBHelpers     = DBHelpers()
    internal let dbu:DBUtils       = DBUtils()
    internal let selector:Selector = #selector(DefinirMetaViewController.goHome as (DefinirMetaViewController) -> () -> ())
    
    internal var selectedReward:Reward?   = nil
    internal var currentGoalObj:PFObject? = nil
    internal var popViewController : UpdateReadingViewController!
    
    internal var newGoal:Bool               = false
    internal var wasFirstReadingMade:Bool   = false
    internal var justDeletedGoal:Bool       = false
    internal var justCameBackRewSelect:Bool = false
    internal var firstReading:Double        = 0.0
    
    internal let DOUBLE_FORMAT             = ".2"
    
    internal let LABEL_BTN_SELECT_REWARD   = "add.png"
    internal let LABEL_BTN_UPDATE_REWARD   = "refresh.png"
    
    internal let REWARD_STATUS_DEFAULT      = "Recompensas tornam objetivos mais divertidos"
    internal let REWARD_STATUS_NOT_SELECTED = "Nenhuma recompensa selecionada :("
    internal let SCREEN_TITLE_NEW           = "Definir Meta"
    internal let SCREEN_TITLE_UPDATE        = "Nova Meta"
    
    
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var amountToPay: UITextField!
    @IBOutlet weak var selectLeftAmount: UIButton!
    @IBOutlet weak var selectRightAmount: UIButton!
    
    @IBOutlet weak var kwhVal: UITextField!
    @IBOutlet weak var selectLeftKwh: UIButton!
    @IBOutlet weak var selectRightKwh: UIButton!
    
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UIDatePicker!
    
    @IBOutlet weak var selectedRewardTitle: UILabel!
    @IBOutlet weak var selectRewardBtn: UIButton!
    
    @IBOutlet weak var deleteRewardBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var toolBar: UIView!

    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        
        // UI initialization
        self.customizeUI()
        
        
        // user is updating a goal
        if(DBHelpers.currentGoal != nil){
        
            self.resetUI()
            self.unlockUI()
            self.loadCurrentGoal()
        }else{
            
            // set new flag to control the current operation across the methods of this class
            self.newGoal = true
            
            // if the fisrt reading of the new goal wasn't made yet
            //if(DBHelpers.currentDevice == nil){
                
                // check if the screen isn't reloading after a goal deletion
                if(!self.wasFirstReadingMade){
                    self.resetUI()
                    self.lockUI()
                    
                    //self.firstReadingDialog()
                    
                    self.inputDialog()
                }
            /*}else{
                print("user has a device, no need to lock and reset the UI")
            }*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.SCREEN_TITLE_NEW
        self.navigationItem.leftBarButtonItem = self.feu.getHomeNavbarBtn(self.selector, parentVC: self)
        
        // left align select reward button text
        self.selectRewardBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left;
        self.deleteRewardBtn.isHidden = true
        
        // setup the distance that the keyboard is going to move and set keyboard disapear
        self.amountToPay.delegate  = self
        self.amountToPay.keyboardType  = UIKeyboardType.decimalPad
        
        self.kwhVal.delegate = self
        self.kwhVal.keyboardType  = UIKeyboardType.decimalPad
        
        self.intervalToHideKeyboard = 1.0
        self.kbHeight = 0.0
        
        // set the scroll view
        // self.setScroller()
    }
    
    
    
    // UI
    /**
     * Cutomize the UI
     */
    func customizeUI(){
        
        //self.feu.roundIt(self.selectLeftAmount, color: self.feu.SUPER_LIGHT_WHITE)
        //self.feu.roundIt(self.selectRightAmount, color: self.feu.SUPER_LIGHT_WHITE)
        //self.feu.roundIt(self.selectLeftKwh, color: self.feu.SUPER_LIGHT_WHITE)
        //self.feu.roundIt(self.selectRightKwh, color: self.feu.SUPER_LIGHT_WHITE)
        
        self.customizeNavBar(self)
        self.customizeToolBar()
    }
    
    
    
    /*
        Selector of the amount to pay
    */
    //selectorAmountSum(sender: AnyObject) {
    @IBAction func sumAmount(_ sender: AnyObject) {
        let sum = self.feu.sumNumber(self.amountToPay.text, precision:".1")
        self.amountToPay.text = sum
    }
    
    @IBAction func sumAmountFast(_ sender: AnyObject) {
        let sum = self.feu.sumNumber(self.amountToPay.text, precision:"1")
        self.amountToPay.text = sum
    }
    
    @IBAction func subAmount(_ sender: AnyObject) {
        let sub = self.feu.subNumber(self.amountToPay.text, precision:".1")
        self.amountToPay.text = sub
    }
    
    @IBAction func subAmountFast(_ sender: AnyObject) {
        let sub = self.feu.subNumber(self.amountToPay.text, precision:"1")
        self.amountToPay.text = sub
    }
    
    
    /*
        Selector KW/h sum
    */
    @IBAction func selectorKwhSum(_ sender: AnyObject) {
        let sum = self.feu.sumNumber(self.kwhVal.text, precision:".01")
        self.kwhVal.text = sum
    }
    
    
    @IBAction func sumKwhFast(_ sender: AnyObject) {
        let sum = self.feu.sumNumber(self.kwhVal.text, precision:".1")
        self.kwhVal.text = sum
    }
    
    
    @IBAction func selectorKwhSub(_ sender: AnyObject) {
        let sub = self.feu.subNumber(self.kwhVal.text, precision:".01")
        self.kwhVal.text = sub
    }
    
    
    @IBAction func subKwhFast(_ sender: AnyObject) {
        let sub = self.feu.subNumber(self.kwhVal.text, precision:".1")
        self.kwhVal.text = sub
    }
    
    
    
    /*
        convert nume
    */
    override func keyboardWillHide(_ notification: Notification) {
        
        // move view to initial position when the keyboard is dismissed
        UIView.animate(withDuration: 0.3,
            animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -self.keyboardMovement)
            }, completion:{
                (success:Bool) in
                
                self.keyboardMovement = 0.0
            }
        )
        
        // clean numeric values from the UI
        self.amountToPay.text = self.feu.replaceComma(self.amountToPay.text!)
        self.kwhVal.text = self.feu.replaceComma(self.kwhVal.text!)
    }
    
    
    
    
    /*
        Navigate to the rewards page and select an available reward
    */
    @IBAction func selectReward(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.SEGUE_SELECT_REWARD_NGOAL, sender: self)
    }
    
    
    /*
        Erase the selected reward from the goal definition
    */
    @IBAction func eraseReward(_ sender: AnyObject) {
        print("\nerases the selected reward from the goal definition")

        if(DBHelpers.currentGoal != nil){
            DBHelpers.currentGoal!.setGoalReward(nil)
            DBHelpers.currentGoal!.setGoalReward(nil)
        }
        
        self.selectedReward = nil
        self.selectedRewardTitle.text = self.REWARD_STATUS_DEFAULT
        self.deleteRewardBtn.isHidden = true
        
        // position the reward picker btn according to the state of selected reward variable
        self.animateRewardPickerBtnToggle()
    }
    
    
    
    /*
        Animate reward picker btn toggle
    */
    internal func animateRewardPickerBtnToggle(){
        
        if(self.deleteRewardBtn.isHidden){
            
            // show add reward btn
            
            UIView.animate(withDuration: 0.1,
                animations: {
                    self.selectRewardBtn.alpha = 1.0
                    
                }, completion:{
                    (val:Bool) in
                    
                    UIView.animate(withDuration: 0.3,
                        animations: {
                           
                            self.selectRewardBtn.alpha = 0.0
                            
                        }, completion:{
                            (val:Bool) in
                            
                            self.selectRewardBtn.setBackgroundImage(UIImage(named: self.LABEL_BTN_SELECT_REWARD), for: UIControlState())
                            
                            UIView.animate(withDuration: 0.6,
                                animations: {
                                    
                                    self.selectRewardBtn.alpha = 1.0
                                }
                            )
                        }
                    )
                }
            )
            
        }else{
            
            UIView.animate(withDuration: 0.1,
                animations: {
                    self.selectRewardBtn.alpha = 1.0
                    
                }, completion:{
                    (val:Bool) in
                    
                    UIView.animate(withDuration: 0.3,
                        animations: {
                            
                            self.selectRewardBtn.alpha = 0.0
                            
                        }, completion:{
                            (val:Bool) in
                            
                            self.selectRewardBtn.setBackgroundImage(UIImage(named: self.LABEL_BTN_UPDATE_REWARD), for: UIControlState())
                            
                            UIView.animate(withDuration: 0.6,
                                animations: {
                                    
                                    self.selectRewardBtn.alpha = 1.0
                                }
                            )
                        }
                    )
                }
            )
        }
        
    }
    
    
    
    
    /*
        Create a new goal or updates an existing one
    */
    @IBAction func saveGoal(_ sender: AnyObject) {
        self.upsertGoal()
    }
    
    
    /*
        Delete current goal from local system and the app backend, and reset UI
    */
    @IBAction func deleteGoal(_ sender: AnyObject) {
        
        if(DBHelpers.currentGoal != nil){
            self.deleteGoalDialog()
        }else{
            self.infoWindow("Não existe um objetivo configurado para este ambiente",title:"Atenção",vc: self)
        }
    }
    
    
    /*
        Redirect the user to the closed and archived goals screen
    */
    @IBAction func goOldGoals(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: self.feu.SEGUE_OLD_GOALS, sender: nil)
    }
    
    
    
    /*
        Send the user to the home pagd
    */
    @IBAction func goHome(_ sender: AnyObject) {
        self.feu.goToSegueX(self.feu.ID_HOME, obj: NSObject())
    }

    
    
    
    /*
        Customize the toolbar
    */
    internal func customizeToolBar(){
        self.toolBar.layer.borderColor = UIColor.white.cgColor

    }
    
    
    
    
    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
        self.scroller.isUserInteractionEnabled = true
        self.scroller.frame = self.view.bounds
        
        self.scroller.contentSize.height = self.contentView.frame.size.height
        self.scroller.contentSize.width = self.contentView.frame.size.width
        
        self.feu.applyCurvedShadow(self.scroller)
    }
    
    
    /*
        Resets the UI high before loading data for update in it, to give a sense of something ongoing
    */
    internal func resetUI(){
        self.amountToPay.text = String(0.0)
        self.kwhVal.text = String(0.0)
        self.startDate.text = Date().formattedWith(self.feu.DATE_FORMAT)
        self.endDate.setDate(Date(), animated: false)
        
        self.animateRewardPickerBtnToggle()
    }
    
    
    /*
        Lock the UI elements. Not input can be done
    */
    internal func lockUI(){
        self.amountToPay.isEnabled       = false
        self.selectLeftAmount.isEnabled  = false
        self.selectRightAmount.isEnabled = false
        
        self.kwhVal.isEnabled            = false
        self.selectLeftKwh.isEnabled  = false
        self.selectRightKwh.isEnabled = false
        
        self.endDate.isEnabled         = false
        self.selectRewardBtn.isEnabled = false
        self.deleteRewardBtn.isEnabled = false
        self.saveBtn.isEnabled         = false
    }
    
    
    /*
        Unlock UI elements
    */
    internal func unlockUI(){
        self.amountToPay.isEnabled       = true
        self.selectLeftAmount.isEnabled  = true
        self.selectRightAmount.isEnabled = true
        
        self.kwhVal.isEnabled            = true
        self.selectLeftKwh.isEnabled  = true
        self.selectRightKwh.isEnabled = true
        
        self.endDate.isEnabled         = true
        self.selectRewardBtn.isEnabled = true
        self.deleteRewardBtn.isEnabled = true
        self.saveBtn.isEnabled         = true
    }
    
    
    /*
        Ask if the user really want to create a new goal without a reward
    */
    internal func createGoalWithoutRewardDialog(_ desiredVal:NSNumber, cDate:Date, endDate:Date, kwh:NSNumber) -> Void{
        
        let title = "Tem certeza?"
        let msg   = self.REWARD_STATUS_DEFAULT
        
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Criar sem recompensa", style: .default, handler: {
            (action: UIAlertAction) in
            
            self.createGoal(
                desiredVal,
                cDate     :cDate,
                endDate   :endDate,
                kwh       :kwh
            )
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            
            print("User canceled the new goal operation without a reward")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    /*
        This dialog is shown before the user create a new goal if the current location doesn't
        have a functional device. A goal can only be created without a device if the user 
        inform the current reading value on his/her eletric monitoring device.
    */
    internal func firstReadingDialog(){
        
        let title = "Você não possui um dispositivo de monitoramento"
        let msg = "Sem um dispositivo de monitoramento ativado no seu imóvel, as leituras da quantidade de Kilowatts gastos deverão ser realizadas manualmente :("
        
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok, criar objetivo", style: .default, handler: { (action: UIAlertAction) in
            
            self.inputDialog()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Não quero criar um objetivo", style: .default, handler: { (action: UIAlertAction) in
            
            print("user canceled the new goal operation")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    /*
        Show the input dialog to get the first reading for the goal that is going to be created, 
        in case the user doesn't have an active device attached to this location
    */
    internal func inputDialog(){
        
        // create a new reading dialog
        self.popViewController = UpdateReadingViewController(
            nibName: "UpdateReadingViewController",
            bundle: nil
        )
        
        // initialize dialog with pointer to this page, in order to get the inserted value
        self.popViewController.callerViewController = self
        self.popViewController.isFirstReading = true
        self.popViewController.title = "This is a popup view"
        self.popViewController.showInView(
            self.view,
            withImage: UIImage(named: ""),
            withMessage: "",
            animated: true
        )
    }
    
    
    /*
        Confirm with the user if the goal really will be deleted
    */
    internal func deleteGoalDialog(){
        
        let title = "Você tem certeza?"
        let msg   = "Ao deletar o objetivo atual você irá deletar todos os dados de leitura, desde a data inicial até a data final do objetivo."
        
        let refreshAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Confirmar", style: .default, handler: { (action: UIAlertAction) in
            
            self.deleteLocationGoalRel()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
            print("User canceled the delete goal operation.")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    /*
        Get data back from the manual reading dialog
    */
    override internal func setReadingValue(_ input:Double){
        
        // make sure the user is going to insert a reading value only once
        if(!self.wasFirstReadingMade){
            
            // if the user inserted a valid value
            if(input != self.popViewController.STD_READING_VAL){
                print("\nok, user has inserted a valid input")
                
                self.firstReading = input
                self.wasFirstReadingMade = true

                self.unlockUI()
            }else{
                print(">>>>>> Aqui")
                self.goHome()
            }
        }
    }
    
    
    
    // LOGIC
    /*
        Upsert a Goal object
    */
    internal func upsertGoal(){
        // loading objects
        print("loading values from UI ...")
        
        let desiredVal = Double(self.feu.replaceComma(self.amountToPay.text!))
        if(desiredVal != nil){
            
            print("desiredValue: \(desiredVal)")
            
            // check if the value to pay is bigger than 0
            if(desiredVal > 0.0){
                
                // getting current date and end date
                let cDate = Date()
                let endDate = self.endDate.date
                
                // check if current date is smaller than today
                if(self.endDate.date.isGreaterThanDate(cDate)){
                    
                    // checkd the kwh
                    let kwh = Double(self.feu.replaceComma(self.kwhVal.text!))
                    if(kwh > 0.0){
                        
                        // UPSERT OPERATIONS
                        if(self.newGoal){
                            
                            // INSERT
                            if(self.selectedReward == nil){
                                print("Warning, reward is nil")
                                
                                self.createGoalWithoutRewardDialog(
                                    desiredVal!,
                                    cDate     :cDate,
                                    endDate   :endDate,
                                    kwh       :kwh!
                                )
                            }else{
                                self.createGoal(
                                    desiredVal!,
                                    cDate     :cDate,
                                    endDate   :endDate,
                                    kwh       :kwh!
                                )
                            }
                        }else{
                        
                            // UPDATE
                            if(DBHelpers.currentGoal != nil){
                            
                                // load updated values
                                var distance:NSNumber = 0.0
                                if let distanceFromGoal:NSNumber = self.dbh.getDistanceOfGoal() as NSNumber?{
                                    distance = distanceFromGoal
                                }
                                
                                let watts = self.getDesiredWatts(
                                    kwh!,
                                    desiredAmountToPay: desiredVal!
                                )
                            
                                DBHelpers.currentGoal!.setDesiredValue(desiredVal)
                                DBHelpers.currentGoal!.setEndDate(self.endDate.date)
                                DBHelpers.currentGoal!.setKWH(
                                    Double(self.kwhVal.text!)
                                )
                                DBHelpers.currentGoal!.setDesiredWatts(watts)
                                DBHelpers.currentGoal!.setGoalReward(
                                    self.selectedReward?.getObId()
                                )
                                DBHelpers.currentGoal!.setDistanceFromGoal(distance)
                                
                                self.updateGoal()
                            }
                        }
                        
                    }else{
                        print("Warning, kwh is too small or equal to 0")
                        self.infoWindow("O valor do KW/h deve ser maior do que 0.\nAinda não atingimos o sonho da energia gratuita (:", title: "Atenção", vc: self)
                    }
                }else{
                    print("Warning, current date is greater than last day")
                    self.infoWindow("A data final deve ser maior do que a data atual", title: "Atenção", vc: self)
                }
            }else{
                print("Warning, goal is too small or equal to 0")
                self.infoWindow("O valor a pagar não pode ser iqual a 0 e o aconselhável é que ele seja alcançável, para que as pessoas não se desmotivem com metas impossíveis", title: "Atenção", vc: self)
            }
        }else{
            print("warning, invalid input for field amount to pay")
            self.infoWindow("O campo 'Valor a pagar', não pode estar vazio e deve ser preenchido somente com valores numéricos", title: "Atenção", vc: self)
        }
    }
    
    
    /*
        Create a goal
    */
    internal func createGoal(_ desiredVal:NSNumber, cDate:Date, endDate:Date, kwh:NSNumber){
        
        if(DBHelpers.currentDevice != nil){
            
            if let iniWatts:Double = self.firstReading{
                
                // build a new Goal object and save it on the backend
                let goal:Goal = Goal()
                
                goal.setInitialWatts(iniWatts)
                
                let watts = self.getDesiredWatts(kwh, desiredAmountToPay: desiredVal)
                goal.setDesiredWatts(watts)
                
                goal.setDesiredValue(desiredVal)
                
                goal.setEndDate(self.endDate.date)
                
                goal.setGoalReward(self.selectedReward?.getObId())
                
                goal.setKWH(Double(self.kwhVal.text!))
                
                goal.setDistanceFromGoal(0)
                
                self.createGoalInBackground(goal)
            }else{
                print("error converting string to int")
                self.infoWindow("Insira um valor numérico para a leitura do relógio", title: "Atenção", vc: self)
            }
        }else{
            
            // ask for first reading
            if(self.firstReading != 0){
                
                if let iniWatts:Double = self.firstReading{
                    
                    // build a new Goal object and save it on the backend
                    let goal:Goal = Goal()
                    
                    goal.setInitialWatts(iniWatts)
                    goal.setDesiredValue(desiredVal)
                    let watts = self.getDesiredWatts(
                        kwh,
                        desiredAmountToPay: desiredVal
                    )
                    goal.setDesiredWatts(watts)
                    goal.setEndDate(self.endDate.date)
                    goal.setGoalReward(self.selectedReward?.getObId())
                    goal.setKWH(Double(self.kwhVal
                        .text!))
                    goal.setDistanceFromGoal(0)
                    
                    self.createGoalInBackground(goal)
                }else{
                    print("error converting string to int")
                    self.infoWindow("Insira um valor numérico para a leitura do relógio", title: "Atenção", vc: self)
                }
            }else{
                print("error getting initial watts value")
                self.infoWindow("Para criar uma meta sem o dispositivo de monitoramento, é preciso fazer a leitura inicial da quantidade de KW/h do seu medidor elétrico.", title: "Faça a leitura inicial", vc: self)
            }
        }
        
    }
    
    
    /*
        Loads the current goal attributes into the UI
    */
    internal func loadCurrentGoal(){
        
        if(DBHelpers.currentGoal != nil){
            
            self.getGoal((DBHelpers.currentGoal?.getObId())!)
            
            // change screen details
            self.title = self.SCREEN_TITLE_UPDATE
        
            self.amountToPay.text  = DBHelpers.currentGoal!.getDesiredValue().stringValue
            
            self.startDate.text    = Date.getReadebleDate(
                (DBHelpers.currentGoal!.getStartingDate())!
            )
            
            self.endDate.setDate(
                (DBHelpers.currentGoal!.getEndDate())! as Date, animated: true
            )
            
            self.kwhVal.text  = DBHelpers.currentGoal!.getKWH().doubleValue.format(
                self.DOUBLE_FORMAT
            )
            
            // get goal reward on the backend, if there is one, and load it
            if(self.dbu.STD_UNDEF_STRING != DBHelpers.currentGoal!.getRewardId()){
                
                // check if the user haven't just selected a reward
                if(!self.justCameBackRewSelect){
                
                    // load the reward currently attached to this goal
                    let query:PFQuery = Reward.query()!
                    query.getObjectInBackground(withId: (DBHelpers.currentGoal!.getRewardId())!){
                        (object, error) -> Void in
                    
                        if(error == nil){
                            print("\nfound reward object")
                            print("load current goal reward for update ...")
                        
                            // get reward from backend if is loading page for the updates
                            if let reward:PFObject = object{
                                self.selectedReward = Reward(reward: reward)
                                print("reward: \(self.selectedReward)")
                            }
                        
                            self.selectedRewardTitle.text = self.selectedReward?.getRewardTitle()
                            
                            // update the reward selection btns state
                            self.deleteRewardBtn.isHidden = false
                            self.animateRewardPickerBtnToggle()
                            
                        }else{
                            print("\nerror performing query to get goal")
                        }
                    }
                
                // load a more recent reward form the rewars seleciton screen
                }else{
                    self.selectedRewardTitle.text = self.selectedReward?.getRewardTitle()
                    
                    // update the reward selection btns state
                    self.deleteRewardBtn.isHidden = false
                    self.animateRewardPickerBtnToggle()
                }
            }
        }
        
    }
    
    
    /*
        Get a goal from the backend by using a pointer from the user-goal-device relationship
    */
    internal func getGoal(_ goalId:String){
        let aux:Goal = Goal()
        let query = aux.selectGoalQuery()
        
        query?.getObjectInBackground(withId: goalId){
            (object, error) -> Void in
            
            if(error == nil){
                print("\nfound pointed goal")
                print("load current goal for update ...")
                
                self.currentGoalObj = object
                DBHelpers.currentGoal?.updateGoal(self.currentGoalObj!)
            }else{
                print("\nerror performing query to get goal")
                self.infoWindow("Houve um erro ao tentar obter o objetivo atual para este local", title: "Falha operacional", vc: self)
            }
        }
    }
    
    
    /*
        Create a Goal object in the database
    */
    internal func createGoalInBackground(_ goal:Goal){
        print("\nsaving object goal in the database ..")
        print("goal: \(goal)")
        
        let goalObj:PFObject = goal.getNewGoalPFObj()
        print("goal obj: \(goalObj)")
        
        goalObj.saveInBackground{
            (success: Bool, error: NSError?) -> Void in
            
            if(error == nil){
                print("saved new goal successfully.")
                self.createUserGoalLocationRel(goalObj)
            }else{
                print("failed to save goal in database. \(error!.description)")
            }
        }
    }
    
    
    /*
        Creates an user - device - goal relationship
    */
    internal func createUserGoalLocationRel(_ goal:PFObject){
        print("\ncreating user-device-goal relashionship ...")
        
        let aux:Goal = Goal()
        
        // get current location object
        if let curLoc = DBHelpers.currentLocation{
            
            let userGoalLocationRel:PFObject = aux.getUserGoalLocationObj(
                PFUser.current()!,
                location: curLoc.getPointerToLocationTable(),
                goal:goal
            )
            
            userGoalLocationRel.saveInBackground{
                (success:Bool, error) -> Void in
                
                if(error == nil){
                    self.infoWindow("Novo objetivo criado com sucesso", title: "Operação concluída", vc: self)
                    
                    // perform changes on the datafile, locally and on the app backend
                    DBHelpers.currentLocationData!.addReading(self.firstReading)
                    
                    // update global variables
                    let newGoal = Goal(goal: goal)
                    
                    DBHelpers.currentGoal = newGoal
                    DBHelpers.locationGoals[(DBHelpers.currentLocation?.getObId())!] = newGoal
                    
                    // update current goal locally and on the app backend
                    self.dbh.updateCurrentGoal()
                    
                    // update UI variables
                    self.currentGoalObj = goal
                    self.newGoal = false
                    self.loadCurrentGoal()
                    
                    // send the user back to the home page
                    self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
                    
                }else{
                    print("error creating user-goal-device relationship")
                    self.infoWindow("Erro ao criar relacionamento entre o usuário e dispositivo atualmente selecionados e a meta criada", title: "Falha na operação", vc: self)
                }
            }
            
        }else{
            print("could not get current location object")
        }
    }
    
    
    /*
        Update the current goal object in the backend
    */
    internal func updateGoal(){
        print("\nupdating current goal")
        print("current goal: \(DBHelpers.currentGoal)")
        print("goal db: \(self.currentGoalObj)")
        
        DBHelpers.currentGoal!.updateGoal(self.currentGoalObj!)
        self.currentGoalObj!.saveInBackground {
            (success, error) -> Void in
            
            if(success){
                
                print("goal successfully updated")
                self.infoWindow("Meta atualizada com sucesso", title: "Operação concluída", vc: self)
                    
                self.newGoal = false
                    
                // analyze current goal and send the user to the dashboard screen to through a goal closure depending on the new goal definitions
                self.loadCurrentGoal()
                
                // send the user back to the home page
                self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
            }else{
                print("error updating goal")
                self.infoWindow("Houve um erro de conexão com o servidor", title: "Falha na operação", vc: self)
            }
        }
    }

    
    
    /*
        Delete location - goal relationship
    */
    internal func deleteLocationGoalRel(){
        
        // delete the goal from the user-location-goal relation
        let openedGoalQuery:PFQuery = DBHelpers.currentGoal!.openedGoalForLocation(DBHelpers.currentLocation!)
        
        openedGoalQuery.findObjectsInBackground(block: {
            (goals:[AnyObject]?, error:NSError?) -> Void in
            
            if(error == nil){
                if let goalRelObj = goals?.first{
                    goalRelObj.deleteInBackground(block: {
                        (success:Bool, error:NSError?) -> Void in
                        
                        if(success){
                            print("deleted location-goal relationship successfuly...")
                            self.deleteGoal()
                        }else{
                            print("there was a problem archiving the current goal")
                            self.infoWindow("Houve um erro ao arquivar o objetivo atual", title:"Falha na operação", vc: self)
                        }
                    })
                }else{
                    print("problem getting user-location object")
                }
            }else{
                print("problem getting user-location object \(error!.description)")
            }
        })
        
    }
    
    
    /*
        Delete goal
    */
    internal func deleteGoal(){
        
        let deleteGoal:PFQuery = Goal.query()!
        deleteGoal.getObjectInBackground(withId: (DBHelpers.currentGoal?.getObId())!){
            (goalObj: PFObject?, error: NSError?) -> Void in
            
            if(error == nil){
                if let goal:PFObject = goalObj{
                    goal.deleteInBackground{
                        (success, error:NSError?) -> Void in
                        
                        if(success){
                            print("Goal was successfuly deleted from the app backend relationship")
                            DBHelpers.eraseGoalTraceFromDatafile()
                            
                            // reset UI variables
                            self.resetUI()
                            self.wasFirstReadingMade  = false
                            self.justDeletedGoal      = true
                            self.firstReading         = 0
                            self.title = "Nova meta"
                            
                            self.feu.goToSegueX(self.feu.ID_HOME, obj:self)
                        }else{
                            print("error while deleting goal \(error!.description)")
                        }
                    }
                }
            }else{
                print("error while deleting goal \(error!.description)")
            }
        }
        
    }
    
    
    /*
        Calculates the desired KWS the user want to use until the end of the goal
    */
    internal func getDesiredWatts(_ kwh:NSNumber, desiredAmountToPay:NSNumber) -> NSNumber{
        
        let watts = desiredAmountToPay.doubleValue / kwh.doubleValue
        
        return NSNumber(value: Double(watts.format("0.3"))! as Double)
    }
    
    
    
    // NAVIGATION
    /*
        Send the user back to the home screen by dismissing the current page from the pages stack
    */
    internal func goHome(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    /*
        Prepare data to next screen
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare some data to the next view controller
    }
    
    
    /*
        Get selected object from rewards
    */
    @IBAction func unwindWithSelectedReward(_ segue:UIStoryboardSegue) {
        
        if let rewardPickerVC:SelectRewardViewController = segue.source as? SelectRewardViewController{
            
            print("\ncame back from reward selection with reward: \(rewardPickerVC.selectedReward)")
            
            if let reward = rewardPickerVC.selectedReward{
                
                // set reward title
                self.selectedRewardTitle.text = reward.getRewardTitle()
                    
                // change btn image from add to update
                self.deleteRewardBtn.isHidden = false
                self.animateRewardPickerBtnToggle()
                    
                // change the selected reward object
                self.selectedReward = reward
                    
                // show the delete reward btn
                self.deleteRewardBtn.isHidden = false
                
                // set a flag to warn the system to keep this reward as the more recent
                self.justCameBackRewSelect = true
                
            }else{
                
                // no reward was selected
                self.selectedRewardTitle.text = self.REWARD_STATUS_NOT_SELECTED
                
                // send button to the 'no selected reward position' if it was in the update
                if(self.selectedReward == nil){
                    self.deleteRewardBtn.isHidden = true
                    self.animateRewardPickerBtnToggle()
                }
            }
        }
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
