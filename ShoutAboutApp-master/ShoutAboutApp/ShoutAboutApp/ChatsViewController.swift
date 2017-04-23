/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

import Firebase
import JSQMessagesViewController
import Photos

final class ChatsViewController: JSQMessagesViewController
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    private var updatedMessageRefHandle:  FIRDatabaseHandle?
    private let imageURLNotSetKey = "NOTSET"
    var photoMessageMap = [String: JSQPhotoMediaItem]()
    // MARK: Properties
    private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var messages = [JSQMessage]()
    var chatPerson:ChatPerson = ChatPerson()
        {
        didSet
        {
            title = chatPerson.name
        }
    }
    
    /*var channel: Channel?
        {
        didSet
        {
            title = channel?.name
        }
    }*/
    var channelRef: FIRDatabaseReference?
    
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().referenceForURL(" gs://shoutaboutapp-53d1c.appspot.com")
     //self.channelRef
   // lazy var usersTypingQuery: FIRDatabaseQuery = self.ch
    
    private lazy var usersTypingQuery: FIRDatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqualToValue(true)
    
    private lazy var userIsTypingRef: FIRDatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId) // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
   
    
    deinit
    {
        if let refHandle = newMessageRefHandle
        {
            messageRef.removeObserverWithHandle(refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle
        {
           messageRef.removeObserverWithHandle(refHandle)
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        // 1
        
        
        usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot) in
        
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 3 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    func setImageURL(url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
  
  // MARK: View Lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.profileImageView.makeImageRounded()
    self.senderId =  FIRAuth.auth()?.currentUser?.uid
    
    collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
    collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    observeMessages()

  }
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        observeTyping()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if let photo  = chatPerson.photo
        {
            setProfileImgeForURL(photo)
        }
        self.nameLabel.text = chatPerson.name
    }
  
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!)
    {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "recipient_id":String(chatPerson.idString)
            ]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        isTyping = false
        
    }
  // MARK: Collection view data source (and related) methods
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)  as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        return cell
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
  
  // MARK: Firebase related methods
  
  
  // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage
    {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.outgoingMessagesBubbleImageWithColor(appColor/*jsq_messageBubbleBlue()*/)
        
        
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage
    {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.grayColor())
        
       // return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        // 1.
        let messageQuery = messageRef.queryLimitedToLast(25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        
        newMessageRefHandle  = messageQuery.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String! where text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            }
            else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            }
            else {
                print("Error! Could not decode message data")
            }

              
                
        })
        
        updatedMessageRefHandle = messageRef.observeEventType(.ChildChanged, withBlock: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
        
        
        
    }

  
  // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(textView: UITextView)
    {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
       isTyping = textView.text != ""
    }
    
    override func didPressAccessoryButton(sender: UIButton)
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
        } else
        {
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
  
}

// MARK: Image Picker Delegate
extension ChatsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? NSURL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssetsWithALAssetURLs([photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage()
            {
                // 4
                asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
                    
                
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                  let path = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate()))/\(photoReferenceUrl.lastPathComponent)"
                    // 5
                    
                    
                    // 6
                    self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(NSDate.timeIntervalSinceReferenceDate()*1000)).jpg"
                // 5
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                
                
                storageRef.child(imagePath).putData(imageData!, metadata: metadata)
                { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    /*
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }*/
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
     func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem)
     {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem)
        {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
     func fetchImageDataAtURL(photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = FIRStorage.storage().referenceForURL(photoURL)
        
        // 2
        storageRef.dataWithMaxSize(INT64_MAX) { (data, error) in
         
            if let error = error
            {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.metadataWithCompletion({ (metadata, metadataErr) in
                
            
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                if (metadata?.contentType == "image/gif")
                {
                   //// mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else
                {
                    return
                }
                self.photoMessageMap.removeValueForKey(key!)
                
            })
        }
    }
}
extension ChatsViewController
{
    func setProfileImgeForURL(urlString:String)
    {
        self.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
    }
}
