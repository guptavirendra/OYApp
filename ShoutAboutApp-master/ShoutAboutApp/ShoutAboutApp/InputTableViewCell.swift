//
//  InputTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//



protocol InputTableViewCellProtocol {
    func getTextsForCell(_ text:String, cell:InputTableViewCell)
}
import UIKit

class InputTableViewCell: UITableViewCell
{
    @IBOutlet weak var inputBaseView:UIView!
    @IBOutlet weak var inputImage:UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    var inputText:String = ""
    var delegate:InputTableViewCellProtocol?
 
    override func awakeFromNib()
    {
        super.awakeFromNib()
        inputTextField.addTarget(self, action:#selector(InputTableViewCell.edited), for:UIControlEvents.editingChanged)
        inputBaseView.makeBorder()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    func edited()
    {
        print("Edited \(inputTextField.text)")
        inputText = inputTextField.text!
        self.delegate?.getTextsForCell(inputText, cell: self)
        
    }
}
