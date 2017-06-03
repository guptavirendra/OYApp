//
//  XMPPClient.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 16/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa

class STXMPPClient: NSObject {
	static var sharedInstance: STXMPPClient?
	var stream: STXMPPStream!
	let connected = MutableProperty<Bool>(false)
	var connectionStatus: Signal<(Bool, NSError?), NSError>?

	static func clientForHost(_ host: String, port: UInt16, user: String, password: String) -> STXMPPClient {
		return STXMPPClient(host: host, port: port, user: user, password: password, stream: STXMPPStream())
	}
	
	init(host: String, port: UInt16, user: String, password: String, stream: STXMPPStream) {
		self.stream = stream
		super.init()
		STXMPPClient.sharedInstance = self
		
		self.connectionStatus = self.stream!.connectionStatus.observeOn(UIScheduler()) //XMPP operations happen in background queue so bring to main thread
		self.connectionStatus!.observe {
			event in
			switch event {
			case let .next(event):
				NSLog("STXMPPClient Next: \(event)")
			case let .failed(event):
				NSLog("STXMPPClient Error: \(event.localizedDescription)")
			case .interrupted:
				NSLog("STXMPPClient Interrupted")
			default:
				NSLog("STXMPPClient default")
				break
			}
		}
		
		self.setupBindings()
		self.stream!.connectToHost(host, port: port, username: user, password: password)
	}
	
	func disconnect() {
		self.stream!.disconnect()
		self.stream = nil
	}
	
	func receiveMessageFromPushNotification(_ messageStr: String) {
		self.stream.receiveMessageFromPushNotification(messageStr)
	}
	
	func sendMessage(_ id: String, text: String, to: String, thread: String, content: STMessageAttachment?) {
		self.stream.messageSender(id, body:text, to: to, thread: thread, content: content)
			.start {
				
				event in
				switch event {
				case let .next(event):
					NSLog("sendMessage: Next \(event)")
				case let .failed(error):
					NSLog("sendMessage: Send error \(error)")
				case .interrupted:
				NSLog("sendMessage Interrupted")
				default:
				NSLog("sendMessage default")
				break
				}
		}
	}
	
	func sendChatState(_ type: String, to: String, thread: String) {
		self.stream.chatStateSender(type, to: to, thread: thread)
			.start {
				
				event in
				switch event {
				case let .next(event):
					NSLog("sendChatState: Next \(event)")
				case let .failed(error):
					NSLog("sendChatState: Send error \(error)")
				case .interrupted:
					NSLog("sendChatState Interrupted")
				default:
					NSLog("sendChatState default")
					break
				}
		}
	}
	
	func sendUnavailable()
	{
		if (self.stream != nil) {
			self.stream.sendUnavailable()
		}
	}
	
	func sendAvailable()
	{
		if (self.stream != nil) {
			self.stream.sendAvailable()
		}
	}
	
	fileprivate func setupBindings()
	{
		self.connected <~ self.stream.connected
		self.connectionStatus = stream.connectionStatus.observeOn(UIScheduler()) //XMPP operations happen in background queue so bring to main thread
		self.connectionStatus!
			.observe {
				event in
				switch event {
				case let .next((connected, _)):
					NSLog("STXMPPClient: Next \(connected) Main Thread? \(Thread.isMainThread)")
				case let .failed(error):
					NSLog("STXMPPClient: Connection error \(error)")
				case .interrupted:
					NSLog("STXMPPClient: Interrupted")
				default:
					NSLog("STXMPPClient: Default")
					break
				}
		}
	}
}
