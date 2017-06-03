//
//  YoutubeSearchView.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 13/11/15.
//  Copyright © 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa

class YoutubeSearchView: UITableView, UITableViewDelegate, UITableViewDataSource {
	//var superFrame: CGRect
	weak var viewModel: SearchViewModel?
	fileprivate let searchCellIdentifier = "YoutubeSearchViewCell"
	fileprivate let detailCellIdentifier = "YoutubeDetailViewCell"
	
	init(frame: CGRect, viewModel: SearchViewModel) {
		//self.superFrame = frame
		self.viewModel = viewModel
		super.init(frame: frame, style: .plain)
		self.separatorStyle = UITableViewCellSeparatorStyle.none
		self.translatesAutoresizingMaskIntoConstraints = false
		self.scrollsToTop = false
		self.dataSource = self
		self.delegate = self
		
		//Top hairline
		var rect: CGRect = CGRect.zero
		rect.size = CGSize(width: frame.width, height: 0.5)
		let hairline = UIView(frame: rect)
		hairline.autoresizingMask = UIViewAutoresizing.flexibleWidth
		hairline.backgroundColor = self.separatorColor
		self.addSubview(hairline)
		
		self.register(SearchViewTableViewCell.self, forCellReuseIdentifier: searchCellIdentifier)
		self.register(SearchViewDetailTableViewCell.self, forCellReuseIdentifier: detailCellIdentifier)

		self.setupBindings()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setupBindings() {
		self.setupSearchResultsBindings()
	}
	
	fileprivate func setupSearchResultsBindings() {
		self.viewModel!.disposer.addDisposable(
			self.viewModel!.searchResults.producer
				.observeOn(UIScheduler())
				.start {
					[weak self] event in
					switch event {
					case .next:
						self?.reloadData()
					default:
						break
					}
			}
		)
	}
	
	//mark - UITableViewDataSource Methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel!.searchResults.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let (result, detailView) = self.viewModel!.searchResults.value[indexPath.row]
		
		if !detailView {
			let searchResultCell = tableView.dequeueReusableCell(withIdentifier: searchCellIdentifier, for: indexPath) as! SearchViewTableViewCell
			searchResultCell.searchResult(result)
			return searchResultCell
		} else {
			let searchDetailsCell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier, for: indexPath) as! SearchViewDetailTableViewCell
			searchDetailsCell.searchDetails(result, searchViewModel: self.viewModel!)
			return searchDetailsCell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(80)
	}
	
	//mark - UITableViewDelegate Methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (result, detailView) = self.viewModel!.searchResults.value[indexPath.row]
		if !detailView {
			self.viewModel?.needDetails(result, atIndex: indexPath.row)
		} 
	}
}
