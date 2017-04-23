/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Firebase

internal class Channel
{
    internal let id: String
    internal let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}


class ChannelListViewController: UITableViewController
{
    var senderDisplayName: String? // 1
    var newChannelTextField: UITextField? // 2
    private var channels: [Channel] = [] // 3
    
    
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    private var channelRefHandle: FIRDatabaseHandle?
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
         return 2 // 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection
            {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    
    // 3
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        /*
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue
        {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue
        {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }*/
        
        return cell
    }
    
    // MARK: Firebase related methods
    private func observeChannels()
    {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["name"] as! String! where name.characters.count > 0 { // 3
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "RW RIC"
        observeChannels()
    }
    
    deinit
    {
        if let refHandle = channelRefHandle
        {
             channelRef.removeObserverWithHandle(refHandle)
            
        }
    }
    
    @IBAction func createChannel(sender: AnyObject)
    {
        if let name = newChannelTextField?.text { // 1
            let newChannelRef = channelRef.childByAutoId() // 2
            let channelItem = [ // 3
                "name": name
            ]
            newChannelRef.setValue(channelItem) // 4
        }
    }
    
    // MARK: Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
         super.prepareForSegue(segue, sender: sender)

        if let channel = sender as? Channel
        {
            let chatVc = segue.destinationViewController as! ChatsViewController
            
            chatVc.senderDisplayName = senderDisplayName
            //chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channels[(indexPath as NSIndexPath).row]
            self.performSegueWithIdentifier( "ShowChannel", sender: channel)
        }
    }


}
