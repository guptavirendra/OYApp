//
//  EditProfileTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 13/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

protocol EditProfileTableViewCellProtocol
{
    func editButtonClickedForCell(_ cell:EditProfileTableViewCell)
    func getTextForCell(_ text:String, cell:EditProfileTableViewCell)
}

class EditProfileTableViewCell: UITableViewCell
{
    @IBOutlet weak var  titleLabel:UILabel!
    @IBOutlet weak var  dataTextField :UITextField!
    @IBOutlet weak var  editButton:UIButton!
    @IBOutlet weak var inputImage:UIImageView!
    
    var delegate:EditProfileTableViewCellProtocol?
 
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.editButton.isHidden = true
       // dataTextField.userInteractionEnabled = false
        dataTextField.addTarget(self, action:#selector(InputTableViewCell.edited), for:UIControlEvents.editingChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func editButtonClicked(_ button:UIButton)
    {
        self.delegate?.editButtonClickedForCell(self)
    }
    
    func edited()
    {
        
       let inputText = dataTextField.text!
        self.delegate?.getTextForCell(inputText, cell: self)
        
    }

}
