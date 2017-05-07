//
//  SearchViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate,UISearchControllerDelegate, ContactTableViewCellProtocol, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationBarDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var allValidContacts  = [SearchPerson]()
    var localContactArray = [SearchPerson]()
    var historyArray      = [String]()
    var errorMessage:String?
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSeaechingLocal:Bool = true
    var isSearching:Bool      = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       // self.setStatusBarStyle(<#T##statusBarStyle: UIStatusBarStyle##UIStatusBarStyle#>)
        searchController.prefersStatusBarHidden()
        setHistoryArray()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "message")
        self.view.backgroundColor = appColor
        searchController.searchBar.delegate = self
        definesPresentationContext = true

        searchController.searchBar.barTintColor = appColor
        searchController.searchBar.tintColor   = UIColor.whiteColor()
        searchController.searchBar.placeholder = "Number Or Name"
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
       // searchController.searchBar.translucent = true
        //self.extendedLayoutIncludesOpaqueBars = true
        
    }
    
    
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition
    {
         return .Top
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.searchController.searchBar.text = nil
        self.navigationController?.navigationBar.hidden = true
        
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.searchController.active = true
        dispatch_async(dispatch_get_main_queue(),
                       {
            self.searchController.searchBar.becomeFirstResponder()
        })
        
    }
    
    
}

extension SearchViewController
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isSearching == false
        {
            if historyArray.count > 0
            {
                return historyArray.count + 1
            }
            return historyArray.count
            
        }else
        {
            
            if isSeaechingLocal == true
            {
                return localContactArray.count
            }
            else
            {
                if allValidContacts.count > 0
                {
                    return  allValidContacts.count //objects.count
                }
            }
        }
        return 0
    }
    
    
    func returnCellForTableView(tableView: UITableView, indexPath: NSIndexPath, dataArray:[SearchPerson])->UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("contact", forIndexPath: indexPath) as! ContactTableViewCell
        cell.delegate = self
        
        let personContact = dataArray[indexPath.row]
        
        
        
        let isExisingContact = ProfileManager.sharedInstance.syncedContactArray.contains
        { (person) -> Bool in
           return person.mobileNumber == personContact.mobileNumber
        }
        /*if ProfileManager.sharedInstance.syncedContactArray.contains(personContact)
        {*/
        if isExisingContact
        {
            cell.callButton.userInteractionEnabled = true
            cell.chaBbutton.userInteractionEnabled = true
            cell.revieBbutton?.userInteractionEnabled = true
            
           //cell.userInteractionEnabled = true
            
            
        }else
        {
            if personContact.mobileNumber.characters.count == 0
            {
                cell.callButton.userInteractionEnabled = false
                cell.chaBbutton.userInteractionEnabled = false
                cell.revieBbutton?.userInteractionEnabled = false
                //cell.userInteractionEnabled = false
            }else
            {
                //cell.userInteractionEnabled = true
                cell.callButton.userInteractionEnabled = true
                cell.chaBbutton.userInteractionEnabled = true
                cell.revieBbutton?.userInteractionEnabled = true
            }
            
        }
        cell.nameLabel?.text = personContact.name
        cell.mobileLabel?.text = personContact.mobileNumber
        if let urlString = personContact.photo
        {
            cell.profileImageView.setImageWithURL(NSURL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
        }else
        {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if isSearching == false
        {
            if historyArray.count > 0
            {
               let cell = tableView.dequeueReusableCellWithIdentifier("message", forIndexPath: indexPath)
               
                
                if historyArray.count == indexPath.row
                {
                    cell.textLabel?.text = "Clear recent searches"
                    cell.textLabel?.textColor = UIColor.redColor()
                    cell.imageView?.image = UIImage(named: "cross")?.imageWithRenderingMode(.AlwaysTemplate)
                    cell.imageView?.tintColor = UIColor.redColor()
                    
                }else
                {
                    cell.textLabel?.text = historyArray[indexPath.row]
                    cell.textLabel?.textColor = UIColor.blackColor()
                    cell.imageView?.image = UIImage(named: "tab_search-h@x")!.imageWithRenderingMode(.AlwaysTemplate)
                    cell.imageView?.tintColor = UIColor.grayColor()
                }
              return cell
            }
            
        }else
        {
            if isSeaechingLocal == true
            {
                return returnCellForTableView(tableView, indexPath: indexPath, dataArray: localContactArray)
            }else
            {
                if allValidContacts.count > 0
                {
                    
                    return returnCellForTableView(tableView, indexPath: indexPath, dataArray: allValidContacts)
                }
            }
        }
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if isSearching == false
        {
            
            if indexPath.row == historyArray.count{
                
               clearHistory()
                
            }else{
                
                isSearching = true
                tableView.allowsSelection = !isSearching
                self.tableView.reloadData()
                let searchText = historyArray[indexPath.row]
                self.searchController.searchBar.text = searchText
                self.searchController.searchBar.delegate?.searchBarSearchButtonClicked!(self.searchController.searchBar)
            }
        }
        
    }
    
    //MARK: CALL
    func buttonClicked(cell: ContactTableViewCell, button: UIButton)
    { 
        if self.tableView.indexPathForCell(cell) != nil
        {
            if let indexPath = self.tableView.indexPathForCell(cell)
            {
                var personContact = SearchPerson()
                if isSeaechingLocal == true
                {
                   personContact =  localContactArray[indexPath.row]
                }else
                {
                    personContact = allValidContacts[indexPath.row]
                    
                }
            
             
            if button.titleLabel?.text == " Call"
            {
                let personContact = allValidContacts[indexPath.row]
                let   phone = "tel://"+personContact.mobileNumber
                UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
            }
            else if button.titleLabel?.text == " Chat"
            {
                let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                self.navigationController!.pushViewController(chattingViewController!, animated: true)
                
            }
            else if button.titleLabel?.text == "reviews"
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
                var searchArray = self.retrievePearson()
                
                if searchArray == nil
                {
                    searchArray = [SearchPerson]()
                    
                }
                if searchArray?.count > 30
                {
                    searchArray?.removeFirst()
                    searchArray?.append(personContact)
                    
                }else
                {
                     searchArray?.append(personContact)
                    
                }

                self.savePerson(searchArray!)
                
                
                let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as? NewProfileViewController
                
                profileViewController?.shouldDisabledUserInteraction = cell.chaBbutton.userInteractionEnabled
                profileViewController?.personalProfile = personContact
                
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
        }
    }
}

extension SearchViewController
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
        isSeaechingLocal = false
        isSearching      = true
        tableView.allowsSelection = !isSearching
        saveSearchHistory(searchBar.text!)
        getSearchForText(searchBar.text!)
        
    }
    
    
    internal func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        allValidContacts.removeAll()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    internal func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.characters.count > 0
        {
            searchString(searchText)
        }else
        {
            isSearching = false
            tableView.allowsSelection = !isSearching
            isSeaechingLocal = true
            allValidContacts.removeAll()
            self.tableView.reloadData()
        }
        
        
    }

    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
       
        
    }
}

extension SearchViewController
{
    func getSearchForText(text:String)
    {
        allValidContacts.removeAll()
        self.view.showSpinner()
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
        
         let dict = ["search":text,  kapp_user_id:String(appUserId), kapp_user_token :appUserToken, ]
        
        DataSessionManger.sharedInstance.searchContact(dict, onFinish: { (response, deserializedResponse, errorMessage) in
            
            self.isSeaechingLocal = false
            dispatch_async(dispatch_get_main_queue(),
                {
                    //self.allValidContacts.appendContentsOf(self.localContactArray)
                    
                  let localSet =   Set(self.localContactArray)
                let apiSet  = Set(deserializedResponse)
                    self.allValidContacts.appendContentsOf(                    localSet.union(apiSet)
)
                    //self.allValidContacts.appendContentsOf(deserializedResponse)
                    //self.allValidContacts = deserializedResponse
                    
                    // NSUserDefaults.standardUserDefaults().setObject(searchArray, forKey: searchHistory)
                    self.view.removeSpinner()
                    self.tableView.reloadData()
                    self.errorMessage = errorMessage
                
                
            });
            
        }) { (error) in
            self.isSeaechingLocal = false
            dispatch_async(dispatch_get_main_queue(), {
                self.view.removeSpinner()
               // self.displayAlert("Success", handler: self.handler)
                
            });//
        }
        
    }
    
    func savePerson(person:[SearchPerson])
    {
        let archivedObject = SearchPerson.archivePeople(person)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: searchHistory)
        defaults.synchronize()
    }
    
    func saveSearchHistory(searchText:String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var array   = defaults.objectForKey("searchString") as? [String]
        if array?.count > 30
        {
            array?.removeLast()
            array?.insert(searchText, atIndex: 0)
        }
        if array == nil
        {
            array = [String]()
        }
        array?.insert(searchText, atIndex: 0)
        defaults.setObject(array, forKey: "searchString")
        historyArray.removeAll()
        historyArray.appendContentsOf(array!)
        
    }
    
    func setHistoryArray()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let array   = defaults.objectForKey("searchString") as? [String]
        if array?.count > 0
        {
            historyArray.removeAll()
            historyArray.appendContentsOf(array!)
        }
        
    }
    func clearHistory()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("searchString")
        historyArray.removeAll()
        self.tableView.reloadData()
        
    }
    
    func retrievePearson() -> [SearchPerson]?
    {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(searchHistory) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [SearchPerson]
        }
        return nil
    }
}


extension SearchViewController
{
    func  searchString(searchString:String)
    {
        isSearching = true
        tableView.allowsSelection = !isSearching
        //let namePredicate  = NSPredicate(format: "(name BEGINSWITH[c] %@)", searchString)
        
        
       // let predicateArray = [namePredicate, phonePredicate]
       // let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        
     let phonePredicate = NSPredicate(format: "(mobileNumber BEGINSWITH[c] %@) OR (name BEGINSWITH[c] %@)", searchString, searchString)
        
    localContactArray  =  ProfileManager.sharedInstance.syncedContactArray.filter
            { phonePredicate.evaluateWithObject($0)
        };
        
    tableView.reloadData()
        
    }
}

extension SearchViewController
{
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
        self.clearText()
        return true
    }
    
    func clearText()
    {
        isSearching = false
        tableView.allowsSelection = !isSearching
        localContactArray.removeAll()
        allValidContacts.removeAll()
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView)
    {
        self.searchController.searchBar.resignFirstResponder()
        
    }
}
