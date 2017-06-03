//
//  PrivacyPolicyViewController.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 16/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var myWebView: UIWebView!
    
    var selection:Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
        
        var urlString:String = "http://oyapp.in/terms-of-use"
        if selection == 1
        {
            urlString = "http://oyapp.in/privacy-policy"
            
        }
        myWebView.loadRequest(URLRequest(url: URL(string: urlString)!))
        
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

}
