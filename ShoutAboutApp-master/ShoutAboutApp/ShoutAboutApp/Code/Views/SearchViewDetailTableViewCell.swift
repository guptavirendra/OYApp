//
//  SearchViewDetailTableViewCell.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 18/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveCocoa
import Result
import ChameleonFramework

class SearchViewDetailTableViewCell: UITableViewCell {
	var searchDetails: UILabel!
	var subscribeButton: UIButton!
	var unsubscribeButton: UIButton!
	var viewModel: SubscriptionViewModel?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.searchDetails = UILabel(frame: CGRect.zero)
		self.searchDetails.adjustsFontSizeToFitWidth = true
		self.addSubview(self.searchDetails)
		self.searchDetails!.snp_makeConstraints { make in
			make.bottom.equalTo(self.snp_bottom).offset(-10)
			make.right.equalTo(self.snp_right).offset(-10)
		}
		
		self.subscribeButton = UIButton(frame: CGRect.zero)
		self.addSubview(subscribeButton)
		subscribeButton.isEnabled = false
		subscribeButton.backgroundColor = UIColor.white
		subscribeButton.layer.cornerRadius = 5
		subscribeButton.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
		subscribeButton.setTitleColor(UIColor.white, for: UIControlState())
		subscribeButton.setTitle("Loading...", for: UIControlState.disabled)
		subscribeButton.setTitle("Subscribe", for: UIControlState())
		subscribeButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
		subscribeButton.snp_makeConstraints { (make) -> Void in
			make.width.equalTo(self).multipliedBy(0.6)
			make.height.equalTo(self).multipliedBy(0.30)
			make.centerX.equalTo(self)
			make.centerY.equalTo(self)
		}
		subscribeButton.addTarget(self, action: #selector(SearchViewDetailTableViewCell.subscribePressed(_:)), for: UIControlEvents.touchUpInside)
		
		self.unsubscribeButton = UIButton(frame: CGRect.zero)
		self.addSubview(unsubscribeButton)
		unsubscribeButton.isHidden = true
		unsubscribeButton.isEnabled = false
		unsubscribeButton.backgroundColor = FlatGreen()
		unsubscribeButton.layer.cornerRadius = 5
		unsubscribeButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
		unsubscribeButton.setTitleColor(UIColor.white, for: UIControlState())
		unsubscribeButton.setTitle("Unsubscribing...", for: UIControlState.disabled)
		unsubscribeButton.setTitle("Unsubscribe", for: UIControlState())
		unsubscribeButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
		unsubscribeButton.snp_makeConstraints { (make) -> Void in
			make.width.equalTo(self).multipliedBy(0.6)
			make.height.equalTo(self).multipliedBy(0.30)
			make.centerX.equalTo(self)
			make.centerY.equalTo(self)
		}
		unsubscribeButton.addTarget(self, action: "unsubscribePressed:", for: UIControlEvents.touchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	func searchDetails(_ result: YoutubeSearchResult, searchViewModel: SearchViewModel) {
		self.setSubscriberCount(result)
		self.viewModel = SubscriptionViewModel(searchResult: result, threadId: searchViewModel.currentThreadId, inConversationWith: searchViewModel.inConversationWith)
		self.setupBindings(searchViewModel)
		self.viewModel!.fetchDetails()
	}
	
	func subscribePressed(_ sender: UIButton) {
		self.viewModel?.subscribe()
		subscribeButton.setTitle("Subscribing...", for: UIControlState.disabled)
		subscribeButton.setTitleColor(UIColor.white, for: UIControlState.disabled)
		subscribeButton.backgroundColor = UIColor.flatGreen()
		subscribeButton.isEnabled = false
	}
	
	func unsubscribePressed(_ sender: UIButton) {
		self.viewModel?.unsubscribe()
		unsubscribeButton.isEnabled = false
	}
	
	fileprivate func setSubscriberCount(_ result: YoutubeSearchResult) {
		let subscribersCount = "\(result.subscriberCount) subscribers"
		let detailsString: NSMutableAttributedString = NSMutableAttributedString(string:subscribersCount)
		detailsString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range: NSMakeRange(0, subscribersCount.characters.count))
		detailsString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize), range: NSMakeRange(0, subscribersCount.characters.count))
		self.searchDetails?.attributedText = detailsString
	}
	
	fileprivate func setSubscribeButtonStatus(_ subscribedAlready: Bool) {
		subscribeButton.isEnabled = !subscribedAlready
		subscribeButton.isHidden = subscribedAlready
		if subscribeButton.isEnabled {
			let app = UIApplication.shared.delegate as! AppDelegate
			subscribeButton.backgroundColor = app.globalColor
		}
		
		unsubscribeButton.isEnabled = subscribedAlready
		unsubscribeButton.isHidden = !subscribedAlready
	}
	
	fileprivate func setupBindings(_ searchViewModel: SearchViewModel) {
		self.setupDetailsFetchedBindings()
		self.setupSubscribedFetchedBindings()
		self.setupSubscriptionStatusBindings(searchViewModel)
	}
	
	fileprivate func setupDetailsFetchedBindings() {
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.detailResult.producer
				.skip(1) //Ignore the initial nil value
				.observeOn(UIScheduler())
				.start {
					[unowned self] event in
					switch event {
					case let .next(searchResult):
						self.setSubscriberCount(searchResult!)
					default:
						break
					}
			}
		)
	}
	
	fileprivate func setupSubscribedFetchedBindings() {
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.alreadySubscribedResult.producer
				.skip(1) //Ignore the initial nil value
				.observeOn(UIScheduler())
				.start {
					[unowned self] event in
					switch event {
					case let .next(subscribedAlready):
						self.setSubscribeButtonStatus(subscribedAlready)
					default:
						break
					}
			}
		)
	}

	fileprivate func setupSubscriptionStatusBindings(_ searchViewModel: SearchViewModel) {
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.subscribeSucceeded.producer
				.skip(1) //Ignore the initial nil value
				.start {
					[unowned self] event in
					switch event {
					case let .next(msgToSend):
						self.setSubscribeButtonStatus(true)
						searchViewModel.subscribeSucceeded.value = msgToSend
					default:
						break
					}
			}
		)
		
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.subscribeFailed.producer
				.skip(1) //Ignore the initial nil value
				.start {
					[unowned self] event in
					switch event {
					case let .next(msgToShow):
						searchViewModel.subscribeFailed.value = msgToShow
					default:
						break
					}
			}
		)
		
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.unsubscribeSucceeded.producer
				.skip(1) //Ignore the initial nil value
				.start {
					[unowned self] event in
					switch event {
					case let .next(msgToSend):
						self.setSubscribeButtonStatus(false)
						searchViewModel.subscribeSucceeded.value = msgToSend
					default:
						break
					}
			}
		)
		
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.unsubscribeFailed.producer
				.skip(1) //Ignore the initial nil value
				.start {
					[unowned self] event in
					switch event {
					case let .next(msgToShow):
						searchViewModel.subscribeFailed.value = msgToShow
					default:
						break
					}
			}
		)
	}
}
