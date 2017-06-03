

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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class FeedsViewController: UIViewController,FeedsTableViewCellProtocol
{

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var locationLabel:UILabel?
    @IBOutlet weak var segment:UISegmentedControl?
    var dataFeedsArray:[dataFeedMyfeedModel] = [dataFeedMyfeedModel]()
    
    
    @IBOutlet weak var countLabel:UILabel?
    @IBOutlet weak var countBackView:UIView?
    
    
    var responseData    = FeedMyfeed()
   // var dataFeedMyfeed  = dataFeedMyfeedModel()
    var msgresponseData = AlertCountCommonModel()
    var dict = [String:String]()
    var segmentIndex: Int!
    var appUserId:Int = 0
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.countBackView?.makeImageRoundedWithWidth(1, color: UIColor.red)
        self.automaticallyAdjustsScrollViewInsets = false
        self.ConfigureVariable()
        self.loadfeedAPICall()
        segmentIndex = 0
    }
    
    
    func ConfigureVariable()
    {
        appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
        dict = [kapp_user_id:String(appUserId),kapp_user_token :appUserToken]
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        getAlertCount()
        
    }
    
    
    func getAlertCount()
    {
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            
        }else
        {
            DataSessionManger.sharedInstance.getAlertCount({ (response, deserializedResponse) in
                
                if let alert_count = deserializedResponse.object(forKey: "alert_count") as? NSNumber
                {
                    ProfileManager.sharedInstance.alert_count = alert_count.intValue
                    self.countLabel?.text = alert_count.stringValue
                    
                    
                }
                
                }, onError: { (error) in
                    
            })
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
         return dataFeedsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        let dataFeedMyfeed = dataFeedsArray[indexPath.row]
        if dataFeedMyfeed.action != profile_picture
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyFeedsTableViewCell", for: indexPath) as? FeedsTableViewCell
            cell?.delegate = self
            cell?.contentView.setGraphicEffects()
            self.configureReviewCellData(cell!, dataFeedMyfeed: dataFeedMyfeed)
          return cell!
        }
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFeedsTableViewCell1", for: indexPath) as? FeedsTableViewCell
        cell?.contentView.setGraphicEffects()
        cell?.delegate = self
        
        self.configureProfileCellData(cell!, dataFeedMyfeed: dataFeedMyfeed)
        return cell!
    }
    
    func configureReviewCellData(_ cell:FeedsTableViewCell,dataFeedMyfeed: dataFeedMyfeedModel)
    {
       
        // by performed person
        if let _ =  dataFeedMyfeed.performed.photo
        {
        //cell.RUserImageView.sd_setImage(with: URL(string:dataFeedMyfeed.performed.photo!), placeholderImage: UIImage(named: "profile"))
        }
        cell.RUserImageView.makeImageRounded()
        
        if dataFeedMyfeed.action == "reviewed"
        {
            
            let reviewAttributeString = NSMutableAttributedString(string: (appUserId == dataFeedMyfeed.performed.idString ? "You":dataFeedMyfeed.performed.name))
            reviewAttributeString.addAttribute(NSForegroundColorAttributeName, value: appColor, range: NSRange(location: 0, length:reviewAttributeString.length ))
            
            let reviewAttributeStrings = NSMutableAttributedString(string:" reviewed")
            reviewAttributeStrings.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length:reviewAttributeStrings.length ))
            reviewAttributeString.append(reviewAttributeStrings)
            
            // name of performed person
            cell.RdescriptionLabel.attributedText  = reviewAttributeString
            
            if  dataFeedMyfeed.action_val.characters.count > 0
            {
                cell.ratingView.rating = Int(Float(dataFeedMyfeed.action_val)!)
                
            }else
            {
                cell.ratingView.rating = 0
                
            }
        }
        
        // effected person profile picture
        if let _ = dataFeedMyfeed.effected.photo
        {
            //cell.UserImageView.sd_setImage(with: URL(string:dataFeedMyfeed.effected.photo!), placeholderImage: UIImage(named: "profile"))
        }
        cell.UserImageView.makeImageRounded()
        
        let reviewAttributeString = NSMutableAttributedString(string:            dataFeedMyfeed.effected.name)
        reviewAttributeString.addAttribute(NSForegroundColorAttributeName, value: appColor, range: NSRange(location: 0, length:reviewAttributeString.length ))
        
        // effected person name
        cell.nameLabel.attributedText = reviewAttributeString
        // effected date
        cell.dateLabel.text =   dataFeedMyfeed.created_at
        // effected person dating
        
        cell.ratingLabel.text = dataFeedMyfeed.action_val + "/5"
        //
        
        cell.descriptionLabel.attributedText = NSMutableAttributedString(string:            dataFeedMyfeed.review)
        
        setLikeDislikeCountCell(cell, dataFeedMyfeed: dataFeedMyfeed)
    }
    
    
    func setLikeDislikeCountCell(_ cell:FeedsTableViewCell, dataFeedMyfeed: dataFeedMyfeedModel)
    {
        if dataFeedMyfeed.likes_count.likeDislikecount.stringValue.characters.count > 0
        {
            cell.likeCountButton!.setTitle(String(dataFeedMyfeed.likes_count.likeDislikecount.stringValue), for: UIControlState())
        }else
        {
            cell.likeCountButton!.setTitle("0", for: UIControlState())
        }
        if  dataFeedMyfeed.dislikes_count.likeDislikecount.stringValue.characters.count > 0
        {
            cell.dislikeCountButton!.setTitle(String(dataFeedMyfeed.dislikes_count.likeDislikecount.stringValue), for: UIControlState())
        }else
        {
            cell.dislikeCountButton!.setTitle("0", for: UIControlState())
        }
        
    }
    
    
    func configureProfileCellData(_ cell:FeedsTableViewCell, dataFeedMyfeed: dataFeedMyfeedModel)
    {
        // you
        
        let reviewAttributeString = NSMutableAttributedString(string: (appUserId == dataFeedMyfeed.performed.idString ? "You":dataFeedMyfeed.performed.name))
        reviewAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange(location: 0, length:reviewAttributeString.length ))
        
        // perforemed Action
        cell.nameLabel.attributedText = reviewAttributeString
        cell.performedActionLabel?.text = "changed " + dataFeedMyfeed.action
        
        //cell.UserImageView.sd_setImage(with: URL(string:dataFeedMyfeed.action_val), placeholderImage: UIImage(named: "profile"))
        cell.UserImageView.makeImageRounded()
        //cell.RUserImageView.sd_setImage(with: URL(string:dataFeedMyfeed.performed.photo!), placeholderImage: UIImage(named: "another"))
        
        //cell?.picButton2?.tag =  indexPath.row
        
       setLikeDislikeCountCell(cell, dataFeedMyfeed: dataFeedMyfeed)
}
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{

      let  dataFeedMyfeed = dataFeedsArray[indexPath.row]
       
        if dataFeedMyfeed.action != profile_picture
        {
            
            return 245
        }
          return 160
    }
    
    // Mohit
    
    
    
    @IBAction func Clicked(_ sender:AnyObject){
        
        let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(chatVc!, animated: true)
        
    }
    
    
    func likeDislikeScreenClicked(_ index: Int)
    {

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        print(segue.identifier)
        
        let btn = sender as! UIButton!
        
        if let cell =  btn?.superview?.superview?.superview?.superview as? FeedsTableViewCell
        {
            if let indexPath = self.tableView.indexPath(for: cell)
            {
               let  dataFeedMyfeed = dataFeedsArray[indexPath.row]
                
                print(dataFeedMyfeed)
                
                if (segue.identifier == "LikeDislikeViewController")
                {
                    //get a reference to the destination view controller
                    let destinationVC:likeDislikeViewController = segue.destination as! likeDislikeViewController
                    
                    //set properties on the destination view controller
                    destinationVC.isSelectedDislike = (btn?.tag)!
                    destinationVC.dataFeedMyfeed = dataFeedMyfeed
                    
                    //etc...
                }
                
                
                if (segue.identifier == "photopreviewViewController")
                {
                    //get a reference to the destination view controller
                    let destinationVC:photopreviewViewController = segue.destination as! photopreviewViewController
                    
                    print(dataFeedMyfeed.performed.photo)
                    destinationVC.picname = dataFeedMyfeed.performed.photo
                    //set properties on the destination view controller
                    print(destinationVC.picname!)
                    //etc...
                }
            }
        
        }
    }
    
    @IBAction func reportAtSpam(_ sender: UIButton) {
        
    }
    
    func screenMoveClicked(_ cell:FeedsTableViewCell, button:UIButton)
    {
       if let indexPath = tableView.indexPath(for: cell)
        {
            let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController
            let  dataFeedMyfeed = dataFeedsArray[indexPath.row]
            if  dataFeedMyfeed.action == "reviewed"
            {
                if button.tag == 1
                {
                    profileViewController?.personalProfile = dataFeedMyfeed.performed
                }else
                {
                    profileViewController?.personalProfile = dataFeedMyfeed.effected
                }
            }else
            {
                if button.tag == 1
                {
                     profileViewController?.personalProfile = dataFeedMyfeed.effected
                }else
                {
                     profileViewController?.personalProfile = dataFeedMyfeed.performed
                }
            }
            
            
        profileViewController?.isToGetPersonData = true
            
            self.navigationController!.pushViewController(profileViewController!, animated: true)
        }
        
        //profileScreen(button.tag)
    }
    
    
    func likebuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    {
        likeData( dict, cell: cell)
    }
    
    func dislikebuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    {
        
        dislikeData(dict, cell: cell)
    }
    
    func picbuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    {
        //reportTospamUser(dict)
        
      if self.tableView.indexPath(for: cell) != nil
        {
            if let indexPath = self.tableView.indexPath(for: cell)
            {
                let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "photopreviewViewController") as? photopreviewViewController
                let  dataFeedMyfeed = dataFeedsArray[indexPath.row]
                if  dataFeedMyfeed.action == "reviewed"
                {
                    if button.tag == 1
                    {
                        chatVc!.picname = dataFeedMyfeed.performed.photo
                    }else
                    {
                        chatVc!.picname = dataFeedMyfeed.effected.photo
                    }
                }else
                {
                    if button.tag == 1
                    {
                        chatVc!.picname = dataFeedMyfeed.effected.photo
                    }else
                    {
                        chatVc!.picname = dataFeedMyfeed.performed.photo
                    }
                }
                if chatVc!.picname?.characters.count >= 0
                {
                    self.navigationController!.pushViewController(chatVc!, animated: true)
                }
            }
        }
    }
    
    
    func likeCountbuttonClicked(_ cell: FeedsTableViewCell, button: UIButton) {
        self.likeDislikeScreenClicked(1)
    }
    
    
    func dislikeCountbuttonClicked(_ cell: FeedsTableViewCell, button: UIButton) {
        self.likeDislikeScreenClicked(2)
    }
    
    //Profile Screen get Called
    func profileScreen(_ index: Int)
    {
        
        let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController
        
        profileViewController?.isToGetPersonData = true
        
        self.navigationController!.pushViewController(profileViewController!, animated: true)
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl)
    {
        
        segmentIndex = sender.selectedSegmentIndex
        
        switch sender.selectedSegmentIndex
        {
            
        case 0:
            loadfeedAPICall()
            
        case 1:
            loadmyfeedAPICall()
            
        default:
            break;
            
        }
    }
    
    
    func loadfeedAPICall()
    {
        
        if NetworkConnectivity.isConnectedToNetwork() != true{
            
            displayAlertMessage("No Internet Connection")
            
        }else{
            
            self.view.showSpinner()
        DataSessionManger.sharedInstance.getfeedslist( { (response, deserializedResponse) in
                print("deserializedResponse \(deserializedResponse)")
                
                DispatchQueue.main.async(execute: {
                        
                        self.getAlertCount()
                    
                    self.responseData = deserializedResponse
                    
                    print(self.responseData.data.count)
                    
                    self.dataFeedsArray = self.responseData.data
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
    
    
    
    func loadmyfeedAPICall()
    {
        
        if NetworkConnectivity.isConnectedToNetwork() != true{
            
            displayAlertMessage("No Internet Connection")
            
        }else{
            
            self.view.showSpinner()
            
            DataSessionManger.sharedInstance.getMyfeedslist( { (response, deserializedResponse) in
                
                print("deserializedResponse \(deserializedResponse)")
                
                DispatchQueue.main.async(execute: {
                    
                    self.responseData = deserializedResponse
                    print(self.responseData.data.count)
                    self.dataFeedsArray = self.responseData.data
                    self.tableView.reloadData()
                    self.view.removeSpinner()
                    self.getAlertCount()
                    
                })
                
                }, onError: { (error) in
                    
                    print("error \(error)")
                    DispatchQueue.main.async(execute: {
                            
                        self.view.removeSpinner()
                  })
            })
        }
    }

    
    func likeData( _ dict:[String:String], cell:FeedsTableViewCell)
    {
        let indexPath = self.tableView.indexPath(for: cell)
        let dataFeedMyfeed = self.dataFeedsArray[indexPath!.row]
        var newDict = dict
        newDict[user_report_spam_post] = String(dataFeedMyfeed.id)
        self.view.showSpinner()
        DataSessionManger.sharedInstance.feedLikeUser(newDict, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                deserializedResponse.performed = dataFeedMyfeed.performed
                deserializedResponse.effected  = dataFeedMyfeed.effected
                self.dataFeedsArray[indexPath!.row] = deserializedResponse
                self.tableView.reloadRows(at: [indexPath!], with: .none)
               
                self.view.removeSpinner()
                    self.getAlertCount()
                
            });

        }) { (error) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
            });
   
        }
 
    }
    func dislikeData(_ dict:[String:String], cell:FeedsTableViewCell)
    {
        let indexPath = self.tableView.indexPath(for: cell)
        let dataFeedMyfeed = self.dataFeedsArray[indexPath!.row]
        var newDict = dict
        newDict[user_report_spam_post] = String(dataFeedMyfeed.id)
        self.view.showSpinner()
        DataSessionManger.sharedInstance.feedisLikeUser(newDict, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                    
                deserializedResponse.performed = dataFeedMyfeed.performed
                deserializedResponse.effected = dataFeedMyfeed.effected
                self.dataFeedsArray[indexPath!.row] = deserializedResponse
                self.tableView.reloadRows(at: [indexPath!], with: .none)
             
                print(deserializedResponse)
                self.view.removeSpinner()
                    self.getAlertCount()
                
            });
        }) { (error) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
                
            });
        }
    }
    
    func reportTospamUser(_ dict:[String:String])
    {
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.reportTospamUser(dict, onFinish: {(response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                self.getAlertCount()
                self.view.removeSpinner()
                
            });
        }) { (error) in
            
            DispatchQueue.main.async(execute: {
                
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
                
            });
        }
    }
}
