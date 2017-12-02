//
//  BaseViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/2/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, ChartViewDelegate{

    
    // VARIABLES
    internal var feu:FrontendUtilities = FrontendUtilities()
    
    // keyboard
    internal var keyboardMovement:CGFloat = 0.0
    internal var kbHeight: CGFloat!
    internal var timer: Timer? = nil
    internal var readingInput: Int = 0
    
    internal var loadingTimer:Timer = Timer()
    internal var SPINNER_SPEED:Double = 0.4
    
    internal var intervalToHideKeyboard = 3.0
    
    
    internal var MENU_BTN_IMG = "rect-menu.png"
    internal var HOME_BTN_IMG = "home-light-blue.png"
    internal var NAVBAR_BACKGROUND_PICTURE = "navbarTexture.png"
    internal let NAVBAR_BACKGROUND_COLOR:UIColor = UIColor(
                                                        red: 94/255.0,
                                                        green: 130/255.0,
                                                        blue: 166/255.0,
                                                        alpha: 1
    )
    internal let NAVBAR_TINT_COLOR:UIColor = UIColor(
                                                    red: 209/255.0,
                                                    green: 235/255.0,
                                                    blue: 252/255.0,
                                                    alpha: 1
    )
    internal let NAVBAR_IMG:String = "navbar.png"

    
    
    
    
    
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kbHeight = 70
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // UI
    /*
        Lock and unlock the screen according to the lockIt param.
        input:
            * the screen lock view
            * the view that indicates the action
    */
    internal func lockScreen(_ lockScreen:UIView, actionIndicator:UIImageView, lockIt:Bool){
        
        if(lockIt){
            
            // show the spinner view and start the loading animation
            self.startLoadingAnimation(actionIndicator)
            
            // start a fade out animation and hide the lock screen
            UIView.animate(
                withDuration: 1.0,
                delay: 0.5,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: {
                    lockScreen.alpha = 0.8
                }, completion: {
                    finished in
                    
                    actionIndicator.isHidden = false
                    lockScreen.isHidden = false
                }
            )
            
        }else{
            
            // show the spinner view and start the loading animation
            self.stopSpinner(actionIndicator)
            
            // start a fade out animation and hide the lock screen
            UIView.animate(
                withDuration: 1.0,
                delay: 0.5,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: {
                    lockScreen.alpha = 0.0
                }, completion: {
                    finished in
                    
                    // hide lock and stop spinner
                    actionIndicator.isHidden = true
                    actionIndicator.stopAnimating()
                    lockScreen.isHidden = true
                }
            )
        }
    }
    
    
    /*
        Activate the locked mode of a screen, blocking the user interaction with its UI.
    */
    internal func activateLockedMode(_ screenLocker:UIView){
        print("lock user iteraction with the screen as needed.")
        
        UIView.animate(withDuration: 0.1, animations:{
            screenLocker.layer.backgroundColor = UIColor.black.cgColor
            screenLocker.layer.opacity = 0.0
        }, completion: {
            (value: Bool) in
            
            UIView.animate(withDuration: 1.0, animations:{
                screenLocker.layer.backgroundColor = UIColor.black.cgColor
                screenLocker.layer.opacity = 0.6
            })
        })
    }
    
    
    /*
        Deactivate the locked mode of a screen, allowing the user interaction with its UI.
    */
    internal func deactivateLockedMode(_ screenLocker:UIView){
        print("unlock user iteraction with the screen as needed.")
        
        UIView.animate(withDuration: 0.1, animations:{
            screenLocker.layer.backgroundColor = self.feu.LIGHT_WHITE.cgColor
            screenLocker.layer.opacity = 0.6
        }, completion: {
            (value: Bool) in
                
            UIView.animate(withDuration: 1.0, animations:{
                screenLocker.layer.backgroundColor = UIColor.black.cgColor
                screenLocker.layer.opacity = 0.0
            }, completion: {
                finished in
                
                screenLocker.isHidden = true
            })
        })
    }
    
    
    /*
        Customize navigation bar
    */
    internal func customizeNavBar(_ page:UIViewController){
        
        page.navigationController!.navigationBar.barTintColor = self.NAVBAR_BACKGROUND_COLOR
        page.navigationController!.navigationBar.tintColor    = self.NAVBAR_TINT_COLOR
        page.navigationController!.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: self.NAVBAR_TINT_COLOR
        ]
        
        let img:UIImage = UIImage(named:self.NAVBAR_IMG)!
        page.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        
        page.navigationController?.navigationBar.barStyle = .black
    }
    
    
    /*
        Customize the menu button
    */
    internal func customizeMenuBtn(_ menuBtn:UIBarButtonItem, btnIdentifier:String){
        
        var myImage = UIImage(named: "imgres.jpg")
        
        // make the image resizable
        if(self.feu.ID_HOME == btnIdentifier){
            myImage = UIImage(named: self.HOME_BTN_IMG)
        }else if(self.feu.ID_MENU == btnIdentifier){
            myImage = UIImage(named: self.MENU_BTN_IMG)
        }
        
        let myInsets:UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        myImage = myImage!.resizableImage(withCapInsets: myInsets)
        
        // the the resizable image to the button
        menuBtn.image = myImage
    }
    
    
    /*
        Customize the status bar color
    */
    internal func customizeStatusBar(){
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    /*
        Customize add button
    */
    internal func customizeAddBtn(_ addBtn:UIButton){
        addBtn.layer.borderColor = self.feu.LIGHT_WHITE.cgColor
        addBtn.layer.borderWidth = 5.0
        addBtn.layer.cornerRadius = addBtn.frame.size.width / 2
        addBtn.clipsToBounds = true
        self.applyCurvedShadow(addBtn)
    }
    
    func applyCurvedShadow(_ view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        let path = UIBezierPath()
        
        // top left
        path.move(to: CGPoint(x: radius, y: height))
        
        // top right
        path.addLine(to: CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLine(to: CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurve(to: CGPoint(x: radius, y: height + depth),
            controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
            controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
    
    /*
        Lock the swipe right action to bring the lateral menu
    */
    internal func lockSwipeRight(){
        let reveal:SWRevealViewController = self.revealViewController()
        reveal.panGestureRecognizer().isEnabled = false
    }
    
    
    /*
        Unlock the swipe right action to bring the lateral menu
    */
    internal func unlockSwipeRight(){
        let reveal:SWRevealViewController = self.revealViewController()
        reveal.panGestureRecognizer().isEnabled = true
    }
    
    
    

    // Information methods
    //--------------------
    /*
        Presents an information dialog
    */
    internal func infoWindow(_ txt:String, title:String, vc:UIViewController) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            //println("Handle Ok logic here")
        }))
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    /*
        Modified version of the method above with the cancel option
    */
    internal func infoWindowWithCancel(_ txt:String, title:String, vc:UIViewController) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            //println("Handle Ok logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Cancel Logic here")
        }))
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    // Keyboard methods
    //-----------------
    /*
       Keyboard event related method. Assign listener methods for notifications, on the notification center. Adds the keyboard related methods
    */
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BaseViewController.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(BaseViewController.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    /*
       Keyboard event related method. Remove the keyboard observers once the view is gonna dissapear
    */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
       Keyboard event related method. Detects that the keyboard is going to show up and call an animation to move the main view up
    */
    func keyboardWillShow(_ notification: Notification) {
        self.animateTextField(true)
    }
    
    /*
       Keyboard event related method. Detects that the keyboard is going to disappear and call an animation to move the main view down
    */
    func keyboardWillHide(_ notification: Notification) {
        
        // move view to initial position when the keyboard is dismissed
        UIView.animate(withDuration: 0.3,
            animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -self.keyboardMovement)
            }, completion:{
                (success:Bool) in
                
                self.keyboardMovement = 0.0
            }
        )
    }
    
    /*
       Keyboard event related method. Animate a text field upwards, being the distance on the movement equal to the keyboard height
    */
    func animateTextField(_ up: Bool) {
        var movement:CGFloat
        
        if(up){
            movement = -kbHeight
            
            self.keyboardMovement = self.keyboardMovement + movement
        }else{
            movement = kbHeight
        }
        
        if(((movement < 0) && (self.view.frame.origin.y >= 0)) ||
            ((movement > 0) && (self.view.frame.origin.y <= 0))){
        
            UIView.animate(withDuration: 0.3,
                animations: {
                    self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
                }
            )
        }
    }
    
    /*
        Text field methods
    */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.calculateDistanceMoviment(textField)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.calculateDistanceMovimentTV(textView)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.calculateDistanceMovimentTV(textView)
        
        return true
    }
    
    
    /*
        Calculate the distance of the input movement on the keyboard animation
    */
    internal func calculateDistanceMoviment(_ textField:UITextField){
        
        // hardcode the keyboard height, can be improved to get the actual keyboard height
        let keyboardHeight = CGFloat(280.0)
        
        // try to get the parentsView origin.y position
        var foundLastSuperView:Bool = false
        var parentsYPos:CGFloat = 0.0
        var parentA = textField.superview
        
        // while not at the top of the element's view hierarchy
        while(!foundLastSuperView){
            
            // get the element superview until the top of the view hierarchy
            if let parentB:UIView = parentA{
                
                // get the Y position of the partent and sum it, to consider the real position of the text input being threated
                parentsYPos += parentB.frame.origin.y
                parentA = parentB.superview
            }else{
                foundLastSuperView = true
            }
        }
        
        // calculate de difference to base distance of the movement
        var difference = self.view.frame.height - (textField.frame.origin.y + parentsYPos)
        
        // if the keyboard is covering the input field, push the input higher and add some extra
        if(difference < keyboardHeight){
            
            // get the distance as a percentage of the difference
            difference = keyboardHeight - difference
            let distance = (difference * CGFloat(100.0)/keyboardHeight) * (keyboardHeight * CGFloat(0.01))
            
            self.kbHeight = distance + CGFloat(30.0)
        }else{
            self.kbHeight = 0.0
        }
    }
    
    
    /*
        Calculate the distance of the input movement on the keyboard animation
    */
    internal func calculateDistanceMovimentTV(_ textView:UITextView){
        
        // hardcode the keyboard height, can be improved to get the actual keyboard height
        let keyboardHeight = CGFloat(280.0)
        
        // try to get the parentsView origin.y position
        var foundLastSuperView:Bool = false
        var parentsYPos:CGFloat = 0.0
        var parentA = textView.superview
        
        // while not at the top of the element's view hierarchy
        while(!foundLastSuperView){
            
            // get the element superview until the top of the view hierarchy
            if let parentB:UIView = parentA{
                
                // get the Y position of the partent and sum it, to consider the real position of the text input being threated
                parentsYPos += parentB.frame.origin.y
                parentA = parentB.superview
            }else{
                foundLastSuperView = true
            }
        }
        
        // calculate de difference to base distance of the movement
        var difference = self.view.frame.height - (textView.frame.origin.y + parentsYPos)
        
        // if the keyboard is covering the input field, push the input higher and add some extra
        if(difference < keyboardHeight){
            
            // get the distance as a percentage of the difference
            difference = keyboardHeight - difference
            let distance = (difference * CGFloat(100.0)/keyboardHeight) * (keyboardHeight * CGFloat(0.01))
            
            self.kbHeight = distance + CGFloat(10.0)
        }else{
            self.kbHeight = 0.0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: self.intervalToHideKeyboard, target: self, selector: #selector(BaseViewController.dismissKeyboard(_:)), userInfo: textField, repeats: false)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(BaseViewController.dismissKeyboard(_:)), userInfo: textView, repeats: false)
        
        return true
    }
    
    
    func dismissKeyboard(_ timer: Timer) {
        if let textField = timer.userInfo as? UITextField{
            textField.resignFirstResponder()
            
        }else if let textView = timer.userInfo as? UITextView{
            textView.resignFirstResponder()
            
        }else{
            print("problem getting textfield out of the userInfo variable of the timer object")
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    
    // Animations
    //-----------
    /*
        Starts the loading animation by creating a timer to rotate the spinner view
    
        Input:
            * a UIImageView to work as a spinner, the view must be hidden
    */
    internal func startLoadingAnimation(_ spinner:UIImageView){
        
        // showt the spinner view
        self.feu.fadeIn(spinner, speed: self.SPINNER_SPEED)
        
        // start counting the loading time
        self.loadingTimer = Timer.scheduledTimer(
            timeInterval: self.SPINNER_SPEED,
            target   : self,
            selector : #selector(BaseViewController.rotateSpinner(_:)),
            userInfo : spinner,
            repeats  : true
        )
    }
    
    
    /*
        Rotate the spinner until it the page is fully loaded
    */
    internal func rotateSpinner(_ timer:Timer){
        
        if let spinner:UIImageView = timer.userInfo as? UIImageView{
            
            UIView.animate(
                withDuration: self.SPINNER_SPEED,
                delay: 0,
                options: .curveLinear, animations: {
                    () -> Void in
                    
                    spinner.transform = spinner.transform.rotated(by: CGFloat(M_PI_2)
                    )
                }
            ){
                (finished) -> Void in
                // something
            }
        }else{
            print("problems to get the spinner view out of the timer's user info variable")
        }
    }
    
    
    /*
        Stop spinner rotation
    */
    internal func stopSpinner(_ spinner:UIImageView){
        
        // hides the spinner
        self.feu.fadeOut(spinner, speed:self.SPINNER_SPEED)
        
        // stops timer
        self.loadingTimer.invalidate()
    }
    
    
    
    // Data transportation
    //--------------------
    internal func setReadingValue(_ input:Double){
        print("\ndo something with the input gathered from UpdateReadingViewController")
        print("value: \(input)")
    }

}



// Extends the Int class to implement some convenience methods
extension Int{
    
    static func random(_ range: Range<Int> ) -> Int{
        var offset = 0
        
        if range.lowerBound < 0{
            offset = abs(range.lowerBound)
        }
        
        let mini = UInt32(range.lowerBound + offset)
        let maxi = UInt32(range.upperBound   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}


// Extends the double class to especify formatting
extension Double {
    
    func format(_ f:String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}


// Extends the NSDate class to customize comparisons between NSDate objects
extension Date{
    
    func isGreaterThanDate(_ dateToCompare:Date) -> Bool{
        
        var isGreater = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending{
            isGreater = true
        }
        
        return isGreater
    }
    
    
    func isLessThanDate(_ dateToCompare:Date) -> Bool{
        
        var isLess = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending{
            isLess = true
        }
        
        return isLess
    }
    
    
    static func getReadebleDate(_ date:Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        //dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.string(from: date)
    }
    
    
    static func getDateObject(_ date:String, format:String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: date)
        
        return date!
    }
    
    
    static func getDaysLeft(_ startDate:Date, endDate:Date) -> Int{
        
        let cal = Calendar.current
        let unit:NSCalendar.Unit = NSCalendar.Unit.day
        let components = (cal as NSCalendar).components(unit, from: startDate, to: endDate, options: [])
        
        // >>> procurar solução definitiva
        return components.day! + 1
    }
}
