//
//  XMPPMessage+Ext.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 02/10/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import XMPPFramework

extension XMPPMessage {
	func id() -> String! {
		return self.attributeStringValue(forName: "id")
	}
	
	func date() -> Date? {
		if self.isForwardedStanza() {
			return self.forwardedStanzaDelayedDeliveryDate()
		}
		
		return self.delayedDeliveryDate()
	}
	
	func content() -> STMessageAttachment? {
		if let contentE = self.forName("content") {
			let contentType = contentE.attributeStringValue(forName: "content-type")
			return STMessageAttachment(contentStr: contentE.stringValue!, contentType: contentType)
		}
		
		return nil
	}
	
	func archiveId() -> String? {
		if let archived = self.forName("archived") {
			return archived.attributeStringValue(forName: "id")
		}
		
		return nil
	}
}
