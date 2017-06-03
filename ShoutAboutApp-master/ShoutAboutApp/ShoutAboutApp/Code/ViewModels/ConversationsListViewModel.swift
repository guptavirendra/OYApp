//
//  ConversationsListViewModel.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 25/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa
import XMPPFramework
import JSQMessagesViewController
import Result
import SwiftyJSON
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ConversationsListViewModel {
	let disposer = CompositeDisposable()
	var messages = MutableProperty<Array<STMessage!>>([]) //Includes the latest message from each conversation
	var unreadMessagesCount = MutableProperty<Int>(0)
	fileprivate var currentlyOpenThread: String? //Does the user have one thread opened
	fileprivate var unreadMessages: Dictionary<String, Set<String>> = [:]
	fileprivate var combinedSentAndReceivedMessages = MutableProperty<XMPPMessage>(XMPPMessage())
	fileprivate unowned var xmppClient: STXMPPClient
	
	init(xmpp: STXMPPClient) {
		self.xmppClient = xmpp
		self.setupBindings()
		self.loadData()
	}
	
	deinit {
		disposer.dispose()
	}
	
	fileprivate func setupBindings() {
		self.setupLatestMessageBindings()
		self.setupUnreadMessagesCountBindings()
	}
	
	fileprivate func setupLatestMessageBindings() {
		//Monitor for incoming and sent messages
		self.combinedSentAndReceivedMessages <~ self.xmppClient.stream.incomingMessages.toSignalProducer().observeOn(UIScheduler())
		self.combinedSentAndReceivedMessages <~ self.xmppClient.stream.sentMessages.toSignalProducer().observeOn(UIScheduler())
		disposer.addDisposable(
			self.combinedSentAndReceivedMessages.producer
				.filter {
					[unowned self] (msg: XMPPMessage) -> Bool  in
					return msg.body() != nil
				}
				.map {
					[unowned self] (msg: XMPPMessage) -> STMessage in
					//NOTE! We do not use msg.from.user here as the sender because it may bot@smalltalk.com if it is sending messages to this thread
					//Instead we get the userid from the threadid (threadId is always user1-user2 even when bot is injecting messages so ww can grab it from there
					let chattingWith = self.chattingWith(msg.thread())
					return STMessage.fromNetworkMessage(msg, inConversationWith: STContact.contactWith(chattingWith, xmppClient: self.xmppClient))
				}
				.start {
					[unowned self] event in
					switch event {
					case let .next(incomingMsg):
						self.insertLatestMsg(incomingMsg)
					default:
						break
					}
			}
		)
	}
	
	fileprivate func setupUnreadMessagesCountBindings() {
		//Monitor how many unread messages the user has
		disposer.addDisposable(
			self.xmppClient.stream.incomingMessages.toSignalProducer()
				.observeOn(UIScheduler())
				.filter {
					[unowned self] (msg: XMPPMessage) -> Bool  in
					return (msg.body() != nil) && (self.currentlyOpenThread == nil || self.currentlyOpenThread! != msg.thread())
				}
				.start {
					[unowned self] event in
					switch event {
					case let .next(incomingMsg):
						let threadId = incomingMsg.thread()
						if var msgSet = self.unreadMessages[threadId] {
							msgSet.insert(incomingMsg.id())
						} else {
							var msgSet = Set<String>()
							msgSet.insert(incomingMsg.id())
							self.unreadMessages[threadId] = msgSet
						}
						
						self.countUnreadMessages()
					default:
						break
					}
			}
		)
	}
	
	func setOpenedThread(_ currentlyOpenThread: String?) {
		self.currentlyOpenThread = currentlyOpenThread
		if self.currentlyOpenThread != nil {
			self.unreadMessages.removeValue(forKey: self.currentlyOpenThread!)
			self.countUnreadMessages()
		}
	}
	
	fileprivate func countUnreadMessages() {
		let unreadMessagesCount: Int = self.unreadMessages.values.reduce(0, { (unreadMessages, msgSet) in
			return unreadMessages + msgSet.count
		})
		self.unreadMessagesCount.value = unreadMessagesCount
	}
	
	//Load the latest message from each conversation
	func loadData() {
		//if User.initialConversationsSyncNeeded {
		//TODO! This should be either or!
		//Either load from Cache or do initial sync with the below
		
		doCachedConversationsSync()
		doInitialConversationsSync()
		//}
	}
	
	fileprivate func doCachedConversationsSync() {
		let context: NSManagedObjectContext? = self.xmppClient.stream.xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext
		let messageEntity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: self.xmppClient.stream.xmppMessageArchivingCoreDataStorage.messageEntityName, in: context!)
		
		let fetchRequest = NSFetchRequest()
		fetchRequest.entity = messageEntity
		// Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
		// All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
		// Since you only want distinct names, only ask for the 'thread' property.
		fetchRequest.resultType = .dictionaryResultType;
		let params: [AnyObject] = [(messageEntity?.propertiesByName["thread"])!]
		fetchRequest.propertiesToFetch = params
		fetchRequest.returnsDistinctResults = true
		
		do {
			let fetchResults = try context!.fetch(fetchRequest)
			for result in fetchResults {
				self.loadLatest(nil, thread: result["thread"] as? String)
			}
		} catch {
			print("Coredata executeFetchRequest error \(error)")
		}
	}
	
	fileprivate func doInitialConversationsSync() {
		disposer.addDisposable(
			self.getConversations()
				.observeOn(UIScheduler())
				.on(failed: { //Side effect handler
					(error: NSError) -> Void in
					NSLog("Side-effect error %@", error)
					//TSMessage.showNotificationInViewController(self.viewController, title: "Contacts fetch error", subtitle: error.localizedDescription , type: TSMessageNotificationType.Error)
					
					
				})
				.map {
					[unowned self] (result: Result<Any, NSError>) -> [String] in
					if (result.value != nil) {
						let json = result.value as! JSON
						return json.arrayObject as! [String]
					}
					return []
				}
				.uncollect() //Transform single [Contacts] array into individiual contact signals
				.throttleAfterFirst(1, onScheduler: UIScheduler().toRACScheduler()) //Don't flood with queries. Do 1 query per second
				.flatMap(FlattenStrategy.merge, transform: {
					[unowned self] (contact: String) -> SignalProducer<(String?, String), NSError> in
					return self.xmppClient.stream.archiveFetcher(contact, num: 1)
					})
				.observeOn(UIScheduler())
				.start {
					[unowned self] event in
					switch event {
					case let .next(next):
						let (archiveId, contact) = next
						if archiveId != nil {
							MAMSync.setOldestArchiveIdInThread(archiveId!, forThread: ConversationViewModel.threadId([User.senderId, contact]))
							//Message is now in archive, load it from there
							self.loadLatest(contact)
						} else {
							//NSLog("No archived messages found with contact %@", contact)
						}
					case let .failed(error):
						//assert(false, "error \(error)")
						NSLog("!!!!! doInitialConversationsSync failed %@", error)
					default:
						break
					}
			}
		)
	}
	
	fileprivate func getConversations() -> SignalProducer<Result<Any, NSError>, NSError> {
		return STHttp.get("\(Configuration.mainApi)/chat_contact_list/?app_user_id=31653&app_user_token=%242y%2410%246PRbH2TSZYMWqWuvQJcO%2FuW05ZnNXDYB4p7Bj8eogEJ9VVacfEJbK", auth:(User.username, User.token))
	}
	
	fileprivate func loadLatest(_ contact: String? = nil, thread: String? = nil) {
		let context: NSManagedObjectContext? = self.xmppClient.stream.xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext
		let messageEntity: NSEntityDescription? = NSEntityDescription.entity(forEntityName: self.xmppClient.stream.xmppMessageArchivingCoreDataStorage.messageEntityName, in: context!)
		let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
		
		let fetchRequest = NSFetchRequest()
		var fetchThread = thread
		if (contact != nil) {
			fetchThread = ConversationViewModel.threadId([User.senderId, contact!])
		}
        if thread != nil
        {
		let predicate: NSPredicate = NSPredicate(format: "thread == %@", fetchThread!)
		fetchRequest.predicate = predicate
        }
		fetchRequest.entity = messageEntity
		fetchRequest.fetchLimit = 1
		fetchRequest.sortDescriptors = [sortDescriptor]
		do {
			let fetchResults = try context!.fetch(fetchRequest) as! [XMPPMAMArchivingMessageCoreDataObject]
			if fetchResults.count > 0 && thread != nil {
				let jsqMessages = fetchResults.map {
					(archivedMessage: XMPPMAMArchivingMessageCoreDataObject) -> STMessage in
                    
					let chatWith: String = self.chattingWith(archivedMessage.thread)
					let contact: STContact = STContact.contactWith(chatWith, xmppClient: self.xmppClient)
					return STMessage.fromStoredMessage(archivedMessage, inConversationWith: contact)
				}
				self.insertLatestMsg(jsqMessages[0]) //There is only 1
			}
		} catch {
			assert(false, "Coredata executeFetchRequest error \(error)")
		}
	}
	
	fileprivate func chattingWith(_ threadId: String) -> String {
		//NOTE! We do not use msg.from.user here as the sender because it may bot@smalltalk.com if it is sending messages to this thread
		//Instead we get the userid from the threadid (threadId is always user1-user2 even when bot is injecting messages so ww can grab it from there
		return threadId.components(separatedBy: "-").filter { $0 != User.username }[0]
	}
	
	//Replace existing message from this conversation with the new message
	fileprivate func insertLatestMsg(_ message: STMessage) {
		var filtered: [STMessage!] = self.messages.value.filter {
			existingMsg in
			//Only keep messages from different conversations
			//OR from this conversation if the message form this conversation is never
			return (existingMsg.threadId != message.threadId) || (existingMsg.date > message.date)
		}
		
		//Check if filter removed (or self.messages didn't include) older message of this thread
		let canInsert = filtered.index { $0.threadId == message.threadId } == nil
		//We have actually removed a message to be replaced
		if canInsert {
			filtered.insert(message, at: 0)
			filtered.sort { (msg1, msg2) in
				return msg1.date > msg2.date
			}
		
			self.messages.value = filtered
		}
	}
}
