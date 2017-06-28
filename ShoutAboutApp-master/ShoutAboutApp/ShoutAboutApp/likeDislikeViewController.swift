//
//  likeDislikeViewController.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 14/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
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


class likeDislikeViewController: UIViewController
{
    
    @IBOutlet weak var tableView:UITableView!
    var dataFeedMyfeed = dataFeedMyfeedModel()
    var isSelectedDislike:Int = 0
    

    override func viewDidLoad(){
        super.viewDidLoad()
        //self.navigationController!.navigationBar.tintColor = UIColor.white;
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(dataFeedMyfeed)
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return isSelectedDislike == 0 ? dataFeedMyfeed.likes_user.count : dataFeedMyfeed.dislikes_user.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertTableViewCell", for: indexPath) as? AlertTableViewCell
       let commonmodel = isSelectedDislike == 0 ? dataFeedMyfeed.likes_user[indexPath.row] : dataFeedMyfeed.dislikes_user[indexPath.row]
        
        
        
        cell?.nameLabel.text = commonmodel.name.characters.count > 0 ? commonmodel.name : commonmodel.mobileNumber
        //cell?.dateLabel.text = "26-Nov"
        cell?.UserImageView.makeImageRounded()
        if  commonmodel.photo?.characters.count > 0
        {
         //cell?.UserImageView.sd_setImage(with: URL(string:(commonmodel.photo)!), placeholderImage: UIImage(named: "profile"))
        }
        cell?.contentView.setGraphicEffects()
        return cell!
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        
        return 110
    }
    
    @IBAction func profileButtonClicked(_ sender:UIButton)
    {
        if let cell = sender.superview?.superview?.superview as? AlertTableViewCell
        {
            if let indexPath = self.tableView.indexPath(for: cell)
            {
            
                let commonmodel = isSelectedDislike == 0 ? dataFeedMyfeed.likes_user[indexPath.row] : dataFeedMyfeed.dislikes_user[indexPath.row]
                
                if commonmodel.idString == 0
                {
                    self.displayAlertMessage("It is not in your friend list")
                }else
                {
                   let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController
                    profileViewController?.personalProfile = commonmodel
                    profileViewController?.isToGetPersonData = true
                   // self.navigationController?.navigationBar.tintColor = UIColor.white
                    self.navigationController!.pushViewController(profileViewController!, animated: true)
                }
            }
        }
        
    }
}
