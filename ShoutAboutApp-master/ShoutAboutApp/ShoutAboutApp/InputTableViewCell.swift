//
//  InputTableViewCell.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//



protocol InputTableViewCellProtocol {
    func getTextForCell(text:String, cell:InputTableViewCell)
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
        inputTextField.addTarget(self, action:#selector(InputTableViewCell.edited), forControlEvents:UIControlEvents.EditingChanged)
        inputBaseView.makeBorder()
        
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    func edited()
    {
        print("Edited \(inputTextField.text)")
        inputText = inputTextField.text!
        self.delegate?.getTextForCell(inputText, cell: self)
        
    }
}
