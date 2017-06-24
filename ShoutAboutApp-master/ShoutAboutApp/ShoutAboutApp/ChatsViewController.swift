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
import Photos
import ContactsUI
import LocationPicker

class ChatsViewController: JSQMessagesViewController, OneMessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate, IQAudioRecorderViewControllerDelegate, CNContactViewControllerDelegate  {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var messages = NSMutableArray()
    var recipient: XMPPUserCoreDataStorageObject?
    var firstTime = true
    var userDetails = UIView()
    var reciepientPerson:SearchPerson?
    
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var statusLabel:UILabel?
    @IBOutlet weak var profilePic:UIImageView?
    
    
    
    var locationManager: CLLocationManager!
    var currentLocation:CLLocation?
    var latitudeToSend: CLLocationDegrees?
    var longitudeToSend: CLLocationDegrees?
    
    var isLocationClicked:Bool = false
    
    var messagesOriginal = NSMutableArray()
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
                imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeAudio as String, kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        } // 2
        
        let secondAction = UIAlertAction(title: "Photo & Video Library", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeAudio as String, kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true,
                                           completion: nil)
            }
        } // 3
        
        
        let thirdAction1 = UIAlertAction(title: "Audio", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            self.actionAudio()
        } // 3
        
        let thirdAction = UIAlertAction(title: "Location", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            self.setupLocationManager()
        } // 3
        
        let fourthAction = UIAlertAction(title: "Contact", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            let cnPicker = CNContactPickerViewController()
            cnPicker.delegate = self
            self.present(cnPicker, animated: true, completion: nil)
            
        } // 3

        let fifthAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3

        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        alert.addAction(thirdAction)
        alert.addAction(thirdAction1)
        alert.addAction(fourthAction)
        alert.addAction(fifthAction)// 5
        present(alert, animated: true, completion:nil) // 6
    }
    
    
    
    func presenceRecieved(notification:NSNotification)
    {
       
        let presence = notification.object as? XMPPPresence
        let from = presence?.fromStr()
        if recipient?.jidStr != nil
        {
            if (from?.contains((recipient?.jidStr)!))!
            {
                statusLabel?.text = presence?.type()
            }
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "presenceRecieved"), object: nil)
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //self.tabBarController?.tabBar.isHidden = true
        let time = ""
        
//        OneLastActivity.sendLastActivityQueryToJID((recipient?.jidStr)!) { (iq, id, elemnt) in
//            
//        }
        
         statusLabel?.text = time
        
        NotificationCenter.default.addObserver(self, selector:#selector(ChatsViewController.presenceRecieved(notification:)) , name: NSNotification.Name(rawValue: "presenceRecieved"), object: nil)
        
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(self.copyMessage))
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(self.deleteMessage(indexPath:)))
        
       let copyMenuItem =   UIMenuItem(title: "forwrd", action: #selector(self.copyMessage))
       let deleteMenuItem =  UIMenuItem(title: "Delete", action: #selector(self.deleteMessage(indexPath:)))
        
        
        UIMenuController.shared.menuItems = [copyMenuItem, deleteMenuItem]
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

        if let recipient = recipient
        {
            self.navigationItem.rightBarButtonItems = []

            navigationItem.title = recipient.displayName
            self.titleLabel?.text = reciepientPerson?.name  //recipient.nickname
            //self.profilePic?.sd_setImage(with: URL(string: (reciepientPerson?.photo)!))

            DispatchQueue.main.async(execute: { () -> Void in
            self.messagesOriginal = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)



                for message in self.messagesOriginal
                {
                    self.addMessage(message: message as! JSQMessage)
                }
                // Here I have to convert all data
                self.finishReceivingMessage(animated: true)
                 self.scrollToBottom(animated: true)
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


        self.collectionView!.collectionViewLayout.springinessEnabled = false
        self.inputToolbar!.contentView!.leftBarButtonItem!.isHidden = false
    }
    
    func copyMessage()
    {
       
        
        
        
        
    }
    func deleteMessage(indexPath:NSIndexPath)
    {
        let msg: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        if let _id  = msg.messageID
        {
            let predicate =  NSPredicate { (msg, bind) -> Bool in
             
                let mesg = msg as!JSQMessage
                return mesg.text.contains(_id)
            }
            let toDeleteArray =  self.messagesOriginal.filtered(using: predicate) as? [JSQMessage]
            let message: JSQMessage = (toDeleteArray?.first)!
            let finalDeleteArray = NSMutableArray()
            for mesege in toDeleteArray!
            {
                finalDeleteArray.add(mesege.text)
            }
            
            OneMessage.sharedInstance.deleteMessagesFrom(jid: message.senderId, messages: finalDeleteArray)
            self.messages.removeObject(at: indexPath.item)
            self.collectionView.reloadData()
        }
        
    }
    
    func getMediaMessage()->[JSQMessage]?
    {
        let predicate =  NSPredicate { (msg, bind) -> Bool in
            
            let mesg = msg as!JSQMessage
            if mesg.media != nil
            {
                return mesg.media.isKind(of: JSQPhotoMediaItem.self)
            }
            return false
        }
        
      return  messages.filtered(using: predicate) as? [JSQMessage]
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
        /*if let recipient = recipient
        {
            self.navigationItem.rightBarButtonItems = []
            
            navigationItem.title = recipient.displayName
            self.titleLabel?.text = reciepientPerson?.name  //recipient.nickname
            //self.profilePic?.sd_setImage(with: URL(string: (reciepientPerson?.photo)!))
            
            DispatchQueue.main.async(execute: { () -> Void in
                            let messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
                
                
                
                for message in messages
                {
                    self.addMessage(message: message as! JSQMessage)
                }
                            // Here I have to convert all data
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
        }*/
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.scrollToBottom(animated: true)
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
        messages.add(fullMessage!)
        
        if let recipient = recipient
        {
            let message = Message()
            message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
            message._isRead = false
            message.msg     = text
            message.msgType = 0
            message.senderId = senderId
            message.receiverId  = recipient.jidStr
            
            
            OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage(animated: true)
            })
        }
    }
    
    // Mark: JSQMessages CollectionView DataSource
    
    
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    {
        if action == #selector(self.copyMessage)
        {
            return true
        }
        if action == #selector(self.deleteMessage(indexPath:))
        {
            return true
        }
        return false
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
    {
        if action == #selector(self.deleteMessage(indexPath:))
        {
            self.deleteMessage(indexPath: indexPath as NSIndexPath)
        }
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        return message
    }
    
    func  addMessage(message:JSQMessage)
    {
        if let _ = message.text, message.text.characters.count > 0
        {
            if let messageDict = NSObject.convertStringToDictionary(message.text)
            {
                let messageType  = messageDict["msgType"] as! Int
                let _id  = messageDict["_id"] as? String
                switch messageType
                {
                case 0:
                    
                    if let msgText = messageDict["msg"] as? String, msgText.characters.count > 0
                    {
                        let fullMessage = JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date: message.date, text: msgText, andMessageID:_id)
                        self.messages.add(fullMessage!)
                    }
                    
                    break
                case 1:
                    if let attachment = messageDict["attachment"] as? NSDictionary
                    {
                        
                        if let  localUrl = attachment.object(forKey: "localUrl") as? String
                        {
                            print("Audio URL\(localUrl)")
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 1 && localUrl.characters.count > 0
                            {
                                let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                                self.addLocalAudioURLFile(url: localUrl, serverURL: serverUrl, message: message, _id: _id!)
                               // self.addLocalURLFile(url: localUrl,serverURL:serverUrl, message: message, _id: _id!)
                                
                            }
                        }
                            
                        else if let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                        {
                            print("Audio URL\(serverUrl)")
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 1 && serverUrl.characters.count > 0
                            {
                                self.downloadAudioForIndexPath(url: serverUrl, message: message,_id: _id!)
                            }
                        }
                    }
                    break
                case 2:
                    break
                case 3:
                    break
                case 4:
                    if let attachment = messageDict["attachment"] as? NSDictionary
                    {
                        let _id  = messageDict["_id"] as? String
                        if let  localUrl = attachment.object(forKey: "localUrl") as? String
                        {
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 4 && localUrl.characters.count > 0
                            {
                                let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                                self.addLocalURLFile(url: localUrl,serverURL:serverUrl, message: message, _id: _id!)
                                
                            }
                        }
                            
                        else if let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                        {
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 4 && serverUrl.characters.count > 0
                            {
                                self.downloadMediaForIndexPath(url: serverUrl, message: message,_id: _id!)
                            }
                        }
                    }
                    break
                case 5:
                    break
                case 6:
                    break
                case 7:
                    break
                case 8:
                    if let attachment = messageDict["attachment"] as? NSDictionary
                    {
                        let _id  = messageDict["_id"] as? String
                        if let  localUrl = attachment.object(forKey: "localUrl") as? String
                        {
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 8 && localUrl.characters.count > 0
                            {
                                let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                                self.addLocalVideoURLFile(url: localUrl, serverURL: serverUrl, message: message, _id: _id!)
                                
                            }
                        }
                            
                        else if let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                        {
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 8 && serverUrl.characters.count > 0
                            {
                                self.downloadVideoForIndexPath(url: serverUrl, message: message, _id: _id!)
                            }
                        }
                    }
                    break
                case 9:
                    if let attachment = messageDict["attachment"] as? NSDictionary
                    {
                        let _id  = messageDict["_id"] as? String
                        if let  localUrl = attachment.object(forKey: "localUrl") as? String
                        {
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 9 && localUrl.characters.count > 0
                            {
                                
                                if let locationItem = JSQContactMediaItem(maskAsOutgoing: message.senderId == self.senderId)
                                {
                                    let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: locationItem, andMessageID:_id)
                                    self.messages.add(fullMessage!)
                                    locationItem.isAddToContact = message.senderId != self.senderId
                                    
                                    DispatchQueue.global(qos: .background).async
                                        {
                                            locationItem.string = localUrl
                                            DispatchQueue.main.async(execute: { () -> Void in
                                                self.collectionView.reloadData()
                                            })
                                            
                                            
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        
                    }
                    break
                case 10:
                    
                    if let attachment = messageDict["attachment"] as? NSDictionary
                    {
                        let _id  = messageDict["_id"] as? String
                        if let  localUrl = attachment.object(forKey: "localUrl") as? String
                        {
                            let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                            if attachmentType == 10 && localUrl.characters.count > 0
                            {
                                
                                if let locationItem = JSQLocationMediaItem(maskAsOutgoing: message.senderId == self.senderId)
                                {
                                    let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: locationItem, andMessageID:_id)
                                    self.messages.add(fullMessage!)
                                    
                                    
                                    DispatchQueue.global(qos: .background).async
                                        {
                                            var latLongArray = localUrl.components(separatedBy: "--")
                                            if latLongArray.count != 2
                                            {
                                                latLongArray = localUrl.components(separatedBy: "-")
                                            }
                                            if let lat = latLongArray.first, let lang = latLongArray.last
                                            {
                                                if let doublevalue = Double(lat),let doublevalue2 =  Double(lang)
                                                {
                                                    let latitudeToSend: CLLocationDegrees = doublevalue
                                                    let longitudeToSend: CLLocationDegrees = doublevalue2
                                                    let ferryBuildingInSF = CLLocation(latitude: latitudeToSend, longitude: longitudeToSend)
                                                    //locationItem.location = ferryBuildingInSF
                                                    
                                                    locationItem.setLocation(ferryBuildingInSF, withCompletionHandler: {
                                                        DispatchQueue.main.async(execute: { () -> Void in
                                                            
                                                            self.collectionView.reloadData()
                                                        })
                                                    })
                                                    
                                                }
                                            }
                                            
                                            
                                    }
                                    
                                }
                                
                                
//                                let latLongArray = localUrl.components(separatedBy: "-")
//                                if let lat = latLongArray.first  , let lang = latLongArray.last
//                                {
//                                    DispatchQueue.main.async(execute: { () -> Void in
//                                        let latitudeToSend: CLLocationDegrees = Double(lat)!
//                                        let longitudeToSend: CLLocationDegrees = Double(lang)!
//                                        let locationItem =  self.buildLocationItem(latitude: latitudeToSend, longitude: longitudeToSend)
//                                        let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: locationItem)
//                                        self.messages.add(fullMessage!)
//                                        //self.collectionView.reloadData()
//                                    })
//                                    
//                                    
//                                    
//                                }
                                
                            }
                        }
                            
                        
                    }
                    
                    
                    break
                case 11:
                    break
                case 12:
                    break
                    
                default:
                    break
                    
                }
                
                
                
                
                
                
                
                
                /*
                let messageType  = messageDict["msgType"] as! Int
                if let msgText = messageDict["msg"] as? String, msgText.characters.count > 0 && messageType == 0
                {
                    self.messages.add(message)
                        
                }
                else if let attachment = messageDict["attachment"] as? NSDictionary
                {
                    if let  localUrl = attachment.object(forKey: "localUrl") as? String
                    {
                        let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                        if attachmentType == 4 && localUrl.characters.count > 0
                        {
                            self.addLocalURLFile(url: localUrl, message: message)
                            
                        }
                    }
                    
                    else if let  serverUrl = attachment.object(forKey: "serverUrl") as? String
                    {
                        let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                        if attachmentType == 4 && serverUrl.characters.count > 0
                        {
                            self.downloadMediaForIndexPath(url: serverUrl, message: message)
                        }
                    }
                }
            }*/
                
            }
            
        }
    }
    
    
    
    func messageType(messageType:Int, messageDict:NSDictionary )
    {
        
        switch messageType
        {
        case 0:
            
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        case 6:
            break
        case 7:
            break
        case 8:
            break
        case 9:
            break
        case 10:
            break
        case 11:
            break
        case 12:
            break
            
        default:
            break
            
        }
    }
    
    
    
    func downloadMediaForIndexPath(url:String, message:JSQMessage, _id:String)
    {
        if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: message.senderId == self.senderId)
        {
            let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem, andMessageID:_id)
            self.messages.add(fullMessage!)
            DispatchQueue.global().async
            {
               DataSessionManger.sharedInstance.downloadImageWithURL(url, downloadedImageData: { (data, test) in
                
                    let image  =  UIImage(data: data!)
                
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                    //let currentTime = Date().timeIntervalSince1970 as TimeInterval
                    let extensionPathStr = "\(_id).jpg"
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                    
                    print(fullPathToFile)
                    
                    let imageData: Data = UIImageJPEGRepresentation(image!, 0.5)!
                    
                    try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
                
                    mediaItem.image = image
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.collectionView.reloadData()
                    })
               })
            }
        }
    }
    
    
    func downloadAudioForIndexPath(url:String, message:JSQMessage, _id:String)
    {
        /*if */let mediaItem = JSQAudioMediaItem(audioViewAttributes: JSQAudioMediaViewAttributes())
        //{
            
            let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem, andMessageID:_id)
            self.messages.add(fullMessage!)
            DispatchQueue.global().async
                {
                    DataSessionManger.sharedInstance.downloadImageWithURL(url, downloadedImageData: { (data, test) in
                        
                        let extensionPathStr = "\(_id)."+URL(fileURLWithPath: url).pathExtension

                         //let currentTime = Date().timeIntervalSince1970 as TimeInterval
                         let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                        
                        print(fullPathToFile)
                        
                        
                            
                            try? data?.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
                            mediaItem.audioData = data
                             
                            
                        
                        
                        
                        
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.collectionView.reloadData()
                        })
                    })
            }
        //}
    }
    
    func downloadVideoForIndexPath(url:String, message:JSQMessage, _id:String)
    {
        if let mediaItem = JSQVideoMediaItem(maskAsOutgoing: message.senderId == self.senderId)
        {
            let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem, andMessageID:_id)
            self.messages.add(fullMessage!)
        
            DispatchQueue.global(qos: .background).async
            {
                if let uRL = URL(string: url),
                    let urlData = NSData(contentsOf: uRL)
                {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)\(_id)/."+uRL.pathExtension;
                    try? urlData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                    mediaItem.fileURL = URL(fileURLWithPath: filePath)
                    mediaItem.isReadyToPlay = true
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.collectionView.reloadData()
                    })
                    
                }
            }
        }
    }
    
    
    
    func addLocalAudioURLFile(url:String, serverURL:String?, message:JSQMessage, _id:String)
    {
        let mediaItem = JSQAudioMediaItem(audioViewAttributes: JSQAudioMediaViewAttributes())
        //{
            mediaItem.appliesMediaViewMaskAsOutgoing = message.senderId == self.senderId
            let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem, andMessageID:_id)
            self.messages.add(fullMessage!)
            
            DispatchQueue.global(qos: .background).async
                {
                    
                    
                    let extensionPathStr = "\(_id)."+URL(fileURLWithPath: url).pathExtension
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                    let idfileURL = URL(fileURLWithPath: fullPathToFile)
                    let fileURL = URL(fileURLWithPath: url)
                    if  let data = NSData(contentsOf: idfileURL)
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            
                            mediaItem.audioData = data as Data
                            self.collectionView.reloadData()
                        })
                    }else if  let data = NSData(contentsOf: fileURL)
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            mediaItem.audioData = data as Data
                            self.collectionView.reloadData()
                        })
                    }else if let fileURL = URL(string: url), let data = NSData(contentsOf: fileURL)
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            mediaItem.audioData = data as Data
                            self.collectionView.reloadData()
                        })
                    }else
                    {
                        if  serverURL != nil
                        {
                            self.downloadAudioForIndexPath(url: serverURL!, message: message, _id: _id)
                            
                        }
                    }
                    
            }
        //}
    }
    
    

    func addLocalVideoURLFile(url:String, serverURL:String?, message:JSQMessage, _id:String)
    {
        
        if let mediaItem = JSQVideoMediaItem(maskAsOutgoing: message.senderId == self.senderId)
        {
            let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem, andMessageID:_id)
            self.messages.add(fullMessage!)
            
            DispatchQueue.global(qos: .background).async
                {
                    
                    let extensionPathStr = "\(_id).MOV"
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                    let  idfileURL = URL(fileURLWithPath: fullPathToFile)
                    let fileURL = URL(fileURLWithPath: url)
                    if  idfileURL.isFileURL == true
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                        mediaItem.fileURL = idfileURL
                        mediaItem.isReadyToPlay = true
                            self.collectionView.reloadData()
                        })
                        
                    }else if fileURL.isFileURL == true
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                        mediaItem.fileURL = fileURL
                        mediaItem.isReadyToPlay = true
                            self.collectionView.reloadData()
                        })
                        
                    }else
                    {
                        if  serverURL != nil
                        {
                            self.downloadVideoForIndexPath(url: url, message: message, _id: _id)
                            
                        }
                    }
                    
                    /*
                    if let uRL = URL(string: url),
                        let urlData = NSData(contentsOf: uRL)
                    {
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                        let filePath="\(documentsPath)\(_id)/."+uRL.pathExtension;
                        try? urlData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                        mediaItem.fileURL = URL(fileURLWithPath: filePath)
                        mediaItem.isReadyToPlay = true
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.collectionView.reloadData()
                        })
                        
                    }*/
            }
            
            
            
            
        }
        
        
        
        /*
        let fileURL = URL(fileURLWithPath: url)
        if  idfileURL.isFileURL == true
        {
            print("file url with path ")
            DispatchQueue.main.async(execute: { () -> Void in
                let mediaItem = JSQVideoMediaItem(fileURL: idfileURL, isReadyToPlay: true)
                
                let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem)
                self.messages.add(fullMessage!)
                //self.collectionView.reloadData()
            })
            
        }
        else if fileURL.isFileURL == true
        {
            print("file url with path ")
            DispatchQueue.main.async(execute: { () -> Void in
                let mediaItem = JSQVideoMediaItem(fileURL: fileURL, isReadyToPlay: true)
                
                let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem)
                self.messages.add(fullMessage!)
                //self.collectionView.reloadData()
            })
        }
        
        else
        {
            if  serverURL != nil
            {
                self.downloadVideoForIndexPath(url: url, message: message, _id: _id)
                
            }
        }
        */
    }
    
    
    
    

    
    
    
    func addLocalURLFile(url:String, serverURL:String?, message:JSQMessage, _id:String)
    {
        if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: message.senderId == self.senderId)
        {
            let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem, andMessageID:_id)
            self.messages.add(fullMessage!)
            
            DispatchQueue.global(qos: .background).async
                {
                    
                    
                    let extensionPathStr = "\(_id).jpg"
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                    let  idfileURL = URL(fileURLWithPath: fullPathToFile)
                    let fileURL = URL(fileURLWithPath: url)
                    if  let data = NSData(contentsOf: idfileURL)
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                         let image  =  UIImage(data: data as Data)
                         mediaItem.image = image
                         self.collectionView.reloadData()
                        })
                    }else if  let data = NSData(contentsOf: fileURL)
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                         let image  =  UIImage(data: data as Data)
                            mediaItem.image = image
                            self.collectionView.reloadData()
                        })
                    }else if let fileURL = URL(string: url), let data = NSData(contentsOf: fileURL)
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                        let image  =  UIImage(data: data as Data)
                        mediaItem.image = image
                        self.collectionView.reloadData()
                        })
                    }else
                    {
                        if  serverURL != nil
                        {
                            self.downloadMediaForIndexPath(url: serverURL!, message: message, _id: _id)
                            
                        }
                    }

                }
        }
        
        
        
        /*
        let extensionPathStr = "\(_id).jpg"
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
        let  idfileURL = URL(fileURLWithPath: fullPathToFile)
        let fileURL = URL(fileURLWithPath: url)
        if  let data = NSData(contentsOf: idfileURL)
        {
            print("file url with path ")
            DispatchQueue.main.async(execute: { () -> Void in
                
                let image  =  UIImage(data: data as Data)
                print("file url with path---- \(String(describing: image))")
                let mediaItem = JSQPhotoMediaItem(image: image)
                let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem)
                self.messages.add(fullMessage!)
                //self.collectionView.reloadData()
            })

        }
        else if  let data = NSData(contentsOf: fileURL)
        {
            print("file url with path ")
            DispatchQueue.main.async(execute: { () -> Void in
               
                let image  =  UIImage(data: data as Data)
                 print("file url with path---- \(String(describing: image))")
                let mediaItem = JSQPhotoMediaItem(image: image)
                let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem)
                self.messages.add(fullMessage!)
                //self.collectionView.reloadData()
            })
        }
        else if let fileURL = URL(string: url), let data = NSData(contentsOf: fileURL)
        {
            print("file url with string ")
             DispatchQueue.main.async(execute: { () -> Void in
                let image  =  UIImage(data: data as Data)
                 print("file url with string---- \(String(describing: image))")
                let mediaItem = JSQPhotoMediaItem(image: image)
                let fullMessage =   JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date:  message.date, media: mediaItem)
                self.messages.add(fullMessage!)
                //self.collectionView.reloadData()
                })
            
        }
        else
        {
            if  serverURL != nil
            {
                self.downloadMediaForIndexPath(url: serverURL!, message: message, _id: _id)
                
            }
        }*/
        
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
            if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: recipient?.jid!) {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!)
    {
         let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        if message.isMediaMessage == true
        {
            
            if message.media.isKind(of: JSQVideoMediaItem.self) == true
            {
                let  video :JSQVideoMediaItem = message.media as!JSQVideoMediaItem
                let videoVC = VideoView(video.fileURL)
                self.present(videoVC!, animated: true, completion: nil)
                
            }else if message.media.isKind(of: JSQLocationMediaItem.self) == true
            {
                let  location :JSQLocationMediaItem = message.media as!JSQLocationMediaItem
                let mapVC = MapView(location.location)
                let nav = UINavigationController(rootViewController: mapVC!)
                self.present(nav, animated: true, completion: nil)
            }else if message.media.isKind(of: JSQPhotoMediaItem.self) == true
            {
                 let imageVC = PictureView(message.messageID, self.getMediaMessage())
                 self.present(imageVC!, animated: true, completion: nil)
            }else if message.media.isKind(of: JSQContactMediaItem.self) == true
            {
                
                let contact : JSQContactMediaItem = message.media as! JSQContactMediaItem
                let  contactArray = contact.string.components(separatedBy: "-")
                                
                if let name = contactArray.first
                {
                    
                    let con = CNMutableContact()
                    con.givenName  = name
                    
                    // con.familyName = "Appleseed"
                    if let mobile = contactArray.last
                    {
                        con.phoneNumbers.append(CNLabeledValue(
                            label: "Mobile Number", value: CNPhoneNumber(stringValue: mobile
                        )))
                    }
                    
                    let addNewContactVC = CNContactViewController(forNewContact: con)
                    addNewContactVC.contactStore = CNContactStore()
                    addNewContactVC.delegate      = self
                    addNewContactVC.allowsActions = false
                    if (message.senderId == self.senderId)
                    {
                        addNewContactVC.allowsEditing = false
                    }
                    let nav = UINavigationController(rootViewController: addNewContactVC)
                    self.present(nav, animated: true, completion: nil)
                    
                }
                
            }
        }
    }
    
    
    
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
   {
         return true
    }
    
    
    // Mark: Chat message Delegates
    
    
    func oneStream(_ sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    {
        if message.isChatMessageWithBody()
        {
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            
            if let msg = message.forName("body")?.stringValue!
            {
                if let  messageDict = NSObject.convertStringToDictionary(msg)
                {
                    if let from = message.attribute(forName: "from")?.stringValue
                    {
                        let messageType = messageDict["msgType"] as! Int
                        if let msgText = messageDict["msg"] as? String, msgText.characters.count > 0, messageType == 0
                        {
                            let message = JSQMessage(senderId: from, senderDisplayName: from , date: Date(), text: msgText)
                            messages.add(message!)
                            self.finishReceivingMessage(animated: true)
                        }else if let attachment = messageDict["attachment"] as? NSDictionary
                        {
                            let _id  = messageDict["_id"] as? String
                            if let  serverUrl = attachment.object(forKey: "serverUrl")
                            {
                                if let url = URL(string: serverUrl as! String)
                                {
                                    
                                    
                                    if messageType == 4
                                    {
                                        DispatchQueue.global().async
                                        {
                                            if  let imageData =  NSData(contentsOf: url)
                                            {
                                                let image  =  UIImage(data: imageData as Data)
                                                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                                                //let currentTime = Date().timeIntervalSince1970 as TimeInterval
                                                let extensionPathStr = "\(_id!)."+url.pathExtension
                                                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                                let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                                                
                                                print(fullPathToFile)
                                                
                                                let imageData: Data = UIImageJPEGRepresentation(image!, 0.5)!
                                                
                                                try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
                                                
                                                
                                                
                                                
                                                let data  =  JSQPhotoMediaItem(image: image)
                                                let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  Date(), media: data!, andMessageID:_id)
                                        
                                                DispatchQueue.main.async(execute: { () -> Void in
                                                self.messages.add(fullMessage!)
                                                    self.finishReceivingMessage(animated: true)
                                                })
                                            }
                                        }
                                    }else if messageType == 8
                                    {
                                        DispatchQueue.global().async
                                            {
                                                
                                                if let urlData = NSData(contentsOf: url)
                                                {
                                                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                                    let filePath="\(documentsPath)\(_id!)/."+url.pathExtension;
                                                     UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil)
                                                    try? urlData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                                                    print("file url with path ")
                                                    DispatchQueue.main.async(execute: { () -> Void in
                                                        let mediaItem = JSQVideoMediaItem(fileURL: URL(fileURLWithPath: filePath), isReadyToPlay: true)
                                                        
                                                        let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  Date(), media: mediaItem!, andMessageID:_id)
                                                        
                                                        DispatchQueue.main.async(execute: { () -> Void in
                                                            self.messages.add(fullMessage!)
                                                            self.finishReceivingMessage(animated: true)
                                                        })
                                                    
                                                })
                                                
                                            }
                                        }
                                        
                                    }
                                    else if messageType == 1
                                    {
                                        DispatchQueue.global().async
                                            {
                                                
                                                if let urlData = NSData(contentsOf: url)
                                                {
                                                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                                    let filePath="\(documentsPath)\(_id!)/."+url.pathExtension;
                                                    
                                                    try? urlData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                                                    print("file url with path ")
                                                    DispatchQueue.main.async(execute: { () -> Void in
                                                        let mediaItem = JSQAudioMediaItem(data: urlData as Data, audioViewAttributes: JSQAudioMediaViewAttributes())
                                                        
                                                        let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  Date(), media: mediaItem, andMessageID:_id)
                                                        
                                                        DispatchQueue.main.async(execute: { () -> Void in
                                                            self.messages.add(fullMessage!)
                                                            self.finishReceivingMessage(animated: true)
                                                        })
                                                        
                                                    })
                                                    
                                                }
                                        }
                                        
                                    }
                                    
                                }
                            }
                            if let  localUrl = attachment.object(forKey: "localUrl") as? String
                            {
                                let attachmentType = attachment.object(forKey: "attachmentType") as! Int
                                if attachmentType == 10 && localUrl.characters.count > 0
                                {
                                    
                                    if let locationItem = JSQLocationMediaItem(maskAsOutgoing: from == self.senderId)
                                    {
                                        let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  Date(), media: locationItem, andMessageID:_id)
                                        self.messages.add(fullMessage!)
                                        
                                        DispatchQueue.global(qos: .background).async
                                            {
                                                var latLongArray = localUrl.components(separatedBy: "--")
                                                if latLongArray.count != 2
                                                {
                                                    latLongArray = localUrl.components(separatedBy: "-")
                                                }
                                                if let lat = latLongArray.first  , let lang = latLongArray.last
                                                {
                                                    if let doublevalue = Double(lat),let doublevalue2 =  Double(lang)
                                                    {
                                                        let latitudeToSend: CLLocationDegrees = doublevalue
                                                        let longitudeToSend: CLLocationDegrees = doublevalue2
                                                        let ferryBuildingInSF = CLLocation(latitude: latitudeToSend, longitude: longitudeToSend)
                                                        //locationItem.location = ferryBuildingInSF
                                                        
                                                        locationItem.setLocation(ferryBuildingInSF, withCompletionHandler: {
                                                            DispatchQueue.main.async(execute: { () -> Void in
                                                                
                                                                self.collectionView.reloadData()
                                                            })
                                                        })
                                                    
                                                    }
                                                }
                                                
                                                
                                        }
                                        
                                    }
                                    
                                }
                                if attachmentType == 9 && localUrl.characters.count > 0
                                {
                                    
                                    if let locationItem = JSQContactMediaItem(maskAsOutgoing: from == self.senderId)
                                    {
                                        let fullMessage =   JSQMessage(senderId: from, senderDisplayName: from, date:  Date(), media: locationItem, andMessageID:_id)
                                        self.messages.add(fullMessage!)
                                        
                                        
                                        DispatchQueue.global(qos: .background).async
                                            {
                                                locationItem.string = localUrl
                                                DispatchQueue.main.async(execute: { () -> Void in
                                                    self.collectionView.reloadData()
                                                })
                                                
                                                
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                                
                            }
                            
                        }
                    }
                }else
                {
                    if let from = message.attribute(forName: "from")?.stringValue!
                    {
                        let message = JSQMessage(senderId: from, senderDisplayName: from , date: Date(), text: msg)
                        messages.add(message!)
                        
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
            /*
            DispatchQueue.main.async(execute: { () -> Void in
                let data =  JSQPhotoMediaItem(image: pickedImage)
                let fullMessage =   JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date:  Date(), media: data)
                self.messages.add(fullMessage!)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishReceivingMessage(animated: true)
            })
            */
    
            
            
            
            if let recipient = self.recipient
            {
                let message = ImageMessage()
                message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
                message._isRead = false
                message.msg     = ""
                message.msgType = 4
                message.senderId = self.senderId
                message.receiverId  = recipient.jidStr
               
                
                UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
                //let currentTime = Date().timeIntervalSince1970 as TimeInterval
                let extensionPathStr = "\(message._id).jpg"
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                
                print(fullPathToFile)
                
                let imageData: Data = UIImageJPEGRepresentation(pickedImage, 0.5)!
                
                try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
                let imagePath =  [ "photo"]
                let mediaPathArray = [fullPathToFile]
                 message.attachment.localUrl = fullPathToFile
                
                
                let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: message.getJson())
                
                self.addMessage(message: fullMessage!)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishReceivingMessage(animated: true)
                
            DataSessionManger.sharedInstance.sendVideoORImageMessage(recipient.jidStr.replacingOccurrences(of: "@localhost", with: ""), message_type: "image", mediaPath: mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
                    
                    
                    message.attachment.serverUrl =  deserializedResponse.object(forKey: "image") as! String
                
                    OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                    
                    ///should update message has been sent
                })
                    
                }, onError: { (error) in
                    
                })
                
            }
        }
        
        
        if let video = info[UIImagePickerControllerMediaURL]  as? URL
        {
            
            if let recipient = self.recipient
            {
                let message = VideoMessage()
                message.attachment.attachmentType = 8
                message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
                message._isRead = false
                message.msg     = ""
                message.msgType = 8
                message.senderId = self.senderId
                message.receiverId  = recipient.jidStr
                
                
                
                
                
                
                //UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
                //let currentTime = Date().timeIntervalSince1970 as TimeInterval
                 let lastPathComponent = video.pathExtension
                let extensionPathStr = "\(message._id)."+lastPathComponent
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                
                print(fullPathToFile)
                UISaveVideoAtPathToSavedPhotosAlbum(fullPathToFile, nil, nil, nil)
                let videoData = NSData(contentsOf: video )
                
                try? videoData?.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
                let imagePath =  ["video"]
                let mediaPathArray = [fullPathToFile]
                message.attachment.localUrl = fullPathToFile
                
                
                let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: message.getJson())
                
                self.addMessage(message: fullMessage!)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishReceivingMessage(animated: true)
                DataSessionManger.sharedInstance.sendVideoORImageMessage(recipient.jidStr.replacingOccurrences(of: "@localhost", with: ""), message_type: "video", mediaPath: mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
                    
                    print("\(deserializedResponse)")
                    if let video = deserializedResponse.object(forKey: "video") as? String
                    {
                        message.attachment.serverUrl = video
                        
                        OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                            
                            ///should update message has been sent
                        })
                    }
                    
                }, onError: { (error) in
                    
                })
                
            }
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
        
        if let data = text.data(using: String.Encoding.utf8)
        {
            do {
                 dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
    
        return dict
    }
}

extension ChatsViewController : CLLocationManagerDelegate
{
    
    func actionAudio()
    {
        let controller = IQAudioRecorderViewController()
        controller.delegate = self
        controller.title = "R"
        controller.maximumRecordDuration = 300;
        controller.allowCropping = false;
        controller.audioFormat = ._caf
        //self.presentAudioRecorderViewControllerAnimated(controller)
        self.presentBlurredAudioRecorderViewControllerAnimated(controller)
        
    }

    
    func buildLocationItem(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: latitude, longitude: longitude)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }

    
    
    
    
    func setupLocationManager(){
        
        
        
       
        
        
        
        let locationPicker = LocationPickerViewController()
        
        // you can optionally set initial location
        if  let coordinates =  currentLocation?.coordinate
        {
           let  location = Location(name: "my current location", location: nil,
                                placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [:]))
            
            
            locationPicker.location = location
        }
        
        // button placed on right bottom corner
        locationPicker.showCurrentLocationButton = true // default: true
        
        // default: navigation bar's `barTintColor` or `.whiteColor()`
        locationPicker.currentLocationButtonBackground = .blue
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        
        locationPicker.mapType = .standard // default: .Hybrid
        
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"
        
        locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"
        
        // optional region distance to be used for creation region when user selects place from search results
        locationPicker.resultRegionDistance = 500 // default: 600
        
        locationPicker.completion =
            { location in
                
               
                
                
                    
                    
                    let locationValue:CLLocationCoordinate2D = (location?.location.coordinate)!
                    
                    print("locations = \(locationValue)")
                    self.latitudeToSend = locationValue.latitude
                    self.longitudeToSend = locationValue.longitude
                    self.locationManager.stopUpdatingLocation()
                    
                    //let locationItem = self.buildLocationItem(latitude: self.latitudeToSend!, longitude: self.longitudeToSend!)
                    
                    ///self.addMedia(media: locationItem)
                    
                    
                    
                    let message = VideoMessage()
                    message.attachment.attachmentType = 10
                    message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
                    message._isRead = false
                    message.msg     = ""
                    message.msgType = 10
                    message.senderId = self.senderId
                    message.receiverId  = (self.recipient?.jidStr)!
                    message.attachment.localUrl = String(describing: self.latitudeToSend!.magnitude)+"-"+String(describing: self.longitudeToSend!.magnitude)
                    
                    let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: message.getJson())
                    self.addMessage(message: fullMessage!)
                    
                    OneMessage.sendMessage(message.getJson(), to: (self.recipient?.jidStr)!, completionHandler: { (stream, message) -> Void in
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.finishSendingMessage(animated: true)
                    })
                    
                
            // do some awesome stuff with location
        }
        
        let nav = UINavigationController(rootViewController: locationPicker)
        self.navigationController?.pushViewController(locationPicker, animated: false)
       // self.present(nav, animated: true, completion: nil)
        
    }
    /*
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        isLocationClicked = true
        
    }
    */
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = manager.location!
        
    }
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error")
        
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        contacts.forEach { contact in
            
            let formatter = CNContactFormatter()
            
            let name = formatter.string(from: contact)
            if let phone = contact.phoneNumbers.first?.value
            {
                let mobile = phone.value(forKey: "digits") as? String
                if (name?.characters.count)! > 0
                {
                    let message = VideoMessage()
                    message.attachment.attachmentType = 9
                    message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
                    message._isRead = false
                    message.msg     = ""
                    message.msgType = 9
                    message.senderId = self.senderId
                    message.receiverId  = (recipient?.jidStr)!
                    message.attachment.localUrl = name!+"-"+mobile!
                    let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: message.getJson())
                    self.addMessage(message: fullMessage!)
                    
                    OneMessage.sendMessage(message.getJson(), to: (recipient?.jidStr)!, completionHandler: { (stream, message) -> Void in
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.finishSendingMessage(animated: true)
                    })
                    
                }
            }
            
            

            print()
        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String)
    {
          let video = URL(fileURLWithPath: filePath)
          if let recipient = self.recipient
            {
                let message = VideoMessage()
                message.attachment.attachmentType = 1
                message._id = (OneChat.sharedInstance.xmppStream?.generateUUID())!
                message._isRead = false
                message.msg     = ""
                message.msgType = 1
                message.senderId = self.senderId
                message.receiverId  = recipient.jidStr
                
                
                
                
                
                
                //UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
                //let currentTime = Date().timeIntervalSince1970 as TimeInterval
                let lastPathComponent = video.pathExtension
                let extensionPathStr = "\(message._id)."+lastPathComponent
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
                
                print(fullPathToFile)
                
                let videoData = NSData(contentsOf: video )
                
                try? videoData?.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
                let imagePath =  ["Audio"]
                let mediaPathArray = [fullPathToFile]
                message.attachment.localUrl = fullPathToFile
                
                
                let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: Date(), text: message.getJson())
                
                self.addMessage(message: fullMessage!)
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishReceivingMessage(animated: true)
                DataSessionManger.sharedInstance.sendVideoORImageMessage(recipient.jidStr.replacingOccurrences(of: "@localhost", with: ""), message_type: "video", mediaPath: mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
                    
                    print("\(deserializedResponse)")
                    if let video = deserializedResponse.object(forKey: "video") as? String
                    {
                        message.attachment.serverUrl = video
                        
                        OneMessage.sendMessage(message.getJson(), to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
                            
                            ///should update message has been sent
                        })
                    }
                    
                }, onError: { (error) in
                    
                })
                
            }
        
        
        
        controller.dismiss(animated: true, completion: nil)
        
        
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?)
    {
        viewController.dismiss(animated: true, completion: nil)
    }
}
