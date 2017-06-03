//
//  AlertTableViewCell.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 06/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit


// Mohit
protocol AlertTableViewCellProtocol {
    
    
    func picbuttonClicked(_ cell:AlertTableViewCell, button:UIButton)
    
    
}



class AlertTableViewCell: UITableViewCell {
    
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var picButton:UIButton!
    var delegate:AlertTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func picbuttonClicked(_ button:UIButton){
        
        self.picButton?.tag = button.tag
        self.delegate?.picbuttonClicked(self, button:button)
        
    }

}
