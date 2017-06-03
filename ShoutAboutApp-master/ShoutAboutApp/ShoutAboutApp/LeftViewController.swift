//
//  LeftViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var mobileLabel:UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.nameLabel.text = ProfileManager.sharedInstance.personalProfile.name
         self.mobileLabel.text = ProfileManager.sharedInstance.personalProfile.mobileNumber
        // else need to update
        if ProfileManager.sharedInstance.localStoredImage != nil
        {
            
            self.profileImageView.image = ProfileManager.sharedInstance.localStoredImage
            
        }else
        {
            if let photo  = ProfileManager.sharedInstance.personalProfile.photo{
                setProfileImgeForURL(photo)
            }
             
        }
    }
    
    func setProfileImgeForURL(_ urlString:String)
    {
        //self.profileImageView.sd_setImage(with: URL(string:urlString ), placeholderImage: UIImage(named: "profile_pic"))
    }
}


extension LeftViewController
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return choiceArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
//        let text = choiceArray[indexPath.row]
////        cell.textLabel?.text = text
//        cell.textLabel?.font = UIFont(name: "TitilliumWeb-Regular", size: 18)
////        cell.textLabel?.textColor = UIColor.darkGrayColor()
//        cell.imageView?.image = UIImage(named: text)
//        return cell
        
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as? settingCell
        
        let text = choiceArray[indexPath.row]
        cell?.nameLabel.textColor = UIColor.darkGray
        cell?.nameLabel?.text = text
        cell?.iconView.image  = UIImage(named: text)?.withRenderingMode(.alwaysTemplate)
        cell?.iconView.tintColor = UIColor.gray
        cell?.textLabel?.font = UIFont(name: "TitilliumWeb-Regular", size: 18)
//        cell?.contentView.setGraphicEffects()
        return cell!
        
        
        
        
    }
    
    //MARK: SELECTION
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       
        if (indexPath.row == 0 ||  indexPath.row == 1 || indexPath.row == 2)
        {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpamFavBlockViewController") as! SpamFavBlockViewController
            if indexPath.row == 0
            {
                vc.favSpamBlock = .block
            }
            if indexPath.row == 1
            {
                vc.favSpamBlock = .spam
            }
            if indexPath.row == 2
            {
                vc.favSpamBlock = .fav
            }
            self.navigationController?.pushViewController(vc, animated: true)
             //self.performSegueWithIdentifier("spam", sender: self)
            
        }
            
        if (indexPath.row == 3)
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "subViewController") as! subViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        else if indexPath.row == 5
        {
            if ((FBSDKAccessToken.current()) != nil)
            {
                //let fbRequest = FBRequest()
                //fbRequest.logoutFacebook()
            }
            
             
            UserDefaults.standard.removeObject(forKey: kapp_user_id)
            UserDefaults.standard.removeObject(forKey: kapp_user_token)
            UserDefaults.standard.removeObject(forKey: contactStored)
            
            let vc = self.storyboard?.instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
            appDelegate.window?.rootViewController = vc
            appDelegate.window?.makeKeyAndVisible()
            
        }else
        {
           
          
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
        
    }
    
}

extension LeftViewController
{
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?)
     {
        if  let vc = (segue.destination as? UINavigationController)?.viewControllers.first as? SpamFavBlockViewController
        {
        
            if let cell = sender as? UITableViewCell
            {
                if let  indexPath = tableView.indexPath(for: cell)
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
    
    
    @IBAction func editProfileButtonCliceked(_ sender:UIButton)
    {
    
       let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        profileViewController.personalProfile = ProfileManager.sharedInstance.personalProfile
        profileViewController.isViewPresented = true
         let navigation = UINavigationController(rootViewController: profileViewController)
        
        self.present(navigation, animated: true, completion:
            {
                
            })
    }
}
