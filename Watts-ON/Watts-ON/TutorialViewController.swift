//
//  ViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class TutorialViewController: BaseViewController, iCarouselDataSource, iCarouselDelegate {
    
    
    // VARIABLES
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var screenLocker: UIView!
    @IBOutlet weak var spinner: UIImageView!
    
    
    
    @IBOutlet weak var progress1: UIImageView!
    @IBOutlet weak var progress2: UIImageView!
    @IBOutlet weak var progress3: UIImageView!
    @IBOutlet weak var progress4: UIImageView!
    @IBOutlet weak var progress5: UIImageView!
    @IBOutlet weak var progress6: UIImageView!
    @IBOutlet weak var progress7: UIImageView!
    
    internal var lastVisualized: Int = 0
    internal var pages:[Int:AnyObject] = [Int:AnyObject]()
    
    internal let FILLED_CIRCLE = "circle-filled.png"
    internal let EMPTY_CIRCLE  = "circle-empty.png"
    internal let tutoImages:Array<String> = [
        "tuto-img-1.png",
        "tuto-img-2.png",
        "tuto-img-3.png",
        "tuto-img-4.png",
        "tuto-img-5.png",
        "tuto-img-6.png",
        "tuto-img-7.png"
    ]
    internal let tutoContent:Array<String> = [
        "Faça o cadastro como administrador ou usuário comum de um ambiente.",
        "Se você quer se tornar usuário comum, tenha a chave de compartilhamento do ambiente.",
        "Se você quer se tornar o dono de um novo ambiente, crie um novo ambiente.",
        "Possui um dispositivo? Adicione a chave de ativação do seu dispositivo",
        "Finalize o cadastro e após a ativação do ambiente, configure seu dispositivo.",
        "Passo 6 do tutorial",
        "Pronto, comece a usar a tecnologia para economizar recursos e aprender com Bolt."
    ]
    
    
    // INITIALIZERS
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // testing area
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        // initializes carousel
        self.carousel.dataSource = self
        self.carousel.delegate = self
        self.carousel.type = .linear
        self.carousel.decelerationRate = 0.5
        self.carousel.bounces = false
        self.carousel.isUserInteractionEnabled = true
        
        self.progress1.image = UIImage(named:self.FILLED_CIRCLE)
        self.lastVisualized = 1
    }
    
    
    // UI
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView{
        
// Apresentação as telas com animações
//        if(index != self.tutoImages.count - 1){
//            var itemView: TutoPage
//            
//            //create new view if no view is available for recycling and fill its content
//            itemView = UIView.loadFromNibNamed("TutoPage") as! TutoPage
//            itemView.tutoView.image = UIImage(named: self.tutoImages[index])
//            itemView.tutoInfo.text  = self.tutoContent[index]
//            
//            self.pages[index] = itemView
//            
//            return itemView
//        }else{
//            var itemView: TutoLastPage
//            
//            //create new view if no view is available for recycling and fill its content
//            itemView = UIView.loadFromNibNamed("TutoLastPage") as! TutoLastPage
//            itemView.parentVC = self
//            
//            self.pages[index] = itemView
//            
//            return itemView
//        }
        
        var itemView: TutoPage
        
        //create new view if no view is available for recycling and fill its content
        itemView = UIView.loadFromNibNamed("TutoPage") as! TutoPage
        itemView.tutoView.image = UIImage(named: self.tutoImages[index])
        itemView.tutoInfo.text  = self.tutoContent[index]
        
        self.pages[index] = itemView
        
        // fade in effect of the first page
        self.feu.fadeIn(itemView.container, speed: 0.4)
        
        return itemView
    }

    
    /*
        Identify when the current view changes
    */
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        
        let currentItem = self.carousel.currentItemIndex
        self.setProgress(currentItem)
        
        if let page = self.pages[currentItem] as? TutoPage{
            self.feu.fadeIn(page.container, speed: 0.4)
        }
        
        /*
        self.lastVisualized = currentItem
        
        if(currentItem == self.tutoImages.count - 1){
            if let lastPageView = self.pages[(self.tutoImages.count - 1)] as? TutoLastPage{
                self.feu.fadeIn(lastPageView.startBtn, speed: 1.2)
                self.feu.fadeIn(lastPageView.readyLabel, speed:2.4)
                self.feu.fadeIn(lastPageView.incentiveMessage, speed:3.2)
            }else{
                print("could not get tuto last page out of the list of pages")
            }
        }
        */
    }
    
    
    /*
        Set the current selected page on the progress view images
    */
    internal func setProgress(_ currentPage:Int){
        
        self.resetProgressIndicators()
        
        if let page = self.pages[currentPage] as? TutoPage{
            
            if(currentPage < 7){
                switch (currentPage){
                    case 0:
                        self.progress1.image = UIImage(named:self.FILLED_CIRCLE)
                        self.feu.fadeIn(page.container, speed: 0.4)
                        self.startBtn.isHidden = true
                    
                    case 1:
                        self.progress2.image = UIImage(named:self.FILLED_CIRCLE)
                        self.startBtn.isHidden = true
                    
                    case 2:
                        self.progress3.image = UIImage(named:self.FILLED_CIRCLE)
                        self.startBtn.isHidden = true
                    
                    case 3:
                        self.progress4.image = UIImage(named:self.FILLED_CIRCLE)
                        self.startBtn.isHidden = true
                    
                    case 4:
                        self.progress5.image = UIImage(named:self.FILLED_CIRCLE)
                        self.startBtn.isHidden = true
            
                    case 5:
                        self.progress6.image = UIImage(named:self.FILLED_CIRCLE)
                        self.startBtn.isHidden = true
                
                    case 6:
                        self.progress7.image = UIImage(named:self.FILLED_CIRCLE)
                        
                        self.feu.fadeIn(self.startBtn, speed: 1.0)
            
                    default:
                        print("current page didn't match any available page of the tutorial")
                }
            }
        }
    }
    
    /*
        Reset the progress indicators to default mode
    */
    internal func resetProgressIndicators(){
        self.progress1.image = UIImage(named:self.EMPTY_CIRCLE)
        self.progress2.image = UIImage(named:self.EMPTY_CIRCLE)
        self.progress3.image = UIImage(named:self.EMPTY_CIRCLE)
        self.progress4.image = UIImage(named:self.EMPTY_CIRCLE)
        self.progress5.image = UIImage(named:self.EMPTY_CIRCLE)
        self.progress6.image = UIImage(named:self.EMPTY_CIRCLE)
        self.progress7.image = UIImage(named:self.EMPTY_CIRCLE)
    }
    
    
    /*
        Controls the space between the views
    */
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat{
        
        if (option == .spacing){
            return value * 0.67;
        }
        
        return value
    }
    
    
    
    @IBAction func startUsing(_ sender: AnyObject) {
       
        // lock the screen
        self.feu.fadeIn(self.screenLocker, speed: 0.6)
        self.startLoadingAnimation(self.spinner)
        
        DBHelpers.initializeGlobalVariables()
    }
    
    
    
    
    // LOGIC
    func numberOfItems(in carousel: iCarousel) -> Int{
        return 7
    }

    
    
    // NAVIGATION
    @IBAction func goHome(_ sender: AnyObject) {
        // lock the screen
        self.feu.fadeIn(self.screenLocker, speed: 0.6)
        self.startLoadingAnimation(self.spinner)
        
        DBHelpers.initializeGlobalVariables()
    }


}
