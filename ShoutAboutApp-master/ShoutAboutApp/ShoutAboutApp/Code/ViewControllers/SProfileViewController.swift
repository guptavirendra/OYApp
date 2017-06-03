//
//  ProfileViewController.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 20/10/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit

class SProfileViewController: UIViewController, UITextFieldDelegate {

	var label: UILabel!
	var usernameField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.usernameField = UITextField(frame: CGRect.zero)
		self.view.addSubview(self.usernameField)
		//self.usernameField.backgroundColor = UIColor.whiteColor()
		self.usernameField.placeholder = "Please choose a nick"
		self.usernameField.borderStyle = UITextBorderStyle.roundedRect
		self.usernameField.autocorrectionType = UITextAutocorrectionType.no
		usernameField.snp_makeConstraints { make in
			make.width.equalTo(self.view).multipliedBy(0.75)
			make.height.equalTo(self.view).multipliedBy(0.06)
			make.centerX.equalTo(self.view)
			make.bottom.equalTo(self.view).multipliedBy(0.20)
		}
		self.usernameField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
		textField.resignFirstResponder()
		self.usernameField.isEnabled = false
		let displayName = self.usernameField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		let stream = STXMPPClient.sharedInstance?.stream
		stream!.updateVCard(displayName)
		User.displayName = displayName
		self.dismiss(animated: true, completion: nil)
		return true
	}
}
