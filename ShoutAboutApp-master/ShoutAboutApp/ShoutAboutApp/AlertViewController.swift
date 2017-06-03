

import UIKit

class AlertViewController: UIViewController,AlertTableViewCellProtocol
{
    @IBOutlet weak var tableView:UITableView!
    
    var responseData = AlertModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.white;
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.ConfigureVariable()
    }
    
    func ConfigureVariable()
    {
        
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        
        let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
        
        _ = [kapp_user_id:String(appUserId), kapp_user_token :appUserToken]
        loadAlertAPICall()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.responseData.data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        let dataList = responseData.data[indexPath.row]
        let comModel = dataList.post

        if comModel.action != profile_picture
        {
            
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertTableViewCell", for: indexPath) as? AlertTableViewCell
        
        
        print(comModel.performed.name)
        print(dataList.action_by.name)
        print(dataList.post.action)
        print(dataList.post.performed.name)
        
        
        cell?.delegate = self
        
        
        let main_string = " \(comModel.performed.name) \(comModel.action) you."
        
        let string_to_color = "\(comModel.action) you."
        
        let range = (main_string as NSString).range(of: string_to_color)
        
        let attributedString = NSMutableAttributedString(string:main_string)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
        
        cell?.nameLabel.attributedText = attributedString
        
        print(comModel.action_val)
        
        cell?.dateLabel.text = dataList.created_at
        cell?.UserImageView.makeImageRounded()
        cell?.contentView.setGraphicEffects()
        return cell!
    }
    
    
    
     func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
     {
        let dataList = responseData.data[indexPath.row]
        let alert_id =  String(dataList.id)
        let post_id  =  String(dataList.post.id)
        
        let alertsPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "AlertsPostViewController") as! AlertsPostViewController
        
       alertsPostViewController.alert_id = alert_id
       alertsPostViewController.post_id  = post_id
        self.navigationController?.pushViewController(alertsPostViewController, animated: true)
        
        
     }
    

    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
       
            return 110
    }
    

    // Mohit
    
    @IBAction func reportAtspam(_ sender: UIButton)
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
                
                DispatchQueue.main.async(execute: {
                    
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
                    DispatchQueue.main.async(execute: {
                            self.view.removeSpinner()
                    })
            })
        }
    }
    
    
    
    func picbuttonClicked(_ cell:AlertTableViewCell, button:UIButton)
    {
        if self.tableView.indexPath(for: cell) != nil
        {
            if let indexPath = self.tableView.indexPath(for: cell)
            {
                let dataList = responseData.data[indexPath.row]
                let comModel = dataList.post
                
                let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "photopreviewViewController") as? photopreviewViewController
                chatVc!.picname = comModel.performed.photo
                self.navigationController!.pushViewController(chatVc!, animated: true)
            }
        }
    }
    
}
