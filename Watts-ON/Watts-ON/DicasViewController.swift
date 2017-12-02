//
//  DicasViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 9/19/15.
//  Copyright (c) 2015 SudoCRUD. All rights reserved.
//

import UIKit

class DicasViewController: BaseViewController, iCarouselDataSource, iCarouselDelegate  {

    
    // VARIABLES
    
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var homeBtn: UIBarButtonItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var carousel: iCarousel!
    
    @IBOutlet weak var btnFaceShareContainer: UIView!
    @IBOutlet weak var btnShareFace: UIButton!
    
    
    internal let dbh:DBHelpers = DBHelpers()
    internal let dbu:DBUtils = DBUtils()
    
    internal var tips = [Int: Tip]()
    internal var selectedTip:Tip = Tip()
    
    var items: [Int] = []
    var lastVisualized: Int = 0
    
    
    
    // INITIALIZERS
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize share btns
        self.feu.roundIt(self.btnFaceShareContainer, color: self.feu.LIGHT_GREY)
        self.feu.roundItBordless(self.btnShareFace)
        
        
        // binds the show menu toogle action implemented by SWRevealViewController to the menu button
        if self.revealViewController() != nil {
            self.menuBtn.target = self.revealViewController()
            self.menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // initializes carousel
        self.carousel.dataSource = self
        self.carousel.delegate = self
        self.carousel.type = .linear
        self.carousel.decelerationRate = 0.5
        self.carousel.bounces = false
        self.carousel.isUserInteractionEnabled = true
        
        self.lastVisualized = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // UI initialization
        self.customizeNavBar(self)
        self.customizeMenuBtn(self.menuBtn, btnIdentifier: self.feu.ID_MENU)
        self.customizeMenuBtn(self.homeBtn, btnIdentifier: self.feu.ID_HOME)
        
        // LOGIC
        self.loadData()
    }
    
    
    
    
    
    // UI
    // Carousel
    //---------
    /*
        Number of items in the carousel
    */
    func numberOfItems(in carousel: iCarousel) -> Int{
        return self.tips.count
    }
    
    /*
        Load nib into carousel
    */
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView{
        
        var itemView: TipCardView
        
        // get a tip out of the list of tips
        if let tip = self.tips[index]{
            
            //create new view if no view is available for recycling
            if (view == nil){
                itemView = UIView.loadFromNibNamed("TipCard") as! TipCardView
                
                itemView.parentVC = self
                itemView.cardIdx = index
                itemView.tipTitle.text = tip.getTipTitle()
                itemView.tipDescription.text = tip.getTipInfo()
                
                let pic = tip.getTipPicture()
                if(pic != nil){
                    pic!.getDataInBackground(block: {
                        (imageData: Data?, error: NSError?) -> Void in
                        
                        if (error == nil) {
                            let image = UIImage(data:imageData!)
                            itemView.tipView.image = image
                        }
                    })
                }else{
                    itemView.tipView.image = UIImage(named:"imgres.jpg")
                }
                
                return itemView
            }else{
                print("returning reused view to save resources")
            }
        }else{
            print("problem getting tip out of array of tips")
        }
        
        itemView = view as! TipCardView
        
        return itemView
    }
    
    /*
        Controls the space between the views
    */
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat{
        
        if (option == .spacing){
            return value * 1;
        }
        
        return value
    }
    
    /*
        Identify when the current view changes
    */
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        
        let currentItem = self.carousel.currentItemIndex + 1
        
        if(self.lastVisualized < currentItem){
            // to do
        }else{
            // to do
        }
        
        self.lastVisualized = currentItem
    }
    
    /*
        Selects an item from the carousel
    */
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        print("selected location...")
    }
    
    
    /*
        Display the previous item
    */
    @IBAction func showPrevious(_ sender: AnyObject) {
        var selectedItem = self.carousel.currentItemIndex - 1
        
        // get the previous item
        if(selectedItem < 0){
            selectedItem = self.tips.count - 1
        }
        
        self.carousel.scrollToItem(at: selectedItem, animated: true)
    }
    
    
    /*
        Display the next item on the carousel
    */
    @IBAction func showNext(_ sender: AnyObject) {
        var selectedItem = self.carousel.currentItemIndex + 1
        
        // get the next item
        if(selectedItem > self.tips.count - 1){
            selectedItem = 0
        }
        
        self.carousel.scrollToItem(at: selectedItem, animated: true)
    }
    
    
    /*
        Starts the share tip on facebook process
    */
    @IBAction func shareTip(_ sender: AnyObject) {
        print("\nsharing tip on Facebook")
        self.shareTipOnFacebook(self.lastVisualized)
    }
    
    
    
    
    
    // LOGIC
    /*
        Get list of tips from the app backend
    */
    internal func loadData(){
        print("loading tips ...")
        
        // request data from the app backend
        PFCloud.callFunction(inBackground: "getAllTips", withParameters: nil) {
            (tipsObjects, error) in
            
            if (error == nil){
                if let tipsArray:Array<AnyObject> = tipsObjects as? Array<AnyObject> {
                    print("\navailable tips: \n\(tipsArray)")
                    
                    for i in 0...(tipsArray.count - 1){
                        if let tipObj = tipsArray[i] as? PFObject{
                            self.tips[i] = Tip(tip: tipObj)
                        }else{
                            print("problem unwraping tip object from array")
                        }
                    }
                    
                    self.carousel.reloadData()
                }else{
                    print("problems converting results into array of tips.")
                }
            }else{
                print("\nerror: \(error)")
            }
        }
    }

    
    
    /*
        Share a tip on Facebook
    */
    internal func shareTipOnFacebook(_ tipIdx:Int){
        print("\nsharing tip with index \(tipIdx) ...")
        
        self.infoWindow("Share selected Tip object on Facebook", title: "Share it on Facebook", vc: self)
        
        // get tip data
        if let tip:Tip = self.tips[tipIdx]{
            print("sharing tip \(tip)")
        }else{
            print("problems to get tip at index \(tipIdx)")
        }
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
