//
//  JoinViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import Firebase
import Contacts
import TSMessages

//import ReactiveCocoa
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ContactManager: NSObject
{
    static let sharedInstance = ContactManager()
}


extension UITableView
{
    func addBackGroundImageView()
    {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bg")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView = imageView
        
        
        let top = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let leading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        self.addConstraints([top, leading, trailing, bottom])
    }
}



class JoinViewController: ProfileViewController/*, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,*/, InputTableViewCellProtocol, ClickTableViewCellProtocol /*,UIPickerViewDataSource, UIPickerViewDelegate*/
{
    var objects = [CNContact]()
    var allValidContacts = [SearchPerson]()
  
    var dob:String = ""
    var notify_token:String = " "
   
    let k_firstName = "firstName"
    let k_lastName = "lastName"
    let k_id = "id"
    let k_email = "email"
    let k_loginType = "loginType"
    let k_photo = "photo"

    var completionHandler: (Float)->Void =
    {
        (arg: Float) -> Void in
    }
    var handler :(UIAlertAction) -> Void =
        { (arg: UIAlertAction) -> Void in
            
            print("do something");
    }
    
    
    var isLoadedFirstTime = false
    //var pickOption = ["Male", "Female"]
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.getProfileData()
        self.imageView?.makeImageRounded()
        self.automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyBoard(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyBoard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //tableView.addBackGroundImageView()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
}

extension JoinViewController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 7
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4

        {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "input", for: indexPath) as! InputTableViewCell
            cell.inputTextField.delegate = self
            cell.delegate = self
            if indexPath.row == 0
            {
                cell.inputTextField.placeholder =  kName
                cell.inputImage.image = UIImage(named: kName)
                cell.inputTextField.tag = 0
                
            }
            
            if indexPath.row == 1
            {
                cell.inputTextField.placeholder = kEmail
                cell.inputImage.image = UIImage(named: kEmail)
                cell.inputTextField.tag = 1
            }
            
            if indexPath.row == 2
            {
                cell.inputTextField.placeholder = kAddress
                cell.inputImage.image = UIImage(named: kAddress)
                cell.inputTextField.tag = 2
            }
            if indexPath.row == 3
            {
                cell.inputTextField.placeholder = kBirthDay
                cell.inputImage.image = UIImage(named: kBirthDay)
                cell.inputTextField.tag = 3
            
                let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: cell.inputTextField.frame.size.width, height: 44))
                
                var items = [UIBarButtonItem]()
                
                let  flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                
                let doneButton =     UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(JoinViewController.dissMissKeyBoard(_:)))
                
                items.append(flexibleSpaceLeft)
                items.append(doneButton)
                toolBar.items = items
                
                
                
                let datePicker = UIDatePicker()
                datePicker.maximumDate = Date()
                datePicker.addTarget(self, action: #selector(JoinViewController.handleDatePicker(_:)), for: .valueChanged)
                datePicker.datePickerMode = .date
                cell.inputTextField.inputView = datePicker
                cell.inputTextField.inputAccessoryView = toolBar
                
                
            }
            if indexPath.row == 4
            {
                cell.inputTextField.placeholder = kGender
                cell.inputImage.image = UIImage(named: kGender)
                cell.inputTextField.tag = 4
                let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: cell.inputTextField.frame.size.width, height: 44))
                
                var items = [UIBarButtonItem]()
                
                let  flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
                
                let doneButton =     UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(JoinViewController.dissMissKeyBoard(_:)))
                
                items.append(flexibleSpaceLeft)
                items.append(doneButton)
                toolBar.items = items
                
                
                
                let pickerView = UIPickerView()
                pickerView.delegate = self
                
                
                cell.inputTextField.inputView = pickerView
                cell.inputTextField.inputAccessoryView = toolBar
                
            }
            return cell
        }
        
        if indexPath.row == 5 || indexPath.row == 7
        {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath) as! ClickTableViewCell
        cell.delegate = self
        
        if indexPath.row == 5
        {
            cell.button.setTitle("Join", for: UIControlState())
            cell.widthConstraints?.constant = cell.contentView.bounds.size.width - 60
        }
            /*
        if indexPath.row == 6
        {
            cell.textLabel?.text = "Or"
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.makeImageRoundedWithGray()
            //cell.button.setTitle("Or", forState: .Normal)
            //cell.button.makeImageRoundedWithGray()
            //cell.button.backgroundColor = UIColor.blackColor()
            cell.button.userInteractionEnabled = false
            //let width = NSLayoutConstraint(item: cell.button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 30)
            
            //cell.button.addConstraint(width)
        }
        
             
        if indexPath.row == 6
        {
            cell.widthConstraints?.constant = 80
            cell.button.setTitle("Skip", forState: .Normal)
            cell.button.backgroundColor = UIColor.blackColor()
            let centerx = NSLayoutConstraint(item: cell.button, attribute: .CenterX, relatedBy: .Equal, toItem: cell.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0)
            cell.contentView.addConstraint(centerx)
        }*/
        
            
            if indexPath.row == 7
            {
                let  cell = tableView.dequeueReusableCell(withIdentifier: "FaceBookGoogleTableViewCell", for: indexPath) as! FaceBookGoogleTableViewCell
                cell.delegate = self
                 
                
            }
        
        return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaceBookGoogleTableViewCell", for: indexPath) as! FaceBookGoogleTableViewCell
        cell.delegate = self
                //cell.button.setTitle("Skip", forState: .Normal)
        return cell
        
      }
    
    
    override func handleDatePicker(_ sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.activeTextField?.text = dateFormatter.string(from: sender.date)
        self.dob = (self.activeTextField?.text)!
        
    }
    
    
    override func dissMissKeyBoard(_ sender:UIBarButtonItem)
    {
        if let datePicker =  self.activeTextField?.inputView as? UIDatePicker
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.activeTextField?.text = dateFormatter.string(from: datePicker.date)
            self.dob = (self.activeTextField?.text)!
        }
        
        if let picker = self.activeTextField?.inputView as? UIPickerView
        {
           
            self.activeTextField?.text = pickOption[ picker.selectedRow(inComponent: 0)]
            self.gender = (self.activeTextField?.text)!
            
        }
        self.activeTextField?.resignFirstResponder()
        
    }
    
    
    
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.activeTextField?.text = pickOption[row]
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 6
        {
            return 66
        }
        
        return 44
    }

}
extension JoinViewController
{
    func buttonClicked(_ cell: ClickTableViewCell)
    {
        //getFireBaseAuth()
        /*
        if cell.button.titleLabel?.text == "Skip"
        {
            print("Skip")
            self.dismiss(animated: false, completion: nil)
            let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
            appDelegate.window?.rootViewController = tabBarVC
            appDelegate.window?.makeKeyAndVisible()

        }*/
        
        if cell.button.titleLabel?.text == "Join"
        {
            print("join")
            
            print(" email:\(self.email), name:\(self.name),  web:\(self.dob ), address:f \(self.address) ")
            
            if self.name.characters.count == 0
            {
                self.displayAlertMessage("Please enter name")
                
            }/*else if self.email.characters.count == 0
            {
                self.displayAlertMessage("Please enter email")
                             }
            else if self.address.characters.count == 0
            {
                self.displayAlertMessage("Please enter address")
                
            }else if self.website.characters.count == 0
            {
                self.displayAlertMessage("Please enter website")
                
            }*/else
            {
                let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
                let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
                
                
                
                let dict = ["name":self.name, "email":self.email, "dob":self.dob, "address":self.address, "website":"webite", kapp_user_id:String(appUserId), kapp_user_token :appUserToken, "notify_token":"text", "gender":self.gender.lowercased()]
                postData(dict)
            }
        }
        
        
        if cell.isKind(of: FaceBookGoogleTableViewCell.self)
        {
            
            if cell.button.tag == 0
            {
                faceBookLogin()
            }else
            {
               // googleLogin()
            }
            
        }
    }
    
    func faceBookLogin()
    {
        if ((FBSDKAccessToken.current()) == nil)
        {
        let fbRequest = FBRequest()
        fbRequest.loginWithFacebook({ (result, error) in
            
            var dict = [String : String]()
            let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
            let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
             dict = [ kapp_user_id:String(appUserId), kapp_user_token :appUserToken, "notify_token":"text"]
            
            if(result!.object(forKey: "name") != nil)
            {
                let  strFirstName: String = (result!.object(forKey: "name") as? String)!
                dict["name"] = strFirstName
                
            }
            
            if(result!.object(forKey: "id") != nil)
            {
                
                let strID: String = (result!.object(forKey: "id") as? String)!
                dict[self.k_id] = strID
                
            }
            
            // if((result!.objectForKey("picture")!.objectForKey("data")!.objectForKey("url")! as! String) != nil){
            let strUrl: String = ((result!.object(forKey: "picture")! as AnyObject).object(forKey: "data")! as AnyObject).object(forKey: "url")! as! String
            dict[self.k_photo] = strUrl
            //}
            
            
            if strUrl.characters.count > 0
            {
                let url = URL(string: strUrl)
                let data = try? Data(contentsOf: url!)
                let image = UIImage(data: data!)
                self.imageFileSelected(image!)
            }
            
            if(result!.object(forKey: "email") != nil)
            {
                
                let strEmail: String = (result!.object(forKey: "email") as? String)!
                dict["email"] = strEmail
                
            }
            if(result!.object(forKey: "birthday") != nil)
            {
               " MM/DD/YYYY"
                let strEmail: String = (result!.object(forKey: "birthday") as? String)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
               let date = dateFormatter.date(from: strEmail)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dob = dateFormatter.string(from: date!)
                dict["dob"] = dob
                
            }
            if(result!.object(forKey: "location") != nil)
            {
                
                let strEmail: String = (result!.object(forKey: "location") as? String)!
                dict["address"] = strEmail
                
            }
            
            if(result!.object(forKey: "website") != nil)
            {
                
                let strEmail: String = (result!.object(forKey: "website") as? String)!
                dict["address"] = strEmail
                
            }
            if(result!.object(forKey: "gender") != nil)
            {
                
                let strEmail: String = (result!.object(forKey: "gender") as? String)!
                dict["gender"] = strEmail.lowercased()
                
            }
            
             self.postData(dict)
            
            if (error == nil)
            {
                
                
            }
            else
            {
                
            }
            
            },
        vc: self)
        }
    }
 
    /*
    func googleLogin()
    {
        GoogleLogin.sharedInstance.vc = self;
        GoogleLogin.sharedInstance.loginWithGoogle { (result, error) in
            if (error == nil)
            {
                    
                    
            }
            else
            {
                    
                    
            }
                
        }
    }*/
    override func displayAlert(_ userMessage: String, handler: ((UIAlertAction) -> Void)?)
    {
        
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        { (action) in
            //self.dismiss(animated: false, completion: nil)
            
            DispatchQueue.main.async(execute: {
                
                self.view.showSpinner()
                });
            DispatchQueue.global(qos: .userInitiated).async
                {
                    
                            self.getContacts()
            }
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func postData(_ dict:[String:String])
    {
         activeTextField?.resignFirstResponder()
        self.view.showSpinner()
        DataSessionManger.sharedInstance.updateProfile(dict, onFinish: { (response, deserializedResponse) in
            if deserializedResponse is NSDictionary
            {
                if deserializedResponse.object(forKey: "success") != nil
                {
                    DispatchQueue.main.async(execute: {
                        self.view.removeSpinner()
                        self.isLoadedFirstTime = true
                        self.displayAlert("Success", handler: nil)
                        
                    });
                }
            }
            
            
            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    self.displayAlertMessage(error as! String)
                    
                });
                
                
        }
    
    
    }
    
    
    func getTextsForCell(_ text: String, cell: InputTableViewCell)
    {
        if cell.inputTextField.tag == 0
        {
            self.name = text
            
        }
        if cell.inputTextField.tag == 1
        {
            self.email = text
        }
        if cell.inputTextField.tag == 2
        {
            self.address = text
        }
        if cell.inputTextField.tag == 3
        {
            self.dob = text
            
        }
        if cell.inputTextField.tag == 4
        {
            self.gender = text
            
        }
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.activeTextField = textField
    }
    override func textFieldDidEndEditing(_ textField: UITextField)
    {
        
        
    }
    
     override func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
            return true
    }
    
    override func showKeyBoard(_ notification: Notification)
    {
        if ((activeTextField?.superview?.superview?.superview!.isKind(of: InputTableViewCell.self)) != nil)
        {
            if let cell = activeTextField?.superview?.superview?.superview as? InputTableViewCell
            {
                let dictInfo: NSDictionary = notification.userInfo! as NSDictionary
                let kbSize :CGSize = ((dictInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size)
                let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
                self.tableView!.contentInset = contentInsets
                self.tableView!.scrollIndicatorInsets = contentInsets
              self.tableView!.scrollToRow(at: self.tableView!.indexPath(for: cell)!, at: .top, animated: true)
            }
        }
    }
    
    
    override func hideKeyBoard(_ notification: Notification)
    {
       if  activeTextField != nil
        {
            let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.tableView!.contentInset = contentInsets
            self.tableView!.scrollIndicatorInsets = contentInsets
        }
    }
}

extension JoinViewController
{
    
    func getFireBaseAuth()
    {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            
            // 2
            if let err = error { // 3
                print(err.localizedDescription)
                return
            }
            
            //self.performSegueWithIdentifier("LoginToChat", sender: nil) // 4
        })

    }
}

extension JoinViewController
{
    func getContacts()
    {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined
        {
            store.requestAccess(for: .contacts, completionHandler: ({ (authorized: Bool, error: Error?) -> Void in
                if authorized
                {
                    self.retrieveContactsWithStore(store)
                }else
                {
                    self.displayCantAddContactAlert()
                }
                }))
        }else if CNContactStore.authorizationStatus(for: .contacts) == .denied
        {
            self.displayCantAddContactAlert()
            
        }
            
        else if CNContactStore.authorizationStatus(for: .contacts) == .authorized
        {
            self.retrieveContactsWithStore(store)
        }
    }
    
    func displayCantAddContactAlert()
    {
        /*let okAction = UIAlertAction(title: "Change Settings",
         style: .Default,
         handler: { action in
         self.openSettings()
         })*/
        //let cancelAction =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        // showAlertWithMessage("You must give the app permission to add the contact first.", okAction: okAction, cancelAction: cancelAction)
        //displayAlert("You must give the app permission to add the contact first.", handler: nil)
        
        let alert = UIAlertController(title: "Alert", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Change Settings", style: .default) { (action) in
            self.openSettings()
            
        }
        let cancelAction =  UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    /*
     override func displayAlert(userMessage: String, handler: ((UIAlertAction) -> Void)?)
     {
     let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
     let okAction = UIAlertAction(title: "Change Settings", style: .Default) { (action) in
     self.openSettings()
     
     }
     let cancelAction =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
     alert.addAction(okAction)
     alert.addAction(cancelAction)
     self.presentViewController(alert, animated: true, completion: nil)
     
     }*/
    
    func showAlertWithMessage(_ message : String, okAction:UIAlertAction, cancelAction:UIAlertAction )
    {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    func openSettings()
    {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    func retrieveContactsWithStore(_ contactStore: CNContactStore)
    {
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            
            CNContactPhoneNumbersKey,
            ] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers
        {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do
            {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        self.objects = results
        allValidContacts.removeAll()
        for contact in self.objects
        {
            let formatter = CNContactFormatter()
            
            let name = formatter.string(from: contact)
            if let phone = contact.phoneNumbers.first?.value
            {
                let mobile = phone.value(forKey: "digits") as? String
                if name?.characters.count > 0 && mobile != nil
                {
                    let personContact = SearchPerson()
                    personContact.name = name!
                    personContact.mobileNumber =  mobile!
                    allValidContacts.append(personContact)
                }
                
            }
        }
        
        //1ProfileManager.sharedInstance.syncedContactArray.appendContentsOf(allValidContacts)
        
        /*allValidContacts.sortInPlace { (person1, person2) -> Bool in
         return person1.name < person2.name
         }*/
        
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            displayAlertMessage("No Internet Connection")
            
        }else
        {
            postData()
        }
    }
    
    func postData(){
        
        let stringtext = getJsonFromArray(allValidContacts)
        
        print("json:\(stringtext)")
        
        let trimmedString = stringtext.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        
        let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
        
        let dict = [kapp_user_id:String(appUserId), kapp_user_token :appUserToken]
        
        let postDict = ["contacts":trimmedString]
        
        postContactToServer(dict, postDict: postDict)
        
    }
    
    /*
    override func displayAlert(userMessage: String, handler: ((UIAlertAction) -> Void)?)
    {
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.getContact()
            //self.tableView.reloadData() hit web service
            self.view.removeSpinner()
            
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }*/
    
    func getContact()
    {
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            self.displayAlertMessage("No Internet Connection")
            
        }else
        {
            self.getContactForPage()
        }
        
    }
    
    func postContactToServer(_ dict:[String:String], postDict:[String:String])
    {
        //self.view.showSpinner()
        DataSessionManger.sharedInstance.syncContactToTheServer(dict, postDict:postDict,  onFinish: { (response, deserializedResponse) in
            
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.getContact()
                //self.view.removeSpinner()
            })
            if deserializedResponse.object(forKey: "success") != nil
            {
                DispatchQueue.main.async(execute: {
                    //self.view.removeSpinner()
                    self.displayAlert("Sync to server successfully ", handler: nil)
                    
                });
            }
            
            
        }) { (error) in
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.view.removeSpinner()
            })
            
        }
        
        
    }
    
    
    func moveToTabBar()
    {
        
        let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC") as? MyTabViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        appDelegate.window?.rootViewController = nil
        appDelegate.window?.rootViewController = tabBarVC
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func getContactForPage()
    {
        //self.view.showSpinner()
        
        //ProfileManager.sharedInstance.syncedContactArray.removeAll
        DataSessionManger.sharedInstance.getContactListForPage( { (response, contactPerson) in
            
            DispatchQueue.main.async(execute: { () -> Void in
            ProfileManager.sharedInstance.syncedContactArray.append(contentsOf: contactPerson.data)
               // self.tableView.reloadData()
                self.dismiss(animated: false, completion: nil)
                self.saveContacts(ProfileManager.sharedInstance.syncedContactArray)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ContactUpdated"), object: nil)
                self.view.removeSpinner()
                if self.isLoadedFirstTime
                {
                    self.moveToTabBar()
                }
                
            })
            
        }) { (error) in
            DispatchQueue.main.async(execute: { () -> Void in
               // self.tableView.reloadData()
               // self.view.removeSpinner()
            })
            
        }
    }
    
    func saveContacts(_ person:[SearchPerson])
    {
        let archivedObject = SearchPerson.archivePeople(person)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: contactStored)
        defaults.set(archivedObject, forKey: contactStored)
        defaults.synchronize()
    }
    
    
    
    //MARK: CONVERT TO JSON
    func getJsonFromArray(_ array: [PersonContact]) -> String
    {
        
        let jsonCompatibleArray = array.map { model in
            return [
                "name":model.name,
                "mobile_number":model.mobileNumber,
                
            ]
        }
        var errorinString = ""
        
        do
        {
            let data = try JSONSerialization.data(withJSONObject: jsonCompatibleArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if let json = json
            {
                errorinString = json as String
                print(json)
            }
            
        }
        catch
        {
            print(" in catch block")
            
        }
        return errorinString
    }
}

extension MainSearchViewController
{
    
    
}
