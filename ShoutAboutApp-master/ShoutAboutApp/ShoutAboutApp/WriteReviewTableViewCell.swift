//
//  WriteReviewTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 07/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class WriteReviewTableViewCell: UITableViewCell
{
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.borderColor = UIColor.blackColor().CGColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 2.0
        //self.contentView.backgroundColor = bgColor
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
