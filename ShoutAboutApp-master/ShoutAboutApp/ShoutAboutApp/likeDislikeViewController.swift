//
//  likeDislikeViewController.swift
//  ShoutAboutApp
//
//  Created by Kshitij Raina on 14/03/17.
//  Copyright © 2017 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class likeDislikeViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    var dataFeedMyfeed = dataFeedMyfeedModel()

    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(dataFeedMyfeed)
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 20
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCellWithIdentifier("AlertTableViewCell", forIndexPath: indexPath) as? AlertTableViewCell

        cell?.nameLabel.text = "Welcome to the world of xcode"
        cell?.dateLabel.text = "26-Nov"
        cell?.UserImageView.makeImageRounded()
       /// cell?.UserImageView.setImageWithURL(NSURL(string:"dp"), placeholderImage: UIImage(named: "profile"))
        cell?.contentView.setGraphicEffects()
        return cell!
        
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 110
    }
    

    
}
