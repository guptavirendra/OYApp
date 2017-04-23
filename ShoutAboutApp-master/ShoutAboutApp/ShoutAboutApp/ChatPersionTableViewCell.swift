//
//  ChatPersionTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 19/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

protocol ChatPersionTableViewCellProtocol {
    func buttonClicked(cell:ChatPersionTableViewCell, button:UIButton)
}

class ChatPersionTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileView:UIImageView!
    @IBOutlet weak var baseView:UIView!
    @IBOutlet weak var profileButton:UIButton!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var textsLabel:UILabel?
    @IBOutlet weak var unreadMessageLabel:UILabel!
    @IBOutlet weak var lastseenLable:UILabel?
    @IBOutlet weak var unreadMessageView:UIView!
    @IBOutlet weak var onlineView:UIView!
    @IBOutlet weak var timerView:UIImageView!
    var delegate:ChatPersionTableViewCellProtocol?
    

    override func awakeFromNib()
    {
        super.awakeFromNib()
        onlineView.makeImageRounded()
        unreadMessageView.makeImageRounded()
       // self.contentView.backgroundColor = bgColor
        baseView.setGraphicEffects()
        profileView.makeImageRoundedWithWidth(3.0, color: UIColor.grayColor())
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonClicked(button:UIButton)
    {
        self.delegate?.buttonClicked(self, button:button )
    }

}
