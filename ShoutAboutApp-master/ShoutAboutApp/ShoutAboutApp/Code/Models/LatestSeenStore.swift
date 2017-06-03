//
//  LatestSeenStore.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 20/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
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


struct LatestSeenStore {
	//Mark what is the oldest message in thread so that we know what message to use as the before key in MAM archive get
	static func setLatestSeenInThread(_ date: Date, msgId: String, forThread: String) {
		let stored  = LatestSeenStore.latestSeenInThread(forThread)
		if stored == nil || stored!.date < date {
			let defaults = UserDefaults.standard
			let dict = ["date": date, "id": msgId]
			defaults.set(dict, forKey: "latestSeenInThread-\(forThread)")
		}
	}
	
	//Get the oldest message archiveId in thread
	static func latestSeenInThread(_ forThread: String) -> (date: Date, id: String)? {
		let defaults = UserDefaults.standard
		if let ret = defaults.object(forKey: "latestSeenInThread-\(forThread)") as? Dictionary<String, AnyObject> {
			let date: Date = ret["date"] as! Date
			let id: String = ret["id"] as! String
			
			return (date: date, id: id)
		}
		
		return nil
	}
	
	//Note! User.logOut deletes all data from this DB as well
}
