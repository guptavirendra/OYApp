//
//  STMessage.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 25/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import XMPPFramework
import SwiftyJSON

class STMessageAttachment: NSObject {
	static let imageContentType = "image/jpeg"
	static let youtubeContentType = "application/youtube"
    var filePath:String = ""
    var key:String = "1492280135.png"
	
	var contentType: String
	var json: JSON
	
	var jsonRawString: String {
		get {
			return json.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions(rawValue: 0))!
		}
	}
	
	init(json: JSON, contentType: String) {
		self.contentType = contentType
		self.json = json
	}
	
	convenience init(contentStr: String, contentType: String) {
		let json = JSON(data: contentStr.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
		self.init(json: json, contentType: contentType)
	}
	
	convenience init(contentWithMediaId: String, contentType: String) {
		let json: JSON = ["id": contentWithMediaId]
		self.init(contentStr: json.rawString()!, contentType: contentType)
	}
	
	override var description: String {
		return "STMessageAttachment: \(self.contentType) JSON: \(self.json)"
	}
}

class STMessage: JSQMessage {
	let id: String
	let inConversationWith: STContact //Always the opposing side's contact
	var attachment: STMessageAttachment? = nil
	var deliveryStatus: DeliveryStatus = .sent
    var shortDisplayText: String
    var threadId: String
	
	static let imageExt = ".png"
	
	enum DeliveryStatus: Int {
		case sent = 0
        case serverAck = 1
		case delivered = 2
		case read = 3
	}
	
	//When user sends a new message
    init(id: String, senderId: String, senderDisplayName: String, date: Date, text: String, media: UIImage?, threadId: String, inConversationWith: STContact) {
		self.id = id
        self.threadId = threadId
		self.inConversationWith = inConversationWith
		self.shortDisplayText = text
		if media != nil {
			let photoItem: JSQPhotoMediaItem = JSQPhotoMediaItem(image: media!)
			photoItem.appliesMediaViewMaskAsOutgoing = senderId == User.senderId
			self.attachment = STMessageAttachment(contentWithMediaId:"1492280135.png" /*"\(senderId)-\(NSUUID().UUIDString)\(STMessage.imageExt)"*/, contentType: STMessageAttachment.imageContentType)
            
            let extensionPathStr = "\(senderId)-\(UUID().uuidString)\(STMessage.imageExt)"
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
            
            print(fullPathToFile)
            self.attachment?.filePath = fullPathToFile
            
            let imageData: Data = UIImageJPEGRepresentation(media!, 0.5)!
            
            
            
            try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
            
            
            
			super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: photoItem)
		} else if STMessage.containsYoutubeLink(text) {
			let outgoing = senderId == User.senderId
			var youtubeLink: String?
			let types: NSTextCheckingResult.CheckingType = [.link]
			let detector = try? NSDataDetector(types: types.rawValue)
			
			//Get the actual link
			detector?.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.characters.count)) { (result, flags, _) in
				let url = (text as NSString).substring(with: result!.range)
				if STMessage.containsYoutubeLink(url) {
					youtubeLink = url
				}
			}
			
			assert(youtubeLink != nil, "Youtube link not found with detector")
			let youtubeItem: STYoutubeMediaItem = STYoutubeMediaItem(url: youtubeLink!, title: nil, channelTitle: nil, outgoing: outgoing)
			youtubeItem.appliesMediaViewMaskAsOutgoing = outgoing
			self.attachment = STMessageAttachment(contentWithMediaId: youtubeLink!, contentType: STMessageAttachment.youtubeContentType)
            super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: youtubeItem)
		} else {
			super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
		}
		
		//assert(self.inConversationWith.username != User.senderId, "init inConversationWith must always be something else than the current user")
	}
	
	//When message is received or loaded
    init(id: String, senderId: String, senderDisplayName: String, date: Date, text: String, attachment: STMessageAttachment?, threadId: String, inConversationWith: STContact) {
		self.id = id
        self.threadId = threadId
		self.inConversationWith = inConversationWith
		self.attachment = attachment
        self.shortDisplayText = text

		if attachment != nil {
			var mediaItem: JSQMediaItem? = nil
			if attachment?.contentType == STMessageAttachment.imageContentType {
				//Image is placeholder (nil) until it is downloaded
				mediaItem = JSQPhotoMediaItem(image: nil)
				mediaItem!.appliesMediaViewMaskAsOutgoing = senderId == User.senderId
			} else if attachment?.contentType == STMessageAttachment.youtubeContentType {
				mediaItem = STYoutubeMediaItem(url: attachment!.json["id"].stringValue, title: attachment!.json["title"].string, channelTitle: attachment!.json["channel_title"].string, outgoing: senderId == User.senderId)
			} else {
				mediaItem = STGameMediaItem(messageId: self.id, data: attachment!.json, outgoing: senderId == User.senderId)
			}
			
			super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: mediaItem)
		} else {
			super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
		}
		
		assert(self.inConversationWith.username != User.senderId, "init inConversationWith must always be something else than the current user")
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	var isGameMediaMessage: Bool {
		get {
			return self.isMediaMessage && self.media.isKind(of: STGameMediaItem.self)
		}
	}
	
	var isPhotoMediaMessage: Bool {
		get {
			return self.isMediaMessage && self.media.isKind(of: JSQPhotoMediaItem.self)
		}
	}
	
	static func fromStoredMessage(_ archivedMessage: XMPPMAMArchivingMessageCoreDataObject, inConversationWith: STContact) -> STMessage {
		let userDisplayName = User.displayName != nil ? User.displayName! : "FIXME" //TODO There's a race condition where ConversationsListViewController may be loading messages before the nickname has been given. Don't allow that situation!
		let ret = STMessage(
			id: archivedMessage.id,
			senderId: archivedMessage.isOutgoing ? User.senderId : inConversationWith.username,
			senderDisplayName: archivedMessage.isOutgoing ? userDisplayName : inConversationWith.displayName,
			date: archivedMessage.timestamp,
			text: archivedMessage.body,
			attachment: archivedMessage.content,
            threadId: archivedMessage.thread,
			inConversationWith: inConversationWith
		)
		ret.deliveryStatus = DeliveryStatus(rawValue: archivedMessage.deliveryStatus.intValue)!
		return ret
	}
	
	static func fromNetworkMessage(_ xmppMsg: XMPPMessage, inConversationWith: STContact) -> STMessage {
		let timestamp: Date = xmppMsg.date() != nil ? xmppMsg.date()! : Date()
		let sender = xmppMsg.from().bare().user
		let ret = STMessage(
			id: xmppMsg.id(),
			senderId: sender,
			senderDisplayName: sender == User.senderId ? User.displayName! : inConversationWith.displayName,
			date: timestamp,
			text: xmppMsg.body(),
			attachment: xmppMsg.content(),
            threadId: xmppMsg.thread(),
			//This should be always the other party (from or to)
			inConversationWith: inConversationWith
		)
		return ret
	}
	
	static func containsYoutubeLink(_ text: String) -> Bool {
		return text.contains("www.youtube.com/watch")
	}
	
	override var description: String {
		get {
			let s = super.description
			return "\(s) chattingWith: \(inConversationWith) content: \(attachment)"
		}
	}
}
