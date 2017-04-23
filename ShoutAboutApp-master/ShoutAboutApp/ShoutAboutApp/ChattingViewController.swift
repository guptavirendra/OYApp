//
//  ChattingViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import Darwin
import AVFoundation

let fmax = FLT_MAX


class DynamicTextView:UITextView
{
    var heightConstraint:NSLayoutConstraint?
    
    override func layoutSubviews()
    {
         super.layoutSubviews()
         self.setNeedsUpdateConstraints()
    }
    
    
    override func updateConstraints()
    {
        let max = CGFloat(fmax)
        let size = self.sizeThatFits(CGSize(width:self.bounds.size.width, height:max))
        
        if ((self.heightConstraint == nil))
        {
           self.heightConstraint =   NSLayoutConstraint(item: self, attribute:.Height , relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: size.height)
            self.addConstraint(self.heightConstraint!)
            
            
        }
        super.updateConstraints()
    }
    
}


class ChattingViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var  toolBar:UIToolbar!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var  chatTextView:DynamicTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintTextFieldBottom:NSLayoutConstraint?
    @IBOutlet weak var tableViewBottomConstant:NSLayoutConstraint?
    @IBOutlet weak var sendButton:UIButton!
    var chatPerson:ChatPerson = ChatPerson()
    
    var contactID:String = ""
    var nextPage         = 1
    var totalMessage     = 0
    var lastPage         = 0
    
    var chatArray = [ChatDetail]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showKeyBoard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.hideKeyBoard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.toolBar.hidden = true
        self.view.backgroundColor = bgColor
        self.tableView.backgroundColor = bgColor
        profileImageView.makeImageRoundedWithGray()
        getChat()
        

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

}



extension ChattingViewController
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let chatDetail = chatArray[indexPath.row]
        print("message type \(chatDetail.message_type)")
        if chatDetail.message_type == "video" ||  chatDetail.message_type == "image"
        {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatImageTableViewCell", forIndexPath: indexPath) as! ChatImageTableViewCell
            if chatDetail.video != nil
            {
                let url = NSURL(string: chatDetail.video!)
                cell.imagesView.image =  self.thumbnail(sourceURL: url!)
                cell.timeLabel.text        = chatDetail.created_at
                
            }
            
            if chatDetail.image != nil
            {
                let url = NSURL(string: chatDetail.image!)
               cell.imagesView.setImageWithURL(url)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("ChattingTableViewCell", forIndexPath: indexPath) as! ChattingTableViewCell
        if chatDetail.text?.characters.count > 0
        {
            cell.messageLabel.text     = chatDetail.text
        }else
        {
            cell.messageLabel.text     = nil
        }
        cell.timeLabel.text        = chatDetail.created_at
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let chatDetail = chatArray[indexPath.row]
        print("message type \(chatDetail.message_type)")
        if chatDetail.message_type == "video" ||  chatDetail.message_type == "image"
        {
            return 150
        }
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let chatDetail = chatArray[indexPath.row]
        print("message type \(chatDetail.message_type)")
        if chatDetail.message_type == "video" ||  chatDetail.message_type == "image"
        {
            return 150
        }
        
        return 57
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let currentCount = indexPath.row + 1
        if (currentCount < self.totalMessage)
        {
            if nextPage < lastPage && (chatArray.count == currentCount)
            {
                nextPage += 1
                self.getChat()
            }
        }
    }

    
    
}

extension ChattingViewController
{
    func showKeyBoard(notification: NSNotification)
    {
        let dictInfo: NSDictionary = notification.userInfo!
        let kbFrame = dictInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)
        let  animationDuration = dictInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        let  keyboardFrame: CGRect  = (kbFrame?.CGRectValue())!
        var  height:CGFloat =  keyboardFrame.size.height ;
        if (self.tabBarController?.tabBar) != nil
        {
            height   -=  (self.tabBarController?.tabBar.frame.size.height)!
            
        }
        
      
        // Because the "space" is actually the difference between the bottom lines of the 2 views,
        // we need to set a negative constant value here.
        
        constraintTextFieldBottom!.constant -= height;
        tableViewBottomConstant!.constant = 0;
        
        self.view.setNeedsUpdateConstraints()
        
        // Update the layout before rotating to address the following issue.
        // https://github.com/ghawkgu/keyboard-sensitive-layout/issues/1
        /*if (self.currentOrientation != orientation) {
         [self.view layoutIfNeeded];
         }*/
        
        
        UIView.animateWithDuration(animationDuration!)
        {
            self.view.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
            if self.chatArray.count > 0
            {
                let indexPath = NSIndexPath(forRow: self.chatArray.count - 1, inSection: 0)
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
                
            }
            
        }
        
    }
    
    
    func hideKeyBoard(notification: NSNotification)
    {
        let dictInfo: NSDictionary = notification.userInfo!
        let  animationDuration = dictInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        constraintTextFieldBottom!.constant = 0
        tableViewBottomConstant!.constant = 0;
        
        
        UIView.animateWithDuration(animationDuration!)
        {
            self.view.layoutIfNeeded()
        
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension ChattingViewController
{
    func getChat()
    {
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            self.displayAlertMessage("No Internet Connection")
            
        }else
        {
            self.getChatForPage(String(self.nextPage))
        }
        
    }
    
    func getChatForPage(page:String)
    {
        self.view.showSpinner()
        
       DataSessionManger.sharedInstance.getChatConversationForID(String(self.chatPerson.idString), page: page, onFinish: { (response, chatConversation) in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.totalMessage = chatConversation.total
            self.nextPage     = chatConversation.current_page
            self.lastPage     = chatConversation.last_page
            self.chatArray.appendContentsOf(chatConversation.data)
            self.chatArray.sortInPlace({ (chatdetail1, chatdetail2) -> Bool in
                chatdetail1.created_at < chatdetail2.created_at
             })
            self.tableView.reloadData()
            self.view.removeSpinner()
            
        })
        
        }) { (error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                 self.view.removeSpinner()
                
            })
            
        }
    }
    
}


extension ChattingViewController
{
    func thumbnail(sourceURL sourceURL:NSURL) -> UIImage
    {
        let asset = AVAsset(URL: sourceURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTime(seconds: 1, preferredTimescale: 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            return UIImage(CGImage: imageRef)
        } catch {
            print(error)
            return UIImage(named: "profile")!
        }
    }
}
extension ChattingViewController
{
    
    @IBAction func sendButtonClicked(sender:UIButton)
    {
        chatTextView.resignFirstResponder()
        
       
        
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            displayAlertMessage("No Internet Connection")
            
        }else
        {
            let message = self.chatTextView.text
            
            self.chatTextView.text = nil
            
            sendTextMessage(message)
        }
    
    }
    
    func sendTextMessage(message:String)
    {
        
        self.view.showSpinner()
        
        DataSessionManger.sharedInstance.sendTextMessage(String(self.chatPerson.idString), message: message, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.view.removeSpinner()
                self.chatArray.removeAll()
                self.getChat()
                
            })
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.view.removeSpinner()
                    
                })
        }
    }
    
}

extension ChattingViewController
{
    func setProfileImgeForURL(urlString:String)
    {
        self.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
    }
    
    @IBAction func attachButtonClicked(sender: AnyObject)
    {
        
        
    }
    @IBAction func callButtonClicked(sender: AnyObject)
    {
        
    }
    
    
}