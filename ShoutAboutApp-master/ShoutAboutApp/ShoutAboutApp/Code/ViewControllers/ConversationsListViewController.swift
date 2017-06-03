//
//  ConversationsListViewController.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 23/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ChameleonFramework

class ConversationsListViewController: UITableViewController {
	fileprivate let cellIdentifier = "ConvListCell"
	fileprivate unowned var xmppClient: STXMPPClient
	fileprivate let viewModel: ConversationsListViewModel
	
	init(xmpp: STXMPPClient) {
		self.xmppClient = xmpp
		self.viewModel = ConversationsListViewModel(xmpp: self.xmppClient)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init!(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//Remove the navigationBar border
		self.navigationController?.navigationBar.isTranslucent = false
		//self.navigationController?.hidesNavigationBarHairline = true
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		let title = NSLocalizedString("Logout", comment: "")
		let logoutItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: Selector("logoutButtonTapped:"))
		self.navigationItem.setLeftBarButton(logoutItem, animated: false)
		
		let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: Selector("composeButtonTapped:"))
		self.navigationItem.setRightBarButton(composeItem, animated: false)
		self.tableView.register(ConversationListViewCell.self, forCellReuseIdentifier: cellIdentifier)
		
		if User.displayName == nil {
			let profile = ProfileViewController()
			self.present(profile, animated: true, completion: nil)
		}
		
		self.title = "smalltalk"
		self.setupBindings()
	}
	
	fileprivate func setupBindings() {
		self.viewModel.disposer.addDisposable(
			self.viewModel.messages.producer
				.start {
					[unowned self] event in
					switch event {
					case .next:
						self.tableView.reloadData()
					default:
						break
					}
			}
		)
		
		self.viewModel.disposer.addDisposable(
			self.viewModel.unreadMessagesCount.producer
				.start {
					[unowned self] event in
					switch event {
					case let .next(howManyArrived):
						var title = "Back"
						if howManyArrived > 0 {
							title += " (\(howManyArrived))"
						}
						self.navigationItem.backBarButtonItem = UIBarButtonItem(title:title, style:.plain, target:nil, action:nil)
					default:
						break
					}
			}
		)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData() //Reload data to make sure that cells are refreshed to reflect latest seen data
		self.viewModel.setOpenedThread(nil)
	}
	
	// MARK - Actions
	
	func composeButtonTapped(_ sender: AnyObject)
    {
		let controller = ContactsViewController(xmpp: self.xmppClient, selectedCallback:
        {
			[unowned self] (contact: STContact) in
			self.navigationController!.popViewController(animated: false)
			let convController = ConversationViewController(chattingWith: contact, xmpp: self.xmppClient)
			self.viewModel.setOpenedThread(convController.viewModel.currentThread)
			self.navigationController!.pushViewController(convController, animated: false)
		})
		
		self.navigationController!.pushViewController(controller, animated: true)
	}
	
	func logoutButtonTapped(_ sender: AnyObject) {
		print("logOutButtonTapAction", terminator: "")
		User.logOut()
		self.navigationController!.popToRootViewController(animated: true)
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.viewModel.messages.value.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70.0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ConversationListViewCell
		let msg = self.viewModel.messages.value[indexPath.row]
		cell.setMessage(msg)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let msg: STMessage = self.viewModel.messages.value[indexPath.row]
		let convController = ConversationViewController(chattingWith: msg.inConversationWith, xmpp: self.xmppClient)
		self.viewModel.setOpenedThread(convController.viewModel.currentThread)
		self.navigationController!.pushViewController(convController, animated: true)
	}
	
	
}
