//
//  XMPPMAMCoreDataStorage.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 01/10/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import XMPPFramework

class XMPPMAMArchivingCoreDataStorage: XMPPMessageArchivingCoreDataStorage {

	override func managedObjectModelName() -> String! {
		return "XMPPMAMArchiving" //XMPPMAMArchiving.xcdatamodel will be used
	}
	
	override func archiveMessage(_ message: XMPPMessage, outgoing isOutgoing: Bool, xmppStream stream: XMPPStream) {
		let messageBody: String? = message.body()
		if messageBody == nil {
			//NSLog("archiveMessage message has no body. Not archiving!")
			return
		}
		
		if message.id() == nil {
			//NSLog("archiveMessage message has no ID. Not archiving!")
			return
		}
		
		self.scheduleBlock {
			if !self.isMessageStored(message) {
				let moc: NSManagedObjectContext? = self.managedObjectContext
				let messageEntity: NSEntityDescription? = self.messageEntity(moc)
				let archivedMessage: XMPPMAMArchivingMessageCoreDataObject = XMPPMAMArchivingMessageCoreDataObject(entity: messageEntity!, insertInto: nil)
				
				let myJid: XMPPJID = self.myJID(for: stream)
				let messageJid: XMPPJID = isOutgoing ? message.to() : message.from()
				
				archivedMessage.id = message.id()
				archivedMessage.senderId = message.from().user
				archivedMessage.message = message
				archivedMessage.body = messageBody
				archivedMessage.bareJid = messageJid.bare()
				archivedMessage.streamBareJidStr = myJid.bare()
				archivedMessage.timestamp = message.date() != nil ? message.date()! : Date()
	
				archivedMessage.archiveId = message.archiveId()
				archivedMessage.thread = message.thread()
				archivedMessage.isOutgoing = isOutgoing;
				archivedMessage.isComposing = false;
				if let contentE = message.content() {
					archivedMessage.contentDataStr = contentE.jsonRawString
					archivedMessage.contentType = contentE.contentType
				}
				
				if message.from().user != User.senderId {
					//assert(archivedMessage.archiveId != nil, "Message received from other doesnt have archiveId!")
				}
				archivedMessage.willInsert()
				//NSLog("insertObject %@", archivedMessage)

				moc!.insert(archivedMessage)
			}
		}
	}
	
	func markMessageDeliveryStatus(_ deliveryStatus: STMessage.DeliveryStatus, forMessage: String) {
		updateObject(forMessage, updateOp: {
			archivedMessage in
			archivedMessage.deliveryStatus = deliveryStatus.rawValue
		})
	}
	
	func updateArchiveId(_ msgId: String, archiveId: String) {
		updateObject(msgId, updateOp: {
			archivedMessage in
			archivedMessage.archiveId = archiveId
		})
	}
	
	fileprivate func isMessageStored(_ message: XMPPMessage) -> Bool
	{
		let moc: NSManagedObjectContext? = self.managedObjectContext
		let messageEntity: NSEntityDescription? = self.messageEntity(moc)
		
		let msgId = message.attributeStringValue(forName: "id")
		let fetchRequest = NSFetchRequest()
		let predicate: NSPredicate = NSPredicate(format: "id == %@", msgId)
		fetchRequest.predicate = predicate
		fetchRequest.entity = messageEntity
		fetchRequest.fetchLimit = 1
		
		do {
			let fetchResults = try moc!.fetch(fetchRequest) as? [XMPPMAMArchivingMessageCoreDataObject]
			return fetchResults!.count > 0
		} catch {
			NSLog("Error executing fetch in isMessageStored \(error)")
			return true
		}
	}
	
	fileprivate func updateObject(_ msgId: String, updateOp: (archivedMessage: XMPPMAMArchivingMessageCoreDataObject) -> (Void)) {
		self.scheduleBlock {
			let moc: NSManagedObjectContext? = self.managedObjectContext
			let messageEntity: NSEntityDescription? = self.messageEntity(moc)
			
			let fetchRequest = NSFetchRequest()
			let predicate: NSPredicate = NSPredicate(format: "id == %@", msgId)
			fetchRequest.predicate = predicate
			fetchRequest.entity = messageEntity
			fetchRequest.fetchLimit = 1
			
			do {
				let fetchResults = try moc!.fetch(fetchRequest) as? [XMPPMAMArchivingMessageCoreDataObject]
				if fetchResults!.count > 0 {
					let archivedMessage = fetchResults![0]
					updateOp(archivedMessage: archivedMessage)
					//scheduleBlock will call save
				}
			} catch {
				NSLog("Error executing fetch in isMessageStored \(error)")
			}
		}
	}
}
