//
//  QRCodeGenerateViewController.swift
//  Bolt
//
//  Created by Paulo Barbosa on 02/12/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class QRCodeGenerateViewController: BaseViewController {
    
    
    // VARIABLES AND CONSTANTS
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnAction: UIButton!
   
    internal var qrcodeImage: CIImage!
    internal var location:Location  = Location()
    internal var sharedKey: String = ""
    
    internal let selector:Selector = #selector(QRCodeGenerateViewController.back)
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(self.selector, parentVC: self, labelText: "<")
        
        if qrcodeImage == nil {
            
            if(self.sharedKey != ""){
                
                textField.text = self.sharedKey
                
                let data = textField.text!.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
                
                let filter = CIFilter(name: "CIQRCodeGenerator")
                
                filter!.setValue(data, forKey: "inputMessage")
                filter!.setValue("Q", forKey: "inputCorrectionLevel")
                
                qrcodeImage = filter!.outputImage
                
                textField.resignFirstResponder()
                
                btnAction.setTitle("Clear", for: UIControlState())
                
                displayQRCodeImage()
            }else{
                self.infoWindow("O valor passado como chave não está correto.", title: "Chave inválida", vc: self)
            }
        }
        else {
            imgQRCode.image = nil
            qrcodeImage = nil
            btnAction.setTitle("Generate", for: UIControlState())
        }
        
        textField.isEnabled = !textField.isEnabled

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }

    
    
    // NAVIGATION
    internal func back(){
        self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_GEN_QRC, sender: nil)
    }
}
