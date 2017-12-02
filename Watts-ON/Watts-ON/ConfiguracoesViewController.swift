//
//  ConfiguracoesViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class ConfiguracoesViewController: BaseViewController {
 

    // VARIABLES
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    
    @IBOutlet weak var facBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    
    
    
    internal let dbh:DBHelpers = DBHelpers()
    
    
    
    // INITIALIZERS
    override func viewDidAppear(_ animated: Bool) {
        
        // UI initialization
        self.customizeNavBar(self)
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        self.customizeMenuBtn(self.homeBtn, btnIdentifier: self.feu.ID_HOME)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.facBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.termsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.deleteAccountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        // binds the show menu toogle action implemented by SWRevealViewController to the menu button
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    
    
    // UI
    /*
        Delete the current account and dissociate the user of all devices available on the database, event thought the user is registered wether as admin or a regular user.
    */
    @IBAction func deleteAccount(_ sender: AnyObject) {
        self.infoWindowWithCancel("Esta é uma operação definitiva, os dados deletados não poderão ser recuperados", title:"Atenção", vc:self)
    }
    
    
    //Information
    //-----------
    /*
        Overrides the info window method to perform a callback action depending on the user choice, delete or not their account
    */
    internal override func infoWindowWithCancel(_ txt:String, title:String, vc:UIViewController) -> Void{
        
        let refreshAlert = UIAlertController(title: title, message: txt, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(
            UIAlertAction(title: "Ok", style: .default, handler: {
                (action: UIAlertAction) in
            
                print("\nDeleting user account ...")
                self.dbh.deleteAccount(self)
            })
        )
        
        refreshAlert.addAction(
            UIAlertAction(title: "Cancel", style: .default, handler: {
                (action: UIAlertAction!) in
                print("\nUser cancelled the delete account operation")
            })
        )
        
        vc.present(refreshAlert, animated: true, completion: nil)
    }

    
    @IBAction func showFAQ(_ sender: AnyObject) {
        print("show FAQ")
        self.infoWindow("Perguntas Frequentes: \nVocê está seguro utilizando o bolt?\nSim, todos os seus dados são criptografados e bem protegidos. ", title: "Perguntas Frequentes", vc: self)
    }
    
    
    @IBAction func showTerms(_ sender: AnyObject) {
        print("show terms and conditions")
        self.infoWindow("Uma vez criada uma conta no bolt, você concorda com estes termos e condições de uso.\n\nAs chaves de compartilhamento são únicas, elas são a única forma de associar novos usuários aos locais, a responsabilidade sobre quem está associado a cada local, e pode visualizar as informações daquele local, é somente do usuário administrador possuidor das chaves de compartilhamento", title: "Termos e Condições", vc: self)
    }
    
    
    @IBAction func showContactAdress(_ sender: AnyObject) {
        print("show contact info")
        self.infoWindow("Para mais informações sobre este software e outros fornecidos pela IoThinking, visite www.iothinking.com", title: "Contato", vc: self)
    }
    
    
    
    // NAVIGATION
    /*
        Go home
    */
    @IBAction func goHome(){
        self.feu.goToSegueX(self.feu.ID_HOME, obj: self)
    }
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
