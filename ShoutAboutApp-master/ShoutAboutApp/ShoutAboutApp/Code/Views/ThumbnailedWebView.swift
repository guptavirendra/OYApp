//
//  ThumbnailedWebView
//  smalltalk
//
//  Created by Mikko Hämäläinen on 7/11/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import WebKit
import SwiftyJSON
import SDWebImage

class ThumbnailedWebView: UIView, WKScriptMessageHandler, NSURLConnectionDelegate {
	let messageId: String
	var webView: WKWebView!
	let viewModel: WebViewModel
	var	viewSize: CGSize
	var gameDownloadSize: Int64 = 0
	var cachedPlaceholderView: UIView? = nil

	fileprivate let jsMsgLog = "log"
	var webConfig:WKWebViewConfiguration {
		get {
			let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
			// Setup WKUserContentController instance for injecting user script
			let userController:WKUserContentController = WKUserContentController()
			// Add a script message handler for receiving  "gameEnded" event notifications posted from the JS document using gameEnded script message
			userController.add(self, name: jsMsgLog)
			webCfg.userContentController = userController;
			return webCfg;
		}
	}
	
	init(messageId: String, data: JSON, outgoing: Bool, size: CGSize) {
		let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
		self.viewSize = size
		self.messageId = messageId
		self.viewModel = WebViewModel(gameType: data["gameType"].stringValue, data: data, outgoingView: outgoing)
		super.init(frame: frame)
		self.webView = WKWebView(frame: frame, configuration: webConfig)
		webView.isUserInteractionEnabled = false
		webView.scrollView.isUserInteractionEnabled = false
		webView.contentMode = UIViewContentMode.scaleAspectFill
		webView.clipsToBounds = true
		self.addWebView()
	}
	
	deinit {
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func addWebView() {
		if let thumbnailImage = cachedScreenshot() {
			//NOTE TODO! For some reason the cachedPlaceholderView bounds are 500x500 instead of 250x250 that is written to cache
			cachedPlaceholderView = UIImageView(image: thumbnailImage)
			cachedPlaceholderView?.frame = self.frame
		} else {
			cachedPlaceholderView = spinnerPlaceholderView()
		}
		
		cachedPlaceholderView?.contentMode = UIViewContentMode.scaleAspectFill
		cachedPlaceholderView?.clipsToBounds = true
		self.addSubview(cachedPlaceholderView!)
		self.loadWebView()
	}
	
	fileprivate func loadWebView() {
		self.viewModel.loadWebView(self.webView, urlConnDelegate: self, completion: {
			[unowned self] success in
			if success {
				//If there's a screenshot, put the view under it first
				if self.cachedPlaceholderView != nil && self.cachedPlaceholderView!.isKind(of: UIImageView.self) {
					self.insertSubview(self.webView, belowSubview: self.cachedPlaceholderView!)
					//Wait for the WKWebView flicker happen
					DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
						[unowned self] in
						self.cachedPlaceholderView?.removeFromSuperview()
						self.snapShot(0.0)
					})
				} else {
					self.cachedPlaceholderView?.removeFromSuperview()
					self.addSubview(self.webView)
					self.snapShot(1.0)
				}
			}
		})
	}
	
	fileprivate func cachedScreenshot() -> UIImage? {
		let jsonStr = self.viewModel.gameData!.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions(rawValue: 0))
		let hashStr = "\(jsonStr!.hash)"
		return SDImageCache.shared().imageFromDiskCache(forKey: hashStr)
	}
	
	fileprivate func spinnerPlaceholderView() -> UIView? {
		let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		let view = JSQMessagesMediaPlaceholderView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 120.0), backgroundColor: (UIApplication.shared.delegate as! AppDelegate).backgroundColor, activityIndicatorView: spinner)
		view.frame = CGRect(x: 0.0, y: 0.0, width: viewSize.width, height: viewSize.height)
		return view
	}
	
	fileprivate func snapShot(_ delay: Double, retry: Int = 0) {
		if retry > 3 {
			NSLog("Cannot get a good snapshot of the view. Giving up...")
			return
		}
		
		let jsonStr = self.viewModel.gameData!.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions(rawValue: 0))
		let hashStr = "\(jsonStr!.hash)"
		//Do not recreate snapshots for images that already exist
		if SDImageCache.shared().imageFromDiskCache(forKey: hashStr) != nil {
			return
		}
		
		//Displatch after to make sure that the WKWebView has been rendered properly
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
			[unowned self] in
			let snapshot = UIImage.imageForView(self.webView)
			if snapshot != nil {
				//TODO! Caches forever, cleanup the cache regularly or figure out a TTL
				///SDImageCache.sharedImageCache().storeImage(snapshot!, forKey: hashStr)
			} 
		})
	}
	
	// WKScriptMessageHandler Delegate. Received data from the embedded game
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if let messageBody:NSDictionary = message.body as? NSDictionary {
			switch message.name {
			case jsMsgLog:
				if let line = messageBody["line"] as? String {
					NSLog("JS[%@]: %@", self.viewModel.gameData!["gameType"].stringValue ,line)
				}
			default:
				NSLog("STGameMediaItem: Unknown JS message received \(message)")
			}
		}
	}
	
	func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse) {
		gameDownloadSize = response.expectedContentLength
		NSLog("STGameMediaItem: Response received! Status Code: %d Content %d", (response as! HTTPURLResponse).statusCode, gameDownloadSize)
	}
	
	func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
		NSLog("STGameMediaItem: data received %d/%d",  data.count, gameDownloadSize)
	}
	
	func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		NSLog("STGameMediaItem: Connection failed with error \(error)")
	}
	
	//func
	
	//mark - NSObject
	override var hash: Int {
		get {
			return super.hash ^ self.viewModel.hash
		}
	}
	
	override var description: String {
		get {
			return "\(self.webView)"
		}
	}
}
