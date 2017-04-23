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
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()]
        if self.revealViewController() != nil
        {
            menuButton!.target = self.revealViewController()
            menuButton!.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
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
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func blockList()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getBlockUserList({ (response, blockUserArray) in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.allValidContacts.removeAll()
                self.allValidContacts = blockUserArray
               self.tableView?.reloadData()
            });
            
            }) { (error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                });
            }
    }
    
    
    func unBlock(userId:String)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.unblockUserID(userId, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.blockList()
                
            });
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    
    
    func favoriteList()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getUserfavoriteList({ (response, favUserArray) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.allValidContacts.removeAll()
                self.allValidContacts = favUserArray
                self.tableView?.reloadData()
                
            });
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    
    
    func unFavorite(userId:String)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.unfavouriteUserID(userId, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.favoriteList()
                
            });
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    func spamList()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getUserSpamList({ (response, spamUserArray) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.allValidContacts.removeAll()
                self.allValidContacts = spamUserArray
                self.tableView?.reloadData()
            });
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                    
                    
                });
        }
    }
    
    func unSpam(userId:String)
    {
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.unspamUserID(userId, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.spamList()
                
            });

            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                    
                    
                });

        }
    }
    
}
extension SpamFavBlockViewController:ContactTableViewCellProtocol
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
        
        
        
        switch favSpamBlock
        {
        case .fav:
            cell.blockButton?.setTitle("UnFavorite", forState: .Normal)
            cell.blockButton?.setImage(UIImage( named: "Favorites"), forState: .Normal)
            break
        case .spam:
            cell.blockButton?.setTitle("UnSpam", forState: .Normal)
            cell.blockButton?.setImage(UIImage( named: "Spam"), forState: .Normal)
            
            break
        case .block:
             cell.blockButton?.setTitle("UnBlock", forState: .Normal)
             cell.blockButton?.setImage(UIImage( named: "Block"), forState: .Normal)
            break
            
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
        if self.tableView!.indexPathForCell(cell) != nil
        {
            let indexPath = self.tableView!.indexPathForCell(cell)
            let personContact = allValidContacts[indexPath!.row]
            if button.titleLabel?.text == " Call"
            {
                
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
                let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
                profileViewController?.personalProfile = personContact
                
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
    }
}
