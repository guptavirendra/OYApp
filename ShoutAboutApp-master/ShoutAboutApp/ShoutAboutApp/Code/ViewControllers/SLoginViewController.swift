//
//  LoginViewController.m
//  smalltalk
//
//  Created by Mikko Hämäläinen on 21/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import DigitsKit
import ChameleonFramework
import SnapKit
import ReactiveCocoa
import Result
import TSMessages
import PhoneNumberKit
import SwiftyJSON

class SLoginViewController: UIViewController, UITextFieldDelegate {
	var loginSequenceCompleted = MutableProperty<Bool>(false)
	
	//Test user data
	var testUserButton: UIButton!
	var testUserText: UITextField!
	//End
	
	var label: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = FlatWhite()
		//ComplementaryFlatColorOf(color)
		//ContrastColor(backgroundColor, isFlat)

		//Check out these values from LaunchScreen.xib
		self.label = UILabel(frame: CGRect(x: 0, y: 0, width: 55, height: 15))
		self.label.text = "smalltalk"
		self.label.font = UIFont.boldSystemFont(ofSize: 22)
		self.label.textColor = FlatRed()
		
		self.view.addSubview(self.label)
		self.label.snp_makeConstraints { (make) -> Void in
			make.centerX.equalTo(self.view)
			make.centerY.equalTo(self.view.snp_bottom).multipliedBy(0.25).offset(1)
		}
		
		let digitsAppearance = DGTAppearance()
		digitsAppearance.backgroundColor = FlatWhite()
		digitsAppearance.accentColor = FlatRed()
		
		let authenticateButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		self.view.addSubview(authenticateButton)
		authenticateButton.isEnabled = true
		authenticateButton.layer.cornerRadius = 5
		authenticateButton.backgroundColor = UIColor.white
		authenticateButton.setTitleColor(FlatWhite(), for: UIControlState())
		authenticateButton.setTitle("Sign up", for: UIControlState())
		authenticateButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
		authenticateButton.backgroundColor = FlatRed()
		authenticateButton.snp_makeConstraints { (make) -> Void in
			make.width.equalTo(self.view).multipliedBy(0.75)
			make.height.equalTo(self.view).multipliedBy(0.06)
			make.centerX.equalTo(self.view)
			make.bottom.equalTo(self.view).multipliedBy(0.80)
		}
		authenticateButton.addTarget(self, action: "digitsAuth:", for: UIControlEvents.touchUpInside)
		
		//Test user functionality
		if Configuration.showTestUser {
			self.testUserButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
			testUserButton.isEnabled = true
			testUserButton.backgroundColor = UIColor.white
			testUserButton.setTitleColor(UIColor.blue, for: UIControlState())
			testUserButton.setTitle("Make a test user", for: UIControlState())
			self.view.addSubview(self.testUserButton)
			testUserButton.snp_makeConstraints { make in
				make.size.equalTo(authenticateButton)
				make.centerX.equalTo(self.view)
				make.top.equalTo(authenticateButton.snp_bottom).offset(10)
			}
			self.testUserButton.addTarget(self, action: "testUserButton:", for: UIControlEvents.touchUpInside)
			
			self.testUserText = UITextField(frame: CGRect.zero)
			self.testUserText.isEnabled = false
			self.testUserText.backgroundColor = UIColor.white
			self.testUserText.alpha = 0.0
			self.testUserText.borderStyle = UITextBorderStyle.line
			self.testUserText.autocapitalizationType = UITextAutocapitalizationType.none
			self.testUserText.autocorrectionType = UITextAutocorrectionType.no
			self.view.addSubview(self.testUserText)
			testUserText.snp_makeConstraints { make in
				make.size.equalTo(testUserButton)
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.view.snp_top).offset(30)
			}
			self.testUserText.delegate = self
		}
		//End test user
	}
	
	func digitsAuth(_ sender: AnyObject?) {
		let appearance = DGTAppearance()
		appearance.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
		appearance.bodyFont = UIFont(name: "HelveticaNeue-Italic", size: 16)
		appearance.accentColor = FlatRed()
		appearance.backgroundColor = FlatWhite()
		
		let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
		configuration.appearance = appearance
		Digits.sharedInstance().authenticate(with: nil, configuration: configuration, completion: {
			(session: DGTSession!, error: NSError!) in
			if (session == nil) {
				//TODO Dismiss this view controller and start from beginning
				self.loginSequenceCompleted.value = true
			} else {
				let digits = Digits.sharedInstance()
				let oauthSigning = DGTOAuthSigning(authConfig:digits.authConfig, authSession:digits.session())
				var authHeaders: [AnyHashable: Any] = oauthSigning.oAuthEchoHeadersToVerifyCredentials()
				
				do {
					let phoneNumber = try PhoneNumber(rawNumber:session.phoneNumber)
					let countryCode = "+\(String(phoneNumber.countryCode))"
					authHeaders["countryCode"] = countryCode
				}
				catch {
					print("Phone number parse error")
				}
				
				self.postToDigits(authHeaders)
					.observeOn(UIScheduler())
					.start {
						event in
						switch event {
						case let .next(result):
							if (result.value != nil) {
								self.saveUserData(result.value as! JSON)
								self.loginSequenceCompleted.value  = true
							}
						
						case let .failed(error):
							NSLog("Post to digits error %@", error)
                            TSMessage.showNotification(in: self, title: "Authentication error", subtitle: error.localizedDescription , type: TSMessageNotificationType.error)
						default:
							break
						}
				}
			}
		})
	}
	
	fileprivate func saveUserData(_ data: JSON) {
		User.loggedInWith(data)
	}
	
	fileprivate func postToDigits(_ authHeaders: [AnyHashable: Any]) -> SignalProducer<Result<Any, NSError>, NSError> {
		return STHttp.post("\(Configuration.mainApi)/users/new", data: authHeaders)
	}
	
	//Test user functionality
	func testUserButton(_ sender: AnyObject?) {
		self.testUserButton.isEnabled = false
		UIView.animate(withDuration: 0.1, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.testUserButton.alpha = 0.0
			},
			completion: {
				finished in
				self.testUserText.isEnabled = true
				self.testUserText.alpha = 1.0
		})
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
		textField.resignFirstResponder()
		self.testUserText.isEnabled = false
		UIView.animate(withDuration: 0.1, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.testUserText.alpha = 0.0
			}, completion: nil)
		let data = ["user": textField.text!]
		self.postTestUser(data)
			.observeOn(UIScheduler())
			.start {
				event in
				switch event {
				case let .next(result):
					if (result.value != nil) {
						self.saveUserData(result.value as! JSON)
						self.loginSequenceCompleted.value = true
					}
				case let .failed(error):
					TSMessage.showNotification(in: self, title: "Authentication error", subtitle: "\(error.code) \(error.localizedDescription)" , type: TSMessageNotificationType.error)
					self.testUserText.isEnabled = true
					self.testUserText.alpha = 1.0
				default:
					break
			}
		}
		
		return true
	}
	
	fileprivate func postTestUser(_ data: [AnyHashable: Any]) -> SignalProducer<Result<Any, NSError>, NSError> {
		return STHttp.post("\(Configuration.mainApi)/users/test", data: data)
	}
}


