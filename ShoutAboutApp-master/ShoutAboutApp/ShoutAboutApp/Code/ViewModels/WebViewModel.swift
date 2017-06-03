//
//  WebViewProtocol.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 28/10/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class WebViewModel: NSObject, WKNavigationDelegate {
	fileprivate let gameType: String
	var gameData: JSON?
	fileprivate var outgoingView: Bool
	fileprivate var completionCallback: ((Bool) -> Void)!
	fileprivate var initialLoad = true
	
	init(gameType: String, data: JSON?, outgoingView: Bool) {
		self.gameType = gameType
		self.gameData = data
		self.outgoingView = outgoingView
	}
	
	deinit {

	}
	
	func loadWebView(_ webView: WKWebView, urlConnDelegate: NSURLConnectionDelegate, completion: (Bool) -> Void) {
		let strUrl = Configuration.games[self.gameType]!.url
		let url = URL(string:strUrl)
		let req = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60)
		var _ = NSURLConnection(request: req, delegate: urlConnDelegate)!
		self.completionCallback = completion
		webView.navigationDelegate = self
		//Make sure we're in main thread
		DispatchQueue.main.async {
			[weak webView] in
				webView?.load(req)!
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		NSLog("webView didFinishNavigation")
		if initialLoad {
			var stateStr: String = "undefined"
			var updateStateStr: String = "undefined"
			let outgoingStr = self.outgoingView ? "true" : "false"
			if gameData != nil {
				stateStr = gameData!["state"].stringValue
				stateStr = "\"\(stateStr)\""
				//UpdatedState is javascript
				let updateState = gameData!["updateState"]
				if let jsonStr = updateState.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions(rawValue: 0)) {
					updateStateStr = jsonStr
				}
			}

			let js = String(format: "applicationStart(%@, %@, %@);", stateStr, updateStateStr, outgoingStr)
			webView.evaluateJavaScript(js, completionHandler: {
				[weak self] (result: AnyObject?, error: NSError?) -> Void in
				if error != nil {
					NSLog("evaluateJavaScript Error \(error)")
					self?.completionCallback(false)
				} else {
					self?.completionCallback(true)
				}
			})
		}
		
		initialLoad = false
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		NSLog("%s. With Error %@", __FUNCTION__, error)
		completionCallback(false)
	}
	
	//mark - NSObject
	override var hash: Int {
		get {
			return super.hash ^ self.gameData!.rawString()!.hash
		}
	}
}

