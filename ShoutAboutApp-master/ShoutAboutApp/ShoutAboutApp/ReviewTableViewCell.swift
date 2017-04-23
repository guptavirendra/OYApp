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
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
