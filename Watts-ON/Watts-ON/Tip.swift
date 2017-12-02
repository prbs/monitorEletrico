//
//  Tip.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/7/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import Foundation

class Tip: PFObject {
    
    
    // VARIABLES
    let dbu:DBUtils = DBUtils()
    
    fileprivate var objId: String?
    @NSManaged var title: String?
    @NSManaged var info: String?
    @NSManaged var comment: String?
    @NSManaged var picture: PFFile?
    @NSManaged var mini_picture: PFFile?
    
    
    // CONSTRUCTORS
    convenience init(tip:PFObject){
        let dbu:DBUtils = DBUtils()
        
        if let id:String = tip.objectId{
            
            var title:String = ""
            if let aux:String = tip[dbu.DBH_TIP_TITLE] as? String{
                title = aux
            }
            
            var info:String = ""
            if let aux:String = tip[dbu.DBH_TIP_INFO] as? String{
                info = aux
            }
            
            var comment:String = ""
            if let aux:String = tip[dbu.DBH_TIP_COMMENT] as? String{
                comment = aux
            }
            
            var picture:PFFile? = nil
            if let aux:PFFile = tip[dbu.DBH_TIP_PICTURE] as? PFFile{
                picture = aux
            }
            
            var mini_picture:PFFile? = nil
            if let aux:PFFile = tip[dbu.DBH_TIP_MINI_PIC] as? PFFile{
                mini_picture = aux
            }
            
            self.init(
                objectId      :id,
                title         :title,
                comment       :comment,
                info          :info,
                picture       :picture,
                mini_picture  :mini_picture
            )
        }else{
            self.init()
        }
    }
    
    init(objectId:String?, title:String?, comment: String?, info:String?, picture:PFFile?, mini_picture: PFFile?) {
        super.init()
        
        self.setObId(objectId)
        self.setTipTitle(title)
        self.setTipComment(comment)
        self.setTipInfo(info)
        self.setTipMiniPicture(picture)
        self.setTipPicture(picture)
    }
    
    override init() {
        super.init()
    }
    
    
    // SETTERS
    internal func setObId(_ id:String?){
        print("Tip id is now: \(id)")
        self.objId = id
    }
    
    internal func setTipTitle(_ title:String?){
        print("Tip title is now: \(title)")
        self.title = title
    }
    
    internal func setTipInfo(_ info:String?){
        print("Tip info is now: \(info)")
        self.info = info
    }
    
    internal func setTipComment(_ comment:String?){
        print("Tip comment is now: \(comment)")
        self.comment = comment
    }
    
    internal func setTipPicture(_ picture:PFFile?){
        print("Tip picture is now: \(picture)")
        self.picture = picture
    }
    
    internal func setTipMiniPicture(_ picture:PFFile?){
        print("Tip picture is now: \(picture)")
        self.mini_picture = picture
    }
    
    
    // GETTERS
    internal func getObId() -> String{
        if let id:String = self.objId{
            return id
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }

    internal func getTipTitle() -> String{
        if let title:String = self.title{
            return title
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getTipInfo() -> String{
        if let info:String = self.info{
            return info
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getTipComment() -> String{
        if let comment:String = self.comment{
            return comment
        }else{
            return self.dbu.STD_UNDEF_STRING
        }
    }
    
    internal func getTipPicture() -> PFFile?{
        if let picture:PFFile = self.picture{
            return picture
        }else{
            return nil
        }
    }
    
    internal func getTipMiniPicture() -> PFFile?{
        if let mini_picture:PFFile = self.mini_picture{
            return mini_picture
        }else{
            return nil
        }
    }
    
    
    
    // QUERIES
    /* 
        Basic query, gets a list of Tip objects
    */
    override class func query() -> PFQuery? {
        let query = PFQuery(className: Tip.parseClassName())
        
        query.order(byDescending: "createdAt")
        
        return query
    }
    
    
    internal func query(_ title:String, shortComment:String) -> PFQuery? {
        let query = PFQuery(className: Tip.parseClassName())
        
        query.order(byDescending: self.dbu.DBH_GLOBAL_STA_DAT)
        query.whereKey(self.dbu.DBH_TIP_TITLE, equalTo: title)
        query.whereKey(self.dbu.DBH_TIP_COMMENT, equalTo: shortComment)
        
        return query
    }
    
}


// Respects the PFSubclassing protocol
extension Tip: PFSubclassing {
    
    // Table view delegate methods here
    class func parseClassName() -> String {
        return "Tip"
    }
    
    override class func initialize() {
        // Let Parse know that you intend to use this subclass for all objects with class type Tip.
        var onceToken: Int = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}



