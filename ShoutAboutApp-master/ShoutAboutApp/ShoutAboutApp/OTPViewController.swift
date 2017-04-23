//
//  OTPViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class OTPViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldBaseView:UIView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet var countDownLabel: UILabel!
    
    var count = 120
    var otpString:String = ""
    var mobileNumberString:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        startTimer()
        otpTextField.addTarget(self, action:#selector(ViewController.edited), forControlEvents:UIControlEvents.EditingChanged)
        verifyButton.userInteractionEnabled = false
        verifyButton.alpha = 0.5
        textFieldBaseView.makeBorder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.hideKeyBoard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(self.hideKeyBoard(_:)))
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidAppear(animated: Bool){
        
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue(),{
           //self.otpTextField.becomeFirstResponder()
        })
        
    }
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    @IBAction func otpButtonClicked(sender: UIButton)
    {
        otpTextField.resignFirstResponder()
        
        /*
        dispatch_async(dispatch_get_main_queue(), {
            let joinViewController = self.storyboard?.instantiateViewControllerWithIdentifier("JoinViewController") as? JoinViewController
            //otpViewController?.mobileNumberString = self.mobileNumberString
            self.presentViewController(joinViewController!, animated: true, completion: nil)
            
        });
        */
        
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            displayAlertMessage("No Internet Connection")
            
        }else
        {
            self.otpTextField.text = nil
            self.view.showSpinner()
            DataSessionManger.sharedInstance.getOTPValidateForMobileNumber(mobileNumberString, otp: otpString, onFinish: { (response, deserializedResponse) in
                print("deserializedResponse \(deserializedResponse)")
                
                if deserializedResponse is NSDictionary
                {
                     if deserializedResponse.objectForKey(message) != nil
                     {
                        let messageString = deserializedResponse.objectForKey(message) as? String
                        if messageString == otpExpireMessage
                        {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.view.removeSpinner()
                                self.verifyButton.userInteractionEnabled = false
                                self.verifyButton.alpha = 0.5
                                self.displayAlertMessage(otpExpireMessage)
                            })
                            
                        }
                        
                        if messageString == inavalidOTP
                        {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.view.removeSpinner()
                                self.verifyButton.userInteractionEnabled = false
                                self.verifyButton.alpha = 0.5
                                self.displayAlertMessage(inavalidOTP)
                            })
                            
                        }
                        
                    }
                    
                    
                    if deserializedResponse.objectForKey(kapp_user_id) != nil
                    {
//                         let appUserId = deserializedResponse.objectForKey(kapp_user_id) as? Int
                        
                         let appUserId = 620
                        
                         NSUserDefaults.standardUserDefaults().setInteger(appUserId, forKey: kapp_user_id)
                         NSUserDefaults.standardUserDefaults().synchronize()
                        
                    }
                    
                    if deserializedResponse.objectForKey(kapp_user_token) != nil
                    {
                        let appUserToken = deserializedResponse.objectForKey(kapp_user_token) as? String
                        
                        
//                         let appUserToken = "$2y$10$RU86wqBxp1Vt8BY5ld60kOjbkefd1VfaN.TxnKvVntGYMV5KA/UTm"
                        
                        
                        NSUserDefaults.standardUserDefaults().setObject(appUserToken, forKey: kapp_user_token)
                         NSUserDefaults.standardUserDefaults().synchronize()
                        
                    }
                    
                    
                    let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id)
                    let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token)
                    
                    if appUserId != nil && appUserToken != nil
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.view.removeSpinner()
                            let joinViewController = self.storyboard?.instantiateViewControllerWithIdentifier("JoinViewController") as? JoinViewController
                            //otpViewController?.mobileNumberString = self.mobileNumberString
                            self.presentViewController(joinViewController!, animated: true, completion: nil)
                            
                        });
                        
                    }
                    
                }
                
                }, onError: { (error) in
                    
                    print("error \(error)")
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self.verifyButton.userInteractionEnabled = false
                            self.verifyButton.alpha = 0.5
                            self.view.removeSpinner()
                    })

            })
            
        }
        
        
    }
    
    @IBAction func resendButtonClicked(sender: UIButton)
    {
        
        if NetworkConnectivity.isConnectedToNetwork() != true{
            
            displayAlertMessage("No Internet Connection")
            
        }else
        {
            //hit webservice
            
            startTimer()
            DataSessionManger.sharedInstance.getOTPForMobileNumber(mobileNumberString, onFinish: { (response, deserializedResponse) in
                
                print(" response :\(response) , deserializedResponse \(deserializedResponse) ")
                if deserializedResponse is NSDictionary
                {
                    if deserializedResponse.objectForKey(message) != nil
                    {
                        let messageString = deserializedResponse.objectForKey(message) as? String
                        if messageString == otpMessage
                        {
                            
                            // print go ahead
                        }else
                        {
                            // stay here
                        }
                    }
                }
                
                }, onError: { (error) in
                    print(" error:\(error)")
                    
            })
        }
    }
}

extension OTPViewController
{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var text:NSString =  textField.text ?? ""
        text =  text.stringByReplacingCharactersInRange(range, withString: string)
        
        
        if text.length == 6
        {
            verifyButton.userInteractionEnabled = true
            verifyButton.alpha = 1.0
        }else
        {
            verifyButton.userInteractionEnabled = false
            verifyButton.alpha = 0.5
        }
        
        if text.length > 6
        {
            return false
        }
        return true
    }
    
    func edited()
    {
        print("Edited \(otpTextField.text)")
        otpString = otpTextField.text!
        if otpString.characters.count == 6
        {
            verifyButton.userInteractionEnabled = true
            verifyButton.alpha = 1.0
        }else
        {
            verifyButton.userInteractionEnabled = false
            verifyButton.alpha = 0.5
        }
    }
    
}

extension OTPViewController
{
    
    func startTimer()
    {
        count = 120
        countDownLabel.text = nil
        countDownLabel.hidden = false
        resetButton.userInteractionEnabled = false
        resetButton.alpha = 0.5
        _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(OTPViewController.update), userInfo: nil, repeats: true)
    }
    
    func update() {
        
        if(count > 0)
        {
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            countDownLabel.text = minutes + " Min" + " : " + seconds+" Sec"
            count -= 1
        }else{
            countDownLabel.hidden = true
            resetButton.userInteractionEnabled = true
            resetButton.alpha = 1.0

            
        }
        
    }
}

extension OTPViewController
{
    func hideKeyBoard(notification: NSNotification)
    {
        otpTextField.resignFirstResponder()
        
    }
}
