//
//  FeedsTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 15/01/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

// Mohit
protocol FeedsTableViewCellProtocol {
    
    func likebuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    func dislikebuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    func picbuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    func likeCountbuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    func dislikeCountbuttonClicked(_ cell:FeedsTableViewCell, button:UIButton)
    func screenMoveClicked(_ cell:FeedsTableViewCell, button: UIButton)
    
    
}

class FeedsTableViewCell: UITableViewCell
{
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var RUserImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var RdescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
   
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var likeButton:UIButton!
    @IBOutlet weak var dislikeButton:UIButton!
    @IBOutlet weak var likeCountButton: UIButton?
    @IBOutlet weak var dislikeCountButton: UIButton?
    @IBOutlet weak var picButton:UIButton!
    @IBOutlet weak var picButton1:UIButton!
    @IBOutlet weak var picButton2:UIButton!
    @IBOutlet weak var performedActionLabel:UILabel?
    
    var delegate:FeedsTableViewCellProtocol?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func likebuttonClicked(_ button:UIButton){
        
        self.delegate?.likebuttonClicked(self, button:button)
    }
    
    @IBAction func dislikebuttonClicked(_ button:UIButton){
        
        self.delegate?.dislikebuttonClicked(self, button:button)
    }
    
    @IBAction func picbuttonClicked(_ button:UIButton)
    {
        self.delegate?.picbuttonClicked(self, button:button)
        
    }

    
    @IBAction func likeCountbuttonClicked(_ button:UIButton){
        self.delegate?.likeCountbuttonClicked(self, button:button)
    }

    @IBAction func dislikeCountbuttonClicked(_ button:UIButton){
        self.delegate?.dislikeCountbuttonClicked(self, button:button)
    }
    
    
    @IBAction func screenMoveClicked(_ button: UIButton){
        self.delegate?.screenMoveClicked(self, button: button)
    }
    
}
