

import UIKit

class FeedsViewController: UIViewController,FeedsTableViewCellProtocol
{

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var locationLabel:UILabel?
    
    
    var responseData = FeedMyfeed()
    var dataFeedMyfeed = dataFeedMyfeedModel()
    var msgresponseData = AlertCountCommonModel()
    var dict = [String:String]()
    var segmentIndex: Int!

    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        self.ConfigureVariable()
        self.loadfeedAPICall()
        
        segmentIndex = 0
       
        
//        self.loadmyfeedAPICall()
        // Do any additional setup after loading the view.
    }
    
    
    func ConfigureVariable() {
        
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        
        let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
        
        dict = [kapp_user_id:String(appUserId), user_report_spam_post:"1",kapp_user_token :appUserToken]
        
//        self.dislikeData(dict)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
       
    }

    override func didReceiveMemoryWarning(){
        
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.responseData.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        dataFeedMyfeed = responseData.data[indexPath.row]
        
//        if segmentIndex==0 {
        
        
        if dataFeedMyfeed.action != profile_picture   {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyFeedsTableViewCell", forIndexPath: indexPath) as? FeedsTableViewCell
            
            cell?.contentView.setGraphicEffects()
            
            let main_string = "\(dataFeedMyfeed.performed.name) \(dataFeedMyfeed.recent_action) \(dataFeedMyfeed.action)"
            
            let string_to_color = "\(dataFeedMyfeed.recent_action) \(dataFeedMyfeed.action)"
            
            let range = (main_string as NSString).rangeOfString(string_to_color)
            
            let attributedString = NSMutableAttributedString(string:main_string)
            
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: range)
            
            cell?.delegate = self
            
            cell?.nameLabel.attributedText = attributedString
            cell?.descriptionLabel.attributedText = attributedString
            cell?.RdescriptionLabel.attributedText = attributedString
            
            
            cell?.UserImageView.makeImageRounded()
            cell?.UserImageView.setImageWithURL(NSURL(string:dataFeedMyfeed.performed.photo), placeholderImage: UIImage(named: "profile"))
        
            cell?.RUserImageView.setImageWithURL(NSURL(string:dataFeedMyfeed.effected.photo), placeholderImage: UIImage(named: "profile"))
            

//            if String(dataFeedMyfeed.action_val) != nil {
//                 cell?.ratingView.rating = Int(Float(dataFeedMyfeed.action_val)!)
//            }
//            else{
//                 cell?.ratingView.rating = 0
//            }
//

            cell?.dateLabel.text = dataFeedMyfeed.created_at
            cell?.ratingLabel.text = dataFeedMyfeed.action_val + "/5"
            
            cell?.likeCountButton!.setTitle(String(dataFeedMyfeed.likes_count.likeDislikecount), forState: UIControlState.Normal)
            cell?.dislikeCountButton!.setTitle(String(dataFeedMyfeed.dislikes_count.likeDislikecount), forState: UIControlState.Normal)
      
            
            cell?.picButton?.tag =  indexPath.row
            cell?.picButton1?.tag =  indexPath.row
            
            return cell!
        }
        

        let cell = tableView.dequeueReusableCellWithIdentifier("MyFeedsTableViewCell1", forIndexPath: indexPath) as? FeedsTableViewCell
        
        let main_string = "\(dataFeedMyfeed.performed.name) \(dataFeedMyfeed.recent_action) \(dataFeedMyfeed.action)"
        
        let string_to_color = "\(dataFeedMyfeed.recent_action) \(dataFeedMyfeed.action)"
        
        let range = (main_string as NSString).rangeOfString(string_to_color)
        
        let attributedString = NSMutableAttributedString(string:main_string)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: range)
        
        cell?.nameLabel.attributedText = attributedString
//        cell?.descriptionLabel.attributedText = attributedString
        
        
        cell?.UserImageView.setImageWithURL(NSURL(string:dataFeedMyfeed.action_val), placeholderImage: UIImage(named: "profile"))
        cell?.UserImageView.makeImageRounded()
        cell?.RUserImageView.setImageWithURL(NSURL(string:dataFeedMyfeed.performed.photo), placeholderImage: UIImage(named: "another"))
        
        cell?.picButton2?.tag =  indexPath.row
        cell?.likeCountButton!.setTitle(String(dataFeedMyfeed.likes_count.likeDislikecount), forState: UIControlState.Normal)
        cell?.dislikeCountButton!.setTitle(String(dataFeedMyfeed.dislikes_count.likeDislikecount), forState: UIControlState.Normal)
        
        cell?.contentView.setGraphicEffects()
        cell?.delegate = self
        return cell!
            
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{

        dataFeedMyfeed = responseData.data[indexPath.row]
       
        if dataFeedMyfeed.action != profile_picture{
            
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

        dataFeedMyfeed = responseData.data[index]
        

//        let likedislikeVc = self.storyboard?.instantiateViewControllerWithIdentifier("LikeDislikeViewController")
//    
//        self.navigationController!.pushViewController(likedislikeVc!, animated: true)
        
    }
    
    
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        print(segue.identifier)
        
        
        let btn = sender as! UIButton!
        dataFeedMyfeed = responseData.data[btn.tag]
        
        print(dataFeedMyfeed)
        
        if (segue.identifier == "LikeDislikeViewController") {
            //get a reference to the destination view controller
            let destinationVC:likeDislikeViewController = segue.destinationViewController as! likeDislikeViewController
            
            //set properties on the destination view controller
            destinationVC.dataFeedMyfeed = dataFeedMyfeed
            //etc...
        }
        
        if (segue.identifier == "photopreviewViewController") {
            //get a reference to the destination view controller
            let destinationVC:photopreviewViewController = segue.destinationViewController as! photopreviewViewController
            
            print(dataFeedMyfeed.performed.photo)
            
            
          
            destinationVC.picname = dataFeedMyfeed.performed.photo
            //set properties on the destination view controller
              print(destinationVC.picname)
            //etc...
        }
    }
    */
    
    
    
 
    
    
    @IBAction func reportAtSpam(sender: UIButton) {
        
    }
    
    func screenMoveClicked(cell:FeedsTableViewCell, button:UIButton)  {
        profileScreen(button.tag)
    }
    
    
    func likebuttonClicked(cell:FeedsTableViewCell, button:UIButton){
        likeData(dict)
    }
    
    func dislikebuttonClicked(cell:FeedsTableViewCell, button:UIButton){
        dislikeData(dict)
    }
    
    func picbuttonClicked(cell:FeedsTableViewCell, button:UIButton){
        //reportTospamUser(dict)
        
        
        
        if self.tableView.indexPathForCell(cell) != nil
        {
            if let indexPath = self.tableView.indexPathForCell(cell)
            {
                
                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("photopreviewViewController") as? photopreviewViewController
                dataFeedMyfeed = responseData.data[indexPath.row]
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
        
//      profileViewController?.personalProfile = responseData.data[index]
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
                    
                    
                    self.tableView.reloadData()
                    
                    self.view.removeSpinner()
                    
//                    let indexPath = NSIndexPath(forRow: 3, inSection: 0)
//                    self.tableView.scrollToRowAtIndexPath(indexPath,
//                        atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                    
                    
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
    
    
    
    func loadmyfeedAPICall()  {
        
        if NetworkConnectivity.isConnectedToNetwork() != true{
            
            displayAlertMessage("No Internet Connection")
            
        }else{
            
            self.view.showSpinner()
            
            DataSessionManger.sharedInstance.getMyfeedslist( { (response, deserializedResponse) in
                
                print("deserializedResponse \(deserializedResponse)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.responseData = deserializedResponse
                    print(self.responseData.data.count)
                    
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

    
    
    func likeData(dict:[String:String]){
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.feedLikeUser(dict, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                
                
                print(deserializedResponse)
                self.msgresponseData = deserializedResponse
                self.displayAlertMessage(self.msgresponseData.likeDislikecount)
                self.view.removeSpinner()
                
            });

        }) { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
            });
   
        }
 
    }
    

    
    
    func dislikeData(dict:[String:String]){
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.feedisLikeUser(dict, onFinish: { (response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                self.msgresponseData = deserializedResponse
                self.displayAlertMessage(self.msgresponseData.likeDislikecount)
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
    
    func reportTospamUser(dict:[String:String]){
        
        self.view.showSpinner()
        DataSessionManger.sharedInstance.reportTospamUser(dict, onFinish: {(response, deserializedResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                
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
