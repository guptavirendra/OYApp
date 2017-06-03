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
        self.navigationController?.isNavigationBarHidden = true
        mobileNumberTextField.addTarget(self, action:#selector(ViewController.edited), for:UIControlEvents.editingChanged)
        submitButton.isUserInteractionEnabled = false
        submitButton.alpha = 0.5
        textFieldBaseView.makeBorder()
        //self.view.backgroundColor = bgColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submitButtonClicked(_ sender: UIButton)
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
                    if deserializedResponse.object(forKey: message) != nil
                    {
                        let messageString = deserializedResponse.object(forKey: message) as? String
                        if messageString == otpMessage
                        {
                            DispatchQueue.main.async(execute: {
                                    self.view.removeSpinner()
                                let otpViewController = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
                                otpViewController?.mobileNumberString = self.mobileNumberString
                                self.present(otpViewController!, animated: true, completion: nil)
                                
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
                    DispatchQueue.main.async(execute: {
                            self.view.removeSpinner()
                    })
                    
            })
        }
    
        
    }

}


extension ViewController:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var text:NSString =  textField.text! as NSString 
        text =  text.replacingCharacters(in: range, with: string) as NSString
        
        
        if text.length == 10
        {
            submitButton.isUserInteractionEnabled = true
            submitButton.alpha = 1.0
        }else
        {
            submitButton.isUserInteractionEnabled = false
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
        print("Edited \(String(describing: mobileNumberTextField.text))")
        mobileNumberString = mobileNumberTextField.text!
        if mobileNumberString.characters.count == 10
        {
            submitButton.isUserInteractionEnabled = true
            submitButton.alpha = 1.0
        }else
        {
            submitButton.isUserInteractionEnabled = false
            submitButton.alpha = 0.5
        }

    }
}



extension UIViewController
{
    /* Displays alert message
     */
    func displayAlertMessage(_ userMessage: String)
    {
        
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func displayAlert(_ userMessage: String, handler: ((UIAlertAction) -> Void)?)
    {
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: handler)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}


import Foundation
import UIKit


public extension UIView
{
    
    func setGraphicEffects()
    {
        self.layer.shadowColor   = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius  = 3.0
        self.layer.shadowOffset  = CGSize(width: 1.0, height: 1.0)
        self.layer.masksToBounds = false
        
    }
    public func showSpinner()
    {
        self.showSpinner(true, userInteractionEnabled: false)
    }
    
    public func showSpinnerWithUserInteractionEnabled(_ userInteractionEnabled: Bool, dimBackground: Bool)
    {
        self.showSpinnerInView(self, spinnerType:"", dimBackgroundEnabled: dimBackground, userInteractionEnabled: userInteractionEnabled)
    }
    
    public func showSpinner(_ dimBackground: Bool, userInteractionEnabled: Bool)
    {
        
        let window = UIApplication.shared.keyWindow
        
        self.showSpinnerInView(window!, spinnerType: "", dimBackgroundEnabled: dimBackground, userInteractionEnabled: userInteractionEnabled)
        
        
    }
    
    //Add ProgressView
    public func showSpinnerInView(_ view:UIView, spinnerType:String, dimBackgroundEnabled: Bool, userInteractionEnabled: Bool)
    {
        self.removeSpinner()
        DispatchQueue.main.async(execute: { //() -> Void in
            
            let viewSize: CGFloat = 44
            let imageSize: CGFloat = 26
            
            // Progress View Background
            let dimBackground = UIView()
            dimBackground.tag = 5001
            dimBackground.frame = view.frame
            if userInteractionEnabled
            {
                dimBackground.isUserInteractionEnabled = false
            }
            else
            {
                dimBackground.isUserInteractionEnabled = true
            }
            if dimBackgroundEnabled
            {
                dimBackground.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
            else
            {
                dimBackground.backgroundColor = UIColor.clear
            }
            dimBackground.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dimBackground)
            
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint.init(item: dimBackground, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
            
            // Progress View Background
            let progressBackground = UIView()
            progressBackground.tag = 5002
            progressBackground.frame = CGRect(x: 0, y: 0, width: viewSize, height: viewSize)
            progressBackground.backgroundColor = UIColor.clear
            progressBackground.translatesAutoresizingMaskIntoConstraints = false
            dimBackground.addSubview(progressBackground)
            
            progressBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44))
            progressBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44))
            dimBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: dimBackground, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
            dimBackground.addConstraint(NSLayoutConstraint.init(item: progressBackground, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: dimBackground, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
            
            // Logo Image
            let logoImage:UIImageView = UIImageView()
            logoImage.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
            logoImage.center = progressBackground.center
            logoImage.backgroundColor = UIColor.clear
            //logoImage.image = UIImage.commonImageNamed("LogoImage.png")
            progressBackground.addSubview(logoImage)
            
            // Rotate Animation
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.duration = 2.0
            animation.repeatCount = HUGE
            animation.fromValue = NSNumber(value: 0.0 as Float)
            animation.toValue   = NSNumber(value: 2 * Float(M_PI) as Float)
            
            // Gradient Circular
            let gradientView: UIView = GradientArcWithClearColorView().draw(progressBackground.frame)
            progressBackground.addSubview(gradientView)
            gradientView.layer.add(animation, forKey: "rotate")
        });
    }
    
    //Remove ProgressView
    public func removeSpinner()
    {
        DispatchQueue.main.async(execute: { //() -> Void in
            
            //if let app = UIApplication.sharedApplication().delegate as? AppDelegate, let window = app.window
            //{
            let window = UIApplication.shared.keyWindow
            
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
    
    internal func draw(_ rect: CGRect) -> UIImageView {
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
        startGradientMaskProp.startArcColor = UIColor.black
        startGradientMaskProp.endArcColor = UIColor.white
        startGradientMaskProp.progressSize += 10.0
        startGradientMaskProp.arcLineWidth += 20.0
        
        // EndGradientMask
        endGradientMaskProp.startArcColor = UIColor.white
        endGradientMaskProp.endArcColor = UIColor.black
        endGradientMaskProp.progressSize += 10.0
        endGradientMaskProp.arcLineWidth += 20.0
        
        // SolidMask
        solidMaskProp.startArcColor = UIColor.black
        solidMaskProp.endArcColor   = UIColor.black
        
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    internal func mask(_ image: UIImage, maskImage: UIImage) -> UIImage {
        
        let maskRef: CGImage = maskImage.cgImage!
        let mask: CGImage = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: maskRef.dataProvider!,
            decode: nil,
            shouldInterpolate: false)!
        
        let maskedImageRef: CGImage = image.cgImage!.masking(mask)!
        let scale = UIScreen.main.scale
        let maskedImage: UIImage = UIImage.init(cgImage: maskedImageRef, scale: scale, orientation: .up)
        
        return maskedImage
    }
    
    internal func viewToUIImage(_ view: UIView) -> UIImage? {
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    internal func composite(image1: UIImage, image2: UIImage, prop: Property) -> UIImage {
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image1.size, false, scale)
        image1.draw(
            in: CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height),
            blendMode: .overlay,
            alpha: ColorUtil.toRGBA(color: prop.startArcColor).a)
        image2.draw(
            in: CGRect(x: 0, y: 0, width: image2.size.width, height: image2.size.height),
            blendMode: .overlay,
            alpha: ColorUtil.toRGBA(color: prop.endArcColor).a)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

import UIKit

public struct Property
{
    let arcLineCapStyle: CGLineCap = CGLineCap.butt
    
    // Progress Size
    var progressSize: CGFloat = 44
    
    // Gradient Circular
    var arcLineWidth: CGFloat = 5.0
    var startArcColor: UIColor = UIColor.clear
    var endArcColor: UIColor = UIColor.orange
    
    // Progress Rect
    var progressRect: CGRect
        {
        get {
            return CGRect(x: 0, y: 0, width: progressSize - arcLineWidth * 2, height: progressSize - arcLineWidth * 2)
        }
    }
}

import UIKit

open class ColorUtil {
    
    open class func toUIColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    internal class func toRGBA(color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
    }
    
    internal class func toNotOpacityColor(color: UIColor) -> UIColor {
        
        if color == UIColor.clear {
            return UIColor.white
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
    var color: UIColor = UIColor.black
    var lineWidth: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, lineWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
        
        self.lineWidth = lineWidth
    }
    
    override func draw(_ rect: CGRect) {
        
        drawArc(rect)
    }
    
    fileprivate func drawArc(_ rect: CGRect) {
        
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
        
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func getGradientPointColor(_ ratio: CGFloat, startColor: UIColor, endColor: UIColor) -> UIColor {
        
        let sColor = ColorUtil.toRGBA(color: startColor)
        let eColor = ColorUtil.toRGBA(color: endColor)
        
        let r = (eColor.r - sColor.r) * ratio + sColor.r
        let g = (eColor.g - sColor.g) * ratio + sColor.g
        let b = (eColor.b - sColor.b) * ratio + sColor.b
        let a = (eColor.a - sColor.a) * ratio + sColor.a
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let prop = prop else {
            return
        }
        
        let circularRect: CGRect = prop.progressRect
        var currentAngle: CGFloat = 0.0
        
        // workaround
        var limit: CGFloat = 1.0 // 32bit
        if MemoryLayout<CGFloat>.size == 8 {
            limit = 1.01 // 64bit
        }
        for i in stride(from: 0.0, to: 1.01, by: 0.01)
        {
       
            
            let arcPoint: CGPoint = CGPoint(x: rect.width/2, y: rect.height/2)
            let arcRadius: CGFloat = circularRect.width/2 + prop.arcLineWidth/2
            let arcStartAngle: CGFloat = -CGFloat(M_PI_2)
            let arcEndAngle: CGFloat = CGFloat(i) * 2.0 * CGFloat(M_PI) - CGFloat(M_PI_2)
            
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
            
            let strokeColor: UIColor = getGradientPointColor(CGFloat(i), startColor: prop.startArcColor, endColor: prop.endArcColor)
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
    func ratingSelected(_ ratingInt:Int)
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
    
    var color:UIColor = UIColor.white
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
        let emptyStarImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        
        for  _ in 0..<5
        {
            let button = UIButton()
            
            button.setImage(emptyStarImage, for: UIControlState())
            button.tintColor = UIColor.white
            
            
            button.setImage(filledStarImage, for: .selected)
            button.setImage(filledStarImage, for: [.highlighted, .selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), for: .touchDown)
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override var intrinsicContentSize : CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * stars
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func ratingButtonTapped(_ button: UIButton)
    {
        rating = ratingButtons.index(of: button)! + 1
        self.delegate?.ratingSelected(rating)
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates()
    {
        for (index, button) in ratingButtons.enumerated()
        {
            // If the index of a button is less than the rating, that button should be selected.
            
            if rating > 3 && rating<=5
            {
                let filledStarImage = UIImage(named: "green_star_s")
                button.setImage(filledStarImage, for: .selected)
                button.setImage(filledStarImage, for: [.highlighted, .selected])
                button.isSelected = index < rating
            }else if rating > 1 && rating<=3
            {
                let filledStarImage = UIImage(named: "orange_star_s")
                
                button.setImage(filledStarImage, for: .selected)
                button.setImage(filledStarImage, for: [.highlighted, .selected])
                button.isSelected = index < rating
                
            }else
            {
                let filledStarImage = UIImage(named: "red_star_s")
                
                button.setImage(filledStarImage, for: .selected)
                button.setImage(filledStarImage, for: [.highlighted, .selected])
                button.isSelected = index < rating
                
            }
        }
    }
}
