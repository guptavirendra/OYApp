//
//  LeftViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    
    var choiceArray = [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        choiceArray = ["Block", "Spam", "Favorites", "Settings", "Premium", "Logout"]
        profileImageView.makeImageRounded()
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.nameLabel.text = ProfileManager.sharedInstance.personalProfile.name
        // else need to update
        if ProfileManager.sharedInstance.localStoredImage != nil{
            
            self.profileImageView.image = ProfileManager.sharedInstance.localStoredImage
            
        }else{
            if let photo  = ProfileManager.sharedInstance.personalProfile.photo{
                setProfileImgeForURL(photo)
            }
             
        }
    }
    
    func setProfileImgeForURL(urlString:String){
        self.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile_pic"))
    }
}


extension LeftViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return choiceArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
//        let text = choiceArray[indexPath.row]
////        cell.textLabel?.text = text
//        cell.textLabel?.font = UIFont(name: "TitilliumWeb-Regular", size: 18)
////        cell.textLabel?.textColor = UIColor.darkGrayColor()
//        cell.imageView?.image = UIImage(named: text)
//        return cell
        
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingCell", forIndexPath: indexPath) as? settingCell
        
        let text = choiceArray[indexPath.row]
        cell?.nameLabel.textColor = UIColor.darkGrayColor()
        cell?.nameLabel?.text = text
        cell?.textLabel?.font = UIFont(name: "TitilliumWeb-Regular", size: 18)
//        cell?.contentView.setGraphicEffects()
        return cell!
        
        
        
        
    }
    
    //MARK: SELECTION
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
       let cell = tableView.cellForRowAtIndexPath(indexPath)
        
//        if indexPath.row == 0
//        {
//            
//            self.performSegueWithIdentifier("recent", sender: cell)
//        }
        
         if (indexPath.row == 0 ||  indexPath.row == 1 || indexPath.row == 2)
        {
             self.performSegueWithIdentifier("spam", sender: cell)
            
        }
            
        if (indexPath.row == 3)
        {
            self.performSegueWithIdentifier("setting", sender: cell)
            
        }
        
        else if indexPath.row == 6
        {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kapp_user_id)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kapp_user_token)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(contactStored)
            
            let vc = self.storyboard?.instantiateInitialViewController()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
            appDelegate.window?.rootViewController = vc
            appDelegate.window?.makeKeyAndVisible()
            
        }else
        {
           
          
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
        
    }
    
}

extension LeftViewController
{
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
     {
        if  let vc = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? SpamFavBlockViewController
        {
        
            if let cell = sender as? UITableViewCell
            {
                if let  indexPath = tableView.indexPathForCell(cell)
                {
                    if indexPath.row == 1
                    {
                        vc.favSpamBlock = .block
                    }
                    if indexPath.row == 2
                    {
                        vc.favSpamBlock = .spam
                    }
                    if indexPath.row == 3
                    {
                        vc.favSpamBlock = .fav
                    }
                }
            }
        }
    }
}
