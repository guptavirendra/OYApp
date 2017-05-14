//
//  ChatViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, ChatPersionTableViewCellProtocol
{
    
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    private var channelRefHandle: FIRDatabaseHandle?


    @IBOutlet weak var tableView: UITableView!
    var chatPersons = [ChatPerson]()
     
     override func viewDidLoad()
     {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.addBackGroundImageView()
       // self.tableView.backgroundColor = bgColor
        //self.view.backgroundColor = bgColor

        // Do any additional setup after loading the view.
        observeChannels()
    }
    
    deinit
    {
        if let refHandle = channelRefHandle
        {
            channelRef.removeObserverWithHandle(refHandle)
            
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            self.displayAlertMessage("No Internet Connection")
            
        }else
        {
            self.getChatPerosn()
        }
    }

}

extension ChatViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatPersons.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatPersionTableViewCell", forIndexPath: indexPath) as! ChatPersionTableViewCell
        
        let chatPerson = chatPersons[indexPath.row]
        
        cell.nameLabel.text = chatPerson.name
        if let urlString = chatPerson.photo
        {
            cell.profileView?.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
        }
        cell.delegate = self
        
        cell.textsLabel?.text = chatPerson.last_message
        cell.lastseenLable?.text = chatPerson.last_message_time
        cell.unreadMessageLabel.text = String(chatPerson.unread_message)
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        return 100
    }
    
}

extension ChatViewController
{
    
    @IBAction func Clicked(sender:AnyObject){
        
        let alertVc = self.storyboard?.instantiateViewControllerWithIdentifier("AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(alertVc!, animated: true)
        
        
    }
    
    func buttonClicked(cell: ChatPersionTableViewCell, button: UIButton)
    {
        if self.tableView.indexPathForCell(cell) != nil
        {
            let indexPath = self.tableView.indexPathForCell(cell)
            let chatPerson = chatPersons[indexPath!.row]
           let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
            chattingViewController?.chatPerson = chatPerson
            
            
            let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatsViewController") as? ChatsViewController
            
            chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
            chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
           // chatVc.channel = channel
            
            //chatVc?.chatPerson = chatPerson
           // chatVc!.channelRef = channelRef.child(String(chatPerson.idString))
            self.navigationController!.pushViewController(chatVc!, animated: true)
        
       // self.navigationController!.pushViewController(chattingViewController!, animated: true)
        }
    }
    
}

extension ChatViewController
{
    func getChatPerosn()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getChatList({ (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.chatPersons = deserializedResponse
                self.tableView.reloadData()
                self.view.removeSpinner()
            })
            }) { (error) in
              
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.view.removeSpinner()
                })
        }
    }
}


extension ChatViewController
{
    // MARK: Firebase related methods
    private func observeChannels()
    {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["name"] as! String! where name.characters.count > 0
            {
                let chatPerson = ChatPerson()
                chatPerson.name = name
                chatPerson.idString = Int(id)!
                self.chatPersons.append(chatPerson)
                // 3
               // self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }


}
