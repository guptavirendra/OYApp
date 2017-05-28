//
//  Message.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 27/05/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class Message: NSObject
{
    var _id: String = ""//"6Ix1N-26","
    var _isRead: Bool = false
    var msg :String = ""
    var msgType:Int = 0
    var receiverId :String = ""
    var senderId :String = ""
    var classDict = [String: AnyObject]()
    
    override init()
    {
        super.init()
        
    }
    

    //MARK: CONVERT TO JSON
    func getJson() -> String
    {
        classDict["_id"] = self._id
        classDict["_isRead"] = self._isRead
        classDict["msg"] = self.msg
        classDict["msgType"] = self.msgType
        classDict["receiverId"] = self.receiverId.stringByReplacingOccurrencesOfString("@localhost", withString: "")

        classDict["senderId"] = self.senderId.stringByReplacingOccurrencesOfString("@localhost", withString: "")
        
        var errorinString = ""
        
        do
        {
            let data = try NSJSONSerialization.dataWithJSONObject(self.classDict, options: NSJSONWritingOptions.PrettyPrinted)
            
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            if let json = json
            {
                errorinString = json as String
                print(json)
            }
            
        }
        catch
        {
            print(" in catch block")
            
        }
        return errorinString
    }
}


class contactMessage:Message
{
    var attachment:Attachment = Attachment()
        {
        didSet
        {
           classDict["attachment"]=attachment.getJson()
        }
    }
    
}

class ImageMessage:Message
{
     var attachment:AttachmentImage = AttachmentImage()
        {
        didSet
        {
            classDict["attachment"]=attachment.getJson()
        }
    }
    
    override func getJson() -> String
    {
        classDict["attachment"] = attachment.getJson()
        return super.getJson()
    }
}

class Attachment:NSObject// contact
{
    var attachmentType :Int = 4
    var isPlaying:Bool = false
    var localUrl:String = ""
    
    var classDict = [String: AnyObject]()
    //MARK: CONVERT TO JSON
    func getJson() -> [String:AnyObject]
    {
        classDict = [
            "attachmentType":self.attachmentType,
            "isPlaying":self.isPlaying,
            "localUrl":self.localUrl,
          ]
        return classDict
        
    }
    
  
    
}

class AttachmentImage:Attachment
{
    var serverUrl:String = "https://s9.postimg.org/n92phj9tr/DSC_0155.jpg"
        {
        didSet
        {
            classDict["serverUrl"] = serverUrl
        }
    }
    
    override func getJson() -> [String : AnyObject]
    {
          super.getJson()
          classDict["serverUrl"] = serverUrl
         return classDict
    }
    
    
}

class AttachmentVideo:AttachmentImage
{
    var thumbnail:String = ""
        {
        didSet
        {
            classDict["thumbnail"] = thumbnail
        }
    }
    
}

class AttachmentAudio:AttachmentImage
{
    var audioDuration  :String = ""
    var loudness:String = ""
    var pitch:String = ""
}

