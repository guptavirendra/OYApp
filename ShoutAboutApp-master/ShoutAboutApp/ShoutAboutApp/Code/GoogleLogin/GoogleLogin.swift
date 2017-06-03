//
//  GoogleLogin.swift
//  GameKeeperApp
//
//  Created by Sushil Mishra on 5/31/16.
//  Copyright © 2016 Taazaa Inc. All rights reserved.
//

import UIKit
import CoreData


class  GoogleLogin: NSObject, GIDSignInDelegate, GIDSignInUIDelegate
{
    private static var __once: () = {
            Static.instance = GoogleLogin()
        }()
    var completionBLock: CompletionHandler?
    var vc: UIViewController?
    var peopleDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    var playerFRC: NSFetchedResultsController? = nil
    
    /*
     * Creates a Singleton Instance
     */
    class var sharedInstance: GoogleLogin
    {
        struct Static
        {
            static var instance: GoogleLogin?
            static var token: Int = 0
        }
        
        _ = GoogleLogin.__once
        
        return Static.instance!
    }

   
    
    
    func logoutGoogle() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    
    
    func loginWithGoogle(_ completion: CompletionHandler)
    {
        self.completionBLock = completion;
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain()
        {
            //logoutGoogle()
            print("alredy login");
            return;
        }
        
        GIDSignIn.sharedInstance().delegate = self;
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        GIDSignIn.sharedInstance().signIn();
        //GIDSignIn.sharedInstance().signInSilently()
    }
    
    
    //MARK: - GIDSignInDelegate
    
   
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: NSError!)
    {
        
    }

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: NSError!)
    
    {
        
        if (error == nil)
        {
            // Perform any operations on signed in user here.
            let userId     = user.userID                  // For client-side use only!
            let idToken    = user.authentication.idToken // Safe to send to the server
            let fullName   = user.profile.name
            let givenName  = user.profile.givenName
            let familyName = user.profile.familyName
            let email      = user.profile.email
            let url        = user.profile.imageURL(withDimension: 200)
            
            var dict = [String : AnyObject]()
            
            if(givenName != nil)
            {
                let strFirstName: String = givenName
                dict["name"] = strFirstName
            }
            if(familyName != nil){
                let strLastName: String = familyName
                dict[""] = strLastName
            }
            if(userId != nil){
                let strID: String = userId
                dict["appuserId"] = strID
            }
            if(email != nil){
                let strEmail: String = email
                dict["email"] = strEmail
            }
            if(url != nil){
                let strUrl: String = url.absoluteString
                dict["photo"] = strUrl
            }
            //dict[k_loginType] = NSNumber(integer: LoginType.Google.rawValue)

            
            //Authorization.sharedInstance.saveAuthorizedUserData(dict)
            
           // User.build(dict)
            
            completionBLock?!(user, error)
            
           // DLog("\(userId), \(fullName), \(email), \(idToken), \(givenName), \(familyName)")
            
            
            //self.playerFRC = PlayerTemplate.playerFRC()
            
            
//            if (self.playerFRC?.fetchedObjects?.count)! == 0{
//                
//                
//                 PlayerTemplate.buildWithGoogle("\(dict[k_firstName]!) \(dict[k_lastName]!)" , photo:  dict[k_photo] as! String, id: dict[k_id] as! String);
//                
//                
//                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//                    //BackGround Sync Queue
//                    self.getPeopleList()
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        
//                    })
//                })
//
//            }
            // ...
        } else {
           // DLog("\(error.localizedDescription)")
            //ActivityIndicator.stopActivityIndicatorOnView((vc?.view)!)

        }

    }
    
    
    //MARK: - GIDSignInUIDelegate
    
    
    
    func sign(_ signIn: GIDSignIn!,
                present viewController: UIViewController!) {
        
        
         vc!.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
                dismiss viewController: UIViewController!) {
        vc!.dismiss(animated: true, completion: nil)
       // ActivityIndicator.stopActivityIndicatorOnView((vc?.view)!)
    }
    

    //MARK: - mark get google circle friend list
    
    
    func performGetRequest(_ targetURL: URL!, completion: (data: Data?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
        completion(data: data, HTTPStatusCode: (response as! HTTPURLResponse).statusCode, error: error)
        })
        task.resume()
    }

    
    
    func getPeopleList()
    {
        let urlString = ("https://www.googleapis.com/plus/v1/people/me/people/visible?access_token=\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)")
        let url = URL(string: urlString)
        
        performGetRequest(url, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                let resultsDictionary = (try! JSONSerialization.jsonObject(with: data!, options: [])) as! Dictionary<String, AnyObject>
                
                // Get the array with people data dictionaries.
                let peopleArray = resultsDictionary["items"] as! Array<Dictionary<String, NSObject>>
                DispatchQueue.main.async(execute: { () -> Void in
                    self.updateDataInDB(peopleArray)

                })
            }
            else {
               // DLog(HTTPStatusCode)
                //DLog(error!)
            }
        })
    }
    
    
    func updateDataInDB(_ arr:[[String: NSObject]])
    {
       
        //let records = PlayerTemplate.buildWithGoogleUserFriends(arr);
       // print(records);
    }
}
