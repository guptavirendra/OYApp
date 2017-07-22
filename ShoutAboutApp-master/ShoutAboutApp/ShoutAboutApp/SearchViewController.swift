//
//  SearchViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios
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
        searchController.prefersStatusBarHidden
        setHistoryArray()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "message")
        self.view.backgroundColor = appColor
        searchController.searchBar.delegate = self
        definesPresentationContext = true

        searchController.searchBar.barTintColor = appColor
        //searchController.searchBar.tintColor   = UIColor.whiteColor()
        searchController.searchBar.placeholder = "Number Or Name"
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.isTranslucent = true
        self.extendedLayoutIncludesOpaqueBars = true
        
    }
    
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition
    {
         return .top
    }
    
    override var prefersStatusBarHidden : Bool
    {
        return true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.searchController.searchBar.text = nil
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
        DispatchQueue.main.async(execute: {
            self.searchController.searchBar.becomeFirstResponder()
        })
        
    }
    
    
}

extension SearchViewController
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
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
    
    
    func returnCellForTableView(_ tableView: UITableView, indexPath: IndexPath, dataArray:[SearchPerson])->UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact", for: indexPath) as! ContactTableViewCell
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
            cell.callButton.isUserInteractionEnabled = true
            cell.chaBbutton.isUserInteractionEnabled = true
            cell.revieBbutton?.isUserInteractionEnabled = true
            
           //cell.userInteractionEnabled = true
            
            
        }else
        {
            if personContact.mobileNumber.characters.count == 0
            {
                cell.callButton.isUserInteractionEnabled = false
                cell.chaBbutton.isUserInteractionEnabled = false
                cell.revieBbutton?.isUserInteractionEnabled = false
                //cell.userInteractionEnabled = false
            }else
            {
                //cell.userInteractionEnabled = true
                cell.callButton.isUserInteractionEnabled = true
                cell.chaBbutton.isUserInteractionEnabled = true
                cell.revieBbutton?.isUserInteractionEnabled = true
            }
            
        }
        cell.nameLabel?.text = personContact.name
        cell.mobileLabel?.text = personContact.mobileNumber
        if let urlString = personContact.photo
        {
            cell.profileImageView.sd_setImage(with: URL(string:urlString ), placeholderImage: UIImage(named: "profile"))
            
        }else
        {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        
        if let count = personContact.reviewCount.first?.count
        {
            
            let title:String = String(count) + " reviews"
            cell.revieBbutton!.setTitle(title, for: UIControlState())
        }else
        {
            let title:String = String(0) + " reviews"
            cell.revieBbutton!.setTitle(title, for: UIControlState())
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if isSearching == false
        {
            if historyArray.count > 0
            {
               let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath)
               
                
                if historyArray.count == indexPath.row
                {
                    cell.textLabel?.text = "Clear recent searches"
                    cell.textLabel?.textColor = UIColor.red
                    cell.imageView?.image = UIImage(named: "cross")?.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor.red
                    
                }else
                {
                    cell.textLabel?.text = historyArray[indexPath.row]
                    cell.textLabel?.textColor = UIColor.black
                    cell.imageView?.image = UIImage(named: "tab_search-h@x")!.withRenderingMode(.alwaysTemplate)
                    cell.imageView?.tintColor = UIColor.gray
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    func buttonClicked(_ cell: ContactTableViewCell, button: UIButton)
    { 
        if self.tableView.indexPath(for: cell) != nil
        {
            if let indexPath = self.tableView.indexPath(for: cell)
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
                UIApplication.shared.openURL(URL(string: phone)!)
            }
            else if button.titleLabel?.text == " Chat"
            {
                let stringID = String(personContact.idString)
                let ejabberID = stringID+"@localhost"
                let user =  OneRoster.userFromRosterForJID(jid: ejabberID)
                print("\(OneRoster.buddyList.sections)")
                //let chattingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChattingViewController") as? ChattingViewController
                
                //let user =   OneRoster.userFromRosterAtIndexPath(indexPath: indexPath!)
                
                let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatsViewController") as? ChatsViewController
                
                chatVc!.senderDisplayName = ProfileManager.sharedInstance.personalProfile.name
                chatVc?.senderId          = String(ProfileManager.sharedInstance.personalProfile.idString)
                chatVc?.reciepientPerson         = personContact
                chatVc?.recipient = user
                chatVc?.hidesBottomBarWhenPushed = true

                self.navigationController?.isNavigationBarHidden = false
                self.navigationController!.pushViewController(chatVc!, animated: true)
                
            }
            else if button.titleLabel?.text == "reviews"
            {
                
                let rateANdReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateANdReviewViewController") as? RateANdReviewViewController
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
                    let isContains = searchArray?.contains(where: { (person) -> Bool in
                        return person.idString == personContact.idString
                    })
                    if isContains == true
                    {
                        let index = searchArray?.index(where: { (person) -> Bool in
                            return person.idString == personContact.idString
                        })
                        searchArray?.remove(at: index!)
                        
                    }
                    if searchArray?.count > 30
                    {
                        searchArray?.removeFirst()
                    }
                    searchArray?.append(personContact)
                    
                }else
                {
                   let isContains = searchArray?.contains(where: { (person) -> Bool in
                        return person.idString == personContact.idString
                    })
                    if isContains == true
                    {
                       let index = searchArray?.index(where: { (person) -> Bool in
                            return person.idString == personContact.idString
                        })
                        
                       searchArray?.remove(at: index!)
                        
                    }
                     searchArray?.append(personContact)
                    
                }

                self.savePerson(searchArray!)
                
                
                let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController
                
                profileViewController?.shouldDisabledUserInteraction = cell.chaBbutton.isUserInteractionEnabled
                profileViewController?.personalProfile = personContact
                 self.navigationController?.navigationBar.isHidden = false
                self.navigationController!.pushViewController(profileViewController!, animated: true)
            }
        }
        }
    }
}

extension SearchViewController
{
   
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true
    }
    
    
    
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        
    }
    
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        isSeaechingLocal = false
        isSearching      = true
        tableView.allowsSelection = !isSearching
        saveSearchHistory(searchBar.text!)
        getSearchForText(searchBar.text!)
        
    }
    
    
    internal func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        allValidContacts.removeAll()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
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

    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
       
        
    }
}

extension SearchViewController
{
    func getSearchForText(_ text:String)
    {
        allValidContacts.removeAll()
        self.view.showSpinner()
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
        
         let dict = ["search":text,  kapp_user_id:String(appUserId), kapp_user_token :appUserToken, ]
        
        DataSessionManger.sharedInstance.searchContact(dict, onFinish: { (response, deserializedResponse, errorMessage) in
            
            self.isSeaechingLocal = false
            DispatchQueue.main.async(execute: {
                    //self.allValidContacts.appendContentsOf(self.localContactArray)
                    
                let localSet =   Set(self.localContactArray)
                let apiSet  = Set(deserializedResponse)
                    self.allValidContacts.append(                    contentsOf: localSet.union(apiSet)
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
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
               // self.displayAlert("Success", handler: self.handler)
                
            });//
        }
        
    }
    
    func savePerson(_ person:[SearchPerson])
    {
        
        let archivedObject = SearchPerson.archivePeople(person)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: searchHistory)
        defaults.set(archivedObject, forKey: searchHistory)
        defaults.synchronize()
    }
    
    func saveSearchHistory(_ searchText:String)
    {
        let defaults = UserDefaults.standard
        var array   = defaults.object(forKey: "searchString") as? [String]
        if array?.count > 30
        {
            array?.removeLast()
            array?.insert(searchText, at: 0)
        }
        if array == nil
        {
            array = [String]()
        }
        array?.insert(searchText, at: 0)
        defaults.set(array, forKey: "searchString")
        historyArray.removeAll()
        historyArray.append(contentsOf: array!)
        
    }
    
    func setHistoryArray()
    {
        let defaults = UserDefaults.standard
        let array   = defaults.object(forKey: "searchString") as? [String]
        if array?.count > 0
        {
            historyArray.removeAll()
            historyArray.append(contentsOf: array!)
        }
        
    }
    func clearHistory()
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "searchString")
        historyArray.removeAll()
        self.tableView.reloadData()
        
    }
    
    func retrievePearson() -> [SearchPerson]?
    {
        if let unarchivedObject = UserDefaults.standard.object(forKey: searchHistory) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [SearchPerson]
        }
        return nil
    }
}


extension SearchViewController
{
    func  searchString(_ searchString:String)
    {
        isSearching = true
        tableView.allowsSelection = !isSearching
        //let namePredicate  = NSPredicate(format: "(name BEGINSWITH[c] %@)", searchString)
        
        
       // let predicateArray = [namePredicate, phonePredicate]
       // let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        
     let phonePredicate = NSPredicate(format: "(mobileNumber BEGINSWITH[c] %@) OR (name BEGINSWITH[c] %@)", searchString, searchString)
        
    localContactArray  =  ProfileManager.sharedInstance.syncedContactArray.filter
            { phonePredicate.evaluate(with: $0)
        };
        
    tableView.reloadData()
        
    }
}

extension SearchViewController
{
    func textFieldShouldClear(_ textField: UITextField) -> Bool
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
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        self.searchController.searchBar.resignFirstResponder()
        
    }
}
