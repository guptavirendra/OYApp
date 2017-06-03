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
         self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = false
        
        choiceArray = ["Term of Use", "Privacy Policy"]
       
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
   
}


extension subViewController
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return choiceArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as? settingCell
        
        let text = choiceArray[indexPath.row]
        cell?.nameLabel.textColor = UIColor.darkGray
        cell?.nameLabel?.text = text
        if indexPath.row == 0
        {
            cell?.iconView.image  =  UIImage(named: "term")
        }else
        {
            cell?.iconView.image  =  UIImage(named: "privacy")
            
        }
        cell?.textLabel?.font = UIFont(name: "TitilliumWeb-Regular", size: 18)
        //        cell?.contentView.setGraphicEffects()
        return cell!
        
    }
    
    //MARK: SELECTION
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
       
        
        
        
        if indexPath.row == 0
        {
            vc.selection = 0
           // self.performSegueWithIdentifier("recent", sender: cell)
        }
        if (indexPath.row == 1)
        {
            vc.selection = 1
           // self.performSegueWithIdentifier("privacyPolicy", sender: cell)
            
        }
        
         self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
        
    }
    
}

extension subViewController
{
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if  let vc = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? PrivacyPolicyViewController
        {
            
            
            
        }
    }
    */
}
