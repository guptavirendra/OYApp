

import UIKit

class FeedsViewController: UIViewController,FeedsTableViewCellProtocol
{

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var locationLabel:UILabel?
    @IBOutlet weak var segment:UISegmentedControl?
    var dataFeedsArray:[dataFeedMyfeedModel] = [dataFeedMyfeedModel]()
    
    
    var responseData    = FeedMyfeed()
    var dataFeedMyfeed  = dataFeedMyfeedModel()
    var msgresponseData = AlertCountCommonModel()
    var dict = [String:String]()
    var segmentIndex: Int!
    var appUserId:Int = 0
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.ConfigureVariable()
        self.loadfeedAPICall()
        segmentIndex = 0
    }
    
    
    func ConfigureVariable()
    {
        appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
        dict = [kapp_user_id:String(appUserId),kapp_user_token :appUserToken]
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
       
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
         return dataFeedsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let dataFeedMyfeed = dataFeedsArray[indexPath.row]
        if dataFeedMyfeed.action != profile_picture
        {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyFeedsTableViewCell", forIndexPath: indexPath) as? FeedsTableViewCell
            cell?.delegate = self
            cell?.contentView.setGraphicEffects()
            self.configureReviewCellData(cell!, dataFeedMyfeed: dataFeedMyfeed)
          return cell!
        }
        

        let cell = tableView.dequeueReusableCellWithIdentifier("MyFeedsTableViewCell1", forIndexPath: indexPath) as? FeedsTableViewCell
        cell?.contentView.setGraphicEffects()
        cell?.delegate = self
        
        self.configureProfileCellData(cell!, dataFeedMyfeed: dataFeedMyfeed)
        return cell!
    }
    
    func configureReviewCellData(cell:FeedsTableViewCell,dataFeedMyfeed: dataFeedMyfeedModel)
    {
       
        // by performed person
        cell.RUserImageView.sd_setImageWithURL(NSURL(string:dataFeedMyfeed.performed.photo), placeholderImage: UIImage(named: "profile"))
        cell.RUserImageView.makeImageRounded()
        
        if dataFeedMyfeed.action == "reviewed"
        {
            
            let reviewAttributeString = NSMutableAttributedString(string: (appUserId == dataFeedMyfeed.performed.id ? "You":dataFeedMyfeed.performed.name))
            reviewAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSRange(location: 0, length:reviewAttributeString.length ))
            
            let reviewAttributeStrings = NSMutableAttributedString(string:" reviewed")
            reviewAttributeStrings.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length:reviewAttributeStrings.length ))
            reviewAttributeString.appendAttributedString(reviewAttributeStrings)
            
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
        cell.UserImageView.sd_setImageWithURL(NSURL(string:dataFeedMyfeed.effected.photo), placeholderImage: UIImage(named: "profile"))
        cell.UserImageView.makeImageRounded()
        
        let reviewAttributeString = NSMutableAttributedString(string:            dataFeedMyfeed.effected.name)
        reviewAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSRange(location: 0, length:reviewAttributeString.length ))
        
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
    
    
    func setLikeDislikeCountCell(cell:FeedsTableViewCell, dataFeedMyfeed: dataFeedMyfeedModel)
    {
        if dataFeedMyfeed.likes_count.likeDislikecount.stringValue.characters.count > 0
        {
            cell.likeCountButton!.setTitle(String(dataFeedMyfeed.likes_count.likeDislikecount.stringValue), forState: UIControlState.Normal)
        }else
        {
            cell.likeCountButton!.setTitle("0", forState: UIControlState.Normal)
        }
        if  dataFeedMyfeed.dislikes_count.likeDislikecount.stringValue.characters.count > 0
        {
            cell.dislikeCountButton!.setTitle(String(dataFeedMyfeed.dislikes_count.likeDislikecount.stringValue), forState: UIControlState.Normal)
        }else
        {
            cell.dislikeCountButton!.setTitle("0", forState: UIControlState.Normal)
        }
        
    }
    
    
    func configureProfileCellData(cell:FeedsTableViewCell, dataFeedMyfeed: dataFeedMyfeedModel)
    {
        // you
        
        let reviewAttributeString = NSMutableAttributedString(string: (appUserId == dataFeedMyfeed.performed.id ? "You":dataFeedMyfeed.performed.name))
        reviewAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSRange(location: 0, length:reviewAttributeString.length ))
        
        // perforemed Action
        cell.nameLabel.attributedText = reviewAttributeString
        cell.performedActionLabel?.text = "changed " + dataFeedMyfeed.action
        
        cell.UserImageView.sd_setImageWithURL(NSURL(string:dataFeedMyfeed.action_val), placeholderImage: UIImage(named: "profile"))
        cell.UserImageView.makeImageRounded()
        cell.RUserImageView.sd_setImageWithURL(NSURL(string:dataFeedMyfeed.performed.photo), placeholderImage: UIImage(named: "another"))
        
        //cell?.picButton2?.tag =  indexPath.row
        
       setLikeDislikeCountCell(cell, dataFeedMyfeed: dataFeedMyfeed)
}
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{

        dataFeedMyfeed = dataFeedsArray[indexPath.row]
       
        if dataFeedMyfeed.action != profile_picture
        {
            
            return 245
        }
          return 160
    }
    
    // Mohit
    
    
    
    @IBAction func Clicked(sender:AnyObject){
        
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(chatVc!, animated: true)
        
    }
    
    
    func likeDislikeScreenClicked(index: Int){

        dataFeedMyfeed = dataFeedsArray[index]
        

//        let likedislikeVc = self.storyboard?.instantiateViewControllerWithIdentifier("LikeDislikeViewController")
//    
//        self.navigationController!.pushViewController(likedislikeVc!, animated: true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        print(segue.identifier)
        
        let btn = sender as! UIButton!
        
        if let cell =  btn.superview?.superview?.superview?.superview as? FeedsTableViewCell
        {
            if let indexPath = self.tableView.indexPathForCell(cell)
            {
               let  dataFeedMyfeed = dataFeedsArray[indexPath.row]
                
                print(dataFeedMyfeed)
                
                if (segue.identifier == "LikeDislikeViewController")
                {
                    //get a reference to the destination view controller
                    let destinationVC:likeDislikeViewController = segue.destinationViewController as! likeDislikeViewController
                    
                    //set properties on the destination view controller
                    destinationVC.isSelectedDislike = btn.tag
                    destinationVC.dataFeedMyfeed = dataFeedMyfeed
                    
                    //etc...
                }
                
                
                if (segue.identifier == "photopreviewViewController")
                {
                    //get a reference to the destination view controller
                    let destinationVC:photopreviewViewController = segue.destinationViewController as! photopreviewViewController
                    
                    print(dataFeedMyfeed.performed.photo)
                    destinationVC.picname = dataFeedMyfeed.performed.photo
                    //set properties on the destination view controller
                    print(destinationVC.picname)
                    //etc...
                }
            }
        
        }
        
        
        
        
    }
    
    
    
    
 
    
    
    @IBAction func reportAtSpam(sender: UIButton) {
        
    }
    
    func screenMoveClicked(cell:FeedsTableViewCell, button:UIButton)  {
        profileScreen(button.tag)
    }
    
    
    func likebuttonClicked(cell:FeedsTableViewCell, button:UIButton)
    {
        
       
        likeData( dict, cell: cell)
    }
    
    func dislikebuttonClicked(cell:FeedsTableViewCell, button:UIButton)
    {
        
        dislikeData(dict, cell: cell)
    }
    
    func picbuttonClicked(cell:FeedsTableViewCell, button:UIButton){
        //reportTospamUser(dict)
        
    if self.tableView.indexPathForCell(cell) != nil
        {
            if let indexPath = self.tableView.indexPathForCell(cell)
            {
                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("photopreviewViewController") as? photopreviewViewController
                dataFeedMyfeed = dataFeedsArray[indexPath.row]
                chatVc!.picname = dataFeedMyfeed.performed.photo
                self.navigationController!.pushViewController(chatVc!, animated: true)
            }
        }
    }
    
    
    func likeCountbuttonClicked(cell: FeedsTableViewCell, button: UIButton) {
        self.likeDislikeScreenClicked(1)
    }
    
    
    func dislikeCountbuttonClicked(cell: FeedsTableViewCell, button: UIButton) {
        self.likeDislikeScreenClicked(2)
    }
    
    
    func profileScreen(index: Int)  {
        
        let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
        
//      profileViewController?.personalProfile = dataFeedsArray[index]
        self.navigationController!.pushViewController(profileViewController!, animated: true)
    }
    
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
        segmentIndex = sender.selectedSegmentIndex
        
        switch sender.selectedSegmentIndex{
            
        case 0:
            loadfeedAPICall()
            
        case 1:
            loadmyfeedAPICall()
            
        default:
            break;
            
        }
    }
    
    
    func loadfeedAPICall()  {
        
        if NetworkConnectivity.isConnectedToNetwork() != true{
            
            displayAlertMessage("No Internet Connection")
            
        }else{
            
            self.view.showSpinner()
        DataSessionManger.sharedInstance.getfeedslist( { (response, deserializedResponse) in
                print("deserializedResponse \(deserializedResponse)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.responseData = deserializedResponse
                    
                    print(self.responseData.data.count)
                    
                    self.dataFeedsArray = self.responseData.data
                    self.tableView.reloadData()
                    
                    self.view.removeSpinner()
                    
                })
                
                }, onError: { (error) in
                    
                    print("error \(error)")
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            
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
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.responseData = deserializedResponse
                    print(self.responseData.data.count)
                    self.dataFeedsArray = self.responseData.data
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

    
    
    func likeData( dict:[String:String], cell:FeedsTableViewCell)
    {
        let indexPath = self.tableView.indexPathForCell(cell)
        let dataFeedMyfeed = self.dataFeedsArray[indexPath!.row]
        var newDict = dict
        newDict[user_report_spam_post] = String(dataFeedMyfeed.id)
        self.view.showSpinner()
        DataSessionManger.sharedInstance.feedLikeUser(newDict, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(),
                {
                deserializedResponse.performed = dataFeedMyfeed.performed
                deserializedResponse.effected  = dataFeedMyfeed.effected
                self.dataFeedsArray[indexPath!.row] = deserializedResponse
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
               
                self.view.removeSpinner()
                
            });

        }) { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
            });
   
        }
 
    }
    func dislikeData(dict:[String:String], cell:FeedsTableViewCell){
        let indexPath = self.tableView.indexPathForCell(cell)
        let dataFeedMyfeed = self.dataFeedsArray[indexPath!.row]
        var newDict = dict
        newDict[user_report_spam_post] = String(dataFeedMyfeed.id)
        self.view.showSpinner()
        DataSessionManger.sharedInstance.feedisLikeUser(newDict, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(),
                {
                    
                deserializedResponse.performed = dataFeedMyfeed.performed
                deserializedResponse.effected = dataFeedMyfeed.effected
                self.dataFeedsArray[indexPath!.row] = deserializedResponse
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
             
                print(deserializedResponse)
                self.view.removeSpinner()
                
            });
        }) { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
                
            });
        }
    }
    
    func reportTospamUser(dict:[String:String])
    {
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.reportTospamUser(dict, onFinish: {(response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(),
                {
                
                self.view.removeSpinner()
                
            });
        }) { (error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
                
            });
        }
    }
}
