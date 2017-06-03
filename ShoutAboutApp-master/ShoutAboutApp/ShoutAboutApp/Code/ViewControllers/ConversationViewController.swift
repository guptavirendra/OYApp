//
//  ConversationViewController.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 24/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa
import JSQMessagesViewController
import MobileCoreServices
import WebKit
import TSMessages
import SwiftyJSON
import SnapKit
import NYTPhotoViewer
import ChameleonFramework

class ConversationViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate { //UIScrollViewDelegate {
	fileprivate let outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.red /*(UIApplication.sharedApplication().delegate as! AppDelegate).selfColor!.lightenByPercentage(0.07)*/)
	fileprivate let outgoingTaillessBubbleImageView = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.red/*(UIApplication.sharedApplication().delegate as! AppDelegate).selfColor!.lightenByPercentage(0.145)*/)
	fileprivate let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.red/*(UIApplication.sharedApplication().delegate as! AppDelegate).globalColor?.lightenByPercentage(0.07)*/)
	fileprivate let incomingTaillessBubbleImageView = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.red/*(UIApplication.sharedApplication().delegate as! AppDelegate).globalColor!.lightenByPercentage(0.145)*/)

	fileprivate var senderImageUrl: String!
	
	fileprivate unowned var xmppClient: STXMPPClient
	fileprivate let chattingWith: STContact
	let viewModel: ConversationViewModel
	fileprivate let searchViewModel: SearchViewModel
	fileprivate var prevMessagesLen = 0
	fileprivate let headerCellIdentifier = "MoreMessages"
	fileprivate var showLoadingMoreIndicator = MutableProperty<Bool>(false)
	fileprivate var showingLoadingMoreIndicator = false
	fileprivate var keyboardShown = MutableProperty<Bool>(false)
	
	var gameData: STGameData?
	var gameView: WebGameView?
	
	fileprivate var ytSearchView: UITableView?
	
	init(chattingWith: STContact, xmpp: STXMPPClient) {
		self.xmppClient = xmpp
		self.chattingWith = chattingWith
		self.viewModel = ConversationViewModel(xmpp: self.xmppClient, chattingWith: self.chattingWith)
        self.searchViewModel = SearchViewModel(threadId: self.viewModel.currentThread, inConversationWith: self.chattingWith)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		self.senderId =  User.senderId
		self.senderDisplayName = self.chattingWith.username//User.username
		super.viewDidLoad()
		self.inputToolbar!.contentView!.leftBarButtonItem = JSQMessagesToolbarButtonFactory.defaultAccessoryButtonItem()
		self.inputToolbar!.contentView?.backgroundColor = UIColor.white
		self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero //Don't show own avatar
		self.automaticallyScrollsToMostRecentMessage = true
		setupBindings()
		self.collectionView!.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellIdentifier)
		self.title = chattingWith.displayName
		
		self.collectionView?.backgroundColor = (UIApplication.shared.delegate as! AppDelegate).backgroundColor!
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		collectionView!.collectionViewLayout.springinessEnabled = false
	}
	
	fileprivate func setupBindings() {
		self.setupMessageBindings()
		self.setupChatStateBindings()
		self.setupKeyboardBindings()
		self.setupSearchViewBindings()
	}
	
	fileprivate func setupMessageBindings() {
		self.showLoadingMoreIndicator <~ self.viewModel.loadingMoreContent
		self.viewModel.disposer.addDisposable(
			self.showLoadingMoreIndicator.producer
				.start {
					[unowned self] event in
					switch event {
					case let .next(shouldShow):
						if shouldShow == false && self.showingLoadingMoreIndicator == true {
							//Get rid of the current activity spinner
							self.showingLoadingMoreIndicator = false
							self.collectionView!.reloadData()
						}
					default:
						break
					}
			}
		)
		
		//Monitor messages appearing from network after the initial db load
		self.viewModel.disposer.addDisposable(
			self.viewModel.messages.producer
				.start {
					[unowned self] event in
					switch event {
					case let .next(messages):
						if self.viewModel.messagesLoadFromDb { //We don't animate messages coming from db load
							self.collectionView!.reloadData()
							
							//Test https://github.com/jessesquires/JSQMessagesViewController/pull/976/files
							//same as http://stackoverflow.com/questions/25548257/uicollectionview-insert-cells-above-maintaining-position-like-messages-app/25579438#25579438
							//THIS MIGHT BE BEST! TEST THIS FIRST!
							//http://stackoverflow.com/a/32691888
							
							//When loading new messages from DB due to loadMore gesture, scroll the position to the new messages that were loaded
							let howManyNewMessages = self.viewModel.messages.value.count - self.prevMessagesLen
							if self.showLoadingMoreIndicator.value == true && howManyNewMessages > 0 && self.viewModel.messages.value.count > howManyNewMessages {
								self.collectionView!.scrollToItem(at: IndexPath(item: howManyNewMessages - 1, section: 0), at: .top, animated: false)
							}
							self.showLoadingMoreIndicator.value = false
							
						} else {
							self.newMessageAdded(messages.last!)
						}
						self.prevMessagesLen = self.viewModel.messages.value.count
                        
                        if self.viewModel.messages.value.count > 1
                        {
						let latestMessage = self.viewModel.messages.value[self.viewModel.messages.value.count - 1]
						//Message has been loaded to view so it has been marked as viewed
						LatestSeenStore.setLatestSeenInThread(latestMessage.date, msgId: latestMessage.id, forThread: self.viewModel.currentThread)
                        }
					default:
						break
					}
			}
		)
		
		//Reload single messages
		self.viewModel.disposer.addDisposable(
			self.viewModel.reloadMesssage.producer
				.start {
					[unowned self] event in
					switch event {
					case let .next(index):
						if index != nil {
							//let path = NSIndexPath(forItem: index!, inSection: 0)
							//self.collectionView!.reloadItemsAtIndexPaths([path])
							
							//We do not use reloadItemsAtIndexPaths because of assertion failures in UICollectionView
							//if reloadData and reloadItemsAtIndexPaths are called in quick succession
							//(Invalid update: invalid number of items in section 0.  The number of items contained in an existing section after the update (30)
							//must be equal to the number of items contained in that section before the update (15))
							//This may happen when you load new messages by scrolling up and at the same time new image is loaded in
							//-> reloadData starts -> reloadMessage is called reloadItemsAtIndexPaths starts -> reloadData completes -> reloadItemsAtIndexPaths completes
							self.collectionView!.reloadData()
						}
					default:
						break
					}
			}
		)
	}
	
	fileprivate func setupChatStateBindings() {
		self.viewModel.disposer.addDisposable(
			self.viewModel.typing <~ self.inputToolbar!.contentView!.textView!.rac_textSignal().toSignalProducer()
				.discardError()
				.map {
					[unowned self] text in
					return text as! String
			}
		)
		//Note that the typing observation above breaks the KVO in JSQMessagesInputToolbar, hence we need to enable the button here
		self.viewModel.disposer.addDisposable(
			self.viewModel.typing.producer
				.map {
					[unowned self] (value: String) in
					return value.trim()
				}
				.filter {
					[unowned self] (value: String) in
					//Related to the /command syntax. Don't enable 'Send' button if this is a slash command.
					return value.characters.first == nil ||
						(value.characters.first != nil && value.characters.first !=  "/")
				}
				.map {
					[unowned self] (value: String) in
					return value.characters.count > 0
				}
				.start {
					[unowned self] event in
					switch event {
					case let .next(enabled):
						self.inputToolbar!.contentView!.rightBarButtonItem!.isEnabled = enabled
					default:
						break
					}
			}
		)
		
		//Should be display typingIndicator
		self.viewModel.disposer.addDisposable(
			self.viewModel.shouldDisplayChatStateComposingNotif.producer
				.start {
					[unowned self] event in
					switch event {
					case let .next(displayed):
						self.showTypingIndicator = displayed
						if (self.showTypingIndicator) {
							let scrollViewHeight = self.collectionView!.frame.size.height
							let scrollContentSizeHeight = self.collectionView!.contentSize.height
							let scrollOffset = self.collectionView!.contentOffset.y
							let maxDistanceFromBottom: CGFloat = 100.0
							let nearBottom = scrollOffset + scrollViewHeight + maxDistanceFromBottom >= scrollContentSizeHeight + statusBarHeight()
							if nearBottom {
								self.scrollToBottom(animated: true)
							}
						}
					default:
						break
					}
			}
		)
	}
	
	fileprivate func setupKeyboardBindings() {
		self.keyboardShown <~ self.viewModel.keyboardShown
		self.viewModel.disposer.addDisposable(
			self.keyboardShown.producer
				.start {
					[unowned self] event in
					switch event {
					case let .next(shown):
						if shown && self.gameView != nil {
							self.gameView!.moveToHighPoint(true)
						} else if !shown && self.gameView != nil {
							self.gameView!.moveToLowPoint(true)
						}
					default:
						break
					}
			}
		)
	}
	
	fileprivate func setupSearchViewBindings() {
		self.searchViewModel.disposer.addDisposable(
			self.searchViewModel.typing <~ self.inputToolbar!.contentView!.textView!.rac_textSignal().toSignalProducer()
				.discardError()
				.map {
					[unowned self] text in
					return text as! String
				}
				.map {
					[unowned self] (value: String) in
					return value.trim()
				}
		)

		self.searchViewModel.disposer.addDisposable(
			self.searchViewModel.typing.producer
			.map {
				[unowned self] (value: String) in
				return value.characters.first != nil && value.characters.first ==  "/" //Enabled or not
			}
			.start {
				[unowned self] event in
				switch event {
				case let .next(enabled):
					if enabled {
						if self.ytSearchView == nil {
							let frame = self.collectionView!.frame
							self.ytSearchView = YoutubeSearchView(frame: frame, viewModel: self.searchViewModel)
							self.view.addSubview(self.ytSearchView!)
							self.ytSearchView!.snp_makeConstraints { (make) -> Void in
								make.height.equalTo(self.collectionView!).multipliedBy(0.4)
								make.width.equalTo(self.collectionView!)
								make.bottom.equalTo(self.inputToolbar!.snp_top)
								make.centerX.equalTo(self.collectionView!)
							}
							
						}
					} else {
						self.removeSearchView()
					}
				default:
					break
				}
			}
		)
		
		self.searchViewModel.disposer.addDisposable(
			self.searchViewModel.subscribeSucceeded.producer
				.skip(1) //Skip the first nil value
				.observeOn(UIScheduler())
				.start {
					[unowned self] event in
					switch event {
					case let .next(msgToSend):
						self.removeSearchView()
						self.sendMessage(msgToSend)
					default:
						break
					}
			}
		)
		
		self.searchViewModel.disposer.addDisposable(
			self.searchViewModel.subscribeFailed.producer
				.skip(1) //Skip the first nil value
				.observeOn(UIScheduler())
				.start {
					[unowned self] event in
					switch event {
					case let .next(msgToShow):
						self.removeSearchView()
						TSMessage.showNotification(withTitle: msgToShow, type: TSMessageNotificationType.error)
					default:
						break
					}
			}
		)
	}

	fileprivate func removeSearchView() {
		if self.ytSearchView != nil {
			self.ytSearchView?.removeFromSuperview()
			self.ytSearchView = nil
			self.inputToolbar!.contentView!.textView!.text = ""
		}
	}
	
	//Message has been added to viewcontroller. May be mine or someone elses
	func newMessageAdded(_ message: STMessage) {
		JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
		self.finishReceivingMessage(animated: true)
		if message.senderId != User.senderId {
			self.messageReceived(message)
		}
	}
	
	//A new message received from network (Not from DB)
	func messageReceived(_ message: STMessage) {
		//Realtime multiplayer support
		if message.isGameMediaMessage {
			let gameData: JSON = message.attachment!.json
			self.gameView?.newGameMessageReceived(gameData)
		}
	}
	
	// ACTIONS
	
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
		JSQSystemSoundPlayer.jsq_playMessageSentSound()
		sendMessage(text)
		
		self.finishSendingMessage(animated: true)
	}
	
	override func didPressAccessoryButton(_ sender: UIButton!) {
		self.presentPhotoAction()
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
		return self.viewModel.messages.value[indexPath.item]
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
		let message = self.viewModel.messages.value[indexPath.item]
		if message.senderId != User.senderId && self.shouldPresentAvatar(indexPath) {
			let avatarId = "small-\(message.senderId)"
			if AvatarUtils.avatars[avatarId] == nil {
				AvatarUtils.setupAvatarImage(avatarId, displayName: message.senderDisplayName, fontSize: UIFont.smallSystemFontSize)
			}
		
			return AvatarUtils.avatars[avatarId]
		}
		
		return nil
	}
	
	fileprivate func shouldPresentAvatar(_ indexPath: IndexPath) -> Bool {
		if indexPath.row + 1 < self.viewModel.messages.value.count {
			let message = self.viewModel.messages.value[indexPath.item]
			let nextMessage = self.viewModel.messages.value[indexPath.row + 1]
			if nextMessage.senderId != message.senderId {
				return true //We show avatar because the next message isn't from us
			} else if self.shouldPresentTimestamp(indexPath.row + 1) {
				return true //We show avatar because even thought the next message was from us, there is a time gap between these messages meaning that a new timestamp has been generated
			}
			
			return false //This is a message from same person within a one timestamp window
		}
			
		return true //This is a last message in conversation
	}
	
	//Timestamps
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
		if self.shouldPresentTimestamp(indexPath.row) {
			return kJSQMessagesCollectionViewCellLabelHeightDefault
		}
		
		return 0.0
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
		if shouldPresentTimestamp(indexPath.row) {
			let message = self.viewModel.messages.value[indexPath.row]
			return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
		}
		
		return nil
	}
	
	fileprivate func shouldPresentTimestamp(_ indexPathRow: Int) -> Bool {
		if indexPathRow - 1 >= 0 {
			let message = self.viewModel.messages.value[indexPathRow]
			let prevMessage = self.viewModel.messages.value[indexPathRow - 1]
			let deltaSeconds = message.date.timeIntervalSince(prevMessage.date)
			//If a message has been within 5 minutes of prev message, we don't give it a new timestamp
			if deltaSeconds < (5*60) {
				return false
			}
		}
		
		return true
	}
	
	//End timestamps
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message = self.viewModel.messages.value[indexPath.row]
		if (message.senderId == User.senderId) {
			if self.shouldPresentAvatar(indexPath) {
				return self.outgoingBubbleImageView
			} else {
				return self.outgoingTaillessBubbleImageView
			}
		} else {
			if self.shouldPresentAvatar(indexPath) {
				return self.incomingBubbleImageView
			} else {
				return self.incomingTaillessBubbleImageView
			}
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.viewModel.messages.value.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
		let message = self.viewModel.messages.value[indexPath.item]
		
		if cell.textView != nil {
			if message.senderId == senderId {
				cell.textView!.textColor = (UIApplication.shared.delegate as! AppDelegate).darkColor!
			} else {
				cell.textView!.textColor = UIColor.white
			}
			
			let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView!.textColor!, NSUnderlineStyleAttributeName: 1]
			cell.textView!.linkTextAttributes = attributes
		}
        
        //Workaround to image squashing bug: https://github.com/jessesquires/JSQMessagesViewController/issues/740
        //TODO NOTE! This causes sender avatar to turn GREY (selected)! This happens only with "initials" type avatar because JSQMessageAvatarImageFactory
        //sets the highlighed image as grey
        if message.isPhotoMediaMessage {
            cell.isHighlighted = true
            cell.isSelected = true
        }
        
        return cell
    }
	
	
	// View  usernames above bubbles
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
		/*
		Testing not having display names in chat for cleanliness
		let message = self.viewModel.messages.value[indexPath.item];
		
		// Sent by me, skip
		if message.senderId == senderId {
			return nil;
		}
		
		// Same as previous sender, skip
		if indexPath.item > 0 {
			let previousMessage = self.viewModel.messages.value[indexPath.item - 1];
			if previousMessage.senderId == message.senderId {
				return nil;
			}
		}
		
		return NSAttributedString(string:message.senderDisplayName)
		*/
		
		return nil
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
		let message = self.viewModel.messages.value[indexPath.item]
		
		// Sent by me, skip
		if message.senderId == senderId {
			return CGFloat(0.0);
		}
		
		// Same as previous sender, skip
		if indexPath.item > 0 {
			let previousMessage = self.viewModel.messages.value[indexPath.item - 1];
			if previousMessage.senderId == message.senderId {
				return CGFloat(0.0);
			}
		}
		
		return kJSQMessagesCollectionViewCellLabelHeightDefault
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
		let message = self.viewModel.messages.value[indexPath.item];
		if message.senderId == User.senderId {
			let checkmark: String = "✔︎"
			var textColor: UIColor = UIColor.lightGray
			switch message.deliveryStatus {
			case .sent:
				textColor = UIColor.white
			case .serverAck:
				textColor = UIColor.lightGray
			case .delivered:
				textColor = UIColor.orange
			case .read:
				textColor = UIColor.green
			}
			
			return NSAttributedString(string: checkmark, attributes: [NSForegroundColorAttributeName: textColor])
		} else {
			if message.isGameMediaMessage {
				let gameData = message.attachment!.json
				let gameType = gameData["gameType"].string
				let gameConfig = Configuration.games[gameType!]
				if gameConfig!.continuous {
					return NSAttributedString(string: "                    Your turn to make a move", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize), NSForegroundColorAttributeName: FlatRed()])
				}
			}
		}
		
		return nil
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
		//To uses for the label. "Your turn" on game messages from other person and delivery status on your messages
		
		//Only send the info for latest message in the stream if it is from me and it has been acked by the server
		let message = self.viewModel.messages.value[indexPath.item]
		if message.senderId == User.senderId {
			if indexPath.item == (self.viewModel.messages.value.count - 1) && message.deliveryStatus != .sent {
				return 15.0
			}
		} else {
			if message.isGameMediaMessage {
				return 15.0
			}
		}
		
		return 0.0
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
		self.hideKeyboard()

		let message = self.viewModel.messages.value[indexPath.row]
		if message.isGameMediaMessage {
			var gameData = message.attachment!.json
			let gameType = gameData["gameType"].string
			let gameConfig = Configuration.games[gameType!]
			
			//Check if the game can be tapped open
			if gameConfig!.continuous { //Continous games can be tapped open if it's your turn
				if message.senderId == User.senderId {
					TSMessage.showNotification(withTitle: "It's not your turn.", type: TSMessageNotificationType.warning)
					return
				}
			} else {
				//Non continous games start the game from fresh slate for you to play
				gameData = nil
			}
			let outgoing = message.senderId == User.senderId
			
			//Find the location of the message on screen and present the game
			let attributes: UICollectionViewLayoutAttributes = self.collectionView!.layoutAttributesForItem(at: indexPath)!
			let frame: CGRect  = self.collectionView!.convert(attributes.frame, to:self.view)
			let cellOrigin: CGPoint = frame.origin;
			self.presentGame(gameType!, gameData:gameData, tapPoint:cellOrigin, outgoing:outgoing)
		} else if message.isPhotoMediaMessage {
			let key =  message.attachment!.key
			//Get the big image
			var image = STHttp.getFromCache(Configuration.mediaBucket, key: key)
			//If the big image is not in cache for some reason, use the thumbnail
			if image == nil {
				image = (message.media as! JSQPhotoMediaItem).image
			}
			
			let photo = MessagePhoto(image: image)
			let photosViewController: NYTPhotosViewController = NYTPhotosViewController(photos: [photo], initialPhoto: photo)
			self.present(photosViewController, animated: true, completion: nil)
		} else if message.media != nil {
			//(message.media as! STTappableMedia).tapped()
		}
		
		/*
		//http://stackoverflow.com/questions/13780153/uicollectionview-animate-cell-size-change-on-selection
		self.collectionView!.collectionViewLayout.invalidateLayout()
		let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
		UIView.transitionWithView(cell, duration:0.1, options: .CurveLinear,
			animations: {
				var frame: CGRect = cell.frame
				frame.size = CGSizeMake(frame.size.width + 50, frame.size.height + 50)
				cell.frame = frame;
			
			},
			completion:nil
		)
		*/
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
		NSLog("didTapCellAtIndexPath")
		self.hideKeyboard()
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
		NSLog("didTapAvatarImageView")
	}
	
	//UIScrollView delegation - Checking if more content should be loaded
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (decelerate) { //Still moving
			return
		}
		
		self.loadMoreContent()
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.loadMoreContent()
	}
	
	//Using tap to nav bar
	override func scrollViewDidScroll(toTop scrollView: UIScrollView) {
		self.loadMoreContent()
	}
	
	fileprivate func loadMoreContent() {
		if (self.collectionView!.frame.equalTo(CGRect.zero)) {
			return
		}
		
		let topOffset: CGFloat = -self.collectionView!.contentInset.top;
		let distanceFromTop: CGFloat = self.collectionView!.contentOffset.y - topOffset
		let minimumDistanceFromTopToTriggerLoadingMore: CGFloat = 100
		let nearTop: Bool = distanceFromTop <= minimumDistanceFromTopToTriggerLoadingMore
		if (nearTop) {
			self.showLoadingMoreIndicator.value = true
			collectionView!.reloadData() //To reload the view and show the activity spinner if the loading takes a while
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { //Give the spinner a tick to show
				[weak self] in
				self?.viewModel.loadMore()
			})
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionElementKindSectionHeader {
			let header: UICollectionViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellIdentifier, for: indexPath) as! UICollectionViewCell
			let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
			spinner.startAnimating()
			header.addSubview(spinner)
			spinner.snp_makeConstraints { (make) -> Void in
				make.centerX.equalTo(self.collectionView!)
				make.top.equalTo(self.collectionView!).offset(15)
			}
			showingLoadingMoreIndicator = true
			return header
		}
		
		return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
	}
	
	//Overrides superclasses ability to show load more messages button. Makes room for our loading more spinner if needed
	override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if !self.showLoadingMoreIndicator.value {
			return CGSize.zero
		}
		
		return CGSize(width: 100, height: 50);
	}
	
	//Image handling
	fileprivate func presentPhotoAction() {
		self.hideKeyboard()
		
		let alert = UIAlertController(title: "Pick an image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		let photo = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.default) { alert in
			self.presentImagePicker(UIImagePickerControllerSourceType.camera)
		}
		let library = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { alert in
			self.presentImagePicker(UIImagePickerControllerSourceType.photoLibrary)
		}
		let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { alert in
		}
		let chessButton = UIAlertAction(title: "Chess", style: UIAlertActionStyle.default) { alert in
			self.presentGame("chess", gameData:nil, tapPoint:nil, outgoing: true)
			self.sendMessage("Started a new chess game!", image: nil)
		}
		let chessButton2 = UIAlertAction(title: "Start a new game (delete old)", style: UIAlertActionStyle.default) { alert in
			self.presentGame("chess", gameData:nil, tapPoint:nil, outgoing: true)
			self.sendMessage("Deleted the old game and started a new!", image: nil)
			//Delete previous game messages.
			self.viewModel.deleteAllPreviousMessagesOfType(STGameData.contentTypeForGameType("chess"))
		}
		
		let button2048 = UIAlertAction(title: "2048", style: UIAlertActionStyle.default) { alert in
			self.presentGame("2048", gameData:nil, tapPoint:nil, outgoing: true)
		}
		
		if !self.viewModel.hasMessagesOfType(STGameData.contentTypeForGameType("chess")) { //Only allow new chess games if there is no game ongoing atm
			alert.addAction(chessButton)
		} else {
			alert.addAction(chessButton2)
			alert.title = "Warning: This will delete the old game!"
			alert.message = "A chess game is already in progress"
		}
		
		alert.addAction(button2048)
		alert.addAction(photo)
		alert.addAction(library)
		alert.addAction(cancelButton)
		self.present(alert, animated: true, completion: nil)
	}
	
	fileprivate func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
		let picker: UIImagePickerController = UIImagePickerController()
		picker.delegate = self
		picker.sourceType = sourceType
		picker.mediaTypes = [kUTTypeImage as String]
		self.present(picker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		self.dismiss(animated: true, completion: nil)
		
		if info[UIImagePickerControllerMediaType] as! String == kUTTypeImage as String {
			let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
			self.sendMessage("A new photo", image: image)
		} else {
			assert(false, "Unknown media type picked")
		}
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismiss(animated: true, completion: nil)
	}
	
	//Game handling
	
	func gameNotified(_ gameData: STGameData) {
		self.gameData = gameData
		let gameConf = Configuration.games[gameData.data["gameType"].stringValue]
		if gameConf!.continuous && gameConf!.players > 1 {
			self.sendGameMessage("made a move", data:gameData)
		} else if gameData.data["postState"].bool != nil {
			self.sendGameMessage("a new highscore!", data:gameData, deleteOwnOnly: true)
		}
		
		//If there is any notifier messages to post
		if let msgToPost = self.gameData!.data["msgToPost"].string {
			self.sendMessage(msgToPost, image: nil)
		}
	}
	
	func presentGame(_ gameType: String, gameData: JSON?, tapPoint: CGPoint?, outgoing: Bool) {
		self.hideKeyboard()

		if (self.gameView == nil) {
			let superview: UIView = UIApplication.shared.keyWindow!
			var useTapPoint: CGPoint? = tapPoint
			if tapPoint == nil {
				useTapPoint = CGPoint(x: superview.frame.origin.x + superview.frame.width / 2, y: superview.frame.height - 60) //Low center
			}
			
			self.gameView = WebGameView(superViewFrame: superview.frame, gameType: gameType, gameData: gameData, tapPoint: useTapPoint!, outgoing: outgoing)
			self.gameView!.gameNotified.producer
				.ignoreNil() //Ignore the first nil value
				.start {
					[unowned self] event in
					switch event {
					case let .next(next):
						let notifiedGameData: STGameData? = next
						self.gameNotified(notifiedGameData!)
					default:
						break
					}
			}
			
			self.gameView!.controllerDelegate = self
			superview.addSubview(self.gameView!)
			self.gameView!.animateToView()
		}
	}
	
	func gameDismissed() {
		self.gameView = nil
	}
	
	//Private methods
	fileprivate func hideKeyboard() {
		self.inputToolbar!.contentView!.textView!.resignFirstResponder()
	}
	
	fileprivate func sendMessage(_ text: String!, image: UIImage? = nil) {
		self.viewModel.sendMessage(text, image:image)
	}
	
	fileprivate func sendGameMessage(_ text: String, data: STGameData, deleteOwnOnly: Bool = false) {
		self.viewModel.sendGameMessage(text, data: data, deleteOwnOnly: deleteOwnOnly)
	}
}

