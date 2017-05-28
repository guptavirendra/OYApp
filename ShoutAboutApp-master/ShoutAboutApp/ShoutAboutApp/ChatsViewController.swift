//
//  ChatViewController.swift
//  OneChat
//
//  Created by Paul on 20/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import xmpp_messenger_ios
import JSQMessagesViewController
import XMPPFramework
import MobileCoreServices


class ChatsViewController: JSQMessagesViewController, OneMessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var messages = NSMutableArray()
    var recipient: XMPPUserCoreDataStorageObject?
    var firstTime = true
    var userDetails = UIView?()
    var reciepientPerson:SearchPerson?
    
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var statusLabel:UILabel?
    @IBOutlet weak var profilePic:UIImageView?
    
    // Mark: Life Cycle
    
    
    override func didPressAccessoryButton(sender: UIButton!)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet) // 1
        let firstAction = UIAlertAction(title: "Camera", style: .Default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button one")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
        } // 2
        
        let secondAction = UIAlertAction(title: "Photo & Video Library", style: .Default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeAudio as String]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
        } // 3
        
        let thirdAction = UIAlertAction(title: "Location", style: .Default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3
        
        let fourthAction = UIAlertAction(title: "Contact", style: .Default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3

        let fifthAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3

        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        alert.addAction(thirdAction)
        alert.addAction(fourthAction)
        alert.addAction(fifthAction)// 5
        presentViewController(alert, animated: true, completion:nil) // 6
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.profilePic?.makeImageRounded()
        
        //recipient = OneRoster.userFromRosterForJID(jid: "\(reciepientPerson)@localhost" )
        
        //recipient = XMPPUserCoreDataStorageObject(entity: <#T##NSEntityDescription#>, insertIntoManagedObjectContext: <#T##NSManagedObjectContext?#>)
        
        //recipient?.jidStr =
        
        OneMessage.sharedInstance.delegate = self
        
        if OneChat.sharedInstance.isConnected()
        {
            self.senderId = OneChat.sharedInstance.xmppStream?.myJID.bare()
            self.senderDisplayName = OneChat.sharedInstance.xmppStream?.myJID.bare()
        }
        
        self.collectionView!.collectionViewLayout.springinessEnabled = false
        self.inputToolbar!.contentView!.leftBarButtonItem!.hidden = false
    }
    
    
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.navigationBarHidden = false
        if let recipient = recipient
        {
            self.navigationItem.rightBarButtonItems = []
            
            navigationItem.title = recipient.displayName
            self.titleLabel?.text = reciepientPerson?.name  //recipient.nickname
            self.profilePic?.sd_setImageWithURL(NSURL(string: (reciepientPerson?.photo)!))
            
            dispatch_async(dispatch_get_main_queue(),
                           { () -> Void in
                            self.messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
                            self.finishReceivingMessageAnimated(true)
            })
        } else
        {
            if userDetails == nil
            {
                self.titleLabel?.text = "New message"
            }
            
            self.inputToolbar!.contentView!.rightBarButtonItem!.enabled = false
            
            if firstTime
            {
                firstTime = false
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollToBottomAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        userDetails?.removeFromSuperview()
    }
    
    // Mark: Private methods
    
    
    
    func didSelectContact(recipient: XMPPUserCoreDataStorageObject) {
        self.recipient = recipient
        if userDetails == nil {
            navigationItem.title = recipient.displayName
        }
        
        if !OneChats.knownUserForJid(jidStr: recipient.jidStr) {
            OneChats.addUserToChatList(jidStr: recipient.jidStr)
        } else {
            messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
            finishReceivingMessageAnimated(true)
        }
    }
    
    // Mark: JSQMessagesViewController method overrides
    
    var isComposing = false
    var timer: NSTimer?
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        
        if textView.text.characters.count == 0 {
            if isComposing {
                hideTypingIndicator()
            }
        } else {
            timer?.invalidate()
            if !isComposing
            {
                self.isComposing = true
                
                if recipient != nil
                {
                    OneMessage.sendIsComposingMessage((recipient?.jidStr)!, completionHandler: { (stream, message) -> Void in
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(ChatsViewController.hideTypingIndicator), userInfo: nil, repeats: false)
                    })
                }
            } else {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(ChatsViewController.hideTypingIndicator), userInfo: nil, repeats: false)
            }
        }
    }
    
    func hideTypingIndicator() {
        if let recipient = recipient {
            self.isComposing = false
            OneMessage.sendIsComposingMessage((recipient.jidStr)!, completionHandler: { (stream, message) -> Void in
                
            })
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: NSDate(), text: text)
        messages.addObject(fullMessage)
        
        if let recipient = recipient
        {
            let message = Message()
            message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
            message._isRead = false
            message.msg     = text
            message.msgType = 1
            message.senderId = senderId
            message.receiverId  = recipient.jidStr
            
            
            OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessageAnimated(true)
            })
        }
    }
    
    // Mark: JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        var message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
//        if let  messageDict = NSObject.convertStringToDictionary(message.text)
//        {
//            if let msgText = messageDict["msg"] as? String
//            {
//                if msgText.characters.count > 0
//                {
//                    message = JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId , date: message.date, text: msgText)
//                                        
//                }
//            }
//            if let attachment = messageDict["attachment"] as? NSDictionary
//            {
//                if let  localUrl = attachment.objectForKey("serverUrl") as? String
//                {
//                    let attachmentType = attachment.objectForKey("attachmentType") as! Int
//                    if attachmentType == 4 && localUrl.characters.count > 0
//                    {
//                        if let url = NSURL(string: localUrl )
//                        {
//                            
//                            let imageData = ChatAsyncPhotoMedia(URL: url)
//                            message  =  JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: imageData)
//                            
//                        }
//                    }
//                }
//            }
//        }

       
        
        return message
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        let incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        if message.senderId == self.senderId {
            return outgoingBubbleImageData
        }
        
        return incomingBubbleImageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoDataForJID(OneChat.sharedInstance.xmppStream?.myJID) {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: photoData), diameter: 30)
                return senderAvatar
            } else {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0), diameter: 30)
                return senderAvatar
            }
        } else {
            if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoDataForJID(recipient!.jid!) {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: photoData), diameter: 30)
                return recipientAvatar
            } else {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0)!, diameter: 30)
                return recipientAvatar
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        if indexPath.item % 3 == 0
        {
            let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // Mark: UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let msg: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if !msg.isMediaMessage
        {
            if msg.senderId == self.senderId
            {
                cell.textView!.textColor = UIColor.blackColor()
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.blackColor(), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            } else
            {
                cell.textView!.textColor = UIColor.whiteColor()
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            }
        }else
        {
        
        }
        
        return cell
    }
    
    // Mark: JSQMessages collection view flow layout delegate
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let currentMessage: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    // Mark: Chat message Delegates
    
    
    func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    {
        if message.isChatMessageWithBody()
        {
            //let displayName = user.displayName
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if let msg = message.elementForName("body")?.stringValue!
            {
                if let  messageDict = NSObject.convertStringToDictionary(msg)
                {
                    if let from = message.attributeForName("from")?.stringValue
                    {
                        if let msgText = messageDict["msg"] as? String
                        {
                            let message = JSQMessage(senderId: from, senderDisplayName: from , date: NSDate(), text: msgText)
                            messages.addObject(message)
                            self.finishReceivingMessageAnimated(true)
                        }
                        if let attachment = messageDict["attachment"] as? NSDictionary
                        {
                            
                            if let  serverUrl = attachment.objectForKey("serverUrl")
                            {
                                if let url = NSURL(string: serverUrl as! String)
                                {
                                    
                                   let imageData = ChatAsyncPhotoMedia(URL: url)
                                    
                                        
                                        //let imageData =  NSData(contentsOfURL: url)
                                        //let image  =  UIImage(data: imageData!)
                                        //let data  =  JSQPhotoMediaItem(image: image)
                                        let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  NSDate(), media: imageData)
                                        self.messages.addObject(fullMessage)
                                        self.finishReceivingMessageAnimated(true)
                                        
                                    
                                    
                                }
                            }
                            
                        }
                        
                        
                    }
                }else
                {
                    if let from = message.attributeForName("from")?.stringValue!
                    {
                        let message = JSQMessage(senderId: from, senderDisplayName: from , date: NSDate(), text: msg)
                        messages.addObject(message)
                        
                        self.finishReceivingMessageAnimated(true)
                    }
                }
            }
        }
    }
    
    
    
    func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject) {
        self.showTypingIndicator = !self.showTypingIndicator
        self.scrollToBottomAnimated(true)
    }
    
    // Mark: Memory Management
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let data =  JSQPhotoMediaItem(image: pickedImage)
            let fullMessage =   JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date:  NSDate(), media: data)
                messages.addObject(fullMessage)
            self.finishSendingMessageAnimated(true)

            
        
            
            
            //self.finishSendingMessageAnimated(true)
            
           // DataSessionManger.sharedInstance.
            
        //hit webservice =
            
            
            
            let currentTime = NSDate().timeIntervalSince1970 as NSTimeInterval
            let extensionPathStr = "profile\(currentTime).jpg"
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
            let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
            
            print(fullPathToFile)
            
            let imageData: NSData = UIImageJPEGRepresentation(pickedImage, 0.5)!
            
            imageData.writeToFile(fullPathToFile, atomically: true)
            let imagePath =  [ "photo"]
            let mediaPathArray = [fullPathToFile]
            DataSessionManger.sharedInstance.sendVideoORImageMessage(recipient!.jidStr.stringByReplacingOccurrencesOfString("@localhost", withString: ""), message_type: "image", mediaPath: mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
                
                
                if let recipient = self.recipient
                {
                    let message = ImageMessage()
                    message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
                    message._isRead = false
                    message.msg     = ""
                    message.msgType = 4
                    message.senderId = self.senderId
                    message.receiverId  = recipient.jidStr
                    message.attachment.localUrl = fullPathToFile
                    message.attachment.serverUrl =  deserializedResponse.objectForKey("image") as! String
                    
                    OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        
                    })
                }
                
                
                }, onError: { (error) in
                    
            })
            
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension NSObject
{

   class func convertStringToDictionary(text: String) -> [String:AnyObject]?
    {
        var dict = [String:AnyObject]()
        print("json to convert \(text)")
        
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                 dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
    
        return dict
    }
}

