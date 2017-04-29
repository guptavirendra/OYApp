//
//  FBRequest.swift
//  GameKeeperApp
//
//  Created by Sushil Mishra on 4/20/16.
//  Copyright © 2016 Taazaa Inc. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


typealias CompletionHandler = ((AnyObject?,NSError?)-> Void)?

class FBRequest: NSObject {
    
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    
    func loginWithFacebook(successBlock:CompletionHandler ,vc:UIViewController) {
        
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        fbLoginManager.logInWithReadPermissions(facebookReadPermissions, fromViewController: vc,handler: { (result, error) -> Void in
            if (error == nil){
                
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if fbloginresult.grantedPermissions != nil{
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    if(successBlock != nil) {
                        
                        self.getFBUserData(successBlock);
                       
                    }
                }
                }
                else{
                ActivityIndicator.stopActivityIndicatorOnView(vc.view)
                }
            }
        })

    }
    
    func logoutFacebook() {
        fbLoginManager.logOut()
    }
    
    func getFBUserData(success: CompletionHandler){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    if(success != nil) {
                    
                     success!(result, error);
                        
                        
                        
                    }
                                        
                }
            })
        }
    }
    
    
    
    func fetchFacebookFriendList(){
        
    
        let request = FBSDKGraphRequest(graphPath:"/me?fields=invitable_friends", parameters: nil);
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            let resultdict = result as! NSDictionary
            DLog("Result Dict: \(resultdict)")
            
                    let friendArr : [AnyObject] = (resultdict.objectForKey("invitable_friends")!).objectForKey("data")! as! [AnyObject]
            
                    for i in 0 ..< friendArr.count
                    {
                        let valueDict : NSDictionary = friendArr[i] as! NSDictionary
                        let id = valueDict.objectForKey("id") as! String
                        PlayerTemplate.buildWithFB(valueDict.objectForKey("name") as! String, id: id, photo: ((valueDict.objectForKey("picture"))?.objectForKey("data"))?.objectForKey("url") as! String)
            
                    }

            
            
            
            
            
             let pagingData : AnyObject = (resultdict.objectForKey("invitable_friends")!).objectForKey("paging")!
            
            if(pagingData.objectForKey("next") != nil){
                
                let pagingStr = pagingData.objectForKey("next")! as! String

                 NSOperationQueue().addOperationWithBlock({
            
                    self.getFacebookFriendListRecursively(pagingStr)
            
                  })
                
              }
        }
        
    
    
    }
    
    
    func getFacebookFriendListRecursively(next: String?) -> Void {
        
        let url = NSURL(string: next!)
        let request = NSURLRequest(URL: url!);
        let operationQueue = NSOperationQueue.mainQueue();
        let connection = NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue) { (response, data, error) in
        
    
            let jsonResults : AnyObject

            
            do {
                jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                
                let frndArr : [AnyObject] = jsonResults.objectForKey("data")! as! [AnyObject]
                
                for i in 0 ..< frndArr.count
                {
                    let valueDict : NSDictionary = frndArr[i] as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    PlayerTemplate.buildWithFB(valueDict.objectForKey("name") as! String, id: id, photo: ((valueDict.objectForKey("picture"))?.objectForKey("data"))?.objectForKey("url") as! String)
                    
                }
                
                let pagingData : AnyObject = jsonResults.objectForKey("paging")!
                
                let nextPage = (pagingData.objectForKey("next") as? String)
                
                
                if nextPage != nil && (frndArr.count > 0){
                    self.getFacebookFriendListRecursively(nextPage)
                }
                else {
                    return;
                }

                
                             // success ...
            } catch let error as NSError {
                // failure
                DLog("Fetch failed: \(error.localizedDescription)")
                
                return;
            }
        }
    }
    
    
    

}
