//
//  AvatarUtils.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 19/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class AvatarUtils: NSObject {
	static var avatars = Dictionary<String, JSQMessagesAvatarImage>()

	static func setupAvatarImage(_ id: String, displayName: String, fontSize: CGFloat) {
		let diameter = UInt(kJSQMessagesCollectionViewAvatarSizeDefault)
		let jsqImage: JSQMessagesAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: AvatarUtils.getInitials(displayName),
			backgroundColor: UIColor.white,
			textColor: UIColor.black,
			font: UIFont.systemFont(ofSize: fontSize),
			diameter: diameter)
		
		AvatarUtils.avatars[id] = jsqImage
	}
	
	static fileprivate func getInitials(_ name: String) -> String {
		return name.characters.split { token in
			return token == " "
		}
		.map { String($0) }
		.map { word in
				return word[word.startIndex]
		}
		.reduce("") { accIn, firstCharacter in
				return "\(accIn)\(firstCharacter)"
		}
	}
}
