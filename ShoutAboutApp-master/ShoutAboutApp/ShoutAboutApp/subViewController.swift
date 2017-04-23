//
//  subViewController.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 17/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class subViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableView:UITableView!
    
    
    var choiceArray = [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        choiceArray = ["Faq", "Privacy Policy"]
       
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
   
}


extension subViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return choiceArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
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
        
                if indexPath.row == 0
                {
        
                    self.performSegueWithIdentifier("recent", sender: cell)
                }
        if (indexPath.row == 1)
        {
            self.performSegueWithIdentifier("privacyPolicy", sender: cell)
            
        }
            
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
        
    }
    
}

extension subViewController
{
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if  let vc = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? PrivacyPolicyViewController
        {
            
            
            
        }
    }
}