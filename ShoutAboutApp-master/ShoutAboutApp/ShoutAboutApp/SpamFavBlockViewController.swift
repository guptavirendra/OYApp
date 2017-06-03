//
//  SpamFavBlockViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 08/01/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
enum FavSpamBlock
{
    case fav
    case spam
    case block
}

class SpamFavBlockViewController: UIViewController
{
    @IBOutlet weak var menuButton: UIBarButtonItem?
    @IBOutlet weak var tableView:UITableView?
    var favSpamBlock:FavSpamBlock = .fav
    var allValidContacts = [SearchPerson]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        /*if self.revealViewController() != nil
        {
            menuButton!.target = self.revealViewController()
            menuButton!.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        */
        
        switch favSpamBlock
        {
            case .fav:
                self.title = "Favorite"
                favoriteList()
                break
            case .spam:
                self.title = "Spam"
                spamList()
                break
            case .block:
                self.title = "Block"
                blockList()
                break

        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func popVC()
    {
        self.revealViewController().rearViewRevealWidth = 60
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func blockList()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getBlockUserList({ (response, blockUserArray) in
            
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.allValidContacts.removeAll()
                self.allValidContacts = blockUserArray
               self.tableView?.reloadData()
            });
            
            }) { (error) in
                
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                });
            }
    }
    
    
    func unBlock(_ userId:String)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.unblockUserID(userId, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.blockList()
                
            });
            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    
    
    func favoriteList()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getUserfavoriteList({ (response, favUserArray) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.allValidContacts.removeAll()
                self.allValidContacts = favUserArray
                self.tableView?.reloadData()
                
            });
            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    
    
    func unFavorite(_ userId:String)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.unfavouriteUserID(userId, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.favoriteList()
                
            });
            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    func spamList()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getUserSpamList({ (response, spamUserArray) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.allValidContacts.removeAll()
                self.allValidContacts = spamUserArray
                self.tableView?.reloadData()
            });
            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    
    func unSpam(_ userId:String)
    {
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.unspamUserID(userId, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.spamList()
                
            });

            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    
                    
                });

        }
    }
    
}
extension SpamFavBlockViewController:ContactTableViewCellProtocol
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  allValidContacts.count //objects.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact", for: indexPath) as! ContactTableViewCell
        cell.delegate = self
        
        let personContact = allValidContacts[indexPath.row]
        cell.nameLabel?.text = personContact.name
        cell.mobileLabel?.text = personContact.mobileNumber
        if let urlString = personContact.photo
        {
            
            ///cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
        }else
        {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        
        
        
        switch favSpamBlock
        {
        case .fav:
            cell.blockButton?.setTitle("UnFavorite", for: UIControlState())
            cell.blockButton?.setImage(UIImage( named: "unfav"), for: UIControlState())
            break
        case .spam:
            cell.blockButton?.setTitle("UnSpam", for: UIControlState())
            cell.blockButton?.setImage(UIImage( named: "spamGray"), for: UIControlState())
            
            break
        case .block:
             cell.blockButton?.setTitle("UnBlock", for: UIControlState())
             cell.blockButton?.setImage(UIImage( named: "unblock"), for: UIControlState())
            break
            
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
        if self.tableView!.indexPath(for: cell) != nil
        {
            let indexPath = self.tableView!.indexPath(for: cell)
            let personContact = allValidContacts[indexPath!.row]
            if button.titleLabel?.text == " Call"
            {
                
                let   phone = "tel://"+personContact.mobileNumber
                UIApplication.shared.openURL(URL(string: phone)!)
            }
            else if button.titleLabel?.text == " Chat"
            {
                let chattingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChattingViewController") as? ChattingViewController
                self.navigationController!.pushViewController(chattingViewController!, animated: true)
                
            }
            else if button.titleLabel?.text == "reviews"
            {
                
                let personContact = allValidContacts[(indexPath?.row)!]
                let rateANdReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateANdReviewViewController") as? RateANdReviewViewController
                rateANdReviewViewController?.idString = String(personContact.idString)
                rateANdReviewViewController?.name = personContact.name
                if let _ = personContact.photo
                {
                    rateANdReviewViewController?.photo = personContact.photo!
                }
                self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
                
                
            }
                
            else if button.titleLabel?.text == "UnFavorite" || button.titleLabel?.text == "UnSpam" || button.titleLabel?.text == "UnBlock"
            {
                
                switch favSpamBlock
                {
                case .fav:
                    
                     unFavorite(String(personContact.idString))
                    break
                case .spam:
                    
                    unSpam(String(personContact.idString))
                    break
                case .block:
                    
                    unBlock(String(personContact.idString))
                    break
                    
                }
                
                
            }
            
            else
            {
                let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController
                profileViewController?.personalProfile = personContact
                
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
    }
}
