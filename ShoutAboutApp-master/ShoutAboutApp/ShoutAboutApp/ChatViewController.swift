//
//  ChatViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import Firebase
import XMPPFramework
import xmpp_messenger_ios

class ChatViewController: UIViewController, ChatPersionTableViewCellProtocol
{
    
    fileprivate lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    fileprivate var channelRefHandle: FIRDatabaseHandle?


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
            channelRef.removeObserver(withHandle: refHandle)
            
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
    
    override func viewWillAppear(_ animated: Bool)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatPersons.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatPersionTableViewCell", for: indexPath) as! ChatPersionTableViewCell
        
        let chatPerson = chatPersons[indexPath.row]
        
        cell.nameLabel.text = chatPerson.name
        if chatPerson.photo != nil
        {
            //cell.profileView?.setImageWith(URL(string:urlString ), placeholderImage: UIImage(named: "profile"))
        }
        cell.delegate = self
        
        cell.textsLabel?.text = chatPerson.last_message
        cell.lastseenLable?.text = chatPerson.last_message_time
        cell.unreadMessageLabel.text = String(chatPerson.unread_message)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        
        return 100
    }
    
}

extension ChatViewController
{
    
    @IBAction func Clicked(_ sender:AnyObject){
        
        let alertVc = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(alertVc!, animated: true)
        
        
    }
    
    func buttonClicked(_ cell: ChatPersionTableViewCell, button: UIButton)
    {
        if self.tableView.indexPath(for: cell) != nil
        {
            let indexPath = self.tableView.indexPath(for: cell)
            let chatPerson = chatPersons[indexPath!.row]
            
                    let stringID = String(chatPerson.idString)
                    let ejabberID = stringID+"@localhost"
                    let user =  OneRoster.userFromRosterForJID(jid: ejabberID)
                    print("\(OneRoster.buddyList.sections)")
                    //let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                    
                    //let user =   OneRoster.userFromRosterAtIndexPath(indexPath: indexPath!)
                    
                    let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatsViewController") as? ChatsViewController
                    
                    chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
                    chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
                    chatVc?.reciepientPerson         = chatPerson
                    chatVc?.recipient = user
                    self.navigationController!.pushViewController(chatVc!, animated: true)
                    
            
        }
    }
    
}

extension ChatViewController
{
    func getChatPerosn()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getChatList({ (response, deserializedResponse) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.chatPersons = deserializedResponse
                self.tableView.reloadData()
                self.view.removeSpinner()
            })
            }) { (error) in
              
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                    self.view.removeSpinner()
                })
        }
    }
}


extension ChatViewController
{
    // MARK: Firebase related methods
    fileprivate func observeChannels()
    {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0
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
