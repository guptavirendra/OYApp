//
//  MainSearchViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 19/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import TSMessages
import ReactiveCocoa
import XMPPFramework
import xmpp_messenger_ios

class MainSearchViewController: UIViewController, ContactTableViewCellProtocol
{
    var xmppClient: STXMPPClient?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton:UIButton!
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var clearButtonBaseView:UIView!
    
    var allValidContacts = [SearchPerson]()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.searchButton.layer.cornerRadius = 5.0
        self.navigationController?.navigationBarHidden = true
        self.searchButton.setImage(UIImage(named: "tab_search-h@x")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.searchButton.tintColor = UIColor.grayColor()
        
        
        
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id)
        let stringID = String(appUserId!)
        let ejabberID = stringID+"@localhost"
        
        
        OneChat.sharedInstance.connect(username: ejabberID, password: "12345") { (stream, error) -> Void in
            if let _ = error
            {
                let alertController = UIAlertController(title: "Sorry", message: "An error occured: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    //do something
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else
            {
                
            }
        }
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
         self.navigationController?.navigationBarHidden = true
        if let historydata = self.retrievePearson()
        {
            
            allValidContacts = historydata.reverse()
            self.tableView.reloadData()
            
        }
        enableDisableClearButton()
       
        
    }
    func retrievePearson() -> [SearchPerson]?
    {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(searchHistory) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [SearchPerson]
        }
        return nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.getProfileData()
    }
    
   
    
    
}

extension MainSearchViewController
{
    @IBAction func searchButtonClicked(button:UIButton)
    {
        
        let searchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as? SearchViewController
        let nav = UINavigationController(rootViewController: searchViewController!)
         nav.navigationBar.barTintColor = appColor
        self.presentViewController(nav, animated: true, completion: nil)
        //self.navigationController!.pushViewController(searchViewController!, animated: true)
        
    }
}

extension MainSearchViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  allValidContacts.count //objects.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("contact", forIndexPath: indexPath) as! ContactTableViewCell
        cell.delegate = self
        
        let personContact = self.allValidContacts[indexPath.row]
        cell.nameLabel?.text = personContact.name
        cell.mobileLabel?.text = personContact.mobileNumber
        
        //cell.rateView!.rating =  personContact.reviewCount.count
        //cell.ratingLabel.text = String(personContact.reviewCount.count) + "/5"
        
        // if personContact.app_user_token != nil
        // {
        cell.revieBbutton!.hidden = false
        cell.rateView?.hidden    = false
        cell.ratingLabel!.hidden  = false
        
        if let count = personContact.reviewCount.first?.count
        {
            
            let title:String = String(count) + " reviews"
            cell.revieBbutton!.setTitle(title, forState: .Normal)
        }else
        {
            let title:String = String(0) + " reviews"
            cell.revieBbutton!.setTitle(title, forState: .Normal)
        }
        if let ratingAverage = personContact.ratingAverage.first?.average
        {
            cell.rateView!.rating = Int(Float(ratingAverage)!)
            cell.ratingLabel!.text   =  String(cell.rateView!.rating) + "/5"
        }else
        {
            cell.rateView!.rating =  0
            cell.ratingLabel!.text   =  String(cell.rateView!.rating) + "/5"
        }
        
        //}else
        //{
        //cell.revieBbutton.hidden = true
        //cell.rateView?.hidden    = true
        //cell.ratingLabel.hidden  = true
        
        //}
        
        
        
        if let urlString = personContact.photo
        {
            
            cell.profileImageView.sd_setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
        }else
        {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0
        
    }
    
    //MARK: CALL
    func buttonClicked(cell: ContactTableViewCell, button: UIButton)
    {
        if self.tableView.indexPathForCell(cell) != nil
        {
            let indexPath = self.tableView.indexPathForCell(cell)
            let personContact = allValidContacts[indexPath!.row]
            if button.titleLabel?.text == " Call"
            {
                let personContact = allValidContacts[indexPath!.row]
                let   phone = "tel://"+personContact.mobileNumber
                UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
            }
            else if button.titleLabel?.text == " Chat"
            {
                let stringID = String(personContact.idString)
                let ejabberID = stringID+"@localhost"
                let user =  OneRoster.userFromRosterForJID(jid: ejabberID)
                print("\(OneRoster.buddyList.sections)")
                //let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                
                //let user =   OneRoster.userFromRosterAtIndexPath(indexPath: indexPath!)
                
                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatsViewController") as? ChatsViewController
                
                chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
                chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
                chatVc?.reciepientPerson         = personContact
                chatVc?.recipient = user
                self.navigationController?.navigationBarHidden = false
                self.navigationController!.pushViewController(chatVc!, animated: true)
                
            }
            else if ((button.titleLabel?.text?.containsString("reviews")) != nil)
            {
                
                let personContact = allValidContacts[(indexPath?.row)!]
                let rateANdReviewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RateANdReviewViewController") as? RateANdReviewViewController
                rateANdReviewViewController?.idString = String(personContact.idString)
                rateANdReviewViewController?.name = personContact.name
                if let _ = personContact.photo
                {
                    rateANdReviewViewController?.photo = personContact.photo!
                }
                self.navigationController?.navigationBar.tintColor = appColor
                self.navigationController?.navigationBar.hidden = false
                self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
                
                
            }else
            {
                let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
                profileViewController?.personalProfile = personContact
               // self.navigationController?.navigationBar.tintColor = appColor
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
    }
}

extension MainSearchViewController
{
    @IBAction func Clicked(sender:AnyObject)
    {
        
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(chatVc!, animated: true)
        
}
    
    
     func clearSearchHistory(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(searchHistory)
        
        defaults.synchronize()
        allValidContacts.removeAll()
        self.tableView.reloadData()
        enableDisableClearButton()
        
    }
    
    func enableDisableClearButton()
    {
        if allValidContacts.count > 0
        {
            self.clearButtonBaseView.hidden = false
            clearButton.userInteractionEnabled = true
            clearButton.alpha   = 1.0
        }else
        {
            self.clearButtonBaseView.hidden = true
            clearButton.userInteractionEnabled = false
            clearButton.alpha   = 0.5
        }
    }
    
    @IBAction func displayClearAlert()
   {
    
        let alert = UIAlertController(title: "Clear Recent Searchs", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Yes", style: .Default)
        { (action) in
            self.clearSearchHistory()
        }
    
        let cancelAction =  UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
