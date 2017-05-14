//
//  AlertsPostViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 14/05/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class AlertsPostViewController: FeedsViewController
{

    var post_id:String  = ""
    var alert_id:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        segment?.hidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func loadfeedAPICall()
    {
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            displayAlertMessage("No Internet Connection")
        }else
        {
            self.view.showSpinner()
            
            DataSessionManger.sharedInstance.getPostDetail(post_id, alert_id: alert_id, onFinish: { (response, dataFeedsArray) in
                self.view.removeSpinner()
                self.dataFeedsArray.removeAll()
                self.dataFeedsArray = dataFeedsArray
                self.tableView.reloadData()
                
                }, onError: { (error) in
                    self.view.removeSpinner()

                 
            })
        }
    }
}
