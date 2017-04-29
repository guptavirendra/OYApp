//
//  GoogleLogin.swift
//  GameKeeperApp
//
//  Created by Sushil Mishra on 5/31/16.
//  Copyright © 2016 Taazaa Inc. All rights reserved.
//

import UIKit
import CoreData


class  GoogleLogin: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    var completionBLock: CompletionHandler?
    var vc: UIViewController?
    var peopleDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    var playerFRC: NSFetchedResultsController? = nil
    
    /*
     * Creates a Singleton Instance
     */
    class var sharedInstance: GoogleLogin {
        struct Static {
            static var instance: GoogleLogin?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GoogleLogin()
        }
        
        return Static.instance!
    }

   
    
    
    func logoutGoogle() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    
    
    func loginWithGoogle(completion: CompletionHandler)  {
        self.completionBLock = completion;
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            //logoutGoogle()
            
            print("alredy login");
            
            return;
        }
        
        GIDSignIn.sharedInstance().delegate = self;
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn();
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        //GIDSignIn.sharedInstance().signInSilently()

    
    }
    
    
    //MARK: - GIDSignInDelegate
    
   
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }

    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            let url = user.profile.imageURLWithDimension(200)
            
            
            
            var dict = [String : AnyObject]()
            
            if(givenName != nil){
                let strFirstName: String = givenName
                dict[k_firstName] = strFirstName
            }
            if(familyName != nil){
                let strLastName: String = familyName
                dict[k_lastName] = strLastName
            }
            if(userId != nil){
                let strID: String = userId
                dict[k_id] = strID
            }
            if(email != nil){
                let strEmail: String = email
                dict[k_email] = strEmail
            }
            if(url != nil){
                let strUrl: String = url.absoluteString
                dict[k_photo] = strUrl
            }
            dict[k_loginType] = NSNumber(integer: LoginType.Google.rawValue)

            
            Authorization.sharedInstance.saveAuthorizedUserData(dict)
            
            User.build(dict)
            
            completionBLock?!(user, error)
            
            DLog("\(userId), \(fullName), \(email), \(idToken), \(givenName), \(familyName)")
            
            
            self.playerFRC = PlayerTemplate.playerFRC()
            
            
            if (self.playerFRC?.fetchedObjects?.count)! == 0{
                
                
                 PlayerTemplate.buildWithGoogle("\(dict[k_firstName]!) \(dict[k_lastName]!)" , photo:  dict[k_photo] as! String, id: dict[k_id] as! String);
                
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    //BackGround Sync Queue
                    self.getPeopleList()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                    })
                })

            }
            // ...
        } else {
            DLog("\(error.localizedDescription)")
            ActivityIndicator.stopActivityIndicatorOnView((vc?.view)!)

        }

    }
    
    
    //MARK: - GIDSignInUIDelegate
    
    
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        
        
         vc!.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        vc!.dismissViewControllerAnimated(true, completion: nil)
        ActivityIndicator.stopActivityIndicatorOnView((vc?.view)!)
    }
    

    //MARK: - mark get google circle friend list
    
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
        })
        task.resume()
    }

    
    
    func getPeopleList() {
        let urlString = ("https://www.googleapis.com/plus/v1/people/me/people/visible?access_token=\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)")
        let url = NSURL(string: urlString)
        
        performGetRequest(url, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                let resultsDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! Dictionary<String, AnyObject>
                
                // Get the array with people data dictionaries.
                let peopleArray = resultsDictionary["items"] as! Array<Dictionary<String, NSObject>>
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateDataInDB(peopleArray)

                })
            }
            else {
                DLog(HTTPStatusCode)
                DLog(error!)
            }
        })
    }
    
    
    func updateDataInDB(arr:[[String: NSObject]])  {
       
        let records = PlayerTemplate.buildWithGoogleUserFriends(arr);
        print(records);
    }
    
    
    
    
    
}
