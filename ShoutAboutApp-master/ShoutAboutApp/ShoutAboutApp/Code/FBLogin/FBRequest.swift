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

class FBRequest: NSObject
{
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    
    func loginWithFacebook(_ successBlock:CompletionHandler ,vc:UIViewController)
    {
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        fbLoginManager.logIn(withReadPermissions: facebookReadPermissions, from: vc,handler: { (result, error) -> Void in
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil
                {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        if(successBlock != nil)
                        {
                            self.getFBUserData(successBlock);
                       
                        }
                    }
                }
                else
                {
                    //ActivityIndicator.stopActivityIndicatorOnView(vc.view)
                }
            }
        })

    }
    
    func logoutFacebook()
    {
        fbLoginManager.logOut()
    }
    
    func getFBUserData(_ success: CompletionHandler)
    {
        if((FBSDKAccessToken.current()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,  birthday, gender, location, website"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil)
                {
                    if(success != nil)
                    {
                        success!(result as AnyObject, error as NSError?);
                    }
                }
            })
        }
    }
    
    
}
