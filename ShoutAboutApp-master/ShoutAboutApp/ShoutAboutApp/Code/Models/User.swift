//
//  User.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 23/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import DigitsKit
import SwiftyJSON

struct User {
	static var username: String {
		get {
			return  "31653" //NSUserDefaults.standardUserDefaults().objectForKey("username") as! String
		}
	}
	
	static var token: String {
		get {
            return "12345"
			//return NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
		}
	}
	
	static var senderId: String {
		get {
			return  "31653@localhost" //return User.username
		}
	}
	
	static var displayName: String? {
		get {
			return "Virendra" //NSUserDefaults.standardUserDefaults().objectForKey("displayName") as? String
		}
		
		set(value) {
			UserDefaults.standard.set(value, forKey: "displayName")
		}
	}

	static var initialConversationsSyncNeeded: Bool {
		get {
			//Only do this if this was not a new user (may have conversations from previous logins)
			let newUser = UserDefaults.standard.object(forKey: "new") as? Bool
			let syncNeeded = UserDefaults.standard.object(forKey: "initialConversationsSyncNeeded") as? Bool
			return ((newUser == nil || newUser == false) && (syncNeeded == nil || syncNeeded == true))
		}
		
		set(value)
        {
			UserDefaults.standard.set(value, forKey: "initialConversationsSyncNeeded")
		}
	}
	
	static func loggedInWith(_ data: JSON) {
		let defaults = UserDefaults.standard
		defaults.setValuesForKeys(data.dictionaryObject!)
	}
	
	static func isLoggedIn() -> Bool {
		return UserDefaults.standard.object(forKey: "username") != nil
	}
	
	static func logOut() {
		Digits.sharedInstance().logOut()
		STXMPPClient.sharedInstance?.disconnect()
		let appDomain = Bundle.main.bundleIdentifier
		UserDefaults.standard.removePersistentDomain(forName: appDomain!)
	}
}
