//
//  CropperViewController.swift
//  AKImageCropperDemo
//  GitHub: https://github.com/artemkrachulov/AKImageCropper
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

protocol CropperViewControllerDelegate
{
    func croppedImage(_ image:UIImage, vc:UIViewController)
   // func cancelCropping()
}

class CropperViewController: UIViewController
{
    
    var delegate:CropperViewControllerDelegate?
    
    // MARK: - Components
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    var _image: UIImage!
    
    //@IBOutlet weak var showHideBtn: UIButton!
    @IBOutlet weak var cropBtn: UIButton!
    
    @IBOutlet weak var cropView: AKImageCropperView!
    
    var cropViewProgrammatically: AKImageCropperView!
    
    // MARK: - Life Cycle
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        cropView.image = _image
        cropView.delegate = self
        showHideFrameBtn(nil)
        self.navigationController?.navigationBar.isHidden = true
        
        
        // Uncomment this line to detect all Scrollview events
        // cropView.scrollView.delegate = self
        
        /**
        
            Initialize Crop View programmatically
        
        */
        
        /*
        cropViewProgrammatically = AKImageCropperView(image: _image, showOverlayView: false)
        cropViewProgrammatically.delegate = self
        cropViewProgrammatically.scrollView.delegate = self
        cropViewProgrammatically.setTranslatesAutoresizingMaskIntoConstraints(false)

        view.addSubview(cropViewProgrammatically)

        let right = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -20)
        let left = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 20)
        let top = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
        let bottom = NSLayoutConstraint(item: cropViewProgrammatically, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: showHideBtn, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)

        view.addConstraint(right)
        view.addConstraint(left)
        view.addConstraint(top)
        view.addConstraint(bottom)
        
        var leftBtn = NSLayoutConstraint(item: cropBtn, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cropViewProgrammatically, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
    
        view.addConstraint(leftBtn)
     
        var rightBtn = NSLayoutConstraint(item: showHideBtn, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: cropViewProgrammatically, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        
        view.addConstraint(rightBtn)
        */
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /**
        
            If you use programmatically initalization
            Switch 'cropView' to 'cropViewProgrammatically'
        
            Example: cropViewProgrammatically.refresh()
        
        */
        
        cropView.refresh()
    }
    
    // MARK: - Button Actions
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _    
    
    @IBAction func showHideFrameBtn(_ sender: UIButton?) {
        
        /**
        
            If you use programmatically initalization
            Switch 'cropView' to 'cropViewProgrammatically'
        
            Example: if cropViewProgrammatically.overlayViewIsActive {
                        ...
        
        */
        
        
        if cropView.overlayViewIsActive {
            
           // showHideBtn.setTitle("Show Crop Frame", forState: UIControlState.Normal)
            
            cropView.dismissOverlayViewAnimated(true) { () -> Void in
                
                print("Frame disabled")
            }
        } else {
            
           // showHideBtn.setTitle("Hide Crop Frame", forState: UIControlState.Normal)
            
            cropView.showOverlayViewAnimated(true, withCropFrame: nil, completion: { () -> Void in
                
                print("Frame active")
            })
        }
        cropView.setCropRect(CGRect(x: (cropView.imageView.frame.size.width - 150)/2,y: (cropView.imageView.frame.size.height - 150)/2, width: 150, height: 150))
        cropView.center =  (cropView.superview?.center)!
    }
    
    @IBAction func cropTestBtn(_ sender: UIBarButtonItem) {
        
        cropView.setCropRect(CGRect(x: (self.view.frame.origin.x+150)/2, y: (self.view.frame.origin.x+150)/2, width: 150, height: 150))
    }
    
    // MARK: - Navigation
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if let vc = segue.destination as? ImageViewController {
            
            vc._image = cropView.croppedImage()
        }
    }
    
    @IBAction func saveButtonClicked(_ sender:UIButton)
    {
        self.delegate?.croppedImage(cropView.croppedImage(),vc:self.parent!)
    }
    
    @IBAction func cancelButtonClicked(_ sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
        //self.delegate?.cancelCropping()
    }
}




// MARK: - AKImageCropperDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension CropperViewController: AKImageCropperViewDelegate
{
    
    func cropRectChanged(_ rect: CGRect) {
        
        print("New crop rectangle: \(rect)")
    }
}

// MARK: - UIScrollViewDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

// Uncomment this block if cropView.scrollView.delegate = self is set


extension CropperViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return cropView.imageView
    }
}
