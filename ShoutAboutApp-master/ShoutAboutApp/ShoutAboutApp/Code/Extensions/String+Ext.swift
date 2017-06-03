//
//  String+Ext.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 13/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import Foundation

extension String {
	func trim() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespaces)
	}
	
	func trimWithNewline() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
}
