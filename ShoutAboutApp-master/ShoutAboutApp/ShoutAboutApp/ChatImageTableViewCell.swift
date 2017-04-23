//
//  ChatImageTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 20/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class ChatImageTableViewCell: UITableViewCell
{

    @IBOutlet weak var imagesView:UIImageView!
    @IBOutlet weak var timeLabel:UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.backgroundColor = bgColor
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
