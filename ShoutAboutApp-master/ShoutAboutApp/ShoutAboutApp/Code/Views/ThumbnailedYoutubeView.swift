//
//  ThumbnailedYoutubeView.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 10/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftyJSON
import SDWebImage
import youtube_ios_player_helper
import ReactiveCocoa

class ThumbnailedYoutubeView: UIView, YTPlayerViewDelegate, UIGestureRecognizerDelegate {
	let videoViewSize: CGSize
	let url: String
	let title: String?
	let channelTitle: String?
	let isOutgoing: Bool
	var cachedPlaceholderView: UIView? = nil
	var ytView: YTPlayerView?
	var playbackPosition = MutableProperty<Float>(0.0)
	
	init(url: String, title: String?, channelTitle: String?, outgoing: Bool, size: CGSize, videoHeightOfWholeHeight: CGFloat) {
		let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
		self.videoViewSize = CGSize(width: size.width, height: videoHeightOfWholeHeight)
		self.url = url
		self.title = title
		self.channelTitle = channelTitle
		self.isOutgoing = outgoing
		super.init(frame: frame)
		self.addTitleView()
		self.startYTViewAdd()
		setupBindings()
	}
	
	deinit {
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setupBindings() {
		self.setupPlaybackPosMonitoringBindings()
	}
	
	fileprivate func setupPlaybackPosMonitoringBindings() {
		self.playbackPosition.producer
			.throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
			.filter { $0 > 1.0 }
			.start {
				event in
				switch event {
				case let .next(playbackPos):
					let rewinded = max(1.0, playbackPos - 2.0) //Rewind 2 secs to give the user a context where she is returning to
					VideoStore.setPlaybackPosition(rewinded, forVideoId: self.url)
				default:
					break
				}
		}
	}
	
	fileprivate func addTitleView() {
		if title != nil {
			//Place the frame below the video
			let frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.videoViewSize.height, width: self.frame.width, height: self.frame.height - self.videoViewSize.height)
			let view = UIView(frame: frame)
			view.backgroundColor = UIColor.white
			self.addSubview(view)
			
			let label = UILabel(frame: frame)
			label.bounds = view.frame.insetBy(dx: 15.0, dy: 5.0)
			label.numberOfLines = 1
			if channelTitle != nil {
				label.text = "\(channelTitle): \(title)"
			} else {
				label.text = title
			}
			label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
			label.textColor = UIColor.lightGray
			self.addSubview(label)
		}
	}
	
	fileprivate func startYTViewAdd() {
		if let thumbnailImage = cachedScreenshot() {
			//NOTE TODO! For some reason the cachedPlaceholderView bounds are 500x500 instead of 250x250 that is written to cache
			cachedPlaceholderView = UIImageView(image: thumbnailImage)
			var frame = self.frame
			frame.size = self.videoViewSize
			cachedPlaceholderView?.frame = frame
			//If we have screenshot we use that until the user taps it
			let recognizer = UITapGestureRecognizer(target: self, action:#selector(ThumbnailedYoutubeView.handleTap(_:)))
			self.addGestureRecognizer(recognizer)
		} else {
			cachedPlaceholderView = spinnerPlaceholderView()
			//We don't have a screenshot so we load the actual player
			self.loadPlayerView()
		}
		
		cachedPlaceholderView?.contentMode = UIViewContentMode.scaleAspectFill
		cachedPlaceholderView?.clipsToBounds = true
		self.addSubview(cachedPlaceholderView!)
	}

	func handleTap(_: UIGestureRecognizer) {
		//Put a spinner on top of the screenshot
		let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		spinner.center = cachedPlaceholderView!.convert(cachedPlaceholderView!.center, from: cachedPlaceholderView?.superview)
		cachedPlaceholderView!.addSubview(spinner)
        spinner.startAnimating()
		self.loadPlayerView()
	}

	func loadPlayerView() {
		if ytView != nil {
			return
		}
		
		//https://developers.google.com/youtube/player_parameters#autohide
		let playerVars: [AnyHashable: Any] = [
			"controls" : 1, //Show player controls
			"autohide" : 1, //Hide controls automatically
			"playsinline" : 1, //Can play embedded
			"showinfo" : 0, //Don't show additional youtube info
			"modestbranding" : 1,
			"origin" :  self.url //Allows more embeds? https://github.com/youtube/youtube-ios-player-helper/issues/123
		]
		var frame = self.frame
		frame.size = self.videoViewSize
		ytView = YTPlayerView(frame: frame)
		ytView!.load(withVideoId: ThumbnailedYoutubeView.videoId(self.url)!, playerVars: playerVars)
		ytView!.delegate = self
	}
	
	func playerViewDidBecomeReady(_ playerView: YTPlayerView!) {
		NSLog("Playerview ready")
        self.cachedPlaceholderView?.removeFromSuperview()
        self.addSubview(self.ytView!)
        
        //If there's a screenshot available, we know that the playerViewDidBecomeReady was called from tapping the screenshot
        //-> we can start playing the video and snapshotting is not needed
		if self.cachedPlaceholderView != nil && self.cachedPlaceholderView!.isKind(of: UIImageView.self) {
			if let playbackPos = VideoStore.playbackPosition(self.url) {
				ytView!.seek(toSeconds: playbackPos, allowSeekAhead: true)
			}
			ytView?.playVideo()
        } else {
            //We don't need to call playVideo because the user hasn't tapped the video yet. We have just loaded the video for the very first time
            //and user is seeing it for the first time now. Snapshot the video for thumbnail and start playing after user taps the video.
            self.snapShot(1.0) //We wait for 1 second because there's a fade in animation
		}
	}

	func playerView(_ playerView: YTPlayerView!, didChangeTo state: YTPlayerState) {
		switch (state) {
		case YTPlayerState.playing:
			NSLog("Started playback")
		case YTPlayerState.paused:
			NSLog("Paused playback")
		case YTPlayerState.buffering:
			NSLog("Buffering playback")
		case YTPlayerState.queued:
			NSLog("Queued playback")
		case YTPlayerState.ended:
			NSLog("Ended playback")
			VideoStore.clearPlaybackPosition(self.url)
		case YTPlayerState.unstarted:
			NSLog("Unstarted playback")
		case YTPlayerState.unknown:
			NSLog("Unknown playerstate")
		}
	}

	func playerView(_ playerView: YTPlayerView!, didChangeTo quality: YTPlaybackQuality) {
		NSLog("playerView Changed to quality \(quality)")
	}
	
	func playerView(_ playerView: YTPlayerView!, receivedError error: YTPlayerError) {
		NSLog("Did change quality \(error)")
	}
	
	func playerView(_ playerView: YTPlayerView!, didPlayTime playTime: Float) {
		//TODO you can track metrics how much time is spent watching videos
		self.playbackPosition.value = playTime
	}
	
	fileprivate func cachedScreenshot() -> UIImage? {
		let hashStr = "\(self.url.hash)"
		return SDImageCache.shared().imageFromDiskCache(forKey: hashStr)
	}
	
	fileprivate func spinnerPlaceholderView() -> UIView? {
		let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		let view = JSQMessagesMediaPlaceholderView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 120.0), backgroundColor: (UIApplication.shared.delegate as! AppDelegate).backgroundColor, activityIndicatorView: spinner)
		view.frame = CGRect(x: 0.0, y: 0.0, width: videoViewSize.width, height: videoViewSize.height)
		return view
	}
	
	fileprivate func snapShot(_ delay: Double) {
		let hashStr = "\(self.url.hash)"
		//Do not recreate snapshots for images that already exist
		if SDImageCache.shared().imageFromDiskCache(forKey: hashStr) != nil {
			return
		}
	
		//Displatch after to make sure that the youtube has been rendered properly
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
			[unowned self] in
			let snapshot = UIImage.imageForView(self.ytView!)
			if snapshot != nil {
				//TODO! Caches forever, cleanup the cache regularly or figure out a TTL
				SDImageCache.shared().store(snapshot!, forKey: hashStr)
			}
		})
	}
	
	static func videoId(_ strUrl: String) -> String? {
		//https://www.youtube.com/watch?v=nZZpy0BHJH8
		//Grab ?v=nZZpy0BHJH8
		let paramsStr = strUrl.components(separatedBy: "?")[1]
		//Check if there are more params and find the one with "v"
		let params = paramsStr.components(separatedBy: "&")
		for singleParamStr in params {
			var singleParamComponents = singleParamStr.components(separatedBy: "=")
			if singleParamComponents.count > 0 && singleParamComponents[0] == "v" {
				return singleParamComponents[1]
			}
		}
		
		return nil
	}
	
	//func
	
	//mark - NSObject
	override var hash: Int {
		get {
			return super.hash ^ self.url.hash
		}
	}
	
	override var description: String {
		get {
			return "\(self.ytView)"
		}
	}
}
