/*
    Subclassing PFUser
*/


import UIKit


class User: PFUser{
    
    
    // VARIABLES
    internal let dbu:DBUtils = DBUtils()
    
    fileprivate var id : String = ""
    @NSManaged var name : String
    @NSManaged var picture : PFFile?
    fileprivate var userPicture: UIImage?
    @NSManaged var account_type : String
    @NSManaged var is_athome : Bool
    
    fileprivate let PLACEHOLDER_USER_IMAGE = "user.png"
    
    
    
    // INITIALIZERS
    convenience init(user:PFUser){
        
        let dbu:DBUtils = DBUtils()
        
        var userId:String = dbu.STD_UNDEF_STRING
        if let id:String = user.objectId{
            userId = id
        }
            
        var email:String = dbu.STD_UNDEF_STRING
        if let em:String = user.object(forKey: dbu.DBH_USER_EMAIL) as? String{
            email = em
        }
            
        var name:String = dbu.STD_UNDEF_STRING
        if let nm:String = user.object(forKey: dbu.DBH_USER_NAME) as? String{
            name = nm
        }
            
        var picture:PFFile? = nil
        if let pic:PFFile = user.object(forKey: dbu.DBH_USER_PICTURE) as? PFFile{
            picture = pic
        }
            
        var accType:String = dbu.STD_UNDEF_STRING
        if let acT:String = user.object(forKey: dbu.DBH_USER_ACC_TYPE) as? String{
            accType = acT
        }
            
        var isAtHome = false
        if let isAtH:Bool = user.object(forKey: dbu.DBH_USER_IS_HOME) as? Bool{
            isAtHome = isAtH
        }
            
        self.init(
            id: userId,
            email: email,
            password: "",
            name:name,
            picture: picture,
            account_type:accType,
            is_athome:isAtHome
        )
        
    }
    
    
    
    init (id:String, email:String, password:String, name:String, picture:PFFile?,  account_type:String, is_athome:Bool) {
        super.init()
        
        super.username = email
        super.password = password
        super.email = email
        
        //set initial key-value pairs for person
        self.setSetObId(id)
        self.setUserName(name)
        self.setUserPicture(picture)
        self.setUserAccountType(account_type)
        self.setAtHomeStatus(is_athome)
    }
    
    override init() {
        super.init()
    }
    
    
    // SETTERS
    internal func setSetObId(_ id:String){
        //print("user id is now \(id)")
        self.id = id
    }
    
    internal func setUserName(_ name:String){
        //print("User name is now: \(name)")
        self.name = name
    }
    
    internal func setUserPicture(_ picture:PFFile?){
        //print("User picture is now: \(picture)")
        self.picture = picture
        
        // load the user picture for this object
        if(picture != nil){
            picture!.getDataInBackground(block: {
                (imageData: Data?, error: NSError?) -> Void in
                
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    self.userPicture = image
                }else{
                    print("failed to get user picture")
                    self.userPicture = UIImage(named: self.PLACEHOLDER_USER_IMAGE)
                }
            })
        }else{
            self.userPicture = UIImage(named: self.PLACEHOLDER_USER_IMAGE)
        }
    }
    
    internal func setUserAccountType(_ account_type:String?){
        //print("User account_type is now: \(account_type)")
        self.account_type = account_type!
    }
    
    internal func setAtHomeStatus(_ is_athome:Bool?){
        //print("User is_athome is now: \(is_athome)")
        self.is_athome = is_athome!
    }
    
    
    
    // GETTERS
    internal func getObId() -> String?{
        if let id:String = self.id{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getUserEmail() -> String?{
        if let email:String = self.email{
            return email
        }else{
            return nil
        }
    }
    
    internal func getUserName() -> String?{
        if let name:String = self.name{
            return name
        }else{
            return nil
        }
    }
    
    internal func getUserPicture() -> PFFile?{
        if let picture:PFFile = self.picture{
            return picture
        }else{
            return nil
        }
    }
    
    internal func getUserPicUIImage() -> UIImage?{
        if let picture:UIImage = self.userPicture{
            return picture
        }else{
            return nil
        }
    }
    
    
    internal func getUserAccountType() -> String{
        if let account_type:String = self.account_type{
            return account_type
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getAtHomeStatus() -> Bool{
        if let is_athome:Bool = self.is_athome{
            return is_athome
        }else{
            return false
        }
    }
    
    internal func getUserAsDictionary() -> [String:AnyObject]{
        var userDict:[String:AnyObject] = [String:AnyObject]()
        
        userDict[self.dbu.DBH_GLOBAL_ID]     = self.objectId as AnyObject?
        userDict[self.dbu.DBH_USER_USERNAME] = self.username as AnyObject?
        userDict[self.dbu.DBH_USER_EMAIL]    = self.email as AnyObject?
        userDict[self.dbu.DBH_USER_NAME]     = self.getUserName() as AnyObject?
        userDict[self.dbu.DBH_USER_ACC_TYPE] = self.getUserAccountType() as AnyObject?
        userDict[self.dbu.DBH_USER_PICTURE]  = self.getUserPicture()
        userDict[self.dbu.DBH_USER_IS_HOME]  = self.getAtHomeStatus() as AnyObject?

        return userDict
    }
    
    
    // QUERIES
    internal func deleteTempUsersQuery() -> PFQuery{
        
        let query:PFQuery = PFQuery(className: self.dbu.DB_CLASS_USER)
        query.whereKeyDoesNotExist(self.dbu.DBH_USER_EMAIL)
        query.whereKeyDoesNotExist(self.dbu.DBH_USER_NAME)

        return query
    }
    
    
    
    // Conformation to PFObjectSubclassing
    override class func initialize() {
        self.registerSubclass()
    }
    
}
