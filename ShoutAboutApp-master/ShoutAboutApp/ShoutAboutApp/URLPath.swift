//
//  URLPathvar swift
//  iCancerHealth
//
//  Created by VIRENDRA GUPTA on 05/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import Foundation
import UIKit

let contactStored  = "contactStored"
let searchHistory  = "searchHistory"
let searchString   = "searchString"
let search_mobile  = "search_result"
let message        = "message"
let Responsedata   = "data"
let otpMessage     = "Successfully sent the One Time Password to your Mobile Number"
let otpExpireMessage = "your otp has been expired, please regenerate new otp."
let kapp_user_id    = "app_user_id"
let kapp_user_token = "app_user_token"
let user_report_spam_post  = "post_id"

let profile_picture = "profile picture"
let inavalidOTP     = "Invalid OTP Number"

let kBirthDay = "Birthday"
let kEmail   = "Email"
let kName    = "Name"
let kAddress = "Address"
let kWebsite = "Website"
let kGender  = "Gender"

let bgColor = UIColor(patternImage: UIImage(named: "bg")!)
let appColor = UIColor(red: 31.0/255.0, green: 141.0/255.0, blue: 200.0/255.0, alpha: 1.0)


let name  = "name"
let email: String = "email"
let mobile_number: String = "mobile_number"
let created_at: String = "created_at"
let updated_at: String = "updated_at"
let dob : String = "dob"
let address: String = "address"
let website: String = "website"
let photo: String = "photo"
let gcm_token: String = "gcm_token"
let last_online_time: String = "last_online_time"
let user_profile = "user_profile"


struct WebServicePath
{
    
    let add_app_user           = "add_app_user"
    let match_otp              = "match_otp"
    let update_profile         = "update_profile"
    let add_contact_list       = "add_contact_list"
    let search_mobile_number   = "advanced_search"
    let chat_contact_list      = "chat_contact_list"
    let user_contact_list      = "user_contact_list"
    let app_user_profile      = "app_user_profile"
    let image_upload           = "image_upload"
    let send_message           = "send_message"
    let chat_conversation      = "chat_conversation"
    let contact_review_list    = "contact_review_list"
    let add_rate_review        = "add_rate_review"
    let like_review            = "like_review"
    let dislike_review         = "dislike_review"
    let unlike_review          = "unlike_review"
    let undislike_review       = "undislike_review"
    let block_mobile_number    = "block_mobile_number"
    let unblock_mobile_number  = "unblock_mobile_number"
    let user_block_list        = "user_block_list"
    let spam_mobile_number        = "spam_mobile_number"
    let user_spam_list            = "user_spam_list"
    let unspam_mobile_number      = "unspam_mobile_number"
    let favourite_mobile_number   = "favourite_mobile_number"
    let unfavourite_mobile_number = "unfavourite_mobile_number"
    let user_favourite_list       = "user_favourite_list"
    let post_detail               = "post_detail"
    let alert_count               = "alert_count"

    
    // Mohit
    
    let user_feed_list         = "feeds"
    let user_myfeed_list       = "myfeeds"
    let user_alerts_list       = "alerts"
    let user_report_spam_state = "report_spam"
    
    let like_user              = "like"
    let dislike_user           = "dislike"
    
    let nextPage              = "page"
    
    
}

class ChatPerson:SearchPerson
{
   // var idString:Int = 0
    //var name:String?
   // var photo:String?
    var last_message:String?
    var last_message_time:String?
    var unread_message:Int = 0
}


class SearchPerson:PersonContact, NSCoding
{
    var idString:Int = 0
    //var name: String
    var email: String?
    //var "mobile_number": "1234567890",
    var app_user_token: String?
    var created_at : String?
    var updated_at: String?
    var dob: String?
    var address: String?
    var website: String?
    var birthday:String?
    var gender:String?
    var photo: String?
    var gcm_token: String?
    var last_online_time: String?
    var status:String?
    var ratingAverage  = [RatingAverage]()
    var reviewCount    = [ReviewCount]()
    
    required override init()
    {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        if let id = aDecoder.decodeObject(forKey: "idString") as? Int
        {
            idString = id
        }
        if let status = aDecoder.decodeObject(forKey: "status") as? String
        {
            self.status = status
        }
        if let name = aDecoder.decodeObject(forKey: "name") as? String
        {
            self.name = name
        }
        if let email = aDecoder.decodeObject(forKey: "email") as? String
        {
            self.email = email
        }
        if let mobileNumber = aDecoder.decodeObject(forKey: "mobileNumber") as? String
        {
            self.mobileNumber = mobileNumber
        }
        if let created_at = aDecoder.decodeObject(forKey: "created_at") as? String
        {
            self.created_at = created_at
        }
        if let updated_at = aDecoder.decodeObject(forKey: "updated_at") as? String
        {
            self.updated_at = updated_at
        }
        if let dob = aDecoder.decodeObject(forKey: "dob") as? String
        {
            self.dob = dob
        }
        if let birthday = aDecoder.decodeObject(forKey: "birthday") as? String
        {
            self.birthday = birthday
        }
        if let gender = aDecoder.decodeObject(forKey: "gender") as? String
        {
            self.gender = gender
        }
        if let address = aDecoder.decodeObject(forKey: "address") as? String
        {
            self.address = address
        }
        if let website = aDecoder.decodeObject(forKey: "website") as? String
        {
            self.website = website
        }
        if let photo = aDecoder.decodeObject(forKey: "photo") as? String
        {
            self.photo = photo
        }
        
        if let ratingAverage = aDecoder.decodeObject(forKey: "ratingAverage") as? [RatingAverage]
        {
            self.ratingAverage = ratingAverage
            
        }
        
        if let reviewCount = aDecoder.decodeObject(forKey: "reviewCount") as? [ReviewCount]
        {
            self.reviewCount = reviewCount
            
        }
        
        
    }
    
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(idString, forKey: "idString")
        aCoder.encode(idString, forKey: "status")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(mobileNumber, forKey: "mobileNumber")
        aCoder.encode(created_at, forKey: "created_at")
        aCoder.encode(updated_at, forKey: "updated_at")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(birthday, forKey: "birthday")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(website, forKey: "website")
        aCoder.encode(photo, forKey: "photo")
        aCoder.encode(ratingAverage, forKey: "ratingAverage")
        aCoder.encode(reviewCount, forKey: "reviewCount")
    }
    
    class func archivePeople(_ people:[SearchPerson]) -> Data
    {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: people as NSArray)
        return archivedObject
    }
    
}

class ContactPerson:NSObject
{
    var total : Int = 0
    var per_page: Int = 0
    var current_page: Int = 0
    var last_page: Int = 0
    var next_page_url: String?
    var prev_page_url: String?
    var from: Int = 0
    var to: Int = 0
    var data:[SearchPerson] = [SearchPerson]()
}


class ChatDetail:NSObject
{
    var id: Int = 0
    var sender_id: String?
    var recipient_id: String?
    var message_type: String?
    var text: String?
    var image: String?
    var video: String?
    var message_read: String?
    var received_at: String?
    var created_at: String?
    var updated_at: String?
    var conversation_id: String?
}

class ChatConversation:NSObject
{
    var total: Int = 0
    var per_page: Int = 0
    var current_page: Int = 0
    var last_page: Int = 0
    var next_page_url: String?
    var prev_page_url: String?
    var from: Int = 0
    var to: Int = 0
    var data:[ChatDetail] = [ChatDetail]()
}

 
