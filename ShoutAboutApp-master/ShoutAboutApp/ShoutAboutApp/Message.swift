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
        classDict["_id"] = self._id as AnyObject
        classDict["_isRead"] = self._isRead as AnyObject
        classDict["msg"] = self.msg as AnyObject
        classDict["msgType"] = self.msgType as AnyObject
        classDict["receiverId"] = self.receiverId.replacingOccurrences(of: "@localhost", with: "") as AnyObject

        classDict["senderId"] = self.senderId.replacingOccurrences(of: "@localhost", with: "") as AnyObject
        
        var errorinString = ""
        
        do
        {
            let data = try JSONSerialization.data(withJSONObject: self.classDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
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
           classDict["attachment"]=attachment.getJson() as AnyObject
        }
    }
    
}

class ImageMessage:Message
{
     var attachment:AttachmentImage = AttachmentImage()
        {
        didSet
        {
            classDict["attachment"]=attachment.getJson() as AnyObject
        }
    }
    
    override func getJson() -> String
    {
        classDict["attachment"] = attachment.getJson() as AnyObject
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
            "attachmentType":self.attachmentType as AnyObject,
            "isPlaying":self.isPlaying as AnyObject,
            "localUrl":self.localUrl as AnyObject,
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
            classDict["serverUrl"] = serverUrl as AnyObject
        }
    }
    
    override func getJson() -> [String : AnyObject]
    {
          super.getJson()
          classDict["serverUrl"] = serverUrl as AnyObject
         return classDict
    }
    
    
}

class AttachmentVideo:AttachmentImage
{
    var thumbnail:String = ""
        {
        didSet
        {
            classDict["thumbnail"] = thumbnail as AnyObject
        }
    }
    
}

class AttachmentAudio:AttachmentImage
{
    var audioDuration  :String = ""
    var loudness:String = ""
    var pitch:String = ""
}

