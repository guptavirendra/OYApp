//
//  ChattingTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class ChattingTableViewCell: UITableViewCell
{
    @IBOutlet weak var  messageLabel:UILabel!
    @IBOutlet weak var  timeLabel:UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.contentView.backgroundColor = bgColor
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        
    }

}
