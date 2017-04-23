//
//  UesrReviewTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class UesrReviewTableViewCell: UITableViewCell
{

    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var rateView: RatingControl!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        profileImageView.makeImageRounded()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
