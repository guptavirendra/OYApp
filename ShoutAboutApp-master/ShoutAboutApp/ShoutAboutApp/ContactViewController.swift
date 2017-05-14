//
//  ContactViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//


class PersonContact: NSObject
{
    var name:String  = ""
    var mobileNumber:String = ""
    
    override init()
    {
        self.name = ""
        self.mobileNumber = ""
    }
}


class ContactManger:NSObject
{
    static let sharedInstance = ContactManger()
    var  deviceContactArray    = [PersonContact]()
    
}

import UIKit

import Contacts
import ContactsUI
import XMPPFramework
import xmpp_messenger_ios
import CoreData

class ContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ContactTableViewCellProtocol, UISearchBarDelegate,UISearchControllerDelegate, CNContactViewControllerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    var xmppClient: STXMPPClient?
    var objects = [CNContact]()
    var allValidContacts = [PersonContact]()
    var syncContactArray = [SearchPerson]()
    var searchContactArray = [SearchPerson]()
    var nextPage         = 1
    var totalContact     = 0
    var lastPage         = 0
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearching:Bool = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ContactViewController.contactReload) , name: "ContactUpdated", object: nil)
        
        
        
        self.tableView.addBackGroundImageView()
        
       // self.tableView.backgroundColor = bgColor
       // self.getContacts()
        

        // Do any additional setup after loading the view.
        
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.searchBar.barTintColor = appColor
        searchController.searchBar.tintColor   = UIColor.whiteColor()
        searchController.searchBar.placeholder = "Number Or Name"
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.translucent = true
        self.extendedLayoutIncludesOpaqueBars = false
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ContactUpdated", object: nil)
        
    }
    
    func contactReload()
    {
        syncContactArray =  ProfileManager.sharedInstance.syncedContactArray
       /*
       syncContactArray =   syncContactArray.sort { (first, second) -> Bool in
           return first.app_user_token != nil
        }*/
        tableView.reloadData()
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        syncContactArray =  ProfileManager.sharedInstance.syncedContactArray
        
        dispatch_async(dispatch_get_global_queue(0, 0))
        {
            self.getContact()
        }
        
       
        //self.navigationController?.navigationBar.hidden = true
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ContactViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  isSearching ? searchContactArray.count: syncContactArray.count //allValidContacts.count //objects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("contact", forIndexPath: indexPath) as! ContactTableViewCell
        cell.delegate = self
        
        let personContact = isSearching ? searchContactArray[indexPath.row]: syncContactArray[indexPath.row]
        cell.nameLabel?.text = personContact.name
        cell.mobileLabel?.text = personContact.mobileNumber
        
        //cell.rateView!.rating =  personContact.reviewCount.count
        //cell.ratingLabel.text = String(personContact.reviewCount.count) + "/5"
        
       // if personContact.app_user_token != nil
       // {
            cell.revieBbutton!.hidden = false
            cell.rateView?.hidden    = false
            cell.ratingLabel!.hidden  = false
        
            if let count = personContact.reviewCount.first?.count
            {
                
                let title:String = String(count) + " reviews"
                cell.revieBbutton!.setTitle(title, forState: .Normal)
            }else
            {
                let title:String = String(0) + " reviews"
                cell.revieBbutton!.setTitle(title, forState: .Normal)
            }
            if let ratingAverage = personContact.ratingAverage.first?.average
            {
                cell.rateView!.rating = Int(Float(ratingAverage)!)
                cell.ratingLabel!.text   =  String(cell.rateView!.rating) + "/5"
            }else
            {
                cell.rateView!.rating =  0
                cell.ratingLabel!.text   =  String(cell.rateView!.rating) + "/5"
            }

        //}else
        //{
            //cell.revieBbutton.hidden = true
            //cell.rateView?.hidden    = true
            //cell.ratingLabel.hidden  = true
            
        //}
        
        
        
        if let urlString = personContact.photo
        {
            
            cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
        }else
        {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        return cell
    }
    
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
     func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0
        
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        
        let currentCount = indexPath.row + 1
        if (currentCount < self.totalContact)
        {
            if nextPage < lastPage && (syncContactArray.count == currentCount) 
            {
                nextPage += 1
               // self.getContact()
            }
        }
    }
    
    //MARK: CALL
    func buttonClicked(cell: ContactTableViewCell, button: UIButton)
    {
        if self.tableView.indexPathForCell(cell) != nil
        {
            let indexPath = self.tableView.indexPathForCell(cell)
            let personContact =  isSearching ? searchContactArray[(indexPath?.row)!]: syncContactArray[(indexPath?.row)!]
            if button.titleLabel?.text == " Call"
            {
                //let personContact = allValidContacts[indexPath!.row]
                let   phone = "tel://"+personContact.mobileNumber
                UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
            }
            else if button.titleLabel?.text == " Chat"
            {
                let stringID = String(personContact.idString)
                let ejabberID = stringID+"@localhost"
                let user =  OneRoster.userFromRosterForJID(jid: ejabberID)
                print("\(OneRoster.buddyList.sections)")
                //let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                
                //let user =   OneRoster.userFromRosterAtIndexPath(indexPath: indexPath!)
                
                let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatsViewController") as? ChatsViewController
                
                chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
                chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
                chatVc?.reciepientPerson         = personContact
                chatVc?.recipient = user
                self.navigationController!.pushViewController(chatVc!, animated: true)
                
            }
            else if button.titleLabel?.text?.containsString("reviews") == true
            {

                let rateANdReviewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RateANdReviewViewController") as? RateANdReviewViewController
                rateANdReviewViewController?.idString = String(personContact.idString)
                rateANdReviewViewController?.name = personContact.name
                if let _ = personContact.photo
                {
                    rateANdReviewViewController?.photo = personContact.photo!
                }
                 self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
                
                
            }else
            {
                let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
                profileViewController?.personalProfile = personContact
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
    }
}

extension ContactViewController
{
    /*
    func getContacts()
    {
        let store = CNContactStore()
        
         if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined
        {
            store.requestAccessForEntityType(.Contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
                if authorized
                {
                    self.retrieveContactsWithStore(store)
                }else
                {
                    self.displayCantAddContactAlert()
                }
            })
        }else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Denied
        {
            self.displayCantAddContactAlert()
            
        }
        
        else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized
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
        
        let alert = UIAlertController(title: "Alert", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Change Settings", style: .Default) { (action) in
            self.openSettings()
            
        }
        let cancelAction =  UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
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
    
    func showAlertWithMessage(message : String, okAction:UIAlertAction, cancelAction:UIAlertAction )
    {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    func openSettings()
    {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    func retrieveContactsWithStore(contactStore: CNContactStore)
    {
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            
            CNContactPhoneNumbersKey,
           ]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }

            self.objects = results
            allValidContacts.removeAll()
            for contact in self.objects
            {
                let formatter = CNContactFormatter()
                
                let name = formatter.stringFromContact(contact)
                let mobile = (contact.phoneNumbers.first?.value as! CNPhoneNumber).valueForKey("digits") as? String
                
                if name?.characters.count > 0 && mobile != nil
                {
                    let personContact = PersonContact()
                    personContact.name = name!
                    personContact.mobileNumber =  mobile!
                    allValidContacts.append(personContact)
                    
                    
                }
            }
        
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
    
    func postData()
    {
        let stringtext = getJsonFromArray(allValidContacts)
        print("json:\(stringtext)")
        
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
        
        let dict = ["contacts":stringtext, kapp_user_id:String(appUserId), kapp_user_token :appUserToken, ]
        postContactToServer(dict)
    }
    
    
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
        
    }
    
    func getContact()
    {
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            self.displayAlertMessage("No Internet Connection")
            
        }else
        {
            self.getContactForPage(String(self.nextPage))
        }
        
    }
    
    func postContactToServer(dict:[String:String])
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.syncContactToTheServer(dict, onFinish: { (response, deserializedResponse) in
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.view.removeSpinner()
            })
            if deserializedResponse.objectForKey("success") != nil
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.removeSpinner()
                    self.displayAlert("Sync to server successfully ", handler: nil)
                    
                });
            }
            
            
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.view.removeSpinner()
                })
                
        }
        
        
    }
    
    
    func getContactForPage(page:String)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getContactListForPage(page, onFinish: { (response, contactPerson) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.totalContact = contactPerson.total
                self.nextPage = contactPerson.current_page
                self.lastPage = contactPerson.last_page
                self.syncContactArray.appendContentsOf(contactPerson.data)
                self.tableView.reloadData()
                self.view.removeSpinner()
            })
            
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.view.removeSpinner()
                })
                
        }
    }
    
    func getJsonFromArray(array: [PersonContact]) -> String
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
            let data = try NSJSONSerialization.dataWithJSONObject(jsonCompatibleArray, options: NSJSONWritingOptions.PrettyPrinted)
            
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
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

    
    */
    
    
    func saveContacts(person:[SearchPerson])
    {
        
        let archivedObject = SearchPerson.archivePeople(person)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(contactStored)
        defaults.setObject(archivedObject, forKey: contactStored)
        defaults.synchronize()
    }
    
    
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
    
    
    func getContactForPage()
    {
        //self.view.showSpinner()
        
        //ProfileManager.sharedInstance.syncedContactArray.removeAll
        DataSessionManger.sharedInstance.getContactListForPage( { (response, contactPerson) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.saveContacts(ProfileManager.sharedInstance.syncedContactArray)
                ProfileManager.sharedInstance.syncedContactArray.removeAll()
                ProfileManager.sharedInstance.syncedContactArray.appendContentsOf(contactPerson.data)
                // self.tableView.reloadData()
               
                self.contactReload()
                self.view.removeSpinner()
            })
            
        }) { (error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // self.tableView.reloadData()
                // self.view.removeSpinner()
            })
            
        }
    }
    
}

extension ContactViewController
{
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        return true
    }
    
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        
    }
    
    
    internal func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if searchBar.text?.characters.count > 0
        {
            isSearching = true
            self.searchString(searchBar.text!)
        }else
        {
            isSearching = false
            tableView.reloadData()
        }
        
    }
    
    
    internal func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        isSearching = false
        tableView.reloadData()
    }
    
    
    internal func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.characters.count > 0
        {
            isSearching = true
        
            self.searchString(searchText)
        }else
        {
            isSearching = false
            tableView.reloadData()
        }
        
    }
    
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        
        
    }
    
    
    func  searchString(searchString:String)
    {
        let phonePredicate = NSPredicate(format: "(mobileNumber BEGINSWITH[c] %@) OR (name BEGINSWITH[c] %@)", searchString, searchString)
        
        
        searchContactArray =  syncContactArray.filter { phonePredicate.evaluateWithObject($0)
            
        };
        
        
        tableView.reloadData()
        
    }

}


extension ContactViewController
{
    
    @IBAction func  addContactScreen(sender:AnyObject)
    {
        let addNewContactVC = CNContactViewController(forNewContact: nil)
        addNewContactVC.contactStore = CNContactStore()
        addNewContactVC.delegate = self
        addNewContactVC.allowsActions = false
        let nav = UINavigationController(rootViewController: addNewContactVC)
        nav.navigationBar.tintColor =  appColor
        nav.navigationBar.barTintColor = UIColor.whiteColor()
        
        
        self.presentViewController(nav, animated: true, completion: nil)
    
    }
    
    func contactViewController(viewController: CNContactViewController, didCompleteWithContact contact: CNContact?)
    {
         viewController.dismissViewControllerAnimated(true, completion: nil)
        
        let joinVC = JoinViewController()
        joinVC.getContacts()
        
    }
    
      func contactViewController(viewController: CNContactViewController, shouldPerformDefaultActionForContactProperty property: CNContactProperty) -> Bool
    {
        return true
    }
}