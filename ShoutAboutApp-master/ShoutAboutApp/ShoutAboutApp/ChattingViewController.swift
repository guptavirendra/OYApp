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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
           self.heightConstraint =   NSLayoutConstraint(item: self, attribute:.height , relatedBy:NSLayoutRelation.equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: size.height)
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
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyBoard(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyBoard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.toolBar.isHidden = true
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
    
    
    override func viewWillAppear(_ animated: Bool)
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}



extension ChattingViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let chatDetail = chatArray[indexPath.row]
        print("message type \(chatDetail.message_type)")
        if chatDetail.message_type == "video" ||  chatDetail.message_type == "image"
        {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageTableViewCell", for: indexPath) as! ChatImageTableViewCell
            if chatDetail.video != nil
            {
                let url = URL(string: chatDetail.video!)
                cell.imagesView.image =  self.thumbnail(sourceURL: url!)
                cell.timeLabel.text        = chatDetail.created_at
                
            }
            
            if chatDetail.image != nil
            {
                let url = URL(string: chatDetail.image!)
               //cell.imagesView.setImageWith(url)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChattingTableViewCell", for: indexPath) as! ChattingTableViewCell
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        let chatDetail = chatArray[indexPath.row]
        print("message type \(chatDetail.message_type)")
        if chatDetail.message_type == "video" ||  chatDetail.message_type == "image"
        {
            return 150
        }
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        let chatDetail = chatArray[indexPath.row]
        print("message type \(chatDetail.message_type)")
        if chatDetail.message_type == "video" ||  chatDetail.message_type == "image"
        {
            return 150
        }
        
        return 57
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
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
    func showKeyBoard(_ notification: Notification)
    {
        let dictInfo: NSDictionary = notification.userInfo! as NSDictionary
        let kbFrame = dictInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let  animationDuration = (dictInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as AnyObject).doubleValue
        let  keyboardFrame: CGRect  = ((kbFrame as AnyObject).cgRectValue)!
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
        
        
        UIView.animate(withDuration: animationDuration!, animations: {
            self.view.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
            if self.chatArray.count > 0
            {
                let indexPath = IndexPath(row: self.chatArray.count - 1, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                
            }
            
        })
        
        
    }
    
    
    func hideKeyBoard(_ notification: Notification)
    {
        let dictInfo: NSDictionary = notification.userInfo! as NSDictionary
        let  animationDuration = (dictInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as AnyObject).doubleValue
        constraintTextFieldBottom!.constant = 0
        tableViewBottomConstant!.constant = 0;
        
        
        UIView.animate(withDuration: animationDuration!, animations: {
            self.view.layoutIfNeeded()
        
        })
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
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
    
    func getChatForPage(_ page:String)
    {
        self.view.showSpinner()
        
       DataSessionManger.sharedInstance.getChatConversationForID(String(self.chatPerson.idString), page: page, onFinish: { (response, chatConversation) in
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.totalMessage = chatConversation.total
            self.nextPage     = chatConversation.current_page
            self.lastPage     = chatConversation.last_page
            self.chatArray.append(contentsOf: chatConversation.data)
            self.chatArray.sort(by: { (chatdetail1, chatdetail2) -> Bool in
                chatdetail1.created_at < chatdetail2.created_at
             })
            self.tableView.reloadData()
            self.view.removeSpinner()
            
        })
        
        }) { (error) in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                 self.view.removeSpinner()
                
            })
            
        }
    }
    
}


extension ChattingViewController
{
    func thumbnail(sourceURL:URL) -> UIImage
    {
        let asset = AVAsset(url: sourceURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTime(seconds: 1, preferredTimescale: 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print(error)
            return UIImage(named: "profile")!
        }
    }
}
extension ChattingViewController
{
    
    @IBAction func sendButtonClicked(_ sender:UIButton)
    {
        chatTextView.resignFirstResponder()
        
       
        
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            displayAlertMessage("No Internet Connection")
            
        }else
        {
            let message = self.chatTextView.text
            
            self.chatTextView.text = nil
            
            sendTextMessage(message!)
        }
    
    }
    
    func sendTextMessage(_ message:String)
    {
        
        self.view.showSpinner()
        
        DataSessionManger.sharedInstance.sendTextMessage(String(self.chatPerson.idString), message: message, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.view.removeSpinner()
                self.chatArray.removeAll()
                self.getChat()
                
            })
            }) { (error) in
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.view.removeSpinner()
                    
                })
        }
    }
    
}

extension ChattingViewController
{
    func setProfileImgeForURL(_ urlString:String)
    {
        self.profileImageView.sd_setImage(with: URL(string:urlString ), placeholderImage: UIImage(named: "profile"))
    }
    
    @IBAction func attachButtonClicked(_ sender: AnyObject)
    {
        
        
    }
    @IBAction func callButtonClicked(_ sender: AnyObject)
    {
        
    }
    
    
}
