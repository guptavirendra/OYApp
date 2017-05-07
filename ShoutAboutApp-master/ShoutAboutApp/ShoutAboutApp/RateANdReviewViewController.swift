//
//  RateANdReviewViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class RateANdReviewViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, ClickTableViewCellProtocol
{
    @IBOutlet weak var tableView: UITableView!
    
    var activeTextView:UITextView?
    
    var person:SearchPerson = SearchPerson()
    
    var reviewUser = ReviewUser()
    
    var rating:String = "0"
    var review:String = ""
    var idString:String?
    var name:String = ""
    var photo:String = ""
    var subtractCount:Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setBackIndicatorImage()
        
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        if String(appUserId) == idString
        {
            subtractCount = 3
            
        }
        
        //self.tableView.addBackGroundImageView()
        //self.tableView.backgroundColor = bgColor
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.navigationBar.hidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showKeyBoard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.hideKeyBoard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(self.hideKeyBoard(_:)))
        
        self.title = "Rate & Review"
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = appColor
        getReview()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}

extension RateANdReviewViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4 - subtractCount + reviewUser.rateReviewList.count //allValidContacts.count //objects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.row == (0-subtractCount)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("RatingTableViewCell", forIndexPath: indexPath) as! RatingTableViewCell
            cell.nameLabel.text = name
            cell.ratingView.delegate = self
            let urlString       = photo
            if urlString.characters.count != 0
            {
                
                cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
                
            }else
            {
                cell.profileImageView.image = UIImage(named: "profile")
            }
            
            rating = String(cell.ratingView.rating)
            
            
            return cell
        }
        if indexPath.row == (1-subtractCount)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("WriteReviewTableViewCell", forIndexPath: indexPath) as! WriteReviewTableViewCell
            cell.textView.layer.borderColor = UIColor.blackColor().CGColor
            review = cell.textView.text
            return cell
        }
        
        if indexPath.row == (2-subtractCount)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("button", forIndexPath: indexPath) as! ClickTableViewCell
            //cell.contentView.backgroundColor = bgColor
            cell.button.layer.borderWidth = 1.0
            cell.button.layer.borderColor = appColor.CGColor
            cell.button.layer.cornerRadius = 2.0
            cell.delegate = self
            return cell
        }
        
        if indexPath.row == (3-subtractCount)
        {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ReviewTableViewCell", forIndexPath: indexPath) as! ReviewTableViewCell
            
            let urlString       = photo
            if urlString.characters.count != 0
            {
                
                cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
                
            }else
            {
                cell.profileImageView.image = UIImage(named: "profile")
            }
            
            
            var message:String = ""
            cell.name.text = name
            var total:Float = 0.0
            var totalRating:Float  = 0.0
            
            if reviewUser.rateGraphArray.count >= 1
            {
                
                let  rating = reviewUser.rateGraphArray[0].count
                totalRating =   Float(rating)!
                
                if totalRating > 0 && totalRating <= 1
                {
                    
                    message.appendContentsOf(rating)
                    message.appendContentsOf(" rating")
                }else
                {
                    message.appendContentsOf(rating)
                    message.appendContentsOf(" ratings")
                    
                }
            }
            
            
            if let _ = reviewUser.reviewCountArray.first
            {
                cell.reviewCount.text = (reviewUser.reviewCountArray.first?.count)! + " total"
                if let count = reviewUser.reviewCountArray.first?.count
                {
                    total =   Float(count)!
                }
                
                
                
                if reviewUser.rateGraphArray.count >= 1
                {
                    
                    let  rating = reviewUser.rateGraphArray[0].count
                    let  ratingFloat =  CGFloat(Float(rating)!)
                    
                    if ratingFloat > 0 && ratingFloat <= 1
                    {
                        message.appendContentsOf(", ")
                    }
                }
                
                if total > 0 && total <= 1
                {
                    message.appendContentsOf(String(Int(total)))
                    message.appendContentsOf(" review")
                    
                }else
                {
                    message.appendContentsOf(String(Int(total)))
                    message.appendContentsOf(" reviews")
                    
                }
            }
            
            //cell.reviewMessage?.text = message
            cell.reviewCount.text = message
            
            if let ratingAverage = reviewUser.ratingAverageArray.first?.average
            {
                cell.ratingView.rating = Int(Float(ratingAverage)!)
                cell.ratingOutOfFive.text   =  String(cell.ratingView.rating) + "/5"
            }
            let fixConstraints:CGFloat = cell.graphbaseView5.frame.size.width
            var fiveCount:Float = 0
            var fourCount:Float = 0
            var threeCount:Float = 0
            var twoCount:Float = 0
            var oneCount:Float = 0
            for rateGraph in reviewUser.rateGraphArray
            {
                switch rateGraph.rate
                {
                case "5":
                    
                    fiveCount =  Float(Int(rateGraph.count)!)
                    
                    break
                case "4":
                    
                    fourCount =  Float(Int(rateGraph.count)!)
                    
                    break
                case "3":
                    
                    threeCount =  Float(Int(rateGraph.count)!)
                    
                    break
                case "2":
                    
                    twoCount =  Float(Int(rateGraph.count)!)
                    
                    break
                case "1":
                    
                    oneCount =  Float(Int(rateGraph.count)!)
                    
                    break
                default:
                    break
                }
                
            }
            if fiveCount > 0 && totalRating > 0
            {
                //cell.fiveConstraints.constant  = (fiveCount/total)*fixConstraints
                cell.progressView5?.progress = fiveCount/totalRating
                
            }else
            {
                //cell.fiveConstraints.constant  = 0.0
                cell.progressView5?.progress = 0.0
            }
            cell.countLabel5.text          = String(Int(fiveCount))
            if fourCount > 0 && totalRating > 0
            {
                //cell.fourConstraints.constant  = (fourCount/total)*fixConstraints
                cell.progressView4?.progress = fourCount/totalRating
            }else
            {
                //cell.fourConstraints.constant  = 0.0
                 cell.progressView4?.progress  = 0.0
            }
            cell.countLabel4.text          = String(Int(fourCount))
            if threeCount > 0 && totalRating > 0
            {
                //cell.threeConstraints.constant = (threeCount/total)*fixConstraints
                cell.progressView3?.progress = threeCount/totalRating
            }else
            {
                //cell.threeConstraints.constant = 0.0
                cell.progressView3?.progress  = 0.0
            }
            cell.countLabel3.text          = String(Int(threeCount))
            if twoCount > 0 && totalRating > 0
            {
                //cell.twoConstraints.constant   = (twoCount/total)*fixConstraints
                cell.progressView2?.progress = twoCount/totalRating
            }else
            {
                //cell.twoConstraints.constant   = 0.0
                cell.progressView2?.progress   = 0.0
            }
            cell.countLabel2.text          = String(Int(twoCount))
            if oneCount > 0 && totalRating > 0
            {
               // cell.oneConstraints.constant   = (oneCount/total)*fixConstraints
                cell.progressView1?.progress = oneCount/totalRating
            }else
            {
                //cell.oneConstraints.constant   =  0.0
                cell.progressView1?.progress   =  0.0
            }
            cell.countLabel1.text          = String(Int(oneCount))
            
            
            return cell
        }
        
        if reviewUser.rateReviewList.count > (indexPath.row-4)-subtractCount
        {
            
            let rateReviewer = reviewUser.rateReviewList[(indexPath.row-4)-subtractCount]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("UesrReviewTableViewCell", forIndexPath: indexPath) as! UesrReviewTableViewCell
            cell.nameLabel.text    = rateReviewer.appUser.name
            cell.commentLabel.text = rateReviewer.review
            
            if rateReviewer.rate.characters.count > 0
            {
                cell.rateView.rating   = Int(rateReviewer.rate)!
            }
            cell.timeLabel.text    = rateReviewer.created_at
            let urlString       = rateReviewer.appUser.photo
            if urlString.characters.count != 0
            {
                cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
                
            }else
            {
                cell.profileImageView.image = UIImage(named: "profile")
            }
            
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 0-subtractCount
        {
            return 150
        }
        
        if indexPath.row == 1-subtractCount
        {
            return 140
        }
        if indexPath.row == 2-subtractCount
        {
            return 54
        }
        
        if indexPath.row == 3-subtractCount
        {
            return 210
        }
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 1-subtractCount
        {
            return 100
        }
        if indexPath.row == 2-subtractCount
        {
            return 54
        }
        if indexPath.row == 0-subtractCount
        {
            return 210
        }
        
        return 100
    }
}

extension RateANdReviewViewController
{
    func textViewDidBeginEditing(textView: UITextView)
    {
        activeTextView = textView
        textView.becomeFirstResponder()
    }
    
    
    /*
     - (void)textViewDidBeginEditing:(UITextView *)textView
     {
     // save the text view that is being edited
     
     if ([textView.text isEqualToString:NSLocalizedString(@"Add question", nil)] ||[textView.text isEqualToString:NSLocalizedString(@"Add answer", nil)] )
     {
     textView.text = @"";
     textView.textColor = [UIColor colorWithRed:39./255. green:39./255. blue:39./255. alpha:1.]; //optional
     }
     mActiveView = textView;
     [textView becomeFirstResponder];
     
     
     }*/
    
    
    func textViewDidEndEditing(textView: UITextView)
    {
        review = textView.text
        // textView.text = nil
        //textView.resignFirstResponder()
    }
    /*
     - (void)textViewDidEndEditing:(UITextView *)textView
     {
     
     if ([textView.text isEqualToString:@"Add question"] ||[textView.text isEqualToString:@"Add answer"] )
     {
     textView.text = @"";
     textView.textColor = [UIColor lightGrayColor]; //optional
     
     [textView resignFirstResponder];
     }
     else
     {
     if (textView.tag == 1)
     {
     mQuestion = textView.text;
     }
     else if (textView.tag == 2)
     {
     mAnswer = textView.text;
     }
     
     }
     // release the selected text view as we don't need it anymore
     mActiveView = nil;
     }
     
     */
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        //review.appendContentsOf(text)
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    func showKeyBoard(notification: NSNotification)
    {
        if ((activeTextView?.superview?.superview?.superview?.isKindOfClass(WriteReviewTableViewCell)) != nil)
        {
            if let cell = activeTextView?.superview?.superview?.superview as? WriteReviewTableViewCell
            {
                // let dictInfo: NSDictionary = notification.userInfo!
                //let kbSize :CGSize = (dictInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue().size)!
                //let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
                // self.tableView.contentInset = contentInsets
                // self.tableView.scrollIndicatorInsets = contentInsets
                
                
                if let indexPath = self.tableView.indexPathForCell(cell)
                {
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                }
                
            }
        }
    }
    
    
    func hideKeyBoard(notification: NSNotification)
    {
        
        if  activeTextView != nil
        {
            let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            self.tableView.scrollToNearestSelectedRowAtScrollPosition(.Bottom, animated: true)
        }
    }
    
}

extension RateANdReviewViewController:RatingControlDelegate
{
    func buttonClicked(cell:ClickTableViewCell)
    {
        let ratingInt = Int(rating)
        if ratingInt == 0 || ratingInt > 5
        {
            return
            
            
        }else
        {
            if  activeTextView != nil
            {
                review.appendContentsOf((activeTextView?.text)!)
                activeTextView?.resignFirstResponder()
            }
            if self.tableView.indexPathForCell(cell) != nil
            {
                let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
                let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
                
                if idString != nil
                {
                    
                    let dict = ["by_user_id":String(appUserId),"for_user_id":idString!, "rate":rating, "review":review,kapp_user_id:String(appUserId), kapp_user_token :appUserToken ]
                    
                    postReview(dict)
                }
            }
        }
    }
    
    func addLike()
    {
        
    }
    
    func ratingSelected(ratingInt: Int)
    {
        rating = String(ratingInt)
    }
    
    
    func postReview(dict:[String:String])
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.addRateReview(dict, onFinish: { (response, deserializedResponse) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // self.tableView.reloadData()
                self.view.removeSpinner()
                self.activeTextView?.text = nil
                self.getReview()
            })
            
        }) { (error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // self.tableView.reloadData()
                self.view.removeSpinner()
                self.getReview()
            })
            
        }
    }
    
    
    func getReview()
    {
        self.view.showSpinner()
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
        
        if idString != nil
        {
            
            let dict = ["for_user_id":idString!,kapp_user_id:String(appUserId), kapp_user_token :appUserToken ]
            
            DataSessionManger.sharedInstance.getContactReviewList(dict, onFinish: { (response, reviewUser) in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.reviewUser = reviewUser
                    self.tableView.reloadData()
                    self.view.removeSpinner()
                })
                
            }) { (error) in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // self.tableView.reloadData()
                    self.view.removeSpinner()
                })
            }
        }
        
    }
}

extension UIViewController
{
    func setBackIndicatorImage()
    {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
    }
}
