//
//  settingCell.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 17/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class settingCell: UITableViewCell
{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconView:UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
