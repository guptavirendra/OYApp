

import UIKit

class MoreCell: UITableViewCell {

    @IBOutlet fileprivate var label: UILabel!

    static let reuseIdentifier = "MoreCell"

    lazy fileprivate var textColour = {
        UIColor(red: 0.196, green: 0.3098, blue: 0.52, alpha: 1.0)
    }()


    override func awakeFromNib() {
        label.textColor = textColour
        label.text = NSLocalizedString("Load More Button", value: "Load More", comment: "String for Load More button")
    }

}
