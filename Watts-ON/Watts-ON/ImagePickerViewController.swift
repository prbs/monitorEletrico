//
//  ImagePickerViewController.swift
//  x
//
//  Created by Diego Silva on 11/22/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class ImagePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    // VARIABLES AND CONSTANTS
    internal var feu:FrontendUtilities = FrontendUtilities()
    
    internal var callerVC:UIViewController? = nil
    internal var imagePicker = UIImagePickerController()
    internal var pffileImg:PFFile? = nil
    internal var source:String = ""
    internal var needRotation:Bool = false
    
    internal let IMAGE_COMPRESSION_QUALITY:CGFloat = 0.5
    internal let MAX_IMAGE_FILE_SIZE:Int = 122880  // 120kb
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
    // SETTERS
    internal func setCallerVC(_ viewController:UIViewController, source:String){
        self.source = source
        self.callerVC = viewController
    }
    
    
    /*
        Set the selected picture PFFile variable, the one that is going to be saved on the app 
        backend
    */
    internal func setSelectedImageFile(_ imgFile:PFFile){
        
        // profile
        if(self.source == self.feu.ID_PROFILE){
            
            if let profileVC:PerfilViewController = self.callerVC as? PerfilViewController{
                
                // set caller view controller image attribute
                profileVC.setChosenImgFile(imgFile)
            }else{
                print("problem getting callerVC as PerfilViewController")
            }
            
        // new reward
        }else if(self.source == self.feu.ID_NEW_REWARD){
                
            if let profileVC:NewRewardViewController = self.callerVC as? NewRewardViewController{
                
                // set caller view controller image attribute
                profileVC.setChosenImgFile(imgFile)
            }else{
                print("problem getting callerVC as PerfilViewController")
            }
            
        // sign up
        }else if(self.source == self.feu.ID_SIGNUP){
        
            if let signUpVC:CadastroViewController = self.callerVC as? CadastroViewController{
                
                // set caller view controller image attribute
                signUpVC.setChosenImgFile(imgFile)
            }else{
                print("problem getting callerVC as PerfilViewController")
            }
            
        }else{
            print("unknown page")
        }
        
        
        
    }
    
    
    /*
        Set the actual image of the target element, let's say the picker picture button image.
    */
    internal func setTargetViewImage(_ img:UIImage){
        
        // profile
        if(self.source == self.feu.ID_PROFILE){
            if let profileVC:PerfilViewController = self.callerVC as? PerfilViewController{
                
                // set image on the targete container
                profileVC.setChosenImg(img)
            }else{
                print("problem gettin callerVC as PerfilViewController")
            }
            
        // new reward
        }else if(self.source == self.feu.ID_NEW_REWARD){
            if let newRewardVC:NewRewardViewController = self.callerVC as? NewRewardViewController{
                
                // set image on the target container
                newRewardVC.setChosenImg(img)
            }else{
                print("problem gettin callerVC as NewRewardViewController")
            }
        
        // sign up
        }else if(self.source == self.feu.ID_SIGNUP){
            
            if let signUpVC:CadastroViewController = self.callerVC as? CadastroViewController{
                
                // set image on the target container
                signUpVC.setChosenImg(img)
                
            }else{
                print("problem gettin callerVC NewRewardViewController")
            }
            
        }else{
            print("unknown page")
        }
    }
    
    
    
    
    
    // IMAGE PICKER METHODS
    /*
        Select a new picture for the reward from the user's camera roll
    */
    internal func selectPictureFromRoll(_ sender: AnyObject) {
        print("\nselect picture from camera roll")
        
        
        // profile
        if(self.source == self.feu.ID_PROFILE){
            if let profileVC:PerfilViewController = self.callerVC as? PerfilViewController{
                
                // image picker initialization
                profileVC.imagePicker.delegate = self
                profileVC.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                profileVC.imagePicker.allowsEditing = false
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                    print("selecting image from roll ...")
                    
                    profileVC.present(profileVC.imagePicker, animated: true, completion: nil)
                }
            }else{
                print("problem getting callerVC as PerfilViewController")
            }
            
        // new reward
        }else if(self.source == self.feu.ID_NEW_REWARD){
            
            if let newRewardVC:NewRewardViewController = self.callerVC as? NewRewardViewController{
                
                // image picker initialization
                newRewardVC.imagePicker.delegate = self
                newRewardVC.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                newRewardVC.imagePicker.allowsEditing = false
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                    print("selecting image from roll ...")
                    
                    newRewardVC.present(newRewardVC.imagePicker, animated: true, completion: nil)
                }
            }else{
                print("problem gettin callerVC as NewRewardViewController")
            }
        
        // sign up
        }else if(self.source == self.feu.ID_SIGNUP){
            
            if let signUpVC:CadastroViewController = self.callerVC as? CadastroViewController{
                
                // image picker initialization
                signUpVC.imagePicker.delegate = self
                signUpVC.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                signUpVC.imagePicker.allowsEditing = false
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                    print("selecting image from roll ...")
                    
                    signUpVC.present(signUpVC.imagePicker, animated: true, completion: nil)
                }
                
            }else{
                print("problem gettin callerVC NewRewardViewController")
            }
            
        }else{
            print("unknown page")
        }
        
    }
    
    
    /*
        Open the camera roll
    */
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // profile
        if(self.source == self.feu.ID_PROFILE){
            if let profileVC:PerfilViewController = self.callerVC as? PerfilViewController{
                
                // dismiss view controller once the user finished picking image
                self.fetchProfileImg(info as [String : AnyObject])
                profileVC.dismiss(animated: true, completion: nil)
                
            }else{
                print("problem gettin callerVC as PerfilViewController")
            }
            
        // new reward
        }else if(self.source == self.feu.ID_NEW_REWARD){
            if let newRewardVC:NewRewardViewController = self.callerVC as? NewRewardViewController{
                
                // dismiss view controller once the user finished picking image
                self.fetchProfileImg(info as [String : AnyObject])
                newRewardVC.dismiss(animated: true, completion: nil)
                
            }else{
                print("problem gettin callerVC as NewRewardViewController")
            }
        
        // sign up
        }else if(self.source == self.feu.ID_SIGNUP){
            
            if let signUpVC:CadastroViewController = self.callerVC as? CadastroViewController{
                
                // dismiss view controller once the user finished picking image
                self.fetchProfileImg(info as [String : AnyObject])
                signUpVC.dismiss(animated: true, completion: nil)
                
            }else{
                print("problem gettin callerVC NewRewardViewController")
            }
            
        }else{
            print("unknown page")
        }
    }
    
    
    /*
        Fetch profile image
    */
    internal func fetchProfileImg(_ info: [String : AnyObject]){
        
        if let imgFromPicker = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            // fix image orientation if needed
            var image = self.fixOrientation(imgFromPicker)
            
            // get image as a file
            var imageData = UIImageJPEGRepresentation(image, self.IMAGE_COMPRESSION_QUALITY)
            
            // if the image is valid, try to convert it
            if let imgSizeAux1:Int = imageData?.count{
                
                // get the initial image size file
                var imageSize = imgSizeAux1
                
                print("\n\n>>>>> initial image size \(imageSize)")
                
                // make sure the image file is not going to explode the defined image file size threshold
                while(!self.validImageSize(imageSize)){
                    
                    if let img = self.scaleImage(image){
                        
                        // update image
                        image = img
                        
                        // get image as a file
                        imageData = UIImageJPEGRepresentation(image, self.IMAGE_COMPRESSION_QUALITY)
                        
                        // get the image file size
                        if let imgSizeAux2:Int = imageData?.count{
                            
                            // pass it to the variable that is going to check the loop condition
                            imageSize = imgSizeAux2
                            
                            print("\n\n>>>>> intermediate image size \(imageSize)")
                            
                        }else{
                            print("problems getting image size")
                            
                            // failed to get image size, cancelling loop
                            imageSize = 0
                        }
                    }else{
                        print("could not get resized image")
                        
                        // failed to get image size, cancelling loop
                        imageSize = 0
                    }
                }
            
            }else{
                print("problems getting image size")
            }
            
            // get the adjusted image file
            if let imgFile:PFFile = self.convertImageToPFFile(image){
                
                // set the selected picture
                self.setSelectedImageFile(imgFile)
            }else{
                print("problems getting image as a PFFile")
            }
        }
    }
    
    
    /*
        Scale image
    */
    internal func scaleImage(_ img:UIImage) -> UIImage?{
        
        let cgImage = img.cgImage
        
        let width = (cgImage?.width)! / 2
        let height = (cgImage?.height)! / 2
        let bitsPerComponent = cgImage?.bitsPerComponent
        let bytesPerRow = cgImage?.bytesPerRow
        let colorSpace = cgImage?.colorSpace
        let bitmapInfo = cgImage?.bitmapInfo
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent!, bytesPerRow: bytesPerRow!, space: colorSpace!, bitmapInfo: (bitmapInfo?.rawValue)!)
        
        context!.interpolationQuality = .medium
        
        context?.draw(cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
        
        let scaledImage = context?.makeImage().flatMap { UIImage(cgImage: $0) }
        
        if let _:UIImage = scaledImage{
            return scaledImage
        }else{
            return nil
        }
    }
    
    
    
    /*
        Convert image to PFFile
    */
    internal func convertImageToPFFile(_ image:UIImage?) -> PFFile?{
        if let img = image{
            
            // the caller target image outlet
            self.setTargetViewImage(img)
            
            let imgData:Data = UIImagePNGRepresentation(img)!
            
            return PFFile(name: "picture", data: imgData)
        }else{
            return nil
        }
    }
    
    
    /*
        Actions taken if the user cancel the select picture operation
    */
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("\nuser canceled the operation")
        
        // profile
        if(self.source == self.feu.ID_PROFILE){
            if let profileVC:PerfilViewController = self.callerVC as? PerfilViewController{
                profileVC.dismiss(animated: true, completion: nil)
            }else{
                print("problem gettin callerVC as PerfilViewController")
            }
          
        // new reward
        }else if(self.source == self.feu.ID_NEW_REWARD){
            if let newRewardVC:NewRewardViewController = self.callerVC as? NewRewardViewController{

                newRewardVC.dismiss(animated: true, completion: nil)
            }else{
                print("problem gettin callerVC NewRewardViewController")
            }
            
        // sign up
        }else if(self.source == self.feu.ID_SIGNUP){
            
            if let signUpVC:CadastroViewController = self.callerVC as? CadastroViewController{
                
                signUpVC.dismiss(animated: true, completion: nil)
            }else{
                print("problem gettin callerVC NewRewardViewController")
            }
            
        }else{
            print("unknown page")
        }
    }
    
    
    /*
        If the profile picture is too large, show a message and return false
    */
    internal func validImageSize(_ size:Int) -> Bool{
        if(size < self.MAX_IMAGE_FILE_SIZE){
            return true
        }
        
        return false
    }
    
    
    
    internal func fixOrientation(_ image:UIImage) -> UIImage {
    
        // No-op if the orientation is already correct
        if (image.imageOrientation == .up){
            return image
        }
    
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
    
        switch (image.imageOrientation) {
            
            case .down:
                transform = transform.translatedBy(x: image.size.width, y: image.size.height);
                transform = transform.rotated(by: CGFloat(M_PI));
                break;
            
            case .downMirrored:
                transform = transform.translatedBy(x: image.size.width, y: image.size.height);
                transform = transform.rotated(by: CGFloat(M_PI));
                break;
    
            case .left:
                transform = transform.translatedBy(x: image.size.width, y: 0);
                transform = transform.rotated(by: CGFloat(M_PI_2));
                break;
            
            case .leftMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0);
                transform = transform.rotated(by: CGFloat(M_PI_2));
                break;
    
            case .right:
                transform = transform.translatedBy(x: 0, y: image.size.height);
                transform = transform.rotated(by: CGFloat(-M_PI_2));
                break;
            
            case .rightMirrored:
                transform = transform.translatedBy(x: 0, y: image.size.height);
                transform = transform.rotated(by: CGFloat(-M_PI_2));
                break;
            
            default:
                print("could not find image oritentation")
        }
    
        switch (image.imageOrientation) {
            
            case .upMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0);
                transform = transform.scaledBy(x: -1, y: 1);
                break;
            
            case .downMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0);
                transform = transform.scaledBy(x: -1, y: 1);
                break;
    
            case .leftMirrored:
                transform = transform.translatedBy(x: image.size.height, y: 0);
                transform = transform.scaledBy(x: -1, y: 1);
                break;
            
            case .rightMirrored:
                transform = transform.translatedBy(x: image.size.height, y: 0);
                transform = transform.scaledBy(x: -1, y: 1);
                break;
            default:
                print("could not find image oritentation")
        }
    
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(
            data: nil,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: image.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: image.cgImage!.colorSpace!,
            bitmapInfo: image.cgImage!.bitmapInfo.rawValue
        )!;
        
        ctx.concatenate(transform);
        
        switch (image.imageOrientation) {
            case .rightMirrored:
                // Grr...
                ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width));
                break;
    
            default:
                ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.width,height: image.size.height));
                break;
        }
    
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!;
        let img:UIImage = UIImage(cgImage:cgimg)
        
        return img;
    }
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
