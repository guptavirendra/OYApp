//
//  SearchViewTableViewCell.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 17/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import SnapKit
import ChameleonFramework
import ReactiveCocoa
import Result

class SearchViewTableViewCell: UITableViewCell {
	var searchImageView: UIImageView!
	var searchTitle: UILabel!
	var searchSummary: UILabel!

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.searchImageView = UIImageView(frame: CGRect.zero)
		self.searchImageView!.backgroundColor = UIColor.white
		self.addSubview(self.searchImageView)
		self.searchImageView!.snp_makeConstraints { make in
			make.height.equalTo(self)
			make.width.equalTo(searchImageView!.snp_height)
			make.bottom.equalTo(self.snp_bottom)
			make.left.equalTo(self.snp_left)
		}
		
		self.searchTitle = UILabel(frame: CGRect.zero)
		self.searchTitle.adjustsFontSizeToFitWidth = true
		self.addSubview(self.searchTitle)
		self.searchTitle!.snp_makeConstraints { make in
			make.top.equalTo(self.snp_top).offset(10)
			make.left.equalTo(self.searchImageView!.snp_right).offset(10)
			make.right.equalTo(self.snp_right).offset(-10)
		}
		
		self.searchSummary = UILabel(frame: CGRect.zero)
		self.searchSummary.numberOfLines = 4
		self.searchSummary.adjustsFontSizeToFitWidth = true
		self.addSubview(self.searchSummary)
		self.searchSummary!.snp_makeConstraints { make in
			make.top.equalTo(self.searchTitle.snp_bottom)
			make.left.equalTo(self.searchTitle.snp_left)
			make.right.equalTo(self.searchTitle.snp_right)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func searchResult(_ result: YoutubeSearchResult) {
        let titleString: NSMutableAttributedString = NSMutableAttributedString(string:result.title)
        titleString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: NSMakeRange(0, result.title.characters.count))
        self.searchTitle?.attributedText = titleString
		
		let summaryString: NSMutableAttributedString = NSMutableAttributedString(string:result.desc)
		summaryString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize), range: NSMakeRange(0, result.desc.characters.count))
		summaryString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range: NSMakeRange(0, result.desc.characters.count))
		self.searchSummary?.attributedText = summaryString
		
		self.downloadMedia(result.imageUrl)
			.observeOn(UIScheduler())
			.start {
				[unowned self] event in
				switch event {
				case let .next(result):
					NSLog("GetImage success!")
					if (result.value != nil) {
						let (image, _) = result.value!
						self.searchImageView.image = image
					}
				case let .failed(error):
					NSLog("GetImage %@", error)
				default:
					break
				}
		}
	}
	
	fileprivate func downloadMedia(_ url: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
		return SignalProducer(values: [url])
			.observeOn(QueueScheduler())
			.flatMap(FlattenStrategy.merge, transform: {
				[unowned self] (key: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> in
				return STHttp.getImage(url)
			})
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
