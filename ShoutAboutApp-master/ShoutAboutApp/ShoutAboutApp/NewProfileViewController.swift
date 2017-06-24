//
//  NewProfileViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 29/01/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import ContactsUI
import XMPPFramework
import xmpp_messenger_ios


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
    
    @IBOutlet weak var ratReviewBaseScreen:UIView?
    @IBOutlet weak var rateView: RatingControl?
    @IBOutlet weak var ratingLabel: UILabel?
    @IBOutlet weak var totalReviewButton:UIButton?
    

    
    
    @IBOutlet weak var callButtonLeading:NSLayoutConstraint?
    @IBOutlet weak var callLabelLeading:NSLayoutConstraint?
    @IBOutlet weak var chatButtonWidth:NSLayoutConstraint?
    @IBOutlet weak var detailButtonTrailing:NSLayoutConstraint?
    @IBOutlet weak var detailLabelTrailing:NSLayoutConstraint?
    
    
    
    
    var isViewPresented:Bool?
        {
        didSet
        {
            self.doneButton?.isHidden = false
            self.doneButton?.setTitle("Done", for: UIControlState())
            self.doneButton?.titleLabel?.textColor = UIColor.white
            self.doneButton?.setImage(nil, for: UIControlState())
            
        }
    }
    
    
    
    var shouldDisabledUserInteraction:Bool = true
    @IBOutlet weak var doneButton:UIButton?

     var popOver : UIPopoverPresentationController!
    
    override var personalProfile: SearchPerson{
        
        didSet
        {
            nameLabel?.text     = personalProfile.name
            locationLabel?.text = personalProfile.address
            
            self.updateData()
            
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.doneButton?.isHidden = true
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.isHidden    = false
        ratReviewBaseScreen?.layer.cornerRadius = 5.0
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        
    }
    
    
    func updateData()
    {
        let isExisingContact  = ProfileManager.sharedInstance.syncedContactArray.contains
            { (person) -> Bool in
                return person.mobileNumber == personalProfile.mobileNumber
        }
        if isExisingContact == false
        {
            favoriteLabel?.text = "Add to Contact"
            favoriteButton?.setImage(nil, for: UIControlState())
            favoriteButton?.setTitle("+", for: UIControlState())
            
        }
        
        
        
        self.view.isUserInteractionEnabled = self.shouldDisabledUserInteraction
        self.navigationController?.isNavigationBarHidden = false
        //self.navigationController?.navigationBar.tintColor = appColor
        nameLabel?.text     = personalProfile.name
        locationLabel?.text = personalProfile.address
        
        if let _ = personalProfile.ratingAverage.first?.average
        {
            rateView?.rating    = Int(Float(personalProfile.ratingAverage.first!.average)!)
            ratingLabel!.text    = "Avearge Rating:" + String(personalProfile.ratingAverage.first!.average)
        }else
        {
            ratingLabel!.text    = "Avearge Rating:0"
        }
        var  totalreviewString = ""
        if let _ = personalProfile.reviewCount.first?.count
        {
            totalreviewString = "Total Review:"+String(personalProfile.reviewCount.first!.count)
            
        }else
        {
            totalreviewString = "Total Review: 0"
        }
        
        totalReviewButton?.setTitle(totalreviewString, for: UIControlState())
        
        
        
        if personalProfile.idString == ProfileManager.sharedInstance.personalProfile.idString
        {
            self.spamBlockBaseView?.isHidden = true
            self.cameraButton!.isHidden      = false
            callLabel?.text                = "Status"
            chatLabel?.isHidden              = true
            chatLabel?.text                = "Review"
            callButtonLeading?.constant    = 40.0
            callLabelLeading?.constant     = 40.0
            chatButtonWidth?.constant      = 0.0
            detailButtonTrailing?.constant = 40.0
            detailLabelTrailing?.constant  = 40.0
            callButton?.setImage(UIImage(named: "message"), for: UIControlState())
            
        }else
        {
            self.spamBlockBaseView?.isHidden = false
            self.cameraButton!.isHidden      = true
            
        }

        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.updateData()
        
    }
    


    @IBAction override func goToReviewScreen(_ sender:UIButton)
    {
        if sender.tag == 7
        {
            
            let rateANdReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateANdReviewViewController") as? RateANdReviewViewController
            
            rateANdReviewViewController?.idString = String(personalProfile.idString)
            rateANdReviewViewController?.name = personalProfile.name
            if let _ = personalProfile.photo
            {
                rateANdReviewViewController?.photo = personalProfile.photo!
            }
            
            self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
            
        }else
        {
            let stringID = String(personalProfile.idString)
            let ejabberID = stringID+"@localhost"
            let user =  OneRoster.userFromRosterForJID(jid: ejabberID)
            print("\(String(describing: OneRoster.buddyList.sections))")
            //let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
            
            //let user =   OneRoster.userFromRosterAtIndexPath(indexPath: indexPath!)
            
            let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatsViewController") as? ChatsViewController
            
            chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
            chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
            chatVc?.reciepientPerson         =  personalProfile
            chatVc?.recipient = user
            self.navigationController!.pushViewController(chatVc!, animated: true)
            
        }
    }
    
    
    @IBAction func callStatusScreen()
    {
        if  callLabel?.text == "Status"
        {
            
            var inputTextField: UITextField?
            let passwordPrompt = UIAlertController(title: "Status", message: "", preferredStyle: UIAlertControllerStyle.alert)
            passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                // Now do whatever you want with inputTextField (remember to unwrap the optional)
                
                let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
                let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
                
                var  email = ""
                if let _ = self.personalProfile.email
                {
                    email = self.personalProfile.email!
                    
                }
                
                var birthday = ""
                
                if let _ = self.personalProfile.birthday
                {
                    birthday = self.personalProfile.birthday!
                    
                }
                var gender = ""
                if let _ = self.personalProfile.gender
                {
                    gender = self.personalProfile.gender!
                    
                }
                
                
                var  address = ""
                if let _ = self.personalProfile.address
                {
                    address = self.personalProfile.address!
                    
                }
                
                
                let dict = ["status":inputTextField!.text!, "name":self.personalProfile.name, "email":email, "dob":birthday, "gender":gender, "address":address, kapp_user_id:String(appUserId), kapp_user_token :appUserToken, "notify_token":"text"]
                
                   self.postData(dict)
                print(" sta\(inputTextField!.text)")
            }))
            passwordPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.text        = self.personalProfile.status
                textField.placeholder = "Status"
                textField.borderStyle = .none
                inputTextField = textField
                
            })
            
            present(passwordPrompt, animated: true, completion: nil)
            
            
        }else
        {
            //let personContact = allValidContacts[indexPath!.row]
            let   phone = "tel://"+personalProfile.mobileNumber
            UIApplication.shared.openURL(URL(string: phone)!)
        }
    }
    
    
    @IBAction func goToDetailScreen(_ sender:UIButton){
        
        let navController = self.storyboard?.instantiateViewController(withIdentifier: "prfileNav") as? UINavigationController
        
        let profileViewController = navController?.viewControllers.first as? ProfileViewController
        profileViewController?.delegate = self
        profileViewController?.personalProfile = self.personalProfile
        navController!.modalPresentationStyle = .popover
        popOver = navController!.popoverPresentationController
        
        popOver.delegate = self
        popOver.sourceView = self.view
        popOver.sourceRect = self.view.bounds
        
        popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        profileViewController!.preferredContentSize = CGSize(width: 300, height:337)
       // navController.title = "Detail"
        //controller!.popoverPresentationController!.delegate = self
        //profileViewController!.view.backgroundColor = UIColor.clearColor()
        profileViewController!.popoverPresentationController?.backgroundColor = UIColor.gray
        
        
        self.present(navController!, animated: true, completion: nil)

        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    func profileDismissied()
    {
         self.personalProfile = ProfileManager.sharedInstance.personalProfile
    }
    
    
    @IBAction func Clicked(_ sender:AnyObject)
    {
       
        self.dismiss(animated: true, completion: nil)
         
        
        let alertVc = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController
        self.navigationController!.pushViewController(alertVc!, animated: true)
        
        
    }
    
    @IBAction override func favoriteButtonClicked(_ sender:UIButton)
    {
        //sender.setImage(nil, forState: .Normal)
        //sender.setTitle("+", forState: .Normal)
        if favoriteLabel?.text == "Add to Contact"
        {
            
            let con = CNMutableContact()
            con.givenName  = personalProfile.name

           // con.familyName = "Appleseed"
            con.phoneNumbers.append(CNLabeledValue(
                label: "Mobile Number", value: CNPhoneNumber(stringValue: personalProfile.mobileNumber
          )))
            
            let addNewContactVC = CNContactViewController(forNewContact: con)
            addNewContactVC.contactStore = CNContactStore()
            addNewContactVC.delegate      = self
            addNewContactVC.allowsActions = false
            let nav = UINavigationController(rootViewController: addNewContactVC)
            //let lightBlue = UIColor(hexString: "1F8DC8")
            //let medBlue = UIColor(hexString: "FFFFFF")
            //nav.navigationBar.tintColor =  appColor
            //nav.navigationBar.barTintColor = UIColor.white
            
             self.present(nav, animated: true, completion: nil)
            
        }else
        {
            super.favoriteButtonClicked(sender)
        }
        
        
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?)
    {
        viewController.dismiss(animated: true, completion: nil)
        let joinVC = JoinViewController()
        joinVC.getContacts()
         
    }
    
}
