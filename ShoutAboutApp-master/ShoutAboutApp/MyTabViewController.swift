//
//  MyTabViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 19/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class MyTabViewController: UITabBarController, UITabBarControllerDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController)
    {
        
        if let vc = viewController as? UINavigationController
        {
            if let profilevc = vc.viewControllers.first as? NewProfileViewController
            {
                profilevc.personalProfile = ProfileManager.sharedInstance.personalProfile
            }
        }
    }

}

/*curl --header "Authorization: key=AIzaSyCiarKO0nxdVMk2VTJsYGNHK2IrUgdoWlE" --header Content-Type:"application/json" https://fcm.googleapis.com/fcm/send -d "{\"registration_ids\":[\"a08b82ff9e92bca7a5fa33f4c72f05a583996c2ff48cbb69d9312231672a23d4\"]}"
 */
