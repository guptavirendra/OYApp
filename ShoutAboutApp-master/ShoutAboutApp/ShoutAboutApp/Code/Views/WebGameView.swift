//
//  WebGameView.swift
//  Meatspace
//
//  Created by Mikko Hämäläinen on 14/09/15.
//  Copyright (c) 2015 layer. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import ReactiveCocoa
import ChameleonFramework

class WebGameView: UIView, WKScriptMessageHandler, NSURLConnectionDelegate {
	let gameNotified = MutableProperty<STGameData?>(nil)
	var controllerDelegate: ConversationViewController! //UGLY! WebGameViewController should not be coupled this way
	
	fileprivate let viewModel: WebViewModel
	fileprivate var webView: WKWebView!
	fileprivate var gameType: String!
	fileprivate var targetDownPos: CGPoint
	fileprivate var targetHighPos: CGPoint
	fileprivate var atHighPoint = false
	fileprivate var tapPoint: CGPoint
	fileprivate var targetFrame: CGRect
	
	fileprivate let jsMsgLog = "log"
	fileprivate let jsMsgGameStateUpdated = "gameStateUpdated"
	fileprivate let jsMsgGameEnded = "gameEnded"
	
	fileprivate var gameDownloadSize: Int64 = 0
	
	var webConfig:WKWebViewConfiguration {
		get {
			let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
			// Setup WKUserContentController instance for injecting user script
			let userController:WKUserContentController = WKUserContentController()
			// Add a script message handler for receiving  "gameEnded" event notifications posted from the JS document using gameEnded script message
			userController.add(self, name: jsMsgLog)
			userController.add(self, name: jsMsgGameStateUpdated)
			userController.add(self, name: jsMsgGameEnded)
			webCfg.userContentController = userController;
			return webCfg;
		}
	}

	init(superViewFrame: CGRect, gameType: String, gameData: JSON?, tapPoint:CGPoint, outgoing: Bool) {
		self.gameType = gameType
		self.viewModel = WebViewModel(gameType: gameType, data: gameData, outgoingView: outgoing)

		self.tapPoint = tapPoint
		self.targetFrame = 	CGRect(x: superViewFrame.origin.x, y: superViewFrame.origin.y + statusBarHeight(), width: superViewFrame.width, height: superViewFrame.height - round(superViewFrame.height/4.5))
		self.targetDownPos = targetFrame.origin
		self.targetHighPos = CGPoint(x: targetFrame.origin.x, y: targetFrame.origin.y - targetFrame.height + navigationBarHeight())

		let startFrame = CGRect(x: tapPoint.x, y: tapPoint.y, width: 100, height: 100)
		super.init(frame: startFrame)

		self.backgroundColor = (UIApplication.shared.delegate as! AppDelegate).globalColor!
		self.setupWebView()
		self.setupSwipeLabel()
		
		let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WebGameView.panned(_:)))
		panRecognizer.minimumNumberOfTouches = 1
		panRecognizer.maximumNumberOfTouches = 1
		self.addGestureRecognizer(panRecognizer)
	}
	
	// WKScriptMessageHandler Delegate. Received data from the embedded game
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if let messageBody:NSDictionary = message.body as? NSDictionary {
			switch message.name {
			case jsMsgLog:
				if let line = messageBody["line"] as? String {
					NSLog("JS: %@", line)
				}
			case jsMsgGameStateUpdated:
				let data = STGameData(gameData: messageBody, type: self.gameType)
				self.gameNotified.value = data
			case jsMsgGameEnded:
				let data = STGameData(gameData: messageBody, type: self.gameType)
				self.gameNotified.value = data
			default:
				assert(false, "Unknown JS message received \(message)")
			}
		}
	}
	
	func newGameMessageReceived(_ incomingGameData: JSON) {
		let gameType = incomingGameData["gameType"].string
		if (self.gameType == gameType) {
			//UpdateState is JSON
			let updateState = incomingGameData["updateState"]
			if let jsonStr = updateState.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions(rawValue: 0)) {
				let js = String(format: "gameMoveMade(%@);", jsonStr)
				webView!.evaluateJavaScript(js, completionHandler: { (result: AnyObject?, error: NSError?) -> Void in
					if error != nil {
						assert(false, "evaluateJavaScript Error \(error)")
					}
				})
			}
		}
	}
	
	fileprivate func setupWebView() {
		self.webView = WKWebView(frame: CGRect.zero, configuration: webConfig)
		self.webView.backgroundColor = (UIApplication.shared.delegate as! AppDelegate).backgroundColor!
		self.webView.scrollView.backgroundColor = (UIApplication.shared.delegate as! AppDelegate).backgroundColor!

		self.alpha = 0.5
		self.webView.alpha = 0.5
		self.addSubview(webView!)
		webView.scrollView.bounces = false;
		
		webView.translatesAutoresizingMaskIntoConstraints = false
		let height = NSLayoutConstraint(item: webView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: -40)
		let width = NSLayoutConstraint(item: webView!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0)
		let centerx = NSLayoutConstraint(item: webView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
		let top = NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
		
		self.addConstraints([height, width, centerx, top])
		
		self.viewModel.loadWebView(self.webView, urlConnDelegate: self, completion: {
			[unowned self] success in
			if success {
				NSLog("View loaded succesfully")
			}
		})
	}
	
	fileprivate func setupSwipeLabel() {
		let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
		label.text = "Swipe left to dismiss, up to make room"
		label.font = UIFont.boldSystemFont(ofSize: 12)
		label.textColor = UIColor.white
		label.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(label)
		let center = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
		let bottom = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -10)
		self.addConstraints([center, bottom])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse) {
		gameDownloadSize = response.expectedContentLength
		NSLog("WebGameView: Response received! Status Code: %d Content %d", (response as! HTTPURLResponse).statusCode, gameDownloadSize)
	}

	func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
		NSLog("WebGameView: data received %d/%d",  data.count, gameDownloadSize)
	}
	
	func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		NSLog("WebGameView: Connection failed with error \(error)")
	}
	
	func animateToView()
	{
		UIView.animate(withDuration: TimeInterval(0.25),
			animations: {
				self.frame = self.targetFrame
				self.alpha = 1.0
				self.webView!.alpha = 1.0
			},
			completion: nil
		)
	}

	func panned(_ sender: AnyObject?)
	{
		let recognizer: UIPanGestureRecognizer = sender as! UIPanGestureRecognizer
		let point: CGPoint = recognizer.translation(in: self.controllerDelegate.view)

		if (recognizer.state == UIGestureRecognizerState.changed) {
			//Only allow movement to up if not at midpoint or down if at midpoint
			if (point.y < 0 && !atHighPoint) {
				self.frame.origin.y = self.targetDownPos.y + point.y
			} else if (point.y > 0 && atHighPoint) {
				self.frame.origin.y = self.targetHighPos.y + point.y
			}
			
			//Only allow movement to left
			if (point.x < 0) {
				self.frame.origin.x = self.targetDownPos.x + point.x
			}
			
		} else if(recognizer.state == .ended) {
			//All fingers have been lifted.
			let velocity: CGFloat = recognizer.velocity(in: self.controllerDelegate.view).x
			let duration = (abs(velocity) * 0.0002) + 0.2
			
			let dismissThreshold: CGFloat = 40.0
			let moveThreshold: CGFloat = 30.0
			
			if (point.x < -dismissThreshold) {
				//Dismiss
				UIView.animate(withDuration: TimeInterval(0.5), delay: TimeInterval(0.0), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState],
					animations: {
						self.frame.origin.x = -self.frame.width //Toss to side TODO Make a better animation
					},
					completion: {
						finished in
						self.removeFromSuperview()
						self.controllerDelegate.gameDismissed()
					}
				)
			} else if (!atHighPoint && point.y < -moveThreshold) {
				self.moveToHighPoint()
			} else if (atHighPoint && point.y > moveThreshold) {
				self.moveToLowPoint()
			} else {
				//Return if no threshold was triggered
				if (!self.atHighPoint) {
					self.animateMove(0.5, animations: {
						self.frame.origin.y = self.targetDownPos.y
						self.frame.origin.x = self.targetDownPos.x
					})
				} else {
					self.animateMove(0.5, animations: {
						self.frame.origin.y = self.targetHighPos.y
						self.frame.origin.x = self.targetHighPos.x
					})
				}
			}
		}

	}
	
	func moveToHighPoint(_ slow: Bool = false) {
		//Move to highpoint
		if !atHighPoint {
			self.atHighPoint = true
			let speed = slow ? 0.3 : 0.1
			self.animateMove(speed, animations: {
				self.frame.origin.y = self.targetHighPos.y
				self.frame.origin.x = self.targetHighPos.x
			})
		}
	}
	
	func moveToLowPoint(_ slow: Bool = false) {
		//Move back down from highpoint
		if atHighPoint {
			self.atHighPoint = false
			let speed = slow ? 0.3 : 0.1
			self.animateMove(speed, animations: {
				self.frame.origin.y = self.targetDownPos.y
				self.frame.origin.x = self.targetDownPos.x
			})
		}
	}
	
	fileprivate func animateMove(_ duration: Double, animations: () -> Void) {
		UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(0.0), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState],
			animations: animations,
			completion: nil
		)
	}
}
