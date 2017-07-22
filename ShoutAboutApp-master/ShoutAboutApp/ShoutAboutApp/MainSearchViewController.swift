
//
//  MainSearchViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 19/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import TSMessages
//import ReactiveCocoa
import XMPPFramework
import xmpp_messenger_ios

class MainSearchViewController: UIViewController, ContactTableViewCellProtocol
{
    
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
        self.navigationController?.isNavigationBarHidden = true
        self.searchButton.setImage(UIImage(named: "tab_search-h@x")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        self.searchButton.tintColor = UIColor.gray
        
        
        
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id)
        let stringID = String(describing: appUserId!)
        let ejabberID = stringID+"@localhost"
        
        
        OneChat.sharedInstance.connect(username: ejabberID, password: "12345") { (stream, error) -> Void in
            if let _ = error
            {
                let alertController = UIAlertController(title: "Sorry", message: "An error occured: \(String(describing: error))", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                    //do something
                }))
                self.present(alertController, animated: true, completion: nil)
            } else
            {
                
            }
        }
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.isHidden = false
         self.navigationController?.isNavigationBarHidden = true
        if let historydata = self.retrievePearson()
        {
            
            allValidContacts = historydata.reversed()
            self.tableView.reloadData()
            
        }
        enableDisableClearButton()
       
        
    }
    func retrievePearson() -> [SearchPerson]?
    {
        if let unarchivedObject = UserDefaults.standard.object(forKey: searchHistory) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [SearchPerson]
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

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        //self.getProfileData()
    }
    
   
    
    
}

extension MainSearchViewController
{
    @IBAction func searchButtonClicked(_ button:UIButton)
    {
        
        let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        let nav = UINavigationController(rootViewController: searchViewController!)
        // nav.navigationBar.barTintColor = appColor
        self.present(nav, animated: true, completion: nil)
        //self.navigationController!.pushViewController(searchViewController!, animated: true)
        
    }
}

extension MainSearchViewController
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  allValidContacts.count //objects.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact", for: indexPath) as! ContactTableViewCell
        cell.delegate = self
        
        let personContact = self.allValidContacts[indexPath.row]
        cell.nameLabel?.text = personContact.name
        cell.mobileLabel?.text = personContact.mobileNumber
        
        //cell.rateView!.rating =  personContact.reviewCount.count
        //cell.ratingLabel.text = String(personContact.reviewCount.count) + "/5"
        
        // if personContact.app_user_token != nil
        // {
        cell.revieBbutton!.isHidden = false
        cell.rateView?.isHidden    = false
        cell.ratingLabel!.isHidden  = false
        
        if let count = personContact.reviewCount.first?.count
        {
            
            let title:String = String(count) + " reviews"
            cell.revieBbutton!.setTitle(title, for: UIControlState())
        }else
        {
            let title:String = String(0) + " reviews"
            cell.revieBbutton!.setTitle(title, for: UIControlState())
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
            
            cell.profileImageView.sd_setImage(with: URL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
        }else
        {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return 100.0
        
    }
    
    //MARK: CALL
    func buttonClicked(_ cell: ContactTableViewCell, button: UIButton)
    {
        if self.tableView.indexPath(for: cell) != nil
        {
            let indexPath = self.tableView.indexPath(for: cell)
            let personContact = allValidContacts[indexPath!.row]
            if button.titleLabel?.text == " Call"
            {
                let personContact = allValidContacts[indexPath!.row]
                let   phone = "tel://"+personContact.mobileNumber
                UIApplication.shared.openURL(URL(string: phone)!)
            }
            else if button.titleLabel?.text == " Chat"
            {
                let stringID = String(personContact.idString)
                let ejabberID = stringID+"@localhost"
                let user =  OneRoster.userFromRosterForJID(jid: ejabberID)
                print("\(String(describing: OneRoster.buddyList.sections))")
                //let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                
                //let user =   OneRoster.userFromRosterAtIndexPath(indexPath: indexPath!)
                
                let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatsViewController") as? ChatsViewController
                chatVc?.hidesBottomBarWhenPushed = true

                
                chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
                chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
                chatVc?.reciepientPerson         = personContact
                chatVc?.recipient = user
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController!.pushViewController(chatVc!, animated: true)
                
            }
            else if ((button.titleLabel?.text?.contains("reviews")) != nil)
            {
                
                let personContact = allValidContacts[(indexPath?.row)!]
                let rateANdReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateANdReviewViewController") as? RateANdReviewViewController
                rateANdReviewViewController?.idString = String(personContact.idString)
                rateANdReviewViewController?.name = personContact.name
                if let _ = personContact.photo
                {
                    rateANdReviewViewController?.photo = personContact.photo!
                }
               // self.navigationController?.navigationBar.tintColor = appColor
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
                
                
            }else
            {
                let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController
                profileViewController?.personalProfile = personContact
               // self.navigationController?.navigationBar.tintColor = appColor
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
    }
}

extension MainSearchViewController
{
    @IBAction func Clicked(_ sender:AnyObject)
    {
        
        let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(chatVc!, animated: true)
        
}
    
    
     func clearSearchHistory(){
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: searchHistory)
        
        defaults.synchronize()
        allValidContacts.removeAll()
        self.tableView.reloadData()
        enableDisableClearButton()
        
    }
    
    func enableDisableClearButton()
    {
        if allValidContacts.count > 0
        {
            self.clearButtonBaseView.isHidden = false
            clearButton.isUserInteractionEnabled = true
            clearButton.alpha   = 1.0
        }else
        {
            self.clearButtonBaseView.isHidden = true
            clearButton.isUserInteractionEnabled = false
            clearButton.alpha   = 0.5
        }
    }
    
    @IBAction func displayClearAlert()
   {
    
        let alert = UIAlertController(title: "Clear Recent Searchs", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Yes", style: .default)
        { (action) in
            self.clearSearchHistory()
        }
    
        let cancelAction =  UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
