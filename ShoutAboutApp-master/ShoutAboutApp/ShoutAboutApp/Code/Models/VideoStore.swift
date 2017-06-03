//
//  VideoStore.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 19/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit

struct VideoStore {
	//Mark the playbackPosition for a video so that we can continue from the same position later on
	static func setPlaybackPosition(_ position: Float, forVideoId: String) {
		let defaults = UserDefaults.standard
		defaults.set(position, forKey: "playbackPos-\(forVideoId)")
	}
	
	//Get the playbackPos for video
	static func playbackPosition(_ forVideoId: String) -> Float? {
		let defaults = UserDefaults.standard
		return defaults.object(forKey: "playbackPos-\(forVideoId)") as? Float
	}
	
	//Clear the playbackPos for video
	static func clearPlaybackPosition(_ forVideoId: String) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: "playbackPos-\(forVideoId)")
	}
}
