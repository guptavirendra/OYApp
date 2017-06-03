//
//  ClickTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

protocol ClickTableViewCellProtocol
{
    func buttonClicked(_ cell:ClickTableViewCell)
}

class ClickTableViewCell: UITableViewCell
{
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var widthConstraints:NSLayoutConstraint?
    var delegate:ClickTableViewCellProtocol?
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func buttonClicked(_ button:UIButton)
    {
        self.delegate?.buttonClicked(self)
    }

}

class FaceBookGoogleTableViewCell:ClickTableViewCell
{
    @IBOutlet weak var baseTitleView:UIView!
    @IBOutlet weak var button2: UIButton!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        baseTitleView.makeImageRounded()
        
    }
    @IBAction override func buttonClicked(_ button:UIButton)
    {
        self.delegate?.buttonClicked(self)
    }
    
    
}
