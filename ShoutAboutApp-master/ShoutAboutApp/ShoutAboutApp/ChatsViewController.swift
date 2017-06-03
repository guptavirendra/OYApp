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
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var messages = NSMutableArray()
    var recipient: XMPPUserCoreDataStorageObject?
    var firstTime = true
    var userDetails = UIView()
    var reciepientPerson:SearchPerson?
    
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var statusLabel:UILabel?
    @IBOutlet weak var profilePic:UIImageView?
    
    // Mark: Life Cycle
    
    
    override func didPressAccessoryButton(_ sender: UIButton!)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet) // 1
        let firstAction = UIAlertAction(title: "Camera", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button one")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        } // 2
        
        let secondAction = UIAlertAction(title: "Photo & Video Library", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeAudio as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true,
                                       completion: nil)
        } // 3
        
        let thirdAction = UIAlertAction(title: "Location", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3
        
        let fourthAction = UIAlertAction(title: "Contact", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3

        let fifthAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3

        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        alert.addAction(thirdAction)
        alert.addAction(fourthAction)
        alert.addAction(fifthAction)// 5
        present(alert, animated: true, completion:nil) // 6
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
        self.inputToolbar!.contentView!.leftBarButtonItem!.isHidden = false
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
        if let recipient = recipient
        {
            self.navigationItem.rightBarButtonItems = []
            
            navigationItem.title = recipient.displayName
            self.titleLabel?.text = reciepientPerson?.name  //recipient.nickname
            //self.profilePic?.sd_setImage(with: URL(string: (reciepientPerson?.photo)!))
            
            DispatchQueue.main.async(execute: { () -> Void in
                            self.messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
                            self.finishReceivingMessage(animated: true)
            })
        } else
        {
            if userDetails == nil
            {
                self.titleLabel?.text = "New message"
            }
            
            self.inputToolbar!.contentView!.rightBarButtonItem!.isEnabled = false
            
            if firstTime
            {
                firstTime = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollToBottom(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        userDetails.removeFromSuperview()
    }
    
    // Mark: Private methods
    
    
    
    func didSelectContact(_ recipient: XMPPUserCoreDataStorageObject) {
        self.recipient = recipient
        if userDetails == nil {
            navigationItem.title = recipient.displayName
        }
        
        if !OneChats.knownUserForJid(jidStr: recipient.jidStr) {
            OneChats.addUserToChatList(jidStr: recipient.jidStr)
        } else {
            messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
            finishReceivingMessage(animated: true)
        }
    }
    
    // Mark: JSQMessagesViewController method overrides
    
    var isComposing = false
    var timer: Timer?
    
    override func textViewDidChange(_ textView: UITextView) {
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
                        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatsViewController.hideTypingIndicator), userInfo: nil, repeats: false)
                    })
                }
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatsViewController.hideTypingIndicator), userInfo: nil, repeats: false)
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
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: text)
        messages.add(fullMessage)
        
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
                self.finishSendingMessage(animated: true)
            })
        }
    }
    
    // Mark: JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let outgoingBubbleImageData = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        let incomingBubbleImageData = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        if message.senderId == self.senderId {
            return outgoingBubbleImageData
        }
        
        return incomingBubbleImageData
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: OneChat.sharedInstance.xmppStream?.myJID) {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
                return senderAvatar
            } else {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0), diameter: 30)
                return senderAvatar
            }
        } else {
            if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: recipient!.jid!) {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
                return recipientAvatar
            } else {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0)!, diameter: 30)
                return recipientAvatar
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        if indexPath.item % 3 == 0
        {
            let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // Mark: UICollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let msg: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if !msg.isMediaMessage
        {
            if msg.senderId == self.senderId
            {
                cell.textView!.textColor = UIColor.black
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.black, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            } else
            {
                cell.textView!.textColor = UIColor.white
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            }
        }else
        {
        
        }
        
        return cell
    }
    
    // Mark: JSQMessages collection view flow layout delegate
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    // Mark: Chat message Delegates
    
    
    func oneStream(_ sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    {
        if message.isChatMessageWithBody()
        {
            //let displayName = user.displayName
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if let msg = message.forName("body")?.stringValue!
            {
                if let  messageDict = NSObject.convertStringToDictionary(msg)
                {
                    if let from = message.attribute(forName: "from")?.stringValue
                    {
                        if let msgText = messageDict["msg"] as? String
                        {
                            let message = JSQMessage(senderId: from, senderDisplayName: from , date: Date(), text: msgText)
                            messages.add(message)
                            self.finishReceivingMessage(animated: true)
                        }
                        if let attachment = messageDict["attachment"] as? NSDictionary
                        {
                            
                            if let  serverUrl = attachment.object(forKey: "serverUrl")
                            {
                                if let url = URL(string: serverUrl as! String)
                                {
                                    
                                   let imageData = ChatAsyncPhotoMedia(url: url)
                                    
                                        
                                        //let imageData =  NSData(contentsOfURL: url)
                                        //let image  =  UIImage(data: imageData!)
                                        //let data  =  JSQPhotoMediaItem(image: image)
                                        let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  Date(), media: imageData)
                                        self.messages.add(fullMessage)
                                        self.finishReceivingMessage(animated: true)
                                        
                                    
                                    
                                }
                            }
                            
                        }
                        
                        
                    }
                }else
                {
                    if let from = message.attribute(forName: "from")?.stringValue!
                    {
                        let message = JSQMessage(senderId: from, senderDisplayName: from , date: Date(), text: msg)
                        messages.add(message)
                        
                        self.finishReceivingMessage(animated: true)
                    }
                }
            }
        }
    }
    
    
    
    func oneStream(_ sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject) {
        self.showTypingIndicator = !self.showTypingIndicator
        self.scrollToBottom(animated: true)
    }
    
    // Mark: Memory Management
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let data =  JSQPhotoMediaItem(image: pickedImage)
            let fullMessage =   JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date:  Date(), media: data)
                messages.add(fullMessage)
            self.finishSendingMessage(animated: true)

            
        
            
            
            //self.finishSendingMessageAnimated(true)
            
           // DataSessionManger.sharedInstance.
            
        //hit webservice =
            
            
            
            let currentTime = Date().timeIntervalSince1970 as TimeInterval
            let extensionPathStr = "profile\(currentTime).jpg"
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
            
            print(fullPathToFile)
            
            let imageData: Data = UIImageJPEGRepresentation(pickedImage, 0.5)!
            
            try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
            let imagePath =  [ "photo"]
            let mediaPathArray = [fullPathToFile]
            DataSessionManger.sharedInstance.sendVideoORImageMessage(recipient!.jidStr.replacingOccurrences(of: "@localhost", with: ""), message_type: "image", mediaPath: mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
                
                
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
                    message.attachment.serverUrl =  deserializedResponse.object(forKey: "image") as! String
                    
                    OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        
                    })
                }
                
                
                }, onError: { (error) in
                    
            })
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension NSObject
{

   class func convertStringToDictionary(_ text: String) -> [String:AnyObject]?
    {
        var dict = [String:AnyObject]()
        print("json to convert \(text)")
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                 dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
    
        return dict
    }
}

