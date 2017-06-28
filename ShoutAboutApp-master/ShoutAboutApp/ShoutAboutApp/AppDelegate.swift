  //
//  AppDelegate.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 05/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import xmpp_messenger_ios
import UIKit
import XMPPFramework
import Fabric
import Crashlytics
import DigitsKit
//import ReactiveCocoa
import OpenUDID
import TSMessages
import DeepLinkKit
//import ChameleonFramework
import youtube_ios_player_helper
import Watchdog

/***** close******/

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate/*, GIDSignInDelegate*/
{

    var window: UIWindow?
    
    /*
        Small Talk variable
     */
    
    //var window: UIWindow?
    lazy var router: DPLDeepLinkRouter = DPLDeepLinkRouter()
    var globalColor: UIColor?
    var backgroundColor: UIColor?
    var darkColor: UIColor?
    var selfColor: UIColor?
    var highlightColor: UIColor?
    //let watchdog = Watchdog(threshold: 0.016) //60 frames a second
    let crashlytics = Crashlytics.sharedInstance()
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        /* xmpp calling */
        connetToXmpp()
        navBarAppearence()
        loadFirstScreen()
    
        // Initialize google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        
//        if User.isLoggedIn()
//        {
//            crashlytics.setUserIdentifier(User.username)
//            if let displayName = User.displayName
//            {
//                crashlytics.setUserName(displayName)
//            }
//        }
//        Fabric.with([crashlytics, Digits.self()])
//        // Register a class to a route using object subscripting
//        self.router["/messsage/:thread"] = MessageDeeplinkRouteHandler.self
        
        
        // Show View Controller from Main storyboard
    /* Small talk block*/    //self.window!.rootViewController = UINavigationController(rootViewController: controller)
        //self.window!.backgroundColor = UIColor.whiteColor()
        //self.window!.rootViewController?.navigationController?.navigationBarHidden = true

        
        //NotificationCenter.default.addObserver(self,selector: #selector(tokenRefreshNotification(_:)),
                                                        // name: NSNotification.Name.firInstanceIDTokenRefresh,
                                                        // object: nil)
        
      //  UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        

        
        
        FIRApp.configure()
        /*
         
         if #available(iOS 10.0, *)
         
         {
         
         let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
         
         UNUserNotificationCenter.current().requestAuthorization(
         
         options: authOptions,
         
         completionHandler: {_, _ in })
         
         
         
         // For iOS 10 display notification (sent via APNS)
         
         UNUserNotificationCenter.current().delegate = self
         
         // For iOS 10 data message (sent via FCM)
         
         FIRMessaging.messaging().remoteMessageDelegate = self
         
         
         
         } else*/
    
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
         
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
}

    func applicationWillResignActive(_ application: UIApplication)
    {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        
        print("Disconnected from FCM.")

    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        
        if (FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation))
        {
            
            return true;
        }
        else if(GIDSignIn.sharedInstance().handle(url,
            sourceApplication: sourceApplication,
            annotation: annotation))
        {
            
            return true;
        }
        else
        {
            return false;
        }
        
    }
}



func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
{
    print(error)
}

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
{
    
    let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
    
    var tokenString = ""
    for i in 0..<deviceToken.count
    {
        
        tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        
    }
    
    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
    
    print("Device Token:", tokenString)
}



func connectToFcm()
{
    FIRMessaging.messaging().connect { (error) in
        if error != nil
        {
           print("Unable to connect with FCM. \(error)")
        } else
        {
            let refreshedToken = FIRInstanceID.instanceID().token()
            print("InstanceID token: \(refreshedToken)")
            print("Connected to FCM.")
            
        }
    }
    
}


func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
{
    if userInfo["gcm.message_id"] != nil
    {
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
    }
    // Print full message.
    print(userInfo)
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
{
    
    // If you are receiving a notification message while your app is in the background,
    
    // this callback will not be fired till the user taps on the notification launching the application.
    
    // TODO: Handle data of notification
    // Print message ID.
    
    print("Message ID: \(userInfo["gcm.message_id"]!)")
    // Print full message.
    
    print(userInfo)
    FIRMessaging.messaging().appDidReceiveMessage(userInfo)
}
  
  
  
  /*****************************/
  //MARK:// GET CONTACT
  func retrieveContacts() -> [SearchPerson]?
  {
    if let unarchivedObject = UserDefaults.standard.object(forKey: contactStored) as? Data {
        return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [SearchPerson]
    }
    return nil
  }
  
  
  //MARK: Refresh Token
  func tokenRefreshNotification(_ notification: Notification)
  {
    if let refreshedToken = FIRInstanceID.instanceID().token()
    {
        print("InstanceID token: \(refreshedToken)")
    }
    // Connect to FCM since connection may have failed when attempted before having a token.
    connectToFcm()
  }
  
  
  func connetToXmpp()
  {
    OneChat.start(true, delegate: nil) { (stream, error) -> Void in
        print (stream)
        if let _ = error
        {
            //handle start errors here
            print("errors from appdelegate")
        } else {
            print("Yayyyy")
            //Activate online UI
        }
    }
  }

  func navBarAppearence()
  {
    //        let darkBlue = UIColor(hexString: "2C3E50")
    //        let red = UIColor(hexString: "E74C3C")
    //        let light = UIColor(hexString: "ECF0F1")
    //        let lightBlue = UIColor(hexString: "1F8DC8")
    //        let medBlue = UIColor(hexString: "FFFFFF")
    //        self.backgroundColor = light
    //        self.darkColor = darkBlue
    //        self.selfColor = UIColor.white
    //        self.highlightColor = red
    //UIBarButtonItem.appearance().tintColor = lightBlue
    //UIBarButtonItem.my_appearanceWhenContainedIn(UISearchBar.self).tintColor = lightBlue
    // UIBarButtonItem.my_appearanceWhenContainedIn(UINavigationBar.self).tintColor = lightBlue
    //UIBarButtonItem.my_appearanceWhenContainedIn(UIToolbar.self).tintColor = lightBlue
    
    //UINavigationBar.appearance().barTintColor = lightBlue //UIColor.whiteColor()
    //UINavigationBar.appearance().tintColor =  medBlue//appColor
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().barTintColor =  appColor  //(rgba: "#2c8eb5")
    UINavigationBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    
    
    let attributes = [
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont.systemFont(ofSize: 15)
    ]
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: UIControlState())
     
    
    // UITableViewCell.appearance().backgroundColor = light
    // UICollectionView.appearance().backgroundColor = light
    // UIScrollView.appearance().backgroundColor = light
    //UITableView.appearance().backgroundColor = light
    
    
  }
  
  func loadFirstScreen()
  {
    let appUserId = UserDefaults.standard.object(forKey: kapp_user_id)
    let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token)
    
    if appUserId != nil && appUserToken != nil
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabBarVC") as? MyTabViewController
        
        appDelegate.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        appDelegate.window?.rootViewController = tabBarVC
        appDelegate.window?.makeKeyAndVisible()
        
        if let contactStored = retrieveContacts()
        {
            ProfileManager.sharedInstance.syncedContactArray.append(contentsOf: contactStored)
        }
        
    }
}
