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
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
        
        //NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"Google"];
        //[str addAttribute: NSLinkAttributeName value: @"http://www.google.com" range: NSMakeRange(0, str.length)];
        //yourTextView.attributedText = str;
        
        let fontTitilliumRegular =  "TitilliumWeb-Regular"
       
        let fontTitle               =  UIFont.systemFontOfSize(17)//UIFont(name:fontTitilliumRegular, size:17)!
        let myAttribute = [ NSFontAttributeName: fontTitle ]
        let intitiaString = NSMutableAttributedString(string: "Tap \"Agree & Continue \" to accept the OYAPP ", attributes:myAttribute )
        
        
        let mutableString = NSMutableAttributedString(string: "Terms of Use and ")
        mutableString.addAttribute(NSLinkAttributeName, value: "http://oyapp.in/terms-of-use", range: NSMakeRange(0, mutableString.length))
        let mutableString1 = NSMutableAttributedString(string: "Privacy policy")
        mutableString1.addAttribute(NSLinkAttributeName, value: "http://oyapp.in/privacy-policy", range: NSMakeRange(0, mutableString1.length))
       
        intitiaString.appendAttributedString(mutableString)
        intitiaString.appendAttributedString(mutableString1)
        intitiaString.addAttribute(NSFontAttributeName, value: fontTitle, range: NSMakeRange(0, intitiaString.length))
        
        tcTextView.attributedText = intitiaString
        tcTextView.backgroundColor = self.view.backgroundColor
        tcTextView.textAlignment = NSTextAlignment.Center
         
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
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
    
    
    @IBAction func tcButtonClicked(sender:UIButton)
    {
        let mainvc = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController")
        self.navigationController?.pushViewController(mainvc!, animated: true)
        
    }

}
