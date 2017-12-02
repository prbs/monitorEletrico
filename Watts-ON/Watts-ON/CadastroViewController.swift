//
//  CadastroViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/20/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit
import Parse
import Bolts

class CadastroViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    // VARIABLES
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var passConfirmation: UITextField!
    @IBOutlet weak var imageSizeWarning: UILabel!
    @IBOutlet weak var pictureBtn: UIButton!
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()

    internal var imagePicker = UIImagePickerController()
    internal let imgPicController:ImagePickerViewController = ImagePickerViewController()
    internal var selectedPicture:PFFile? = nil
    
    internal let imgTooLargeMsg = "A imagem selecionada é muito grande, por favor selecione outra."
    
   
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the input elements that are going to respond to keyboard events
        self.name.delegate = self
        self.email.delegate = self
        self.pass.delegate = self
        self.passConfirmation.delegate = self
        
        // setup the distance that the keyboard is going to move
        self.kbHeight = 70
        
       // self.setScroller()
        self.resetUI()
    }

    
    
    // UI
    /*
        Reset UI elements
    */
    internal func resetUI(){
        self.name.text = ""
        self.email.text = ""
        self.pass.text = ""
        self.passConfirmation.text = ""
        
        self.name.isEnabled = true
        self.email.isEnabled = true
        self.pass.isEnabled = true
        self.passConfirmation.isEnabled = true
        
        self.customizePicButton()
    }
    
    
    /*
        Customize the user picture btn
    */
    internal func customizePicButton(){
        self.feu.roundItBordless(self.pictureBtn)
    }
    
    
    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
      //  self.scrollView.scrollEnabled = true
        
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize.height = self.contentView.frame.size.height
        self.scrollView.contentSize.width = self.contentView.frame.size.width
    }
    
    
    // IMAGE SELECTOR METHODS
    /*
        Select a new picture for the reward from the user's camera roll
    */
    @IBAction func selectPictureFromRoll(_ sender: AnyObject) {
        print("\nselect picture from camera roll ...")
        
        self.imgPicController.setCallerVC(self, source: self.feu.ID_SIGNUP)
        self.imgPicController.selectPictureFromRoll(sender)
    }
    
    
    /*
        Set the picture selector btn with the chosen image
    */
    internal func setChosenImg(_ img:UIImage){
        print("\nsetting chosen image \(img)")
        
        self.pictureBtn.setImage(img, for: UIControlState())
    }
    
    /*
        Set the selected picture file target with the selected file
    */
    internal func setChosenImgFile(_ file:PFFile){
        
        // set the status bar color
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.selectedPicture = file
    }

    
    
    
    /*
        User registration
    */
    @IBAction func save(_ sender: AnyObject) {
        print("Registration process")
        
        // lock the screen
        self.feu.fadeIn(self.screenLocker, speed: 0.6)
        self.startLoadingAnimation(self.spinner)
        
        self.validateUserData()
    }

    
    
    // LOGIC
    /*
        Validate user data
    */
    internal func validateUserData(){
        
        // validate data
        if(self.feu.isValidEmail(self.email.text!) == true){
            
            PFCloud.callFunction(inBackground: "isEmailTaken", withParameters: [
                "email": self.email.text!
            ]) {
                (answer, error) in
                    
                if (error == nil){
                    
                    if let result:Int = answer as? Int{
                        
                        if(result == 1){
                            
                            print("valid email, no one is using it")
                            if(self.pass.text == self.passConfirmation.text){
                                self.registerUser()
                            }else{
                                self.infoWindow("Senha e confirmação da senha devem ser iquais.", title:"Aviso", vc:self)
                                
                                // lock the screen
                                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                                self.stopSpinner(self.spinner)
                            }
                            
                        }else if(result == 0){
                            print("email already registered")
                            self.infoWindow("Este email já está cadastrado, se cadastre com um novo email.", title:"Aviso", vc:self)
                            
                            // lock the screen
                            self.feu.fadeOut(self.screenLocker, speed: 0.6)
                            self.stopSpinner(self.spinner)
                        }else{
                            print("unknown error")
                            self.infoWindow("Problemas ao verificar email", title:"Falha operacional", vc:self)
                            
                            // lock the screen
                            self.feu.fadeOut(self.screenLocker, speed: 0.6)
                            self.stopSpinner(self.spinner)
                        }
                    }else{
                        print("unknown error")
                        self.infoWindow("Problemas ao verificar email", title:"Falha operacional", vc:self)
                        
                        // lock the screen
                        self.feu.fadeOut(self.screenLocker, speed: 0.6)
                        self.stopSpinner(self.spinner)
                    }
                }
            }
            
        }else{
            self.infoWindow("Por favor insira um endereço de email válido.", title:"Aviso", vc:self)
            
            // lock the screen
            self.feu.fadeOut(self.screenLocker, speed: 0.6)
            self.stopSpinner(self.spinner)
        }
    }
    
    
    /*
        Register a new user and connect it to a location
    */
    internal func registerUser(){
        print("\ntrying to create free account ...")
        
        DBHelpers.freeAccountRegistration(
            self.email.text!,
            name: self.name.text!,
            password: self.pass.text!,
            profilePicture: self.selectedPicture,
            sender:self
        )
    }    
    
    
    
    // MANDATORY
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
