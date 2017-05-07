//
//  NewProfileViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 29/01/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import ContactsUI


class NewProfileViewController: ProfileViewController, UIPopoverPresentationControllerDelegate, ProfileViewControllerDelegate, CNContactViewControllerDelegate
{

     @IBOutlet weak var spamBlockBaseView:UIView?
     @IBOutlet weak var callButton:UIButton?
     @IBOutlet weak var chatButton:UIButton?
     @IBOutlet weak var detailButton:UIButton?
     @IBOutlet weak var blockButton:UIButton?
     @IBOutlet weak var spamButton:UIButton?
     @IBOutlet weak var favoriteButton:UIButton?
     @IBOutlet weak var nameLabel:UILabel?
     @IBOutlet weak var locationLabel:UILabel?
    
     @IBOutlet weak var callLabel:UILabel?
     @IBOutlet weak var chatLabel:UILabel?
     @IBOutlet weak var detailLabel:UILabel?
     @IBOutlet weak var blockLabel:UILabel?
     @IBOutlet weak var spamLabel:UILabel?
     @IBOutlet weak var favoriteLabel:UILabel?
    
    
    var shouldDisabledUserInteraction:Bool = true
    
    
    @IBOutlet weak var doneButton:UIBarButtonItem?

     var popOver : UIPopoverPresentationController!
    
    override var personalProfile: SearchPerson{
        
        didSet
        {
            nameLabel?.text     = personalProfile.name
            locationLabel?.text = personalProfile.address
            
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        if self.isBeingPresented()
        {
            doneButton?.title = "Done"
            
        }
         
        /*
        //self.view.addBackGroundImageView()
        callButton?.makeImageRoundedWithGray()
        chatButton?.makeImageRoundedWithGray()
        detailButton?.makeImageRoundedWithGray()
        blockButton?.makeImageRoundedWithGray()
        spamButton?.makeImageRoundedWithGray()
        favoriteButton?.makeImageRoundedWithGray()
        */
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let isExisingContact  = ProfileManager.sharedInstance.syncedContactArray.contains
            { (person) -> Bool in
                return person.mobileNumber == personalProfile.mobileNumber
        }
        if isExisingContact == false
        {
            favoriteLabel?.text = "Add to Contact"
            favoriteButton!.setImage(nil, forState: .Normal)
            favoriteButton!.setTitle("+", forState: .Normal)
            
        }
        
        
        
    self.view.userInteractionEnabled = self.shouldDisabledUserInteraction
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = appColor
        nameLabel?.text     = personalProfile.name
        locationLabel?.text = personalProfile.address
        if personalProfile.idString == ProfileManager.sharedInstance.personalProfile.idString
        {
            self.spamBlockBaseView?.hidden = true
            self.cameraButton!.hidden      = false
            callLabel?.text                = "Status"
            chatLabel?.text                = "Review"
             
        }else
        {
            self.spamBlockBaseView?.hidden = false
            self.cameraButton!.hidden      = true
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    @IBAction override func goToReviewScreen()
    {
       if chatLabel?.text  == "Review"
       {
            let rateANdReviewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RateANdReviewViewController") as? RateANdReviewViewController
            self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
       }else
       {
            let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
            self.navigationController!.pushViewController(chattingViewController!, animated: true)
        
        }
    }
    
    
    @IBAction func callStatusScreen()
    {
        if  callLabel?.text == "Status"
        {
            
            var inputTextField: UITextField?
            let passwordPrompt = UIAlertController(title: "Status", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                // Now do whatever you want with inputTextField (remember to unwrap the optional)
                
                print(" sta\(inputTextField!.text)")
            }))
            passwordPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Status"
                textField.borderStyle = .None
                inputTextField = textField
            })
            
            presentViewController(passwordPrompt, animated: true, completion: nil)
            
            
        }else
        {
            //let personContact = allValidContacts[indexPath!.row]
            let   phone = "tel://"+personalProfile.mobileNumber
            UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
        }
    }
    
    
    @IBAction func goToDetailScreen(sender:UIButton){
        
        let navController = self.storyboard?.instantiateViewControllerWithIdentifier("prfileNav") as? UINavigationController
        
        let profileViewController = navController?.viewControllers.first as? ProfileViewController
        profileViewController?.delegate = self
        profileViewController?.personalProfile = self.personalProfile
        navController!.modalPresentationStyle = .Popover
        popOver = navController!.popoverPresentationController
        
        popOver.delegate = self
        popOver.sourceView = self.view
        popOver.sourceRect = self.view.bounds
        
        popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        profileViewController!.preferredContentSize = CGSize(width: 300, height:337)
       // navController.title = "Detail"
        //controller!.popoverPresentationController!.delegate = self
        //profileViewController!.view.backgroundColor = UIColor.clearColor()
        profileViewController!.popoverPresentationController?.backgroundColor = UIColor.grayColor()
        
        
        self.presentViewController(navController!, animated: true, completion: nil)

        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    func profileDismissied()
    {
         self.personalProfile = ProfileManager.sharedInstance.personalProfile
    }
    
    
    @IBAction func Clicked(sender:AnyObject)
    {
       
        self.dismissViewControllerAnimated(true, completion: nil)
         
        
        let alertVc = self.storyboard?.instantiateViewControllerWithIdentifier("AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(alertVc!, animated: true)
        
        
    }
    
    @IBAction override func favoriteButtonClicked(sender:UIButton)
    {
        sender.setImage(nil, forState: .Normal)
        sender.setTitle("+", forState: .Normal)
        if favoriteLabel?.text == "Add to Contact"
        {
            
            let con = CNMutableContact()
            con.givenName  = personalProfile.name

           // con.familyName = "Appleseed"
            con.phoneNumbers.append(CNLabeledValue(
                label: "Mobile Number", value: CNPhoneNumber(stringValue:             personalProfile.mobileNumber
          )))
            
            let addNewContactVC = CNContactViewController(forNewContact: con)
            addNewContactVC.contactStore = CNContactStore()
            addNewContactVC.delegate      = self
            addNewContactVC.allowsActions = false
            let nav = UINavigationController(rootViewController: addNewContactVC)
            let lightBlue = UIColor(hexString: "1F8DC8")
            let medBlue = UIColor(hexString: "FFFFFF")
            nav.navigationBar.tintColor =  appColor
            nav.navigationBar.barTintColor = UIColor.whiteColor()
            
             self.presentViewController(nav, animated: true, completion: nil)
            
        }else
        {
            super.favoriteButtonClicked(sender)
        }
        
        
    }
    
    func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact?)
    {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
