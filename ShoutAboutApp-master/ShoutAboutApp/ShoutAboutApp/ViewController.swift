//
//  ViewController.swift
//  ShoutAboutAppV
//
//  Created by VIRENDRA GUPTA on 05/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var textFieldBaseView:UIView!
    
    var mobileNumberString:String = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        mobileNumberTextField.addTarget(self, action:#selector(ViewController.edited), forControlEvents:UIControlEvents.EditingChanged)
        submitButton.userInteractionEnabled = false
        submitButton.alpha = 0.5
        textFieldBaseView.makeBorder()
        //self.view.backgroundColor = bgColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submitButtonClicked(sender: UIButton)
    {
        ///print hit webservice
        print("Mobile Number to Submit \(mobileNumberString)")
        mobileNumberTextField.resignFirstResponder()
        
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            displayAlertMessage("No Internet Connection")
            
        }else
        {
            //hit webservice
            
            self.view.showSpinner()
            DataSessionManger.sharedInstance.getOTPForMobileNumber(mobileNumberString, onFinish: { (response, deserializedResponse) in
                
                print(" response :\(response) , deserializedResponse \(deserializedResponse) ")
                if deserializedResponse is NSDictionary
                {
                    if deserializedResponse.objectForKey(message) != nil
                    {
                        let messageString = deserializedResponse.objectForKey(message) as? String
                        if messageString == otpMessage
                        {
                            dispatch_async(dispatch_get_main_queue(),
                                {
                                    self.view.removeSpinner()
                                let otpViewController = self.storyboard?.instantiateViewControllerWithIdentifier("OTPViewController") as? OTPViewController
                                otpViewController?.mobileNumberString = self.mobileNumberString
                                self.presentViewController(otpViewController!, animated: true, completion: nil)
                                
                            });
                            // print go ahead
                        }else
                        {
                            // stay here
                        }
                    }
                }
                
                }, onError: { (error) in
                    print(" error:\(error)")
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self.view.removeSpinner()
                    })
                    
            })
        }
    
        
    }

}


extension ViewController:UITextFieldDelegate
{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var text:NSString =  textField.text ?? ""
        text =  text.stringByReplacingCharactersInRange(range, withString: string)
        
        
        if text.length == 10
        {
            submitButton.userInteractionEnabled = true
            submitButton.alpha = 1.0
        }else
        {
            submitButton.userInteractionEnabled = false
            submitButton.alpha = 0.5
        }
        
        if text.length > 10
        {
            return false
        }
        return true
    }
    func edited()
    {
        print("Edited \(mobileNumberTextField.text)")
        mobileNumberString = mobileNumberTextField.text!
        if mobileNumberString.characters.count == 10
        {
            submitButton.userInteractionEnabled = true
            submitButton.alpha = 1.0
        }else
        {
            submitButton.userInteractionEnabled = false
            submitButton.alpha = 0.5
        }

    }
}



extension UIViewController
{
    /* Displays alert message
     */
    func displayAlertMessage(userMessage: String)
    {
        
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayAlert(userMessage: String, handler: ((UIAlertAction) -> Void)?)
    {
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: handler)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}


import Foundation
import UIKit


public extension UIView
{
    
    func setGraphicEffects()
    {
        self.layer.shadowColor   = UIColor.lightGrayColor().CGColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius  = 3.0
        self.layer.shadowOffset  = CGSizeMake(1.0, 1.0)
        self.layer.masksToBounds = false
        
    }
    public func showSpinner()
    {
        self.showSpinner(true, userInteractionEnabled: false)
    }
    
    public func showSpinnerWithUserInteractionEnabled(userInteractionEnabled: Bool, dimBackground: Bool)
    {
        self.showSpinnerInView(self, spinnerType:"", dimBackgroundEnabled: dimBackground, userInteractionEnabled: userInteractionEnabled)
    }
    
    public func showSpinner(dimBackground: Bool, userInteractionEnabled: Bool)
    {
        
        let window = UIApplication.sharedApplication().keyWindow
        
        self.showSpinnerInView(window!, spinnerType: "", dimBackgroundEnabled: dimBackground, userInteractionEnabled: userInteractionEnabled)
        
        
    }
    
    //Add ProgressView
    public func showSpinnerInView(view:UIView, spinnerType:String, dimBackgroundEnabled: Bool, userInteractionEnabled: Bool)
    {
        self.removeSpinner()
        dispatch_async(dispatch_get_main_queue(), { //() -> Void in
            
            let viewSize: CGFloat = 44
            let imageSize: CGFloat = 26
            
            // Progress View Background
            let dimBackground = UIView()
            dimBackground.tag = 5001
            dimBackground.frame = view.frame
            if userInteractionEnabled
            {
                dimBackground.userInteractionEnabled = false
            }
            else
            {
                dimBackground.userInteractionEnabled = true
            }
            if dimBackgroundEnabled
            {
                dimBackground.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            }
            else
            {
                dimBackground.backgroundColor = UIColor.clearColor()
            }
            dimBackground.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dimBackground)
            
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
            
            // Progress View Background
            let progressBackground = UIView()
            progressBackground.tag = 5002
            progressBackground.frame = CGRectMake(0, 0, viewSize, viewSize)
            progressBackground.backgroundColor = UIColor.clearColor()
            progressBackground.translatesAutoresizingMaskIntoConstraints = false
            dimBackground.addSubview(progressBackground)
            
            progressBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 44))
            progressBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 44))
            dimBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dimBackground, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
            dimBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dimBackground, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
            
            // Logo Image
            let logoImage:UIImageView = UIImageView()
            logoImage.frame = CGRectMake(0, 0, imageSize, imageSize)
            logoImage.center = progressBackground.center
            logoImage.backgroundColor = UIColor.clearColor()
            //logoImage.image = UIImage.commonImageNamed("LogoImage.png")
            progressBackground.addSubview(logoImage)
            
            // Rotate Animation
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.duration = 2.0
            animation.repeatCount = HUGE
            animation.fromValue = NSNumber(float: 0.0)
            animation.toValue   = NSNumber(float: 2 * Float(M_PI))
            
            // Gradient Circular
            let gradientView: UIView = GradientArcWithClearColorView().draw(progressBackground.frame)
            progressBackground.addSubview(gradientView)
            gradientView.layer.addAnimation(animation, forKey: "rotate")
        });
    }
    
    //Remove ProgressView
    public func removeSpinner()
    {
        dispatch_async(dispatch_get_main_queue(), { //() -> Void in
            
            //if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window
            //{
            let window = UIApplication.sharedApplication().keyWindow
            
            // If spinner view is added on Window
            if let dimView: UIView = window!.viewWithTag(5001)
            {
                if let progressView: UIView = dimView.viewWithTag(5002)
                {
                    progressView.removeFromSuperview()
                }
                dimView.removeFromSuperview()
            }
            else
            {
                // If spinner view is added on View
                if let dimView: UIView = self.viewWithTag(5001)
                {
                    if let progressView: UIView = dimView.viewWithTag(5002)
                    {
                        progressView.removeFromSuperview()
                    }
                    dimView.removeFromSuperview()
                }
            }
            //}
        });
        
    }
}

class GradientArcWithClearColorView : UIView
{
    
    internal func draw(rect: CGRect) -> UIImageView {
        // Gradient Clear Circular
        
        /* Prop */
        var prop: Property = Property()
        
        // Change circle outer color
            prop.endArcColor = ColorUtil.toUIColor(r: 17.0, g: 121.0, b: 190.0, a: 1.0)
        
        
        var startArcColorProp = prop
        var endArcColorProp = prop
        var startGradientMaskProp = prop
        var endGradientMaskProp = prop
        var solidMaskProp = prop
        
        // StartArc
        startArcColorProp.endArcColor = ColorUtil.toNotOpacityColor(color: startArcColorProp.startArcColor)
        
        // EndArc
        endArcColorProp.startArcColor = ColorUtil.toNotOpacityColor(color: endArcColorProp.endArcColor)
        
        // StartGradientMask
        startGradientMaskProp.startArcColor = UIColor.blackColor()
        startGradientMaskProp.endArcColor = UIColor.whiteColor()
        startGradientMaskProp.progressSize += 10.0
        startGradientMaskProp.arcLineWidth += 20.0
        
        // EndGradientMask
        endGradientMaskProp.startArcColor = UIColor.whiteColor()
        endGradientMaskProp.endArcColor = UIColor.blackColor()
        endGradientMaskProp.progressSize += 10.0
        endGradientMaskProp.arcLineWidth += 20.0
        
        // SolidMask
        solidMaskProp.startArcColor = UIColor.blackColor()
        solidMaskProp.endArcColor   = UIColor.blackColor()
        
        /* Mask Image */
        // StartArcColorImage
        let startArcColorView = ArcView(frame: rect, lineWidth: startArcColorProp.arcLineWidth)
        startArcColorView.color = startArcColorProp.startArcColor
        startArcColorView.prop = startArcColorProp
        let startArcColorImage = viewToUIImage(startArcColorView)!
        
        // StartGradientMaskImage
        let startGradientMaskView = GradientArcView(frame: rect)
        startGradientMaskView.prop = startGradientMaskProp
        let startGradientMaskImage = viewToUIImage(startGradientMaskView)!
        
        // EndArcColorImage
        let endArcColorView = ArcView(frame: rect, lineWidth: endArcColorProp.arcLineWidth)
        endArcColorView.color = endArcColorProp.startArcColor
        endArcColorView.prop = endArcColorProp
        let endArcColorImage = viewToUIImage(endArcColorView)!
        
        // EndGradientMaskImage
        let endGradientMaskView = GradientArcView(frame: rect)
        endGradientMaskView.prop = endGradientMaskProp
        let endGradientMaskImage = viewToUIImage(endGradientMaskView)!
        
        // SolidMaskImage
        let solidMaskView = ArcView(frame: rect, lineWidth: solidMaskProp.arcLineWidth)
        solidMaskView.prop = solidMaskProp
        let solidMaskImage = viewToUIImage(solidMaskView)!
        
        /* Masking */
        var startArcImage = mask(startGradientMaskImage, maskImage: solidMaskImage)
        startArcImage = mask(startArcColorImage, maskImage: startArcImage)
        
        var endArcImage = mask(endGradientMaskImage, maskImage: solidMaskImage)
        endArcImage = mask(endArcColorImage, maskImage: endArcImage)
        
        /* Composite */
        let image: UIImage = composite(image1: startArcImage, image2: endArcImage, prop: prop)
        
        /* UIImageView */
        let imageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    internal func mask(image: UIImage, maskImage: UIImage) -> UIImage {
        
        let maskRef: CGImageRef = maskImage.CGImage!
        let mask: CGImageRef = CGImageMaskCreate(
            CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef),
            nil,
            false)!
        
        let maskedImageRef: CGImageRef = CGImageCreateWithMask(image.CGImage, mask)!
        let scale = UIScreen.mainScreen().scale
        let maskedImage: UIImage = UIImage.init(CGImage: maskedImageRef, scale: scale, orientation: .Up)
        
        return maskedImage
    }
    
    internal func viewToUIImage(view: UIView) -> UIImage? {
        
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    internal func composite(image1 image1: UIImage, image2: UIImage, prop: Property) -> UIImage {
        
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(image1.size, false, scale)
        image1.drawInRect(
            CGRectMake(0, 0, image1.size.width, image1.size.height),
            blendMode: .Overlay,
            alpha: ColorUtil.toRGBA(color: prop.startArcColor).a)
        image2.drawInRect(
            CGRectMake(0, 0, image2.size.width, image2.size.height),
            blendMode: .Overlay,
            alpha: ColorUtil.toRGBA(color: prop.endArcColor).a)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

import UIKit

public struct Property
{
    let arcLineCapStyle: CGLineCap = CGLineCap.Butt
    
    // Progress Size
    var progressSize: CGFloat = 44
    
    // Gradient Circular
    var arcLineWidth: CGFloat = 5.0
    var startArcColor: UIColor = UIColor.clearColor()
    var endArcColor: UIColor = UIColor.orangeColor()
    
    // Progress Rect
    var progressRect: CGRect
        {
        get {
            return CGRectMake(0, 0, progressSize - arcLineWidth * 2, progressSize - arcLineWidth * 2)
        }
    }
}

import UIKit

public class ColorUtil {
    
    public class func toUIColor(r r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    internal class func toRGBA(color color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
    }
    
    internal class func toNotOpacityColor(color color: UIColor) -> UIColor {
        
        if color == UIColor.clearColor() {
            return UIColor.whiteColor()
        } else {
            return UIColor(
                red: ColorUtil.toRGBA(color: color).r,
                green: ColorUtil.toRGBA(color: color).g,
                blue: ColorUtil.toRGBA(color: color).b,
                alpha: 1.0)
        }
    }
}

class ArcView : UIView {
    
    var prop: Property?
    var ratio: CGFloat = 1.0
    var color: UIColor = UIColor.blackColor()
    var lineWidth: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, lineWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.masksToBounds = true
        
        self.lineWidth = lineWidth
    }
    
    override func drawRect(rect: CGRect) {
        
        drawArc(rect)
    }
    
    private func drawArc(rect: CGRect) {
        
        guard let prop = prop else {
            return
        }
        
        let circularRect: CGRect = prop.progressRect
        
        let arcPoint: CGPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        let arcRadius: CGFloat = circularRect.width/2 + prop.arcLineWidth/2
        let arcStartAngle: CGFloat = -CGFloat(M_PI_2)
        let arcEndAngle: CGFloat = ratio * 2.0 * CGFloat(M_PI) - CGFloat(M_PI_2)
        
        let arc: UIBezierPath = UIBezierPath(arcCenter: arcPoint,
                                             radius: arcRadius,
                                             startAngle: arcStartAngle,
                                             endAngle: arcEndAngle,
                                             clockwise: true)
        
        color.setStroke()
        
        arc.lineWidth = lineWidth
        arc.lineCapStyle = prop.arcLineCapStyle
        arc.stroke()
    }
}

class GradientArcView : UIView {
    
    internal var prop: Property?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getGradientPointColor(ratio: CGFloat, startColor: UIColor, endColor: UIColor) -> UIColor {
        
        let sColor = ColorUtil.toRGBA(color: startColor)
        let eColor = ColorUtil.toRGBA(color: endColor)
        
        let r = (eColor.r - sColor.r) * ratio + sColor.r
        let g = (eColor.g - sColor.g) * ratio + sColor.g
        let b = (eColor.b - sColor.b) * ratio + sColor.b
        let a = (eColor.a - sColor.a) * ratio + sColor.a
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    override func drawRect(rect: CGRect) {
        
        guard let prop = prop else {
            return
        }
        
        let circularRect: CGRect = prop.progressRect
        var currentAngle: CGFloat = 0.0
        
        // workaround
        var limit: CGFloat = 1.0 // 32bit
        if sizeof(limit.dynamicType) == 8 {
            limit = 1.01 // 64bit
        }
        
        for var i: CGFloat = 0.0; i <= limit; i += 0.01
        {
            
            let arcPoint: CGPoint = CGPoint(x: rect.width/2, y: rect.height/2)
            let arcRadius: CGFloat = circularRect.width/2 + prop.arcLineWidth/2
            let arcStartAngle: CGFloat = -CGFloat(M_PI_2)
            let arcEndAngle: CGFloat = i * 2.0 * CGFloat(M_PI) - CGFloat(M_PI_2)
            
            if currentAngle == 0.0 {
                currentAngle = arcStartAngle
            } else {
                currentAngle = arcEndAngle - 0.1
            }
            
            let arc: UIBezierPath = UIBezierPath(arcCenter: arcPoint,
                                                 radius: arcRadius,
                                                 startAngle: currentAngle,
                                                 endAngle: arcEndAngle,
                                                 clockwise: true)
            
            let strokeColor: UIColor = getGradientPointColor(i, startColor: prop.startArcColor, endColor: prop.endArcColor)
            strokeColor.setStroke()
            
            arc.lineWidth = prop.arcLineWidth
            arc.lineCapStyle = prop.arcLineCapStyle
            arc.stroke()
        }
    }
}



import UIKit
protocol RatingControlDelegate
{
    func ratingSelected(ratingInt:Int)
}

class RatingControl: UIView
{
    // MARK: Properties
    var delegate:RatingControlDelegate?
    var rating = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var ratingButtons = [UIButton]()
    var ratingButtons3 = [UIButton]()
    var ratingButtons1 = [UIButton]()
    var spacing = 5
    var stars = 5
    
    var color:UIColor = UIColor.whiteColor()
        {
        didSet {
            for button in self.subviews
            {
                button.tintColor = color
            }
        }
    }
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        //star_red
        //star_green
        let filledStarImage = UIImage(named: "green_star_s")
        let emptyStarImage = UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate)
        
        for  _ in 0..<5
        {
            let button = UIButton()
            
            button.setImage(emptyStarImage, forState: .Normal)
            button.tintColor = UIColor.whiteColor()
            
            
            button.setImage(filledStarImage, forState: .Selected)
            button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * stars
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func ratingButtonTapped(button: UIButton)
    {
        rating = ratingButtons.indexOf(button)! + 1
        self.delegate?.ratingSelected(rating)
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates()
    {
        for (index, button) in ratingButtons.enumerate()
        {
            // If the index of a button is less than the rating, that button should be selected.
            
            if rating > 3 && rating<=5
            {
                let filledStarImage = UIImage(named: "green_star_s")
                button.setImage(filledStarImage, forState: .Selected)
                button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
                button.selected = index < rating
            }else if rating > 1 && rating<=3
            {
                let filledStarImage = UIImage(named: "orange_star_s")
                
                button.setImage(filledStarImage, forState: .Selected)
                button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
                button.selected = index < rating
                
            }else
            {
                let filledStarImage = UIImage(named: "red_star_s")
                
                button.setImage(filledStarImage, forState: .Selected)
                button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
                button.selected = index < rating
                
            }
        }
    }
}