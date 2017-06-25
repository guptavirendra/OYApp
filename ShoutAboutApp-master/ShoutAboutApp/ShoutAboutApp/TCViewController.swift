//
//  TCViewController.swift
//  
//
//  Created by VIRENDRA GUPTA on 26/04/17.
//
//

import UIKit

class TCViewController: UIViewController
{

    @IBOutlet weak var tcButton: UIButton!
    @IBOutlet weak var tcTextView:UITextView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let fontTitle               =  UIFont.systemFont(ofSize: 17)// 
        let myAttribute = [ NSFontAttributeName: fontTitle ]
        let intitiaString = NSMutableAttributedString(string: "Tap \"Agree & Continue \" to accept the OYAPP ", attributes:myAttribute )
        
        
        let mutableString = NSMutableAttributedString(string: "Terms of Use and ")
        mutableString.addAttribute(NSLinkAttributeName, value: "http://oyapp.in/terms-of-use", range: NSMakeRange(0, mutableString.length))
        let mutableString1 = NSMutableAttributedString(string: "Privacy policy")
        mutableString1.addAttribute(NSLinkAttributeName, value: "http://oyapp.in/privacy-policy", range: NSMakeRange(0, mutableString1.length))
       
        intitiaString.append(mutableString)
        intitiaString.append(mutableString1)
        intitiaString.addAttribute(NSFontAttributeName, value: fontTitle, range: NSMakeRange(0, intitiaString.length))
        
        tcTextView.attributedText = intitiaString
        tcTextView.backgroundColor = self.view.backgroundColor
        tcTextView.textAlignment = NSTextAlignment.center
         
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func tcButtonClicked(_ sender:UIButton)
    {
        let mainvc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(mainvc!, animated: true)
        
    }

}
