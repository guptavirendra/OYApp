//
//  MainSearchViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 19/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class MainSearchViewController: UIViewController, ContactTableViewCellProtocol
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton:UIButton!
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var clearButtonBaseView:UIView!
    
    var allValidContacts = [SearchPerson]()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
       // self.tableView.addBackGroundImageView()
        
        if self.revealViewController() != nil
        {
            self.revealViewController().getProfileData()
//            menuButton.target = self.revealViewController()
//            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
//            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        self.searchButton.setImage(UIImage(named: "tab_search-h@x")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        self.searchButton.tintColor = UIColor.grayColor()

        
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
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
            
            let personContact = allValidContacts[indexPath.row]
            cell.nameLabel?.text = personContact.name
            cell.mobileLabel?.text = personContact.mobileNumber
        if let urlString = personContact.photo
        {
            
            cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
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
                let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                self.navigationController!.pushViewController(chattingViewController!, animated: true)
                
            }
            else if button.titleLabel?.text == "reviews"
            {
                
                let personContact = allValidContacts[(indexPath?.row)!]
                let rateANdReviewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RateANdReviewViewController") as? RateANdReviewViewController
                rateANdReviewViewController?.idString = String(personContact.idString)
                rateANdReviewViewController?.name = personContact.name
                if let _ = personContact.photo
                {
                    rateANdReviewViewController?.photo = personContact.photo!
                }
                self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
                
                
            }else{
                let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
                profileViewController?.personalProfile = personContact
                
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
    
    
   
    
   @IBAction func displayClearAlert(){
    
        let alert = UIAlertController(title: "Clear Recent Searchs", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            self.clearSearchHistory()
        }
    
        let cancelAction =  UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
}
