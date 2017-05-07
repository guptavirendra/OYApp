//
//  ReviewTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell
{
    @IBOutlet weak var ratingOutOfFive: UILabel!
    @IBOutlet weak var nameView: UIImageView!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var countLabel5: UILabel!
    @IBOutlet weak var countLabel4: UILabel!
    @IBOutlet weak var countLabel3: UILabel!
    
    @IBOutlet weak var countLabel2: UILabel!
    
    @IBOutlet weak var countLabel1: UILabel!
    
    
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    
    
    @IBOutlet weak var fiveConstraints:NSLayoutConstraint!
    @IBOutlet weak var fourConstraints:NSLayoutConstraint!
    @IBOutlet weak var threeConstraints:NSLayoutConstraint!
    @IBOutlet weak var twoConstraints:NSLayoutConstraint!
    @IBOutlet weak var oneConstraints:NSLayoutConstraint!
    @IBOutlet weak var graphbaseView5: UIView!
    @IBOutlet weak var graphbaseView4: UIView!
    @IBOutlet weak var graphbaseView3: UIView!
    @IBOutlet weak var graphbaseView2: UIView!
    @IBOutlet weak var graphbaseView1: UIView!
    
    
    @IBOutlet weak var progressView5:UIProgressView?
    @IBOutlet weak var progressView4:UIProgressView?
    @IBOutlet weak var progressView3:UIProgressView?
    @IBOutlet weak var progressView2:UIProgressView?
    @IBOutlet weak var progressView1:UIProgressView?
    
    @IBOutlet weak var reviewMessage:UILabel?
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
         view1.makeImageRounded()
         view2.makeImageRounded()
         view3.makeImageRounded()
         view4.makeImageRounded()
         view5.makeImageRounded()
         profileImageView.makeImageRounded()
         nameView.tintColor = UIColor.whiteColor()
         nameView.image = UIImage(named: "Name")?.imageWithRenderingMode(.AlwaysTemplate)
        
        
        progressView1!.transform = CGAffineTransformScale(progressView1!.transform, 1, 4)
        progressView1?.progressTintColor =  UIColor.redColor()//UIColor(red: 255, green: 12, blue: 20, alpha: 1.0)
        progressView1?.trackTintColor   = UIColor.whiteColor()
        
        progressView2!.transform = CGAffineTransformScale(progressView2!.transform, 1, 4)
        progressView2?.progressTintColor = /* UIColor.greenColor()*/UIColor(red: 109.0/255.0, green: 255.0/255.0, blue: 86.0/255.0, alpha: 1.0)
       progressView2?.trackTintColor   = UIColor.whiteColor()
        
        progressView3!.transform = CGAffineTransformScale(progressView3!.transform, 1, 4)
        
        progressView3?.progressTintColor =  /*UIColor.blueColor()*/UIColor(red: 84.0/255.0, green: 194/255.0, blue: 254/255.0, alpha: 1.0)
        progressView3?.trackTintColor   = UIColor.whiteColor()
        
        progressView4!.transform = CGAffineTransformScale(progressView4!.transform, 1, 4)
        
        progressView4?.progressTintColor = /*UIColor.flatPinkColor()*/UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 218.0/255.0, alpha: 1.0)
        progressView4?.trackTintColor   = UIColor.whiteColor()
        
        progressView5!.transform = CGAffineTransformScale(progressView5!.transform, 1, 4)
        
        progressView5?.progressTintColor = /*UIColor.purpleColor()*/UIColor(red: 255.0/255.0, green: 97.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        progressView5?.trackTintColor   = UIColor.whiteColor()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
