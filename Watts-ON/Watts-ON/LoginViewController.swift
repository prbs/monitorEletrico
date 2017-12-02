//
//  LoginViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/20/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse
import Bolts


class LoginViewController: BaseViewController {
    
    
    // VARIABLES
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var spinner: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var faceBtn: UIButton!

    internal let dbu:DBUtils = DBUtils()
    internal let dbh:DBHelpers = DBHelpers()
    
    internal let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    internal var startedWithFace: Bool = false
    internal var faceOk: Bool = false
    internal var permissions = []
    internal var username:String = ""
    internal var facebookID:String = ""
    internal var userEmail:String = ""
    internal var profileImg:PFFile = PFFile()
    internal var hasInitialized:Bool = false
    
    
    
    // INITIALIZERS
    /*
        This method is execute once the facebook authorization view is about to show up, and it 
        processes if the current user is already signed and registered on Parse, if it is the 
        case the authorized facebook user is logged in on Parse
    */
    override func viewDidAppear(_ animated: Bool) {
        // UI
        self.spinner.isHidden = true
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make the phone information white
        UIApplication.shared.statusBarStyle = .lightContent
        
        // setup the input elements that are going to respond to keyboard events
        self.email.delegate = self
        self.pass.delegate = self
        
        // changing UI according to facebook status
        if(FBSDKAccessToken.current() == nil){
            print("not logged in..")
            self.faceOk = false
            self.faceBtn.setTitle("Conectar com Facebook", for: UIControlState())
        }else{
            print("logged in..")
            self.faceOk = true
            self.faceBtn.setTitle("Desconectar com Facebook", for: UIControlState())
            self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: true)
            self.fastFaceLogin()
            
            // set the user registration type to facebook
            DBHelpers.userRegType = DBHelpers.USER_REG_TYPE_FACE
        }
        
        // starts assuming the user is going to connect regularly, if they click on the 'connect with facebook' button switch the registration mode
        DBHelpers.userRegType  = DBHelpers.USER_REG_TYPE_REGU
    }
    
    
    
    // UI
    /*
        Facebook connection trigger
    */
    @IBAction func loginWithFace(_ sender: AnyObject) {
        
        self.startedWithFace = true
        
        // set the user registration type to Facebook
        DBHelpers.userRegType  = DBHelpers.USER_REG_TYPE_FACE
        
        if(self.faceOk){
            self.logoutWithFace()
        }else{
            self.connectWithFace()
        }
    }
    
    
    /*
        Trouble to login
    */
    @IBAction func troubleToLogin(_ sender:
        AnyObject) {
        self.infoWindow("Caso você não esteja conseguindo acessar o sistema, por favor desinstale e instale a aplicação novamente.", title: "Problemas para entrar no app?", vc: self)
    }
    
    
    
    // LOGIC
    /*
        Get user data from facebook and call the fast login method
    */
    internal func connectWithFace(){
        
        self.fbLoginManager.logIn(withReadPermissions: self.feu.FACEBOOK_PERMISSIONS, handler: {
            (result, error) -> Void in
            
            if (error == nil){
                self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: true)
                
                if let fbloginresult : FBSDKLoginManagerLoginResult = result{
                    if(fbloginresult.grantedPermissions.contains("email")){
                        print("\nfacebook data has been confirmed")
                        
                        // Create request for Facebook user's data
                        let request = FBSDKGraphRequest(graphPath:"me", parameters: ["fields":"name, email"])
                        
                        // Send request to Facebook
                        request?.start {
                            (connection, result, error) in
                            
                            if error != nil {
                                print("error getting user info from facebook \n")
                                self.infoWindow("Erro ao obter dados do Facebook", title: "Erro operacional :(", vc: self)
                            }
                            // Got user data from facebook
                            else if let userData = result as? [String:AnyObject] {
                                
                                // load local variables
                                self.username = (userData["name"] as? String)!
                                self.userEmail = (userData["email"] as? String)!
                                self.email.text = self.userEmail
                                
                                self.facebookID = (userData["id"] as? String)!
                                self.pass.text = self.facebookID
                                
                                // serch for user in the app backend
                                let query = PFQuery(className: self.dbu.DB_CLASS_USER)
                                query.whereKey(self.dbu.DBH_USER_USERNAME, equalTo: self.userEmail)
                                query.findObjectsInBackground {
                                    (objects, error) -> Void in
                                    
                                    // if the query was successful
                                    if error == nil {
                                        
                                        // if was able to get an array with results
                                        if let objs:Array<AnyObject> = objects as Array<AnyObject>?{
                                            
                                            // if the user already exists
                                            if(objs.count > 0){
                                                
                                                // try to log the user in
                                                self.regularLogin(self)
                                            }else{
                                                
                                                // create new user with facebook data
                                                self.requestProfilePicture(self.facebookID, facebookLoginManager:self.fbLoginManager)
                                            }
                                        }else{
                                            self.infoWindow("Erro ao confirmar dados com o servidor", title:"Erro", vc:self)
                                        }
                                    } else {
                                        print("Error: \(error) \(error!.userInfo)")
                                        self.infoWindow("Erro ao obter dados do usuário do facebook.", title:"Erro", vc:self)
                                    }
                                }
                            }else{
                                self.infoWindow("Erro ao obter dados do usuário.", title:"Erro", vc:self)
                            }
                        }
                    }else{
                        self.infoWindow("Operação cancelada.", title: "Aviso", vc: self)
                    }
                }
            }else{
                print("Facebook intial data requesition error: \(error?.localizedDescription) \n")
                self.infoWindow("Falha ao confirmar dados com Facebook", title: "Aviso", vc: self)
            }
        })
    }
    
    
    /*
        Fast facebook login, this method is used to cases when the user is already logged on facebook and needs to be validated on Parse, this method can be called by viewDidLoad or viewDidAppear
    */
    fileprivate func fastFaceLogin(){
        // Get email registered on Facebook
        let request = FBSDKGraphRequest(graphPath:"me", parameters: ["fields":"email"])
        
        request?.start {
            (connection, result, error) in
            
            if error != nil {
                print("error getting user info from facebook \n")
            }
            else if let userData = result as? [String:AnyObject] {
                self.email.text = (userData["email"] as? String)!
                self.pass.text = (userData["id"] as? String)!
                
                print("user info: \(self.email.text), \(self.pass.text)")
                
                self.regularLogin(self)
           }
        }
    }
    
    
    /*
        Logs the user out with facebook
    */
    internal func logoutWithFace(){
        
        // reset the user registration type to Facebook
        DBHelpers.userRegType  = ""
        
        self.fbLoginManager.logOut()
    }
    
    
    /*
        This block is executed when the user press the logout buttom
    */
    internal func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out \n")
    }
    
    
    /*
        Threats the login case when the user uses login and password fieds
    */
    @IBAction func regularLogin(_ sender: AnyObject) {
        
        self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: true)
        
        // checks if the given email exists
        let query = PFQuery(className: self.dbu.DB_CLASS_USER)
        query.whereKey(self.dbu.DBH_USER_USERNAME, equalTo: self.email.text!)
        
        query.findObjectsInBackground {
            (objects, error) -> Void in
            
            if(error == nil){
                if let _:PFObject = objects!.first as? PFObject{
                    print("found user, log he/she in")
                    
                    self.userLogin(self.email.text!, password: self.pass.text!)
                }else{
                    self.infoWindow("Usuário não encontrado, realize o seu cadastro antes de efetuar o login.", title:"Aviso", vc:self)
                        
                    self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
                }
            }else{
                print("There was an error with your request")
                self.infoWindow("Houve um erro com o banco de dados devido a um problema com a sessão anterior", title:"Aviso", vc:self)
            }
        }
    }
    
    
    /*
        Logs in a given user on Parse
    */
    internal func userLogin(_ email:String, password:String){
        print("\nlogging user in")
        
        if let user:PFUser = PFUser.current(){
            print("checking if the user is authenticated ...")
            if(user.isAuthenticated()){
                print("user is authenticated")
            }else{
                print("user is not authenticated")
            }
        }else{
            print("performing login operation")
            
            // check if the username exists for a unique email
            PFUser.logInWithUsername(inBackground: email, password: password){
                object, error in
                
                if error == nil {
                    print("\nLogged in successfully on Parse")
                    
                    if let user:PFUser = PFUser.current(){
                        
                        print("loading user information ...")
                        LoginViewController.loadUserLocations(user)
                    }else{
                        self.infoWindow("Houve um erro ao executar o login", title: "Erro operacional", vc: self)
                    }
                } else if let error = error {
                    print("Parse login error: \(error.localizedDescription)")
                    
                    if(error.localizedDescription == "invalid login parameters"){
                        self.infoWindow("Senha incorreta.", title:"Aviso", vc:self)
                        self.lockScreen(self.lockView, actionIndicator: self.spinner, lockIt: false)
                    }
                }
            }
        }
    }
    
    
    /*
        Get all locations pointed by the User_Location Relationship
    */
    class func loadUserLocations(_ user:PFUser){
        print("\ntrying to load location ...")
        
        // check if the user has at least one valid location
        PFCloud.callFunction(inBackground: "userHasLocation", withParameters: [
            "userId": user.objectId!
        ]) {
            (answer, error) in
        
            if (error == nil){
                if let result:Int = answer as? Int{
                    
                    let feu:FrontendUtilities = FrontendUtilities()
                    
                    switch result{
                        case 0:
                            print("user has at least one location.")
                            
                            // initialize system, making sure the process is going to run only once
                            // >>>>>>>>> DBHelpers.initializeGlobalVariables()
                            feu.goToSegueX(feu.ID_TUTORIAL, obj: NSObject())
                        
                        case 1:
                            print("user doens't have a location.")
                            
                            // initialize system, making sure the process is going to run only once
                            feu.goToSegueX(feu.ID_TUTORIAL, obj: NSObject())
                        
                        case 2:
                            print("operational error.")
                        
                        default:
                            print("unknow error.")
                    }
                    
                }else{
                    print("problems converting cloud query result")
                    //self.infoWindow("Falha ao acessar dados no servidor", title: "Erro operacional", vc: self)
                }
            }else{
                print("\nerror: \(error)")
                //self.infoWindow("Falha ao acessar dados no servidor", title: "Erro operacional", vc: self)
            }
        }
        
    }
    
    
    // Facebook registration methods
    /*
        Make an asynchrounous call to the to get the facebook user's profile picture and place it
        into the local image variable.
    */
    func requestProfilePicture(_ facebookID:String, facebookLoginManager:FBSDKLoginManager) {
        let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
        
        let URLRequest = URL(string: pictureURL)
        let URLRequestNeeded = Foundation.URLRequest(url: URLRequest!)
        
        NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: OperationQueue.main,completionHandler: {
            (response: URLResponse?, data: Data?, error: NSError?) -> Void in
            
            if error == nil {
                if let img = UIImage(data: data!){
                    
                    // get facebook profile picture
                    let imgData:Data = UIImagePNGRepresentation(img)!
                    self.profileImg = PFFile(name: "profile picture", data: imgData)
                    
                    // register with facebook data
                    DBHelpers.freeAccountRegistration(
                        self.userEmail,
                        name: self.username,
                        password: self.facebookID,
                        profilePicture: self.profileImg,
                        sender:self
                    )
                }
            }
            else {
                print("Facebook picture request error: \(error?.localizedDescription) \n")
                self.infoWindow("Erro ao pegar foto de perfil do facebook.", title:"Aviso", vc:self)
            }
        } as! (URLResponse?, Data?, Error?) -> Void)
    }
    
    
    
    /*
        Remember password
    */
    @IBAction func remeberPasword(_ sender: AnyObject) {
        
        let refreshAlert = UIAlertController(title: "Deseja redefinir sua senha?", message: "Um link de redefinição será enviado para o email informado no campo email", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction) in
            
            // get user email
            if let email = self.email.text {
                
                print("user confirmed password reset operation, sending email to \(email)")
                
                // check if the user has at least one valid location
                PFCloud.callFunction(inBackground: "rememberPassword", withParameters: [
                    "username": email
                ]) {
                    (answer, error) in
                        
                    if (error == nil){
                        
                        if let result:Int = answer as? Int{
                                
                            switch result{
                                case 0:
                                    self.infoWindow("Um link para a redefinição de sua senha foi enviado para o email \(email)", title: "Operação concluída", vc: self)
                                    
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
            }else{
                print("failed to convert user email")
            }
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Não", style: .default, handler: { (action: UIAlertAction!) in
            print("user cancelled the password reset operation")
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    // NAVIGATION
    /*
        Send the user to the registration screen
    */
    @IBAction func goRegister(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self.feu.ID_LOGIN_SIGNUP, sender: nil)
    }
    
    
    /*
        Bring the user back from the registration screen
    */
    @IBAction func unwindFromRegistration(_ segue:UIStoryboardSegue) {
        if let _:CadastroViewController = segue.source as? CadastroViewController{
            self.viewDidLoad()
        }
    }
    
    
    
    
    // MANDATORY METHODS    override func didReceiveMemoryWarning() {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
