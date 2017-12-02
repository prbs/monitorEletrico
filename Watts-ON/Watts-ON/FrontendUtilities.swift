
//
//  FrontendUtilities.swift
//  InvasoresDoPlanalto
//
//  Created by Diego Silva on 9/5/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//
    
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Charts
    
    
class FrontendUtilities: UIViewController, ChartViewDelegate  {
    
    
    // CONSTANTS
    //----------
    // Options
    let ACCOUNT_TYPES:[String]       = ["Premium","Free"]
    let LOCATION_TYPES:[String]      = ["Residencial","Business"]
    let FACEBOOK_PERMISSIONS         = ["public_profile", "email", "user_friends"]
    
    //let MAIN_MENU_ITEMS              = ["perfil", "dispositivos", "dicas", "metas_anteriores", "recompensas", "configuracoes", "logout"]
    
    let MAIN_MENU_ITEMS              = ["perfil", "dicas", "metas_anteriores", "recompensas", "configuracoes", "logout"]
    
    let ROTATION_DIRECTION_LEFT      = "left"
    let ROTATION_DIRECTION_RIGHT     = "right"
    
    let DATE_FORMAT                  = "dd-MM-yyyy"
    let DATE_FORMAT_DAY_MONTH        = "dd-MM"
    let TIME_FORMAT                  = "HH:mm:ss"
    
    let PAGE_MODE_CREATE             = "create"
    let PAGE_MODE_UPDATE             = "update"
    let PAGE_MODE_DETAILS            = "details"
    
    let IMAGE_SIZE = 54000000         // bytes
    
    
    // Colors
    //-------
    // charts colors
    let BARCHART_ARRAY_COLORS = [
        UIColor(red: 141/255, green: 235/255, blue: 247/255, alpha: 1)
    ]
    
    // navbar colors
    let NAVBAR_BACKGROUND_COLOR:UIColor = UIColor(red: 49/255.0,green: 104/255.0,blue: 144/255.0,alpha: 1)
    let NAVBAR_BACKGROUND_COLOR_DARKER:UIColor = UIColor(red: 58/255.0,green: 85/255.0,blue: 113/255.0,alpha: 1)
    
    // side bar menu colors
    let SIDEBAR_HEADER_HIGHLIGHTED_COLOR:UIColor = UIColor(red: 45/255.0,green: 66/255.0,blue: 86/255.0,alpha: 1)
    let SIDEBAR_HEADER_NORMAL_COLOR:UIColor = UIColor(red: 59/255.0,green: 86/255.0,blue: 113/255.0,alpha: 1)
    let SIDEBAR_BODY_HIGHLIGHTED_COLOR:UIColor = UIColor(red: 57/255.0,green: 94/255.0,blue: 132/255.0,alpha: 1)
    let SIDEBAR_BODY_NORMAL_COLOR:UIColor = UIColor(red: 64/255.0,green: 107/255.0,blue: 151/255.0,alpha: 1)
    
    // other colors
    var INITIAL_PROGRESS_COLOR  = UIColor.gray
    let SAFE_COLOR              = UIColor(red: 66/255,  green: 143/255, blue: 244/255, alpha: 0.7)
    let WARNING_COLOR           = UIColor(red: 253/255, green: 115/255, blue: 0/255,   alpha: 0.7)
    let DANGER_COLOR            = UIColor(red: 253/255, green: 52/255,  blue: 0/255,  alpha: 1.0)
    let DARK_WHITE              = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
    let LIGHT_WHITE             = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
    let SUPER_LIGHT_WHITE       = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    let LIGHT_GREY              = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25)
    let MEDIUM_GREY             = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    let DARK_GREY               = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    let LIGHT_BLUE              = UIColor(red: 21/255, green: 129/255, blue: 226/255, alpha: 1.0)
    var finalProgressColor      = UIColor.gray
    
    
    // Fonts
    //------
    let SYSTEM_FONT = "Helvetica Neue"
    
    
    // Animations
    //-----------
    internal let HOME_ANIMATION_BOLT     = "bolt"
    internal let HOME_ANIMATION_PROGRESS = "progress"
    
    var FINAL_LANDMARK_FADE_IN_SPEED = 1.3
    let PULSING_SPEED                = 0.7
    let BORDER_STRETCHING_RATIO      = CGFloat(4)
    
    
    // Control variables
    static   var hasAnimated :[String:Bool] = [String:Bool]()
    internal var timer :Timer             = Timer()
    internal var nTimes :Int                = 0
    internal var timesCounter :Int          = 0
    
    // Navigation
    let ID_LOGIN_SIGNUP:String      = "LoginSignup"
    let ID_LOGIN:String             = "Login"
    let ID_HOME:String              = "SWRevealHome"
    let ID_SWITCH_ENVIR:String      = "SwitchEnvironment"
    let ID_SIGNUP:String            = "Signup"
    let ID_HARDWARE_SETUP:String    = "HardwareSetup"
    let ID_SETTINGS:String          = "Settings"
    let ID_TIP:String               = "Tips"
    let ID_MENU:String              = "Menu"
    let ID_MAIN_DEV_SETTINGS:String = "SettingsMainDevices"
    let ID_CAD_DECISION:String      = "CadDecision"
    let ID_CAD_KEY:String           = "CadUsuKey"
    let ID_CAD:String               = "CadUsu"
    let ID_NEW_GOAL:String          = "DefineGoal"
    let ID_UPDATE_READING:String    = "UpdateReading"
    let ID_TUTORIAL:String          = "Tutorial"
    let ID_PROFILE:String           = "Profile"
    let ID_NEW_REWARD:String        = "NewReward"
    
    // Menu options segues
    let SEGUE_SWREAR:String             = "sw_rear"
    let SEGUE_HOME:String               = "HomeSegue"
    let SEGUE_PROFILE:String            = "ProfileSegue"
    let SEGUE_DEVICES:String            = "DevicesSegue"
    let SEGUE_TIPS:String               = "TipsSegue"
    let SEGUE_OLD_GOALS:String          = "ShowOldGoalsSegue"
    let SEGUE_REWARDS:String            = "RewardsSegue"
    let SEGUE_SETTINGS:String           = "SettingsSegue"
    
    // Goals
    let SEGUE_DEFINE_GOAL:String         = "DefineGoalsSegue"
    let SEGUE_CHECK_GOAL:String          = "CheckGoalsSegue"
    let SEGUE_SELECT_REWARD_NGOAL:String = "SelectRewardForNewGoalSegue"
    
    // Rewards
    let SEGUE_REWARD_SHOW:String        = "ShowRewardSegue"
    let SEGUE_REWARD_ADD:String         = "AddRewardSegue"
    let SEGUE_REWARD_UPDATE:String      = "UpdateRewardSegue"
    
    let SEGUE_UNWIND_AFTER_NEW_REW:String = "unwindAfterNewReward"
    let SEGUE_UNWIND_AFTER_DEL_REW:String = "unwindAfterRewardDeletion"
    let SEGUE_UNWIND_AFTER_UDT_REW:String = "unwindAfterRewardUpdate"
    let SEGUE_UNWIND_AFTER_SCT_REW:String = "unwindAfterRewardSelection"
    
    
    // Tips
    let SEGUE_TIP_DETAILS:String        = "TipDetails"
    
    // Tutorial
    let SEGUE_TUTORIAL:String           = "RegistrationTutorialSegue"
    
    // Location
    let SEGUE_CHOOSE_HOW_ADD_LOC:String = "ChooseNewLocationMode"
    let SEGUE_NEW_LOCATION:String       = "NewLocationSegue"
    let SEGUE_LOCATION_DETAILS:String   = "LocationDetailSegue"
    let SEGUE_LOCATION_JOIN:String      = "JoinLocationSegue"
    let SEGUE_LOCATION_UPDATE:String    = "LocationUpdate"
    let SEGUE_SET_BEACONS:String        = "SetBeacons"
    let SEGUE_GENERATE_QRCODE:String    = "GenerateQRCodeSegue"
    
    
    let SEGUE_UNWIND_AFTER_NEW_LOC:String = "unwindAfterNewLocation"
    let SEGUE_UNWIND_AFTER_LOC_DEL:String = "unwindAfterLocationDeletion"
    let SEGUE_UNWIND_AFTER_UPT_LOC:String = "unwindWithUpdatedLocation"
    let SEGUE_UNWIND_AFTER_GEN_QRC:String = "GoBackToPlaceDetailsFromQRCode"
    
    
    // User
    let SEGUE_GO_LOGIN:String           = "goLogin"
    let SEGUE_PERSONAL_REGI:String      = "goPersonalRegistration"
    
    // Readings
    let SEGUE_READINGS:String           = "DailyReadingsDetailsSegue"
    let SEGUE_DAILY_READINGS:String     = "DailyReadingsSegue"
    
    let SEGUE_UNWIND_TO_DAILY_R:String  = "SaveReadingDetailSegue"
    let SEGUE_UNWIND_AFTER_RD_CHK:String  = "unwindAfterReadingsCheck"
    
    
    // Devices
    let SEGUE_UPSERT_DEVICE:String      = "UpsertDeviceSegue"
    
    let SEGUE_UNWIND_AFTER_DEV_UPS:String = "unwindAfterDeviceUpsert"
    let SEGUE_UNWIND_AFTER_DEV_DEL:String = "unwindAfterDeviceDeletion"
    
    
    
    // Images
    let IMAGE_LOC_TYPE_RESIDENCIAL = "icon-home.png"
    let IMAGE_LOC_TYPE_BUSINESS    = "icon-business.png"
    let IMAGE_LOC_TYPE_UNDEFINED   = "doubt.png"
    
    let IMAGE_HOME_NAVBAR_ICO      = "home-light-blue.png"
    let IMAGE_USER_PLACEHOLDER     = "user.png"
    let BTN_WHITE                  = "btn-white.png"
    let BTN_BLUE                   = "btn-blue.png"
    
    
    
    
    
    // GETTERS
    internal func getDefaultProfileImg() -> UIImage?{
        if let stdImg = UIImage(named: self.IMAGE_USER_PLACEHOLDER){
            return stdImg
        }else{
            print("problems getting default user placeholder image")
            return nil
        }
    }
    
    
    internal func getNavbarHeight() -> CGFloat{
        return 60.0
    }
    
    
    
    
    // ANIMATIONS
    /*
        Fade the element in at a certain speed
    */
    internal func fadeIn(_ view:UIView, speed:Double){
        
        // use the hidden attribute to control de animation
        if(view.isHidden){
            view.isHidden = false
            
            // make the method behavior the same, independent of the configuration the user inserted
            view.alpha = 0.0
            view.layer.opacity = 0.0
            
            UIView.animate(withDuration: 1.0, animations:{
                view.alpha = 0.0
                view.layer.opacity = 0.0
                
            }, completion: {
                (value: Bool) in
                    
                UIView.animate(withDuration: speed, animations:{
                    view.alpha = 1.0
                    view.layer.opacity = 1.0
                    
                })
            })
        }
    }
    
    
    /*
        Fade the element out at a certain speed
    */
    internal func fadeOut(_ view:UIView, speed:Double){
        
        if(!view.isHidden){
            
            UIView.animate(withDuration: 1.0, animations:{
                view.alpha = 1.0
                view.layer.opacity = 1.0
                
            }, completion: {
                (value: Bool) in
                    
                UIView.animate(withDuration: speed, animations:{
                    view.alpha = 0.0
                    view.layer.opacity = 0.0
                    
                }, completion: {
                    (value:Bool) in
                    
                    view.isHidden = true
                })
            })
        }
    }
    
    
    /*
        Make the element jump fastly jump 25 points
    */
    internal func btnJump(_ btn:UIButton, distance:CGFloat){
        
        UIView.animate(withDuration: 0.250, animations:{
            btn.frame = CGRect(
                x: btn.frame.origin.x,
                y: btn.frame.origin.y - distance,
                width: btn.frame.size.width,
                height: btn.frame.size.height
            )
        }, completion: {
            (value: Bool) in
                
            UIView.animate(withDuration: 0.175, animations:{
                btn.frame = CGRect(
                    x: btn.frame.origin.x,
                    y: btn.frame.origin.y + distance,
                    width: btn.frame.size.width,
                    height: btn.frame.size.height
                )
            })
        })

    }
    
    
    /*
        Make the element kick 3 times
    */
    internal func kickView(_ view:UIView){
    
        UIView.animate(withDuration: 0.2, animations:{
            
            view.frame = CGRect(
                x: view.frame.origin.x,
                y: view.frame.origin.y,
                width: view.frame.size.width,
                height: view.frame.size.height
            )
            
        }, completion: {
            (value: Bool) in
                
            UIView.animate(withDuration: 0.25, animations:{
                    
                view.frame = CGRect(
                    x: view.frame.origin.x,
                    y: view.frame.origin.y - 20,
                    width: view.frame.size.width,
                    height: view.frame.size.height
                )
                    
            }, completion:{
                (value:Bool) in
                        
                UIView.animate(withDuration: 0.19, animations:{
                            
                    view.frame = CGRect(
                        x: view.frame.origin.x,
                        y: view.frame.origin.y + 20,
                        width: view.frame.size.width,
                        height: view.frame.size.height
                    )
                
                }, completion:{
                    (value:Bool) in
                                
                    UIView.animate(withDuration: 0.17, animations:{
                                    
                        view.frame = CGRect(
                            x: view.frame.origin.x,
                            y: view.frame.origin.y - 10,
                            width: view.frame.size.width,
                            height: view.frame.size.height
                        )
                                    
                    }, completion:{
                        (value:Bool) in
                                        
                        UIView.animate(withDuration: 0.14, animations:{
                                            
                            view.frame = CGRect(
                                x: view.frame.origin.x,
                                y: view.frame.origin.y + 10,
                                width: view.frame.size.width,
                                height: view.frame.size.height
                            )
                                            
                        }, completion:{
                            (value:Bool) in
                                                
                            UIView.animate(withDuration: 0.1, animations:{
                                                    
                                view.frame = CGRect(
                                    x: view.frame.origin.x,
                                    y: view.frame.origin.y - 4,
                                    width: view.frame.size.width,
                                    height: view.frame.size.height
                                )
                                                    
                            }, completion:{
                                (value:Bool) in
                            
                                UIView.animate(withDuration: 0.09, animations:{
                                                    
                                    view.frame = CGRect(
                                        x: view.frame.origin.x,
                                        y: view.frame.origin.y + 4,
                                        width: view.frame.size.width,
                                        height: view.frame.size.height
                                    )
                                                            
                                }, completion:{
                                    (value:Bool) in
                                                                
                                    //print("stopped kicking")
                                })
                            })
                        })
                    })
                })
            })
        })
        
    }
    
    

    
    /*
        Create a pulse effect on the selected view by increasing and reducing the size of the it
    */
    internal func startPulsing(_ view:UIView, times:Int){
        self.nTimes = times
        
        self.timer = Timer.scheduledTimer(
            timeInterval: self.PULSING_SPEED,
            target   : self,
            selector : #selector(FrontendUtilities.pulse(_:)),
            userInfo : view,
            repeats  : true
        )
    }
    
    func pulse(_ timer:Timer){
        if(self.timesCounter < self.nTimes){
            if let view = timer.userInfo as? UIView{
                UIView.animate(withDuration: self.PULSING_SPEED, animations:{
                    view.layer.backgroundColor = self.DARK_WHITE.cgColor
                    view.layer.borderColor     = self.LIGHT_WHITE.cgColor
                }, completion: {
                    (value: Bool) in
                        
                    UIView.animate(withDuration: self.PULSING_SPEED, animations:{
                        view.layer.backgroundColor = UIColor.white.cgColor
                        view.layer.borderColor     = self.LIGHT_GREY.cgColor
                    }, completion:{
                        (value:Bool) in
                            
                        self.timesCounter++
                    })
                })
            }else{
                print("problems getting view to animation")
            }
        }else{
            self.stopPulsing()
        }
    }
    
    internal func stopPulsing(){
        self.timer.invalidate()
        self.timesCounter = 0
    }
    
    
    
    internal func moveRight(_ view:UIView, distance:CGFloat, speed:Double){
        
        // move view to the right side
        UIView.animate(withDuration: speed,
            animations: {
                view.frame = CGRect(
                    x: view.frame.origin.x,
                    y: view.frame.origin.y,
                    width: view.frame.size.width,
                    height: view.frame.size.height
                )
            }, completion:{
                (val:Bool) in
                
                UIView.animate(withDuration: speed,
                    animations: {
                        view.frame = CGRect(
                            x: view.frame.origin.x + distance,
                            y: view.frame.origin.y,
                            width: view.frame.size.width,
                            height: view.frame.size.height
                        )
                    }, completion:{
                        (val:Bool) in
                        
                        print("moved left toggle")
                })
            }
        )
    }
    
    
    
    
    internal func moveLeft(_ view:UIView, distance:CGFloat, speed:Double){
        
        // move view to the right side
        UIView.animate(withDuration: speed,
            animations: {
                view.frame = CGRect(
                    x: view.frame.origin.x,
                    y: view.frame.origin.y,
                    width: view.frame.size.width,
                    height: view.frame.size.height
                )
            }, completion:{
                (val:Bool) in
                
                UIView.animate(withDuration: speed,
                    animations: {
                        view.frame = CGRect(
                            x: view.frame.origin.x - distance,
                            y: view.frame.origin.y,
                            width: view.frame.size.width,
                            height: view.frame.size.height
                        )
                    }, completion:{
                        (val:Bool) in
                        
                        print("moved left toggle")
                })
            }
        )
    }
    
    

    
    
    
    
    
    
    /*
        Call the user's attention by changing the alpha value of an element
    */
    internal func changeAlphaLoop(_ element:UIView, times:Int){
        print("stating alpha transitions ...")
        self.nTimes = times
        self.timesCounter = 0
        
        self.timer = Timer.scheduledTimer(
            timeInterval: self.PULSING_SPEED * 4,
            target   : self,
            selector : #selector(FrontendUtilities.startAlphaTransitions(_:)),
            userInfo : element,
            repeats  : true
        )
    }
    
    
    
    /*
        Animate the header option of the sidebar menu when it is selected
    */
    internal func animationMenuOptionONSelectionForHeader(_ cell:UITableViewCell){
        
        if let originalColor:CGColor = cell.contentView.layer.backgroundColor{
            
            UIView.animate(withDuration: 0.4, animations:{
                cell.contentView.layer.backgroundColor = originalColor
            }, completion: {
                (value: Bool) in
                    
                UIView.animate(withDuration: 0.1, animations:{
                    cell.contentView.layer.backgroundColor = self.SIDEBAR_HEADER_HIGHLIGHTED_COLOR.cgColor
                }, completion:{
                    (value:Bool) in
                            
                    UIView.animate(withDuration: 0.3, animations:{
                        cell.contentView.layer.backgroundColor = originalColor
                    })
                })
            })
            
        }else{
            print("could not get the color of the layer of the UITableViewCell")
        }
    }
    
    
    
    
    /*
        Animation menu option layer background color
    */
    internal func animationMenuOptionOnSelection(_ cell:UITableViewCell){
        
        if let originalColor:CGColor = cell.contentView.layer.backgroundColor{
            
            UIView.animate(withDuration: 0.4, animations:{
                cell.contentView.layer.backgroundColor = originalColor
            }, completion: {
                (value: Bool) in
                    
                UIView.animate(withDuration: 0.1, animations:{
                    cell.contentView.layer.backgroundColor = self.SIDEBAR_BODY_HIGHLIGHTED_COLOR.cgColor
                }, completion:{
                    (value:Bool) in
                            
                    UIView.animate(withDuration: 0.3, animations:{
                        cell.contentView.layer.backgroundColor = originalColor
                    })
                })
            })
            
        }else{
            print("could not get the color of the layer of the UITableViewCell")
        }
    }
    
    
    
    
    internal func startAlphaTransitions(_ timer:Timer){
        
        if(self.timesCounter < self.nTimes){
            if let view = timer.userInfo as? UIView{
                
                UIView.animate(withDuration: self.PULSING_SPEED*0.8, animations:{
                    view.layer.opacity = 0.2
                }, completion: {
                    (value: Bool) in
                        
                    UIView.animate(withDuration: self.PULSING_SPEED*1.3, animations:{
                        view.layer.opacity = 1.0
                    }, completion:{
                        (value:Bool) in
                                
                        UIView.animate(withDuration: self.PULSING_SPEED*0.8, animations:{
                            view.layer.opacity = 0.2
                        }, completion: {
                            (value: Bool) in
                                
                            UIView.animate(withDuration: self.PULSING_SPEED*1.3, animations:{
                                view.layer.opacity = 1.0
                            }, completion:{
                                (value:Bool) in
                                
                                self.timesCounter++
                            })
                        })
                    })
                })
            }else{
                print("problems getting view to animation")
            }
        }else{
            self.stopChangeAlphaLoop()
        }
    }
    
    internal func stopChangeAlphaLoop(){
        print("stopped alpha transitions")
        self.timer.invalidate()
        self.timesCounter = 0
    }
    
    
    
    /*
        Present a btn from the bottom to a higher position, distance points, fadding in from alpha 0 to 1
    */
    internal func presentBtnFromBottom(_ btn:UIButton, distance:CGFloat, speed:Double, callAttention:Bool){

        btn.isHidden = false
        btn.isEnabled = true
        
        UIView.animate(withDuration: speed, animations:{
            btn.frame = CGRect(
                x: btn.frame.origin.x,
                y: btn.frame.origin.y - distance,
                width: btn.frame.size.width,
                height: btn.frame.size.height
            )
        }, completion: {
            (value: Bool) in
        })
        
        UIView.animate(withDuration: speed * 0.7, animations:{
            btn.alpha = 1
        })
    }
    
    
    /*
        Hide a button dragging it down by distance points and fadding out from alpha 1 to 0
    */
    internal func hideFromTop(_ btn:UIButton, distance:CGFloat, speed:Double){
        
        UIView.animate(withDuration: speed, animations:{
            btn.frame = CGRect(
                x: btn.frame.origin.x,
                y: btn.frame.origin.y + distance,
                width: btn.frame.size.width,
                height: btn.frame.size.height
            )
        })
        
        UIView.animate(withDuration: speed * 0.7, animations:{
            btn.alpha = 0
        })
    }
    
    
    /*
        Rotate add/close button
    */
    func rotateToDirection(_ view:UIView, rotationDirection:String, time:Double){
        
        // rotate button left or right
        if(rotationDirection == self.ROTATION_DIRECTION_LEFT){
            UIView.animate(withDuration: time, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
            })
        }else{
            UIView.animate(withDuration: time, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            })
        }
    }

    
    
    /*
        Rotate 90 degrees right
    */
    func rotate90DegreesRight(_ view:UIView, time:Double){
        
        UIView.animate(withDuration: time, animations: {
            view.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            
            self.roundItBordless(view)
        })
    }
    
    
    
    
    
    /*
        Rotate add/close button
    */
    func rotateToDirection(_ btn:UIButton, rotationDirection:String, time:Double, newImage:UIImage){
        
        // rotate button left or right
        if(rotationDirection == "left"){
            UIView.animate(withDuration: time, animations: {
                btn.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
            })
         }else{
            UIView.animate(withDuration: time, animations: {
                btn.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            })
        }
        
        // fade out, change UIImage and fade in back again
        UIView.animate(withDuration: time/2, animations:{
            btn.alpha = 0.001
        }, completion:{
                (value: Bool) in
                
                // change button image
                btn.setImage(newImage, for: UIControlState())
                
                UIView.animate(withDuration: time/2, animations:{
                    btn.alpha = 1
                })
        })

    }
    
    
    
    /*
    Creates the progress bar animation with an intermediate landmark
    */
    func animateProgressBar(_ progressBar:UIView, progressBarTrail:UIView, progressPointer:UIView, landmark:UIView, finalLandmark:UIView, startValue:Float, landmarkValue:Float, endValue:Float){
        
        let LANDMARK_FADE_IN_SPEED       = 1.1
        let MOVING_POINTER_GROWING_RATIO = CGFloat(4)
        let FINAL_LANDMARK_FADE_IN_SPEED = 0.7
        let INITIAL_PROGRESS_COLOR       = UIColor.blue
        let INTERMEDIATE_PROGRESS_COLOR  = UIColor.orange
        let FINAL_PROGRESS_COLOR         = UIColor.red
        
        let pBarWidth     = progressBarTrail.frame.width
        let progressRatio = pBarWidth * 0.01
        let valuePoints   = CGFloat(endValue - startValue)
        let landmarkLeftMov = CGFloat(CGFloat(landmarkValue * 100)/valuePoints) * progressRatio
        let landmarkPos = progressBar.frame.origin.x + landmarkLeftMov
        let finalLandmarkPos = progressBar.frame.origin.x + pBarWidth
        
        print("\n\nPROGRESS BAR ANIMATION")
        print("startValue: \(startValue)")
        print("landmarkValue: \(landmarkValue)")
        print("endValue: \(endValue)")
        
        print("\npBarWidth: \(pBarWidth)")
        print("progressRatio: \(progressRatio)")
        print("landmarkPos: \(landmarkPos)")
        print("finalLandmarkPos: \(finalLandmarkPos)")
        
        // Progress bar pointer animation
        UIView.animate(withDuration: 0.01, animations:{
            
            // set the initial value of the progress pointer
            progressPointer.frame = CGRect(
                x: progressPointer.frame.origin.x - landmarkLeftMov,
                y: progressPointer.frame.origin.y,
                width: progressPointer.frame.size.width - MOVING_POINTER_GROWING_RATIO,
                height: progressPointer.frame.size.height - MOVING_POINTER_GROWING_RATIO
            )
            
            // set the initial value of the landmark view
            landmark.frame = CGRect(
                x: landmark.frame.origin.x - landmarkLeftMov,
                y: landmark.frame.origin.y,
                width: landmark.frame.size.width - MOVING_POINTER_GROWING_RATIO,
                height: landmark.frame.size.height - MOVING_POINTER_GROWING_RATIO
            )
            }, completion: {
                (value: Bool) in
                
                // animate pointer to the intermediary position
                UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                    progressPointer.frame = CGRect(
                        x: progressPointer.frame.origin.x + landmarkLeftMov,
                        y: progressPointer.frame.origin.y + (MOVING_POINTER_GROWING_RATIO/2),
                        width: progressPointer.frame.size.width + MOVING_POINTER_GROWING_RATIO,
                        height: progressPointer.frame.size.height + MOVING_POINTER_GROWING_RATIO
                    )
                    
                    // set the final position of the landmark view
                    landmark.frame = CGRect(
                        x: landmark.frame.origin.x + landmarkLeftMov,
                        y: landmark.frame.origin.y,
                        width: landmark.frame.size.width - MOVING_POINTER_GROWING_RATIO,
                        height: landmark.frame.size.height - MOVING_POINTER_GROWING_RATIO
                    )
                    landmark.alpha = 0.0
                    
                    }, completion: {
                        (value: Bool) in
                        
                        // fade in the intermediate landmark
                        UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                            landmark.isHidden = false
                            landmark.alpha = 1.0
                            }, completion: {
                                (value: Bool) in
                                
                                print("start second part of the animation")
                                
                                // animate progress bar to the final position
                                UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                                    progressBar.frame = CGRect(
                                        x: progressBar.frame.origin.x,
                                        y: progressBar.frame.origin.y,
                                        width: pBarWidth,
                                        height: progressBar.frame.size.height
                                    )
                                    
                                    progressBar.backgroundColor = FINAL_PROGRESS_COLOR
                                })
                                
                                // animate pointer to the final position
                                UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                                    progressPointer.frame = CGRect(
                                        x: finalLandmarkPos,
                                        y: progressPointer.frame.origin.y,
                                        width: progressPointer.frame.size.width,
                                        height: progressPointer.frame.size.height
                                    )
                                    
                                    finalLandmark.isHidden = true
                                    finalLandmark.alpha = 0.0
                                    
                                    }, completion:{
                                        (value: Bool) in
                                        
                                        // fade in the intermediate landmark
                                        UIView.animate(withDuration: FINAL_LANDMARK_FADE_IN_SPEED, animations:{
                                            finalLandmark.isHidden = false
                                            finalLandmark.alpha = 1.0
                                            }, completion:{
                                                (value: Bool) in
                                                print("done with animation")
                                        })
                                })
                        })
                })
        })
        
        // Progress bar animation
        UIView.animate(withDuration: 0.01, animations:{
            
            // set the initial value of the progress pointer
            progressBar.frame = CGRect(
                x: progressBar.frame.origin.x,
                y: progressBar.frame.origin.y,
                width: progressBar.frame.size.width - landmarkLeftMov,
                height: progressBar.frame.size.height
            )
            
            progressBar.backgroundColor = INITIAL_PROGRESS_COLOR
            }, completion: {
                (value: Bool) in
                
                // animate pointer to the intermediary position
                UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                    progressBar.frame = CGRect(
                        x: progressBar.frame.origin.x,
                        y: progressBar.frame.origin.y,
                        width: progressBar.frame.size.width + landmarkLeftMov,
                        height: progressBar.frame.size.height
                    )
                    
                    progressBar.backgroundColor = INTERMEDIATE_PROGRESS_COLOR
                })
        })
        
    }
    
    
    
    
    
    
    
    
    
    /*
        Create an array of labels for each day in a period of time
    */
    internal func getDayLabels(_ startDate:Date, nDays:Int) -> Array<String>{
        
        var dayLabels:Array<String> = Array<String>()
        
        // initialize array of labels
        dayLabels.append(startDate.formattedWith(self.DATE_FORMAT))
        
        // get next day
        var nextDay:Date = startDate.addingTimeInterval(60*60*24)
        
        for _ in 0...(nDays - 1){
            
            // insert next day label on the default format into the array of labels
            dayLabels.append(nextDay.formattedWith(self.DATE_FORMAT))
            
            // get next day
            nextDay = nextDay.addingTimeInterval(60*60*24)
        }
        
        return dayLabels
    }
    
    
    
    /*
        Gets an array of values for day in a period of time
    */
    internal func buildDailyReadingsValues(_ dayLabels:Array<String>, dayWithReadings:Array<String>, values:Array<Double>) -> Array<Double>{
    
        var valuesInPeriod:Array<Double> = Array<Double>()
        
        // initialize array of valuesInPeriod
        for _ in dayLabels{
            valuesInPeriod.append(0.0)
        }
        
        // insert the values of days with readings
        if(dayWithReadings.count > 0){
            
            for i in 0...(dayWithReadings.count - 1){
                
                // get day and value for a specific day with reading
                let dayWithReadingLabel = dayWithReadings[i]
                let dayValue = values[i]
                
                // if day in period has reading, add reading to array of values
                if(dayLabels.count > 0){
                    
                    for j in 0...(dayLabels.count - 1){
                        
                        if(dayLabels[j] == dayWithReadingLabel){
                            
                            // insert sum of readings for day into array
                            valuesInPeriod[j] = dayValue
                        }
                    }
                }
            }
        }
        
        return valuesInPeriod
    }
    
    
    
    
    
    
    
    
    
    
    func resetLineChart(_ lineChartView:LineChartView){
        
        // reset dataset
        let lineChartDataSet = LineChartDataSet(
            yVals: [BarChartDataEntry(value: 0, xIndex: 0)],
            label: "KW/Dia"
        )
        
        let dataPoints:Array<String> = [""]
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        // customize chart
        lineChartView.noDataText = "Nenhum dado de leitura encontrado"
        lineChartView.leftAxis.enabled = true
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.descriptionText = ""
        
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    
    
    // UI customizations
    /*
        Round a view corners
    */
    internal func roundIt(_ view:UIView, color:UIColor){
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 1.1
        view.layer.cornerRadius = view.frame.size.width / 2
        view.clipsToBounds = true
        
        self.applyHoverShadow(view)
    }
    
    
    /*
        Round a view corners
    */
    internal func roundItBordless(_ view:UIView){
        
        view.layer.borderWidth = 0.0
        view.layer.cornerRadius = view.frame.size.width / 2
        view.clipsToBounds = true
        
        self.applyHoverShadow(view)
    }
    
    
    /*
        Slightly round a view's corners
    */
    internal func roundCorners(_ view:UIView, color:UIColor){
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 1.1
        view.layer.cornerRadius = view.frame.size.width / 40
        view.clipsToBounds = true
    }
    
    
    /*
        Round corners without a color at the borders
    */
    internal func roundCornersColorless(_ view:UIView){
        view.layer.borderWidth = 1.1
        view.layer.cornerRadius = view.frame.size.width / 40
        view.clipsToBounds = true
    }
    

    
    /*
        Round upper corners of a UIView element
    */
    internal func roundUpperCorners(_ view:UIView){
        
        let path = UIBezierPath(
            roundedRect:view.bounds,
            byRoundingCorners:[
                UIRectCorner.topRight,
                .topLeft
            ],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
        
        view.clipsToBounds = true
    }
    
    
    
    /*
        Centralize the element vertically
    */
    internal func verticallyCentralizeElement(_ view:UIView, parentView:UIView, speed:Double){
        
        // get the parent view height
        let parentHeight = parentView.frame.height
        
        UIView.animate(withDuration: 0.01, animations:{
            // set the initial value of the progress pointer
            view.frame = CGRect(
                x: view.frame.origin.x,
                y: view.frame.origin.y,
                width: view.frame.size.width,
                height: view.frame.size.height
            )
            
            }, completion: {
                (value: Bool) in
                
                // animate pointer to the intermediary position
                UIView.animate(withDuration: speed, animations:{
                    view.frame = CGRect(
                        x: view.frame.origin.x,
                        y: (parentHeight/2) - (view.frame.size.height/2),
                        width: view.frame.size.width,
                        height: view.frame.size.height
                    )
                })
        })
        
    }
    
    
    /*
        Get a custom navbar home button item
    */
    internal func getHomeNavbarBtn(_ selector:Selector, parentVC:UIViewController) -> UIBarButtonItem{
        
        //create a new button
        let button: UIButton = UIButton(type: UIButtonType.custom)
    
        //set image for button
        button.setImage(UIImage(named: self.IMAGE_HOME_NAVBAR_ICO), for: UIControlState())
    
        //add function for button
        button.addTarget(parentVC, action: selector, for: UIControlEvents.touchUpInside)
    
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 31)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
    
        return UIBarButtonItem(customView: button)
    }
    
    
    /*
        Get a custom navbar back button item
    */
    internal func getBackNavbarBtn(_ selector:Selector, parentVC:UIViewController, labelText:String) -> UIBarButtonItem{
        
        //create a new button
        let button: UIButton = UIButton(type: UIButtonType.custom)
        
        //set image for button
        let backBtnLabel = NSAttributedString(
            string: labelText,
            attributes: [
                NSFontAttributeName:UIFont(name: self.SYSTEM_FONT, size: 30.0)!,
                NSForegroundColorAttributeName: UIColor.white
            ]
        )
        
        button.setAttributedTitle(backBtnLabel, for: UIControlState())
        
        //add function for button
        button.addTarget(parentVC, action: selector, for: UIControlEvents.touchUpInside)
        
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 31)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left

        
        return UIBarButtonItem(customView: button)
    }
    
    
    /*
        Shadow effects
    */
    internal func applyPlainShadow(_ view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
    internal func applyCurvedShadow(_ view: UIView) {
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
        layer.shadowOpacity = 0.05
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
    internal func applyHoverShadow(_ view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        
        let ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    
    internal func applyHoverShadowWithY(_ view: UIView, y:CGFloat){
        let size = view.bounds.size
        let width = size.width
        
        let ovalRect = CGRect(x: 5, y: y + 5, width: width - 10, height: 15)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    
    
    internal func applyHoverShadowWithOpacity(_ view: UIView, opacity:Float) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        
        let ovalRect = CGRect(x: 0, y: height, width: width + 2, height: 5)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 2)
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    
    /*
        Push element down according to the navbar and status bar difference from top
    */
    internal func pushItDown(_ view:UIView, navController:UINavigationController, speed:Double){
        
        // get navbar height
        UIView.animate(withDuration: 0.250, animations:{
            view.frame = CGRect(
                x: view.frame.origin.x,
                y: view.frame.origin.y,
                width: view.frame.size.width,
                height: view.frame.size.height
            )
        }, completion: {
            (value: Bool) in
                    
            UIView.animate(withDuration: speed, animations:{
                view.frame = CGRect(
                    x: view.frame.origin.x,
                    y: view.frame.origin.y + navController.navigationBar.frame.height + 20,
                    width: view.frame.size.width,
                    height: view.frame.size.height
                )
            })
        })
    }
    
    
    /*
        Push element up according to the navbar and status bar difference from top
    */
    internal func pushItUp(_ view:UIView, navController:UINavigationController){
        
        // get navbar height
        UIView.animate(withDuration: 0.250, animations:{
            view.frame = CGRect(
                x: view.frame.origin.x,
                y: view.frame.origin.y,
                width: view.frame.size.width,
                height: view.frame.size.height
            )
        }, completion: {
            (value: Bool) in
                
            UIView.animate(withDuration: 0.4, animations:{
                view.frame = CGRect(
                    x: view.frame.origin.x,
                    y: view.frame.origin.y - navController.navigationBar.frame.height - 20,
                    width: view.frame.size.width,
                    height: view.frame.size.height
                )
            }, completion: {
                (value:Bool) in
                
                
            })
        })
    }
    
    
    
    
    /*
        Sums a float value in a UITextInput object
    */
    internal func sumFloatTextInput(_ floatTxtInput:UITextField){
        
        // if the value currently selected is convertible to Float
        if((Float(floatTxtInput.text!)) != nil){
            
            // increment counter
            let amount = Float(floatTxtInput.text!)! + 0.1
            floatTxtInput.text = String(amount)
        }else{
            floatTxtInput.text = String(0.0)
        }
    }
    
    /*
        Subtracts a float value in a UITextInput object
    */
    internal func subFloatTextInputTilZero(_ floatTxtInput:UITextField){
        
        // if the value currently selected is convertible to Float
        if((Float(floatTxtInput.text!)) != nil){
            let amount = Float(floatTxtInput.text!)! - 0.1
            
            // decrement if value is bigger than 0
            if(amount > 0.0){
                floatTxtInput.text = String(amount)
            }else{
                floatTxtInput.text = String(0.0)
            }
        }else{
            floatTxtInput.text = String(0.0)
        }
    }
    
    /*
        Sums a float value in a UITextInput object
    */
    internal func sumFloatTextInputFast(_ floatTxtInput:UITextField){
        
        // if the value currently selected is convertible to Float
        if((Float(floatTxtInput.text!)) != nil){
            
            // increment counter
            let amount = Float(floatTxtInput.text!)! + 1.0
            floatTxtInput.text = String(amount)
        }else{
            floatTxtInput.text = String(0.0)
        }
    }
    
    /*
        Subtracts a float value in a UITextInput object
    */
    internal func subFloatTextInputTilZeroFast(_ floatTxtInput:UITextField){
        
        // if the value currently selected is convertible to Float
        if((Float(floatTxtInput.text!)) != nil){
            let amount = Float(floatTxtInput.text!)! - 1.0
            
            // decrement if value is bigger than 0
            if(amount > 0.0){
                floatTxtInput.text = String(amount)
            }else{
                floatTxtInput.text = String(0.0)
            }
        }else{
            floatTxtInput.text = String(0.0)
        }
    }
    
    
    
    
    
    
    
    
    
    
    // CHARTS
    /*
        execute the Bolt Percentage animation
    
        Input:
            boltBackgroundView = the view that is going to be hidden by the progress view
            boltProgressView   = the view that is going to rise from behind bolt
            usedPercentage     = the percentage that the view is going to come up
            status:
                -1 - bad
                0  - normal
                1  - good
    
    */
    internal func boltPercentageAnimation(_ boltBackgroundView:UIView, boltProgressView:UIView, usedPercentage:Double, status:Double){
        
        let currentColor    = boltProgressView.backgroundColor
        self.setFinalProgressAnimationColor(status)
        
        let pBarHeight      = boltBackgroundView.frame.height
        let progressRatio   = pBarHeight * 0.01
        let curProgressPerc = boltProgressView.frame.size.height/progressRatio
        let landmarkUpMov   = CGFloat(CGFloat(usedPercentage) - CGFloat(curProgressPerc)) * CGFloat(progressRatio)
        
        UIView.animate(withDuration: 0.01, animations:{
            // set the initial value of the progress pointer
            boltProgressView.frame = CGRect(
                x: boltProgressView.frame.origin.x,
                y: boltProgressView.frame.origin.y,
                width: boltProgressView.frame.size.width,
                height: boltProgressView.frame.size.height
            )
            
            boltProgressView.backgroundColor = currentColor
            
        }, completion: {
            (value: Bool) in
                
            // animate pointer to the intermediary position
            UIView.animate(withDuration: self.FINAL_LANDMARK_FADE_IN_SPEED, animations:{
                boltProgressView.frame = CGRect(
                    x: boltProgressView.frame.origin.x,
                    y: boltProgressView.frame.origin.y - landmarkUpMov,
                    width: boltProgressView.frame.size.width,
                    height: boltProgressView.frame.size.height + landmarkUpMov
                )
                    
                boltProgressView.backgroundColor = self.finalProgressColor
            })
        })
        
    }
    
    
    /*
        Animate the marker of a vertical progress bar animation
    */
    internal func boltPercentageAnimationMarker(_ msProgressTrail:UIView, msProgressMarker:UIView, usedPercentage: Double, status: Double, colorizeIt:Bool){
        
        self.FINAL_LANDMARK_FADE_IN_SPEED = 1.6
        self.setFinalProgressAnimationColor(status)
     
        let progressRatio   = msProgressTrail.frame.height * 0.01
        let pBarStartPoint  = msProgressTrail.frame.origin.y + msProgressTrail.frame.height
        let pMarkerCurPerc  = (pBarStartPoint - CGFloat(msProgressMarker.frame.origin.y))/progressRatio
        let landmarkUpMov   = (CGFloat(usedPercentage) * progressRatio) - (pMarkerCurPerc * progressRatio)
        
        UIView.animate(withDuration: 0.01, animations:{
            // set the initial value of the progress pointer
            msProgressMarker.frame = CGRect(
                x: msProgressMarker.frame.origin.x,
                y: msProgressMarker.frame.origin.y,
                width: msProgressMarker.frame.size.width,
                height: msProgressMarker.frame.size.height
            )
            
            if(colorizeIt){
                msProgressMarker.backgroundColor = self.INITIAL_PROGRESS_COLOR
            }
            
            }, completion: {
                (value: Bool) in
                
                // animate pointer to the intermediary position
                UIView.animate(withDuration: self.FINAL_LANDMARK_FADE_IN_SPEED, animations:{
                    msProgressMarker.frame = CGRect(
                        x: msProgressMarker.frame.origin.x,
                        y: msProgressMarker.frame.origin.y - landmarkUpMov,
                        width: msProgressMarker.frame.size.width,
                        height: msProgressMarker.frame.size.height
                    )
                })
                
                if(colorizeIt){
                    msProgressMarker.backgroundColor = self.finalProgressColor
                }
        })

    }
    
    
    /*
        Decide the final color of a progress animation
    
        Output:
            -1 = redish
            0  = neutral
            1  = blueish
    */
    internal func setFinalProgressAnimationColor(_ status:Double){
        
        // Obs: colors are all set to safe (blue), because we didn't figure it out how to adjust the desing to this circunstance yet.
        
        if(status > 1.0){
            self.finalProgressColor = self.DANGER_COLOR
            
        }else if((status < 1.0) && (status > 0.8)){
            self.finalProgressColor = self.DANGER_COLOR
            
        }else if((status < 0.8) && (status > 0.6)){
            self.finalProgressColor = self.WARNING_COLOR
            
        }else if((status < 0.6) && (status > 0.4)){
            self.finalProgressColor = self.SAFE_COLOR
            
        }else if((status < 0.4) && (status > 0.0)){
            self.finalProgressColor = self.SAFE_COLOR
            
        }else if(status < 0.0){
            self.finalProgressColor = self.SAFE_COLOR
            
        }else{
            self.finalProgressColor = self.SAFE_COLOR
        }
    }



    // DIALOGS
    /*
        Creates a welcome message based on the current hour of the day
    */
    internal func greeting(_ username:String) -> String{
        
        // get current time to build greeting
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute], from: date)
        let hour = components.hour
        
        var greeting = ""
        
        if((hour! >= 6) && (hour! <= 12)){
            greeting = "Bom dia \(username)"
        }else{
            if(hour! <= 18){
                greeting = "Boa tarde \(username)"
            }else{
                greeting = "Boa noite \(username)"
            }
        }
        
        return greeting
    }
    
    
    
    // VALIDATION
    /*
        Validates email address for invalid characters and sql injection
    */
    internal func isValidEmail(_ email:String) -> Bool {
        print("validating email ...")
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    
    
    // NAVIGATION
    /*
        Goes to the determined ViewController that has a defined storyboard id
    */
    internal func goToSegueX(_ storyboardId:String, obj:NSObject){
        
        print("\nSelected screen id: \(storyboardId)")
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        var generalVC:UIViewController = UIViewController()
        
        switch storyboardId {
            
            case self.ID_TUTORIAL:
                print("go to login/register screen")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_TUTORIAL) as! TutorialViewController
            
            case self.ID_SIGNUP:
                print("go to free user account registration screen")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_SIGNUP) as! CadastroViewController
                
            case self.ID_LOGIN:
                print("go to login screen")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_LOGIN) as! LoginViewController
            
            case self.ID_HOME:
                print("go to home screen")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_HOME) as! SWRevealViewController
            
            case self.ID_SETTINGS:
                print("go to home screen, need to be improved to navigate to the previous view")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_HOME) as! SWRevealViewController
            
            case self.ID_TIP:
                print("go to tips screen, need to be improved to navigate to the previous view")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_HOME) as! SWRevealViewController
            
            case self.ID_CAD_DECISION:
                print("go to tips screen, need to be improved to navigate to the previous view")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_CAD_DECISION) as! AddPlaceDecisionViewController
                
            case self.ID_CAD:
                print("go to tips screen, need to be improved to navigate to the previous view")
                generalVC = storyboard.instantiateViewController(withIdentifier: self.ID_CAD) as! CadastroViewController
            
            default:
                print("Error, unknown segue identifier")

        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = generalVC
    }
    
    
    /* 
        In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if((segue.identifier! == self.SEGUE_SWREAR) && (sender as? String == self.ID_SETTINGS)){
            let menu = (segue.destination as! MenuViewController)
            
            menu.destination = self.ID_SETTINGS
        }
    }
    
    
    
    // CONVERTIONS
    /*
        UIImage to PFFile, convertion used to send images to backend
    */
    internal func imageToFile(_ image:UIImage) -> PFFile{
        let imgData:Data = UIImagePNGRepresentation(image)!
        
        return PFFile(name: "profile picture", data: imgData)
    }
    
    
    
    internal func replaceComma(_ text:String) -> String{
        
        var output = ""
        
        let characters = [Character](text.characters)
        
        for c in characters{
            
            if(c == ","){
                output += "."
            }else{
                output += String(c)
            }
        }
        
        return output
    }
    
    
    internal func sumNumber(_ stringNumber:String?, precision:String) -> String{
    
        if let numberStrRep = stringNumber{
            
            let textInput = self.replaceComma(numberStrRep)
            
            if let n:Float = Float(textInput) {
                
                if(precision == "1"){
                    return String(n + 1.0)
                }else if(precision == ".1"){
                    return String(n + 0.1)
                }else{
                    return String(n + 0.01)
                }
            }
        }
        
        return "0.0"
    }
    
    
    internal func subNumber(_ stringNumber:String?, precision:String) -> String{
        
        if let numberStrRep = stringNumber{
            
            let textInput = self.replaceComma(numberStrRep)
            
            if let n:Float = Float(textInput) {
                
                if(n > 0.0){
                    if(precision == "1"){
                        return String(n - 1.0)
                        
                    }else if(precision == ".1"){
                        
                        return String(n - 0.1)
                    }else{
                        
                        return String(n - 0.01)
                    }
                }
            }
        }
        
        return "0.0"
    }
    
    
}


/*
    Add some funcionality to the UIView class
*/
extension UIView {
    
    // to do
}

