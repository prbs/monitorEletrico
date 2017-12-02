//
//  PerfilViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class PerfilViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    // VARIABLES
    // Containers
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var updateContainer: UIView!
    @IBOutlet weak var banner: UIView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    @IBOutlet weak var pictureBtn: UIButton!
    
    
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var registerDate: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var email: UITextField!
    
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils   = DBUtils()
    
    internal var imagePicker = UIImagePickerController()
    internal var selectedPicture:PFFile? = nil
    internal let imgPicController:ImagePickerViewController = ImagePickerViewController()
    
    internal let PASS_PLACEHOLDER:String = "fasçdfja q34**Q234**!@#$*!@$*4"
    
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        // binds the show menu toogle action implemented by SWRevealViewController to the menu button
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // configure container outlets
        self.setScroller()
        
        // keyboard configuration
        self.kbHeight = 10
        
        // initialize textfields state
        self.userName.delegate = self
        self.email.delegate = self
       
        // reset outlets' displaying information
        self.resetOutlets()
        
        // the email field is used as a primary key in the app backend, therefore can not be modified
        self.email.isEnabled = false
        
        // load current user information into the UI
        self.loadData()
        
        // get the user registration type
        if(DBHelpers.userRegType == DBHelpers.USER_REG_TYPE_FACE){
            
            // if registered with facebook block all password fields
        }else if (DBHelpers.userRegType == DBHelpers.USER_REG_TYPE_REGU){
            
            // if the user was registered or logged in regularly, allow
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // UI customizations
        self.customizeNavBar(self)
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        self.customizeMenuBtn(self.homeBtn, btnIdentifier: self.feu.ID_HOME)
        self.feu.roundItBordless(self.pictureBtn)
        
        // Banner labels
        self.feu.fadeIn(self.userNameLabel, speed: 1.0)
        self.feu.fadeIn(self.registerDate, speed: 2.0)
    }
    
    
    
    // UI
    /*
        Reset outlets
    */
    internal func resetOutlets(){
        self.userName.text = ""
        self.email.text = ""
    }
    

    /*
        Configure the dimensions of the scroller view
    */
    internal func setScroller(){
        self.scroller.isUserInteractionEnabled = true
        self.scroller.frame = self.view.bounds
        self.scroller.contentSize.height = self.updateContainer.frame.size.height
        self.scroller.contentSize.width = self.updateContainer.frame.size.width
    }
    
    
    // IMAGE SELECTOR METHODS
    /*
        Initializer the image picker controller, to obey to the PerfilViewController class
    */
    @IBAction func selecteProfilePicture(_ sender: AnyObject) {
        print("\nselecting new profile picture ...")
        
        self.imgPicController.setCallerVC(self, source: self.feu.ID_PROFILE)
        self.imgPicController.selectPictureFromRoll(sender)
    }
    
    /*
        Set the picture selector btn with the chosen image
    */
    internal func setChosenImg(_ img:UIImage){
        print("\nsetting chosen image \(img)")
        
        self.pictureBtn.setImage(img, for: UIControlState())
        self.customizeNavBar(self)
    }
    
    /*
        Set the selected picture file target with the selected file
    */
    internal func setChosenImgFile(_ file:PFFile){
        self.selectedPicture = file
    }
    
    
    /*
        Save user info
    */
    @IBAction func saveInfo(_ sender: AnyObject) {
        print("\nstarting saving user info process ...")
        
        // lock the screen
        self.feu.fadeIn(self.screenLocker, speed: 0.6)
        self.startLoadingAnimation(self.spinner)
        
        // save fields that are not dangerous
        self.validateOtherFields(false)
    }
    
    
    /*
        Change password
    */
    @IBAction func changePassword(_ sender: AnyObject) {
        print("\nstarting password redefinition process ...")
        
        if let username = PFUser.current()?.username{
            
            let titleRed = "Deseja redefinir sua senha?"
            let msgRed = "Um link de redefinição será enviado para o email \(username) e você deverá logar na aplicação novamente."
            
            let refreshAlert = UIAlertController(title: titleRed, message: msgRed, preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction) in
                
                // get user email
                if let email = self.email.text {
                    print("user confirmed password reset operation, sending email to \(email)")
                    
                    self.changeUserPassword(email)
                }else{
                    print("failed to convert user email")
                }
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Não", style: .default, handler: { (action: UIAlertAction!) in
                print("user cancelled the password reset operation")
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    
    
    
    // LOGIC
    /*
        Validate and save non dangerous
    */
    internal func validateOtherFields(_ changedPassword:Bool){
        print("\nvalidating non dangerouns fields ...")
        
        // save user name and picture
        if let name = self.userName.text{
            
            self.save(name, picture: self.selectedPicture, changedPass:changedPassword)
        }else{
            print("problem getting user name")
            
            // unlock the screen
            self.feu.fadeOut(self.screenLocker, speed: 0.6)
            self.stopSpinner(self.spinner)
        }
    }
    
    
    /*
        Validate data used to modify the user password
    
    internal func validateNewPassword(){
        
        if let nPass = self.newPass.text{
            
            if let pConfirmation = self.passConfirmation.text{
                
                if(nPass == pConfirmation){
                    
                    // check the current user password
                    self.changeUserPassword()
                
                }else{
                    // lock the screen
                    self.feu.fadeOut(self.screenLocker, speed: 0.6)
                    self.stopSpinner(self.spinner)
                    
                    print("new password and password confirmation don't match, cancelling operation ...")
                    self.infoWindow("Os campos 'Senha' e 'Confirmação da senha' devem ser iquais", title: "Atenção", vc: self)
                }
            }else{
                print("weird, could not get password confirmation as a String object")
            }
        }else{
            print("weird, could not get new password as a String object")
        }
    }
    */
    
    
    /*
        Validate user password

        This method is not being used because because it was not possible to access the password field of the 
        PFUser.currentUser() object, for a comparison, and other alternatives such as log the user in for 
        validation worked, however it created an invalid session token issue
    
    internal func validateUserPassword(){
        
        if let pass = self.pass.text{
            
            if let username = PFUser.currentUser()?.username{
                print("\nveryfing password \(pass), for username \(username)")
                
                // Get all available locations
                PFCloud.callFunctionInBackground("validateUserPassword", withParameters: [
                    "username": username,
                    "password": pass
                ]) {
                    (answer, error) in
                    
                    print("validating password error \(answer)")
                    
                    if (error == nil){
                            
                        if let result:Int = answer as? Int{
                                
                            if(result == 0){
                                    
                                // save fields that are not dangerous
                                self.validateOtherFields(true)
                                    
                            }else if(result == 1){
                                print("failed to change user password")
                                self.infoWindow("A senha atual está incorreta, caso você tenha esquecido sua senha clique no botão 'lembrar senha' na tela de login", title: "Senha incorreta", vc: self)
                            }
                        }else{
                            print("failed to get results from change password operation")
                        }
                    }else{
                        print("\nerror: \(error)")
                    }
                }
                
            }else{
                print("failed to get username, cancelling passwordValidation operation ...")
                self.infoWindow("Não foi possível obter alguns dados de sua conta", title: "Falha operacional", vc: self)
            }
        }else{
            print("could not get user password as a String")
        }
    }
    */

    
    
    /*
        Change user's password, call a query that is going to get the user in the app backend, by searching by 
        email, and then synchorously in the backend tries to save the user with the new password information
    */
    internal func changeUserPassword(_ email:String){
        print("\ntrying to change user's password ...")
        
        // check if the user has at least one valid location
        PFCloud.callFunction(inBackground: "rememberPassword", withParameters: [
            "username": email
        ]) {
            (answer, error) in
                
            if (error == nil){
                    
                if let result:Int = answer as? Int{
                        
                    switch result{
                        case 0:
                            let title = "Operação concluída"
                            
                            let msg = "Um email com o link para a alteração de sua senha foi enviado para \(email), confirme as novas informações de acesso e realize login novamente."
                            
                            self.infoWindow(msg, title: title, vc: self)
                            
                            self.dbh.logout()
                            
                        case 1:
                            print("user doens't have a location.")
                            
                            // initialize system, making sure the process is going to run only once
                            DBHelpers.initializeInLockedMode()
                            
                        case 204:
                            self.infoWindow("Insira um email para que a senha possa ser enviada", title: "Atenção", vc: self)
                            
                        default:
                            print("unknow error.")
                    }
                        
                }else{
                    print("problems converting cloud query result")
                    self.infoWindow("Por favor tente novamente mais tarde", title: "Não foi possível enviar o email", vc: self)
                }
            }else{
                print("\nerror: \(error)")
                self.infoWindow("Se certifique de que o email inserido é o mesmo utilizado para o seu cadastro", title: "Atenção", vc: self)
            }
        }
    }
    
    
    /*
        If current user is a person registered with facebook, updates only picture profile picture and name,
        otherwise, check if the user has tried to update his/her password.
    
        If a user registered without facebook tried to update password, check if the old password is valid, and
        if the new password match the password confirmation.
    
        Save the changes locally and then save it on the app backend.
    */
    internal func save(_ name:String, picture:PFFile?, changedPass:Bool){
        print("\nsaving user information ...")
        
        // save info locally
        PFUser.current()![self.dbu.DBH_USER_NAME] = name
        
        if let pic = picture{
            PFUser.current()![self.dbu.DBH_USER_PICTURE] = pic
        }
        
        // save in the app backend
        PFUser.current()?.saveInBackground{
            (result, error) -> Void in
            
            if(error == nil){
                
                // if the user has changed the password information, asks to login again
                if(changedPass){
                    
                    self.infoWindow("Por favor confirme a nova senha realizando o login", title: "Credenciais de acesso modificadas com sucesso", vc: self)
                    
                    // lock the screen
                    self.feu.fadeOut(self.screenLocker, speed: 0.6)
                    self.stopSpinner(self.spinner)
                    
                    // log the user out to invalidate access token and confirm information
                    self.dbh.logout()
                }else{
                    
                    self.infoWindow("", title: "Dados atualizados com sucesso", vc: self)
                    
                    // send user back home
                    self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
                    
                    // lock the screen
                    self.feu.fadeOut(self.screenLocker, speed: 0.6)
                    self.stopSpinner(self.spinner)
                }
            }else{
                print("\nfound an error while updating user information \(error?.description)")
                
                // lock the screen
                self.feu.fadeOut(self.screenLocker, speed: 0.6)
                self.stopSpinner(self.spinner)
            }
        }
    }
    
    
    
    
    /*
        Load current user information
    */
    internal func loadData(){
        print("\nloading current user information ...")
        
        if let u:PFUser = PFUser.current(){
            let user:User = User(user:u)
            
            // load user information
            if let regDate:Date = u.createdAt{
                self.loadUserInformation(user, createdAt: regDate)
            }
        }else{
            print("problems to get current user as User object")
        }
    }
    
    
    /*
        Load user information
    */
    internal func loadUserInformation(_ user:User, createdAt:Date){
        
        // set user profile picture
        if let pic:UIImage = user.getUserPicUIImage(){
            self.setChosenImg(pic)
        }else{
            print("problems to get profile picture as a UIImage, getting data from backend")
                
            // load the user picture for this object
            if let picFile:PFFile =  user.getUserPicture(){
                    
                // if the image wasn't download in time make the request to get the file
                picFile.getDataInBackground(block: {
                    (imageData: Data?, error: NSError?) -> Void in
                        
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        self.setChosenImg(image!)
                    }
                })
            }else{
                    
                // if getting image from backend failed, let the picture selector button as it is
                if let stdImg = self.feu.getDefaultProfileImg(){
                    self.setChosenImg(stdImg)
                }
            }
        }
            
        // set username
        if(user.getUserName() == self.dbu.STD_UNDEF_STRING){
            self.userName.text = "Qual é o seu nome?"
        }else{
            self.userName.text = user.getUserName()
            self.userNameLabel.text = user.getUserName()
        }
        
        // set register date
        self.registerDate.text = "Usuário desde " + createdAt.formattedWith(self.feu.DATE_FORMAT)
        
        // set user email
        if(user.getUserEmail() == self.dbu.STD_UNDEF_STRING){
            self.email.text = "Você é fera, se cadastrou sem email"
        }else{
            self.email.text = user.getUserEmail()
        }
        
    }
    
    
    
    // NAVIGATION
    /*
        Go home
    */
    @IBAction func goHome(_ sender: AnyObject) {
        self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
    }
    

    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
