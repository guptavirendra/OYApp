//
//  RatingTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var baseView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.backgroundColor = bgColor
        profileImageView.makeImageRounded()
        
        //self.baseView.backgroundColor = bgColor
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
