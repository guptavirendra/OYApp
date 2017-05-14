

import UIKit

class AlertViewController: UIViewController,AlertTableViewCellProtocol
{
    @IBOutlet weak var tableView:UITableView!
    
    var responseData = AlertModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.ConfigureVariable()
    }
    
    func ConfigureVariable()
    {
        
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        
        let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
        
        _ = [kapp_user_id:String(appUserId), kapp_user_token :appUserToken]
        loadAlertAPICall()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.responseData.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let dataList = responseData.data[indexPath.row]
        let comModel = dataList.post

        if comModel.action != profile_picture
        {
            
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("AlertTableViewCell", forIndexPath: indexPath) as? AlertTableViewCell
        
        
        print(comModel.performed.name)
        print(dataList.action_by.name)
        print(dataList.post.action)
        print(dataList.post.performed.name)
        
        
        cell?.delegate = self
        
        
        let main_string = " \(comModel.performed.name) \(comModel.action) you."
        
        let string_to_color = "\(comModel.action) you."
        
        let range = (main_string as NSString).rangeOfString(string_to_color)
        
        let attributedString = NSMutableAttributedString(string:main_string)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: range)
        
        cell?.nameLabel.attributedText = attributedString
        
        print(comModel.action_val)
        
        cell?.dateLabel.text = dataList.created_at
        cell?.UserImageView.makeImageRounded()
        cell?.contentView.setGraphicEffects()
        return cell!
    }
    
    
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
     {
        let dataList = responseData.data[indexPath.row]
        let alert_id =  String(dataList.id)
        let post_id  =  String(dataList.post.id)
        
        let alertsPostViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AlertsPostViewController") as! AlertsPostViewController
        
       alertsPostViewController.alert_id = alert_id
       alertsPostViewController.post_id  = post_id
        self.navigationController?.pushViewController(alertsPostViewController, animated: true)
        
        
     }
    

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
       
            return 110
    }
    

    // Mohit
    
    @IBAction func reportAtspam(sender: UIButton)
    {
        
        
    }
    
    func loadAlertAPICall()
    {
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            
            displayAlertMessage("No Internet Connection")
            
        }
        else
        {
            
            self.view.showSpinner()
            DataSessionManger.sharedInstance.getAlertlist( { (response, deserializedResponse) in
                print("deserializedResponse \(deserializedResponse)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                self.responseData = deserializedResponse
                
                    for dict in self.responseData.data
                    {
                        print(dict.created_at)
                    }
                    self.tableView.reloadData()
                    self.view.removeSpinner()

                })
                
                }, onError: { (error) in
                    
                    print("error \(error)")
                    dispatch_async(dispatch_get_main_queue(),{
                            self.view.removeSpinner()
                    })
            })
        }
    }
    
    
    
    func picbuttonClicked(cell:AlertTableViewCell, button:UIButton)
    {
        if self.tableView.indexPathForCell(cell) != nil
        {
            if let indexPath = self.tableView.indexPathForCell(cell)
            {
                let dataList = responseData.data[indexPath.row]
                let comModel = dataList.post
                
                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("photopreviewViewController") as? photopreviewViewController
                chatVc!.picname = comModel.performed.photo
                self.navigationController!.pushViewController(chatVc!, animated: true)
            }
        }
    }
    
}
