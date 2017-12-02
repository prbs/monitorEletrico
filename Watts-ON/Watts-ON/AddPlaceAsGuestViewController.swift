//
//  CadUsuKeyViewController.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/24/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit
import AVFoundation

class AddPlaceAsGuestViewController: BaseViewController,AVCaptureMetadataOutputObjectsDelegate {

    
    // VARIABLES
    @IBOutlet weak var sharedKey: UITextField!
    @IBOutlet weak var doubtBtn:UIButton!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var readKeyBtn: UIButton!
    
    
    internal let dbu:DBUtils = DBUtils()
    internal var tempUserConfirmed:Bool = false
    internal var loadedLocation:Location = Location()
    
    internal let selector:Selector = #selector(AddPlaceAsGuestViewController.back)
    
    //QR Reading
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var trava = 0
    
    @IBOutlet weak var messageLabel: UILabel!
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    // Alerts
    internal var confirmLocationDialog : ConfirmPlaceViewController!
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getBackNavbarBtn(self.selector, parentVC: self, labelText: "<")
        
        self.sharedKey.delegate = self
        
        // UI customizations
        self.feu.roundItBordless(self.doubtBtn)
        self.feu.roundIt(self.readKeyBtn, color:self.feu.SUPER_LIGHT_WHITE)
      
    }

    
    
    // UI
    @IBAction func confirmKey(_ sender: AnyObject) {
        print("\nconfirming shared key ...")
        self.validateSharedKey()
    }
    
    
    /*
        Show information outlet
    */
    @IBAction func showInfo(_ sender: AnyObject) {
        if(self.info.isHidden){
            self.feu.fadeIn(self.info, speed: 0.6)
        }else{
            self.feu.fadeOut(self.info, speed: 1.0)
        }
    }
    
    
    
    // LOGIC
    internal func validateSharedKey(){
        
        if let key:String = self.messageLabel.text{
            print("\ntrying to validate the location key \(key) ...")
            
            PFCloud.callFunction(inBackground: "isLocationKeyValid", withParameters: [
                "locationId":key
            ]) {
                (object, error) in
                    
                if (error == nil){
                    print("locs \(object)")
                    
                    if let loc:PFObject = object as? PFObject {
                        let location:Location = Location(location:loc)
                        
                        // get location admin pointer
                        if let locAdmPointer:PFUser = location.getLocationAdmin(){
                            self.getLocationAdmin(location, locObj:loc, admPointer:locAdmPointer)
                        }else{
                            print("problem getting out of the resultant array")
                        }
                    }else{
                        print("problems converting results into array of locations.")
                        self.infoWindow("Se certifique de que a chave está correta.", title: "Local não encontrado", vc: self)
                    }
                }else{
                    print("\nerror: \(error)")
                }
            }
            
        }else{
            print("failed to unwrap shared key")
        }
        
    }
    
    
    /*
        Get the location admin information using its id
    */
    internal func getLocationAdmin(_ location:Location, locObj:PFObject, admPointer:PFUser){
        print("\ntrying to get location admin \(admPointer)")
        
        if let id:String = admPointer.objectId{
            
            // get location admin
            let query:PFQuery = User.query()!
            query.getObjectInBackground(withId: id){
                (user: PFObject?, error: NSError?) -> Void in
                print("admin user found \(user)")
                
                if(error == nil){
                    if let admin:PFUser = user as? PFUser {
                        
                        // check if the current isn't already the location admin
                        if(PFUser.current()?.objectId != admin.objectId){
                            let locAdmin:User = User(user:admin)
                            
                            print("checking if the user is alredy related to the location ...")
                            self.isUserRelatedToLocation(location, locObj:locObj, adm:locAdmin)
                        }else{
                            print("user is already the location admin")
                            self.infoWindow("Você já está cadastrado como o administrador deste local", title: "Operação não pode ser concluída", vc: self)
                        }
                    }else{
                        print("problems unwrapping admin user PFObject")
                        self.infoWindow("A operação não pode ser concluída devido a uma falha ocorrida tentando encontrar o administrador do local", title: "Erro operacional", vc: self)
                    }
                } else {
                    print("problems to get location admin \(error)")
                    self.infoWindow("A operação não pode ser concluída devido a uma falha ocorrida tentando encontrar o administrador do local", title: "Administrador não encontrado", vc: self)
                }
            }
        }else{
            print("problems getting admin id")
        }
    }
    
    
    /*
        Check if the user isn't already related to a location
    */
    internal func isUserRelatedToLocation(_ location:Location, locObj:PFObject, adm:User){
        
        // check if the user isn't already related to the location
        PFCloud.callFunction(inBackground: "isUserRelatedToLocation", withParameters: [
            "locationId":locObj.objectId!,
            "userId"    :PFUser.current()!.objectId!
        ]) {
            (result, error) in
            
            if (error == nil){
                print("location \(locObj)")
                        
                if let result:Int = result as? Int {
                    if(result == 0){
                        self.infoWindow("Você já está associado a este ambiente", title: "Operação inválida", vc: self)
                    }else if(result == 1){
                        print("user is not related to location, showing confirmation dialog ...")
                                
                        self.createConfirmationDialog(location, locObj:locObj, adm:adm)
                    }else{
                        self.infoWindow("Não foi possível te adicionar a este ambiente", title: "Erro operacional", vc: self)
                    }
                }else{
                    print("problems converting results into array of locations.")
                    self.infoWindow("Não foi possível te adicionar a este ambiente", title: "Erro operacional", vc: self)
                }
            }else{
                print("\nerror: \(error)")
                self.infoWindow("Não foi possível te adicionar a este ambiente", title: "Erro operacional", vc: self)
            }
        }
    }
    
    
    /*
        Create a confimation dialog ask the user if he/she really wants to be part of the selected
        location
    */
    internal func createConfirmationDialog(_ location:Location, locObj:PFObject, adm:User){
        print("\ncreating confirmation dialog")
        
        // create a new reading dialog
        self.confirmLocationDialog = ConfirmPlaceViewController(
            nibName: "ConfirmLocation",
            bundle: nil
        )
        
        // initialize dialog with pointer to this page, in order to get the inserted value
        self.confirmLocationDialog.callerViewController = self
        self.confirmLocationDialog.title = "This is a popup view"
        self.confirmLocationDialog.showInView(
            self.view,
            animated  : true,
            location  : location,
            locObj    : locObj,
            admin     : adm
        )
    }
    
    //QRCode Reading
    
    @IBAction func qrCodeReading(_ sender: AnyObject) {
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Move the message label to the top view
            view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No barcode/QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                
                if messageLabel.text != nil && trava == 0{
                    
                        self.validateSharedKey()
                        trava += 1
                }
            }
        }
    }
    
    // NAVIGATION
    internal func back(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    internal func sendUserHomeAfterJoinOp(){
        print("join operation was successful, sending the user home ...")
        
        self.confirmLocationDialog.removeAnimate()
        
        // if this is the first location of the user, unlock the system
        if(DBHelpers.lockedSystem){
            DBHelpers.lockedSystem = false
        }
        
        self.performSegue(withIdentifier: self.feu.SEGUE_UNWIND_AFTER_NEW_LOC, sender: self)
    }
    

    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
