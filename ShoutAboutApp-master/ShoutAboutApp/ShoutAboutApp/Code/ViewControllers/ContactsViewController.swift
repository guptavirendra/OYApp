//
//  ContactsViewController.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 23/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa


class ContactsViewController: UITableViewController {
	fileprivate let viewModel: ContactsViewModel
	fileprivate unowned var xmppClient: STXMPPClient
	let selectedCallback: (STContact) -> ()

	init(xmpp: STXMPPClient, selectedCallback: (STContact) -> ()) {
		self.xmppClient = xmpp
		self.selectedCallback = selectedCallback
		self.viewModel = ContactsViewModel(xmpp:self.xmppClient)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
		self.setupBindings()
		self.tableView.backgroundColor = (UIApplication.shared.delegate as! AppDelegate).backgroundColor!
	}
	
	fileprivate func setupBindings() {
		self.viewModel.disposer.addDisposable(
			self.viewModel.contacts.producer
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
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
		return self.viewModel.contacts.value.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) 
		let contact: STContact = self.viewModel.contacts.value[indexPath.row]
		cell.textLabel?.text = contact.username //contact.displayName
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contact = self.viewModel.contacts.value[indexPath.row]
		self.selectedCallback(contact)
	}
}
