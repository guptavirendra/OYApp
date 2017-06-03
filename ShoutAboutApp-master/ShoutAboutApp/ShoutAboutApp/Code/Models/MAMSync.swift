//
//  MAMSync.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 29/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

struct MAMSync {
	enum OldestMessageType: Int {
		case localCache = 1
		case server = 2
	}
	
	//Mark what is the oldest message in thread so that we know what message to use as the before key in MAM archive get
	static func setOldestArchiveIdInThread(_ archiveId: String, forThread: String) {
		let defaults = UserDefaults.standard
		defaults.set(archiveId, forKey: "archiveId-\(forThread)")
	}
	
	//Get the oldest message archiveId in thread
	static func oldestArchiveIdInThread(_ forThread: String) -> String? {
		let defaults = UserDefaults.standard
		return defaults.object(forKey: "archiveId-\(forThread)") as? String
	}
	
	//We mark a thread noting that all the messages from it have been received
	static func setMamSynced(_ forThread: String) {
		let defaults = UserDefaults.standard
		defaults.set(true, forKey: "mamSynced-\(forThread)")
	}

	static func mamSynced(_ forThread: String) -> Bool? {
		let defaults = UserDefaults.standard
		return defaults.object(forKey: "mamSynced-\(forThread)") as? Bool
	}
	
	//Note! User.logOut deletes all data from this DB as well
}
