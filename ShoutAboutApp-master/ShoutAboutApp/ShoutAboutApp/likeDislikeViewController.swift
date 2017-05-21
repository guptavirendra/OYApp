//
//  likeDislikeViewController.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 14/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class likeDislikeViewController: UIViewController
{
    
    @IBOutlet weak var tableView:UITableView!
    var dataFeedMyfeed = dataFeedMyfeedModel()
    var isSelectedDislike:Int = 0
    

    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(dataFeedMyfeed)
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return isSelectedDislike == 0 ? dataFeedMyfeed.likes_user.count : dataFeedMyfeed.dislikes_user.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCellWithIdentifier("AlertTableViewCell", forIndexPath: indexPath) as? AlertTableViewCell
       let commonmodel = isSelectedDislike == 0 ? dataFeedMyfeed.likes_user[indexPath.row] : dataFeedMyfeed.dislikes_user[indexPath.row]
        
        
        
        cell?.nameLabel.text = commonmodel.name.characters.count > 0 ? commonmodel.name : commonmodel.mobileNumber
        //cell?.dateLabel.text = "26-Nov"
        cell?.UserImageView.makeImageRounded()
        if  commonmodel.photo?.characters.count > 0
        {
         cell?.UserImageView.sd_setImageWithURL(NSURL(string:(commonmodel.photo)!), placeholderImage: UIImage(named: "profile"))
        }
        cell?.contentView.setGraphicEffects()
        return cell!
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 110
    }
    
    @IBAction func profileButtonClicked(sender:UIButton)
    {
        if let cell = sender.superview?.superview?.superview as? AlertTableViewCell
        {
            if let indexPath = self.tableView.indexPathForCell(cell)
            {
            
                let commonmodel = isSelectedDislike == 0 ? dataFeedMyfeed.likes_user[indexPath.row] : dataFeedMyfeed.dislikes_user[indexPath.row]
                
                if commonmodel.idString == 0
                {
                    self.displayAlertMessage("It is not in your friend list")
                }else
                {
                   let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
                    profileViewController?.personalProfile = commonmodel
                    profileViewController?.isToGetPersonData = true
                    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                    self.navigationController!.pushViewController(profileViewController!, animated: true)
                }
            }
        }
        
    }
}
