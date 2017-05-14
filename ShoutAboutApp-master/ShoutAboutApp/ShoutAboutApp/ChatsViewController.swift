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
    
    // Mark: Life Cycle
    
    
    override func didPressAccessoryButton(sender: UIButton!)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet) // 1
        let firstAction = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
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
        
        let secondAction = UIAlertAction(title: "Choose Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
        } // 3
        
        let thirdAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3
        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        alert.addAction(thirdAction) // 5
        presentViewController(alert, animated: true, completion:nil) // 6
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        if let recipient = recipient
        {
            self.navigationItem.rightBarButtonItems = []
            
            navigationItem.title = recipient.displayName
            self.titleLabel?.text = reciepientPerson?.name  //recipient.nickname
            
            
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
        let fullMessage = JSQMessage(senderId: senderId+"@localhost"/*OneChat.sharedInstance.xmppStream?.myJID.bare()*/, senderDisplayName: senderDisplayName, date: NSDate(), text: text)
        messages.addObject(fullMessage)
        
       /* if let recipient = recipient
        {*/
            OneMessage.sendMessage(text, to: String(reciepientPerson!.idString)+"@localhost" /*recipient.jidStr*/, completionHandler: { (stream, message) -> Void in
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessageAnimated(true)
            })
        //}
    }
    
    // Mark: JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
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
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("SR", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0), diameter: 30)
                return senderAvatar
            }
        } else {
            if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoDataForJID(recipient!.jid!) {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: photoData), diameter: 30)
                return recipientAvatar
            } else {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("SR", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0)!, diameter: 30)
                return recipientAvatar
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
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
        
        if !msg.isMediaMessage {
            if msg.senderId == self.senderId {
                cell.textView!.textColor = UIColor.blackColor()
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.blackColor(), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            } else {
                cell.textView!.textColor = UIColor.whiteColor()
                cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            }
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
    
    
    func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject){
        
        
        if message.isChatMessageWithBody()
        {
            //let displayName = user.displayName
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if let msg = message.elementForName("body")?.stringValue!
            {
                if let  messageDict = self.convertStringToDictionary(msg)
                {
                    
                    
                    if let from = message.attributeForName("from")?.stringValue
                    {
                        if let msgText = messageDict["msg"] as? String
                        {
                            let message = JSQMessage(senderId: from, senderDisplayName: from , date: NSDate(), text: msgText)
                            messages.addObject(message)
                            
                            self.finishReceivingMessageAnimated(true)
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
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]?
    {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
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
            
            //JSQMessage(senderId: <#T##String!#>, senderDisplayName: <#T##String!#>, date: <#T##NSDate!#>, media: JSQMessageMediaData!)
            let fullMessage = JSQMessage(senderId:senderId+"@localhost" /*OneChat.sharedInstance.xmppStream?.myJID.bare()*/, senderDisplayName:senderDisplayName, date: NSDate(), media: data)
            messages.addObject(fullMessage)
            
            if let recipient = recipient
            {
                OneMessage.sendMessageImage(pickedImage, to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessageAnimated(true)
                })
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}
