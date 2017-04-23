//
//  DataSession.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

import UIKit

class DataSession: BaseNSURLSession
{
    
    // Mohit
    /*******************  Feed Screen ********************/
    //MARK: GET Feeds
    func getFeedsData(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()) {
        
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_feed_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    /*******************  MYFeed Screen ********************/
    //MARK: GET MYFeeds
    func getMyFeedsData(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()) {
        
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_myfeed_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    /*******************  Alert Screen ********************/
    //MARK: GET Alert
    func getAlertData(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()) {
        
        let dict = NSObject.getAppUserIdAndToken()
        
        super.getWithOnFinish(mCHWebServiceMethod.user_alerts_list, parameters: dict, onFinish: {(response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            
        }) {(error) in
            onError(error: error)
        }
        
    }
    
    
    
    
    /*******************  FEED Screen ********************/
    //MARK: Feed Like
    func feedLike(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.like_user, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
    }
    
    /*******************  Feed Screen ********************/
    //MARK: Feed Dislike
    func feedisLike(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.dislike_user, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
    }
    
    
    
    /*******************  Alert Screen ********************/
    //MARK: Report To Spam
    func reportTospam(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.user_report_spam_state, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
    }
    
    
    
    
    
    /*******************  LOGIN SCREEN ********************/
   //MARK: GET OTP
    func getOTPForMobileNumber(mobileNumber:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()) {
        
        let dict = ["mobile_number":mobileNumber]
        super.getWithOnFinish(mCHWebServiceMethod.add_app_user, parameters: dict, onFinish: { (response, deserializedResponse) in
            
               onFinish(response: response, deserializedResponse: deserializedResponse)
            
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    /*******************  OTP SCREEN ********************/
    //MARK: GET OTP VALIDATION
    func getOTPValidateForMobileNumber(mobileNumber:String, otp:String,  onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = ["mobile_number":mobileNumber, "otp":otp]
        super.getWithOnFinish(mCHWebServiceMethod.match_otp, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    /*******************  SIGN UP ********************/
    //MARK: UPDATE PROFILE
    func updateProfile(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.update_profile, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
    }
    /*******************  SEARCH CONTACT ********************/
    
    //MARK:SEARCH CONTACT
    func searchContact(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.search_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    /******************* PROFILE SCREEN ********************/
    
    //MARK: GET USER PROFILE DATA
    func getProfileData(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.app_user_profile, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
        
    }
    
    //MARK: POST PROFILE IMAGE
    
    func postProfileImage(mediaPath:[String]?, name:[String]?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        /*
         super.postSBMediaWithOnFinish(mCHWebServiceMethod.image_upload, headerParam: dict, mediaPaths: mediaPath, bodyDict: nil, name: name, onFinish: { (response, deserializedResponse) in
         onFinish(response: response, deserializedResponse: deserializedResponse)
         }) { (error) in
         onError(error: error)
         }*/
        
        super.postMediaWithOnFinish(mCHWebServiceMethod.image_upload, headerParam: dict, mediaPaths: mediaPath, bodyDict: nil, name: "photo", onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
    }
    
    
    
    //MARK: SYNC CONTACT
    func syncContactToTheServer(dict:[String:String], postDict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        super.postDataWithOnFinish(mCHWebServiceMethod.add_contact_list, parameters: dict, postBody: postDict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
    }
    
    
    func getContactListForPage(/*page:String,*/ onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
         let dict = NSObject.getAppUserIdAndToken()
         //dict["page"] = page
         super.getWithOnFinish(mCHWebServiceMethod.user_contact_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    
    
    //MARK: CHAT LIST
    func getChatList(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.chat_contact_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    //MARK: Get conversation
    func getChatConversationForID(contactID:String, page: String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var  dict = NSObject.getAppUserIdAndToken()
        dict["contact_id"] = contactID
        dict["page"] = page
        
        super.getWithOnFinish(mCHWebServiceMethod.chat_conversation, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    //MARK: ADD REVIEW LIST
    func addRateReview(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        super.postDataWithOnFinish(mCHWebServiceMethod.add_rate_review, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    //MARK: CONTACT LIST REVIEW
    func getContactReviewList(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        super.getWithOnFinish(mCHWebServiceMethod.contact_review_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    
    //MARK: CHAT CONVERSATION
    
    func getChatConversionForContactID(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        super.getWithOnFinish(mCHWebServiceMethod.chat_conversation, parameters: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }


    }
    
    // MARK: TEXT MESSAGE
    func sendTextMessage(recipient_id:String, message:String,  onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
         var  paramdict = NSObject.getAppUserIdAndToken()
         paramdict["recipient_id"] = recipient_id
         paramdict["message_type"] = "text"
        
         let  postDict = ["text":message]
        
        super.postDataWithOnFinish(mCHWebServiceMethod.send_message, parameters: paramdict, postBody: postDict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)

            }) { (error) in
                onError(error: error)
        }
        
       
    }
    
    
    func sendVideoORImageMessage(recipentID:String, message_type: String, mediaPath:[String]?, name:[String]?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        var dict = NSObject.getAppUserIdAndToken()
        dict["recipient_id"] = recipentID
        dict["message_type"] = message_type
    
        super.postMediaWithOnFinish(mCHWebServiceMethod.send_message, headerParam: dict, mediaPaths: mediaPath, bodyDict: nil, name: message_type, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    func likeUserID(ratereviews_id:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["ratereviews_id"] = ratereviews_id
        super.getWithOnFinish(mCHWebServiceMethod.like_review, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    func dislikeUserID(ratereviews_id:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["ratereviews_id"] = ratereviews_id
        super.getWithOnFinish(mCHWebServiceMethod.dislike_review, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    //MARK: block user id
    
    func blockUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        
        dict["block_user_id"] = String(appUserId)
        dict ["for_user_id"]  = userID
        
        super.postDataWithOnFinish(mCHWebServiceMethod.block_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)

            }) { (error) in
                onError(error: error)

        }
        
    }
    
    func unblockUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        dict["block_user_id"] = String(appUserId)
        dict ["for_user_id"]  = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.unblock_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            
        }) { (error) in
            onError(error: error)
            
        }
        
    }

    
    
    func getBlockUsersList(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_block_list, parameters: dict, onFinish: { (response, deserializedResponse) in
             onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    
    //MARK SPAM
    func spamUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        //dict.removeValueForKey(kapp_user_id)
        let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        
        dict["by_user_id"] = String(appUserId)
        dict["spam_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.spam_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            
        }) { (error) in
            onError(error: error)
            
        }
        
    }
    
    //MARK SPAM
    func unspamUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
         let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
        dict["by_user_id"] = String(appUserId)
        dict["spam_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.unspam_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            
        }) { (error) in
            onError(error: error)
            
        }
        
    }
    
    func getUserSpamList(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_spam_list, parameters: dict, onFinish: { (response, deserializedResponse) in
        onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
        onError(error: error)
        }
        
    }

    
    
    //MARK:FAVOURITE
    func favouriteUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["fav_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.favourite_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            
        }) { (error) in
            onError(error: error)
            
        }
    }

    func unfavouriteUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["fav_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.unfavourite_mobile_number, parameters: dict, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            
        }) { (error) in
            onError(error: error)
            
        }
        
    }
    
    func getUserfavoriteList(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_favourite_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    
    
    
}

class DataSessionManger: NSObject
{
    static let sharedInstance = DataSessionManger()
    
    
    func dislikeUserID(ratereviews_id:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.dislikeUserID(ratereviews_id, onFinish: { (response, deserializedResponse) in
             onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                 onError(error: error)
        }
        
        
    }
    
    
    
    func likeUserID(ratereviews_id:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.likeUserID(ratereviews_id, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)

            }) { (error) in
                onError(error: error)
        }
        
        
    }
    
    func postProfileImage(mediaPath:[String]?, name:[String]?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.postProfileImage(mediaPath, name: name, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    func getProfileData(onFinish:(response:AnyObject,personalProfile:SearchPerson)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.getProfileData({ (response, deserializedResponse) in
            let personalProfileData = SearchPerson()
            if deserializedResponse is NSDictionary
            {
                if let arrayDict = deserializedResponse.objectForKey(user_profile) as? [NSDictionary]
                {
                    
                    
                    let dataDict = arrayDict.first
                    personalProfileData.idString = (dataDict?.objectForKey("id") as? Int)!
                    if let  name = dataDict?.objectForKey(name) as? String
                    {
                        personalProfileData.name = name
                    }
                    personalProfileData.email = (dataDict?.objectForKey(email))! as? String
                    personalProfileData.mobileNumber = dataDict?.objectForKey(mobile_number) as! String
                   
                    personalProfileData.created_at = (dataDict?.objectForKey(created_at))! as? String
                    personalProfileData.updated_at = dataDict?.objectForKey(updated_at) as? String
                    personalProfileData.address = dataDict?.objectForKey(address) as? String
                    personalProfileData.website = dataDict?.objectForKey(website) as? String
                    if let _ = dataDict?.objectForKey(photo) as? String
                    {
                        personalProfileData.photo = dataDict?.objectForKey(photo) as? String
                    }
                    
                    if let _ = dataDict?.objectForKey(gcm_token) as? String
                    {
                    
                        personalProfileData.gcm_token = (dataDict?.objectForKey(gcm_token) as? String)!
                    }
                    
                    
                    if let lastonlineTime = dataDict?.objectForKey(last_online_time) as? String
                    {
                         personalProfileData.last_online_time = lastonlineTime
                        
                    }
                    
                    /*
                   
                    if let _ = (dataDict?.objectForKey("rating_average") as? [AnyObject])
                    {
                        personalProfileData.ratingAverage = (dataDict?.objectForKey("rating_average") as? [AnyObject])!
                    }
                    
                    if let _ = dataDict?.objectForKey("review_count") as? [AnyObject]
                    {
                        personalProfileData.reviewCount = dataDict?.objectForKey("review_count") as! [AnyObject]
                    }
                    */
                    
                }
                
            }
            
            onFinish(response: response, personalProfile: personalProfileData)
            
            
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    
    
    func getOTPForMobileNumber(mobileNumber:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.getOTPForMobileNumber(mobileNumber, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    
    // Mohit
    
    
    
    //feed Like
    func feedLikeUser(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AlertCountCommonModel)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        
        
        dataSession.feedLike(dict, onFinish: { (response, deserializedResponse) in
            let AlertUser:AlertCountCommonModel = AlertCountCommonModel()
            
            print(deserializedResponse)
           
                
                
//                AlertUser.post_id = (deserializedResponse.objectForKey("success") as? Int)!
                AlertUser.likeDislikecount = (deserializedResponse.objectForKey("message") as? String)!
                
            
            
            
            
            onFinish(response: response, deserializedResponse: AlertUser)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    //feed DisLike
    func feedisLikeUser(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AlertCountCommonModel)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.feedisLike(dict, onFinish: { (response, deserializedResponse) in
            let AlertUser:AlertCountCommonModel = AlertCountCommonModel()
            
            
            print(deserializedResponse)
            
            
            
            //                AlertUser.post_id = (deserializedResponse.objectForKey("success") as? Int)!
            AlertUser.likeDislikecount = (deserializedResponse.objectForKey("message") as? String)!
            

            
            
            
            onFinish(response: response, deserializedResponse: AlertUser)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    //Report To Spam
    func reportTospamUser(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.reportTospam(dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    
    //Feedslist
    func getfeedslist(onFinish:(response:AnyObject,deserializedResponse:FeedMyfeed)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        dataSession.getFeedsData({ (response, deserializedResponse) in
            
            let feedMyfeedUser:FeedMyfeed = FeedMyfeed()
            
            
            if deserializedResponse is NSDictionary{
                
                feedMyfeedUser.total = (deserializedResponse.objectForKey("total") as? Int)!
                feedMyfeedUser.per_page = (deserializedResponse.objectForKey("per_page") as? Int)!
                feedMyfeedUser.current_page = (deserializedResponse.objectForKey("current_page") as? Int)!
                feedMyfeedUser.last_page = (deserializedResponse.objectForKey("last_page") as? Int)!
//                feedMyfeedUser.next_page_url = (deserializedResponse.objectForKey("next_page_url") as? String)!
                
//                feedMyfeedUser.prev_page_url = (deserializedResponse.objectForKey("prev_page_url") as? String)!
                
//                feedMyfeedUser.from = (deserializedResponse.objectForKey("from") as? Int)!
//                feedMyfeedUser.to = (deserializedResponse.objectForKey("to") as? Int)!
                
                
                if let  dataList = deserializedResponse.objectForKey("data") as? [NSDictionary]{
                    
                    for dict in dataList{
                        
                        let datavalue = dataFeedMyfeedModel()
                        
                        datavalue.id =   (dict.objectForKey("id") as? Int)!
                        datavalue.action =   (dict.objectForKey("action") as? String)!
//                        datavalue.review =   (dict.objectForKey("review") as? String)!
//                        datavalue.recent_action =   (dict.objectForKey("recent_action") as? String)!
                        datavalue.created_at =   (dict.objectForKey("created_at") as? String)!
                        
                        
                        
                        if let innerDict = dict.objectForKey("performed"){
                            
                            let performedatavalue = commonModel()
                            performedatavalue.id =   (innerDict.objectForKey("id") as? Int)!
                            
//                            performedatavalue.name =   (innerDict.objectForKey("name") as? String)!
                           
                            
                            
                            
                           
                            performedatavalue.photo =   (innerDict.objectForKey("photo") as? String)!
                            performedatavalue.mobile_number =   (innerDict.objectForKey("mobile_number") as? String)!
                           
                            
                            print(innerDict)
                            
                            datavalue.performed = performedatavalue
                            
                        }

                        
//                        datavalue.effected =   (dict.objectForKey("effected") as? String)!
                        
                        
                        
                        if let  likesList = dict.objectForKey("likes_count") as? [NSDictionary]{
                            
                            for dict in likesList{
                                
                                let LikeDislikevalue = AlertCountCommonModel()
                                
                                LikeDislikevalue.post_id =   (dict.objectForKey("post_id") as? String)!
//                                LikeDislikevalue.likeDislikecount =   (dict.objectForKey("dislikes") as? String)!
                                
                                datavalue.likes_count = LikeDislikevalue
                            }
                            
                            print(likesList)
                            
                            
                        }
                        
                        if let  dislikesList = dict.objectForKey("dislikes_count") as? [NSDictionary]{
                            
                            for dict in dislikesList {
                                
                                let LikeDislikevalue = AlertCountCommonModel()
                                
                                LikeDislikevalue.post_id =   (dict.objectForKey("post_id") as? String)!
                                LikeDislikevalue.likeDislikecount =   (dict.objectForKey("dislikes") as? String)!
                                
                                datavalue.dislikes_count = LikeDislikevalue
                            }
                            print(dislikesList)
                        }
                        
                        
                        
                        if let  likesUserList = dict.objectForKey("likes_user") as? [NSDictionary]{
                            
                            for dict in likesUserList{
                                
                                let likesUserdatavalue = commonModel()
                                likesUserdatavalue.id =   (dict.objectForKey("id") as? Int)!
//                                likesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
                                likesUserdatavalue.mobile_number =   (dict.objectForKey("mobile_number") as? String)!
                                likesUserdatavalue.photo =   (dict.objectForKey("photo") as? String)!
                                datavalue.likes_user = likesUserdatavalue
                                
                            }
                        }
                        
                        
                        if let  dislikesUserList = dict.objectForKey("dislikes_user") as? [NSDictionary]{
                            
                            for dict in dislikesUserList{
                                
                                let dislikesUserdatavalue = commonModel()
                                dislikesUserdatavalue.id =   (dict.objectForKey("id") as? Int)!
                                dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
                               
                                dislikesUserdatavalue.mobile_number =   (dict.objectForKey("mobile_number") as? String)!
                             
                                dislikesUserdatavalue.photo =   (dict.objectForKey("photo") as? String)!
                                datavalue.dislikes_user = dislikesUserdatavalue
                            }
                            
                            print(dislikesUserList)
                            
                            
                            
                        }
                        feedMyfeedUser.data.append(datavalue)
                    }
                }
                
                
                
                
            }
            
            
            
            onFinish(response: response, deserializedResponse: feedMyfeedUser)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    //MYFeedslist
    func getMyfeedslist(onFinish:(response:AnyObject,deserializedResponse:FeedMyfeed)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        dataSession.getMyFeedsData({ (response, deserializedResponse) in

            let feedMyfeedUser:FeedMyfeed = FeedMyfeed()
            
            
            if deserializedResponse is NSDictionary{
                
                feedMyfeedUser.total = (deserializedResponse.objectForKey("total") as? Int)!
                feedMyfeedUser.per_page = (deserializedResponse.objectForKey("per_page") as? Int)!
                feedMyfeedUser.current_page = (deserializedResponse.objectForKey("current_page") as? Int)!
                feedMyfeedUser.last_page = (deserializedResponse.objectForKey("last_page") as? Int)!
                
//              feedMyfeedUser.next_page_url = (deserializedResponse.objectForKey("next_page_url") as? String)!
                
//              feedMyfeedUser.prev_page_url = (deserializedResponse.objectForKey("prev_page_url") as? String)!
                
                
                feedMyfeedUser.from = (deserializedResponse.objectForKey("from") as? Int)!
                feedMyfeedUser.to = (deserializedResponse.objectForKey("to") as? Int)!
                
                
                if let  dataList = deserializedResponse.objectForKey("data") as? [NSDictionary]{
                    
                    for dict in dataList{
                        
                        let datavalue = dataFeedMyfeedModel()
                        
                        datavalue.id =   (dict.objectForKey("id") as? Int)!
                        datavalue.action =   (dict.objectForKey("action") as? String)!
                        
                        if dict.objectForKey("action_val") != nil{
                            
                            datavalue.action_val = (dict.objectForKey("action_val") as? String)!
                            
                        }
                        
                        
//                        if dict.objectForKey("review") != nil{
                        
//                             datavalue.review =   (dict.objectForKey("review") as? String)!
                        
//                        }
                        
                        
                       
                        
                        if (dict.objectForKey("recent_action") as? String) != nil{
                        
                            datavalue.recent_action =   (dict.objectForKey("recent_action") as? String)!
                        }
                        datavalue.created_at =   (dict.objectForKey("created_at") as? String)!
                        
                        
                        
                        if let innerDict = dict.objectForKey("performed"){
                            
                            let performedatavalue = commonModel()
                            performedatavalue.id =   (innerDict.objectForKey("id") as? Int)!
                            
                            if innerDict.objectForKey("name") != nil{
                                performedatavalue.name =   (innerDict.objectForKey("name") as? String)!
                            }
                 
                            performedatavalue.mobile_number =   (innerDict.objectForKey("mobile_number") as? String)!
                 
                            performedatavalue.photo =   (innerDict.objectForKey("photo") as? String)!
                 
                            datavalue.performed = performedatavalue
                        }

                        
                        if (self.nullToNil(dict.objectForKey("effected")) != nil){
                        
                        if let effectedDict = dict.objectForKey("effected"){
                            
                           
                            
                            print(effectedDict)
                            print(dict.objectForKey("effected"))
                            let effectedatavalue = commonModel()
                            
                            
                            
                            effectedatavalue.id =   (effectedDict.objectForKey("id") as? Int)!
                            
                            
                            }
                        }
                            
//                        datavalue.effected =   (dict.objectForKey("effected") as? String)!
                        
                            
                            
                            if let  likesList = dict.objectForKey("likes_count") as? [NSDictionary]{
                                
                                for dict in likesList{
                                    
                                    let LikeDislikevalue = AlertCountCommonModel()
                                    
                                    LikeDislikevalue.post_id =   (dict.objectForKey("post_id") as? String)!
                                    LikeDislikevalue.likeDislikecount =   (dict.objectForKey("likes") as? String)!
                                    
                                    datavalue.likes_count = LikeDislikevalue
                                }
                                
                                print(likesList)
                            }
                            
                            if let  dislikesList = dict.objectForKey("dislikes_count") as? [NSDictionary]{
                                
                                for dict in dislikesList {
                                    
                                    let LikeDislikevalue = AlertCountCommonModel()
                                    
                                    LikeDislikevalue.post_id =   (dict.objectForKey("post_id") as? String)!
                                    LikeDislikevalue.likeDislikecount =   (dict.objectForKey("dislikes") as? String)!
                                    
                                    datavalue.dislikes_count = LikeDislikevalue
                                }
                                print(dislikesList)
                            }
                            
                            
                            
                            if let  likesUserList = dict.objectForKey("likes_user") as? [NSDictionary]{
                                
                                for dict in likesUserList{
                                    
                                    let likesUserdatavalue = commonModel()
                                    likesUserdatavalue.id =   (dict.objectForKey("id") as? Int)!
//                                    likesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
                                    likesUserdatavalue.mobile_number =   (dict.objectForKey("mobile_number") as? String)!
                
                                    if (dict.objectForKey("photo") as? String) != nil{
                                       likesUserdatavalue.photo =   (dict.objectForKey("photo") as? String)!
                                    }
                 
                                    datavalue.likes_user = likesUserdatavalue
                                }
                            }
                            
                            
                            if let  dislikesUserList = dict.objectForKey("dislikes_user") as? [NSDictionary]{
                                
                                for dict in dislikesUserList{
                                    
                                    let dislikesUserdatavalue = commonModel()
                                    dislikesUserdatavalue.id =   (dict.objectForKey("id") as? Int)!
//                                    dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
//
                                    dislikesUserdatavalue.mobile_number =   (dict.objectForKey("mobile_number") as? String)!
        
                                    dislikesUserdatavalue.photo =   (dict.objectForKey("photo") as? String)!
//
                                    
                                    datavalue.dislikes_user = dislikesUserdatavalue

                                }
                                
                                print(dislikesUserList)
                            }
                        
                            feedMyfeedUser.data.append(datavalue)
                        }
                    }
                

            }
            

            onFinish(response: response, deserializedResponse: feedMyfeedUser)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    
    
    
    
    
    //Alertlist
    func getAlertlist(onFinish:(response:AnyObject,deserializedResponse:AlertModel)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        dataSession.getAlertData({(response, deserializedResponse) in
            
            let AlertUser:AlertModel = AlertModel()
            
            print(deserializedResponse)
            
            if deserializedResponse is NSDictionary{
                
                AlertUser.total = (deserializedResponse.objectForKey("total") as? Int)!
                AlertUser.per_page = (deserializedResponse.objectForKey("per_page") as? Int)!
                AlertUser.current_page = (deserializedResponse.objectForKey("current_page") as? Int)!
                AlertUser.last_page = (deserializedResponse.objectForKey("last_page") as? Int)!
                AlertUser.next_page_url = (deserializedResponse.objectForKey("next_page_url") as? String)!
                
//                AlertUser.prev_page_url = (deserializedResponse.objectForKey("prev_page_url") as? String)!
                
                AlertUser.from = (deserializedResponse.objectForKey("from") as? Int)!
                AlertUser.to = (deserializedResponse.objectForKey("to") as? Int)!
                
                
                
                
                if let  dataList = deserializedResponse.objectForKey("data") as? [NSDictionary]{
                    
                    for dict in dataList{
                        
                        let datavalue = dataModel()
                        
                        datavalue.id =   (dict.objectForKey("id") as? Int)!
                        
                        datavalue.action =   (dict.objectForKey("action") as? String)!
                        
                        datavalue.created_at =   (dict.objectForKey("created_at") as? String)!

                        if let innerDict = dict.objectForKey("action_by"){
                            
                            let action_bydatavalue = commonModel()
                            action_bydatavalue.id =   (innerDict.objectForKey("id") as? Int)!
                            
                            if (innerDict.objectForKey("name") as? String) != nil {
                                action_bydatavalue.name =   (innerDict.objectForKey("name") as? String)!
                            }
                            
//
                            action_bydatavalue.mobile_number =   (innerDict.objectForKey("mobile_number") as? String)!
                        
                            action_bydatavalue.photo =   (innerDict.objectForKey("photo") as? String)!
//

                        
                            datavalue.action_by = action_bydatavalue
                            
                            
                            
                            print(innerDict)
                            
                            
                            
                        }
                        
                        if let postDict = dict.objectForKey("post"){
                            
                            let postdatavalue = postModel()
                            postdatavalue.id =   (postDict.objectForKey("id") as? Int)!
                            
                            postdatavalue.action =   (postDict.objectForKey("action") as? String)!
                            
                            postdatavalue.action_val =   (postDict.objectForKey("action_val") as? String)!
                            
//                            postdatavalue.review =   (postDict.objectForKey("review") as? String)!

//                            postdatavalue.recent_action =   (postDict.objectForKey("recent_action") as? String)!
                            
                            postdatavalue.created_at =   (postDict.objectForKey("created_at") as? String)!
                           
                            
                           if let performedDict = postDict.objectForKey("performed"){
                                
                                let performedatavalue = commonModel()
                                performedatavalue.id =   (performedDict.objectForKey("id") as? Int)!
                            
                            if (performedDict.objectForKey("name") as? String) != nil{
                                performedatavalue.name =   (performedDict.objectForKey("name") as? String)!
                            }
                                performedatavalue.mobile_number =   (performedDict.objectForKey("mobile_number") as? String)!
    
                                performedatavalue.photo =   (performedDict.objectForKey("photo") as? String)!
                            
                                
                                 postdatavalue.performed = performedatavalue
                                 print(performedDict)
                            }
                           
                           /*
//                            postdatavalue.effected =   (postDict.objectForKey("effected") as? String)!
                            
                            
                            
                            if let  likesList = postDict.objectForKey("likes_count") as? [NSDictionary]{
                                
                                for dict in likesList{
                                    
                                    let LikeDislikevalue = AlertCountCommonModel()
                                    
                                    LikeDislikevalue.post_id =   (dict.objectForKey("post_id") as? String)!
                                    
//                                    LikeDislikevalue.likeDislikecount =   (dict.objectForKey("dislikes") as? String)!
                                    
                                    
                                    postdatavalue.likes_count.append(LikeDislikevalue)
                                }
                                
                                
                                print(likesList)
                            }
                            
                            if let  dislikesList = postDict.objectForKey("dislikes_count") as? [NSDictionary]{
                                
                                for dict in dislikesList {
                                    
                                    let LikeDislikevalue = AlertCountCommonModel()
                                    
                                    LikeDislikevalue.post_id =   (dict.objectForKey("post_id") as? String)!
                                    LikeDislikevalue.likeDislikecount =   (dict.objectForKey("dislikes") as? String)!
                                    
                                    
                                    postdatavalue.dislikes_count.append(LikeDislikevalue)
                                }
                                print(dislikesList)
                            }
                            
                            
                            
                            if let  likesUserList = postDict.objectForKey("likes_user") as? [NSDictionary]{
                                
                                for dict in likesUserList{
                                    
                                    let likesUserdatavalue = commonModel()
                                    likesUserdatavalue.id =   (dict.objectForKey("id") as? Int)!
//                                    likesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
//                                    likesUserdatavalue.email =   (dict.objectForKey("email") as? String)!
                                    likesUserdatavalue.mobile_number =   (dict.objectForKey("mobile_number") as? String)!
                                    likesUserdatavalue.app_user_token =   (dict.objectForKey("app_user_token") as? String)!
                                    likesUserdatavalue.created_at =   (dict.objectForKey("created_at") as? String)!
                                    likesUserdatavalue.updated_at =   (dict.objectForKey("updated_at") as? String)!
//                                    likesUserdatavalue.dob =   (dict.objectForKey("dob") as? String)!
//                                    likesUserdatavalue.address =   (dict.objectForKey("address") as? String)!
//                                    likesUserdatavalue.website =   (dict.objectForKey("website") as? String)!
                                    likesUserdatavalue.photo =   (dict.objectForKey("photo") as? String)!
//                                    likesUserdatavalue.status =   (dict.objectForKey("status") as? String)!
//                                    likesUserdatavalue.gcm_token =   (dict.objectForKey("gcm_token") as? String)!
//                                    likesUserdatavalue.last_online_time =   (dict.objectForKey("last_online_time") as? String)!
                                    
                                    print(likesUserdatavalue)
                                    
                                    postdatavalue.likes_user.append(likesUserdatavalue)
                                }
                            }
                            
                            
                            if let  dislikesUserList = postDict.objectForKey("dislikes_user") as? [NSDictionary]{
                                
                                for dict in dislikesUserList{
                                    
                                    let dislikesUserdatavalue = commonModel()
                                    dislikesUserdatavalue.id =   (dict.objectForKey("id") as? Int)!
//                                    dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
//                                    dislikesUserdatavalue.email =   (dict.objectForKey("email") as? String)!
                                    dislikesUserdatavalue.mobile_number =   (dict.objectForKey("mobile_number") as? String)!
                                    dislikesUserdatavalue.app_user_token =   (dict.objectForKey("app_user_token") as? String)!
                                    dislikesUserdatavalue.created_at =   (dict.objectForKey("created_at") as? String)!
                                    dislikesUserdatavalue.updated_at =   (dict.objectForKey("updated_at") as? String)!
//                                    dislikesUserdatavalue.dob =   (dict.objectForKey("dob") as? String)!
//                                    dislikesUserdatavalue.address =   (dict.objectForKey("address") as? String)!
//                                    dislikesUserdatavalue.website =   (dict.objectForKey("website") as? String)!
                                    dislikesUserdatavalue.photo =   (dict.objectForKey("photo") as? String)!
//                                    dislikesUserdatavalue.status =   (dict.objectForKey("status") as? String)!
//                                    dislikesUserdatavalue.gcm_token =   (dict.objectForKey("gcm_token") as? String)!
//                                    dislikesUserdatavalue.last_online_time =   (dict.objectForKey("last_online_time") as? String)!
                                    
                                    
                                    postdatavalue.dislikes_user.append(dislikesUserdatavalue)
                                
                                }
                                
                                print(dislikesUserList)
                            }
                             */
                            
                            datavalue.post = postdatavalue
                        }
                        
                        AlertUser.data.append(datavalue)
                    }
                }
                
                
                
                
            }
            
            
            print(AlertUser)
            
            
            onFinish(response: response, deserializedResponse: AlertUser)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    //MARK:// GRET OTP
    func getOTPValidateForMobileNumber(mobileNumber:String, otp:String,  onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.getOTPValidateForMobileNumber(mobileNumber, otp: otp, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    //UPDATE PROFILE
    func updateProfile(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.updateProfile(dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    // SYNC CONTACT TO SERVER
    func syncContactToTheServer(dict:[String:String],postDict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.syncContactToTheServer(dict, postDict:postDict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }

    }
    
    //CONTACT
    func searchContact(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:[SearchPerson], errorMessage:String?)->(), onError:(error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.searchContact(dict, onFinish: { (response, deserializedResponse) in
            
            var personArray:[SearchPerson] = [SearchPerson]()
            var errorMessage:String?
            if deserializedResponse is NSDictionary
            {
                if deserializedResponse.objectForKey("error") != nil
                {
                    errorMessage = deserializedResponse.objectForKey("error") as?String
                }
                
                
                if deserializedResponse.objectForKey(search_mobile) != nil
                {
                    
                    let responseDictionary = deserializedResponse.objectForKey(search_mobile) as? NSDictionary
                    if let dataArray = responseDictionary?.objectForKey("data") as? [NSDictionary]
                    {
                    for dict in dataArray
                    {
                        
                        let person:SearchPerson = SearchPerson()
                        if let name = dict.objectForKey("name") as? String
                        {
                            
                            person.name = name
                        }
                        
                        if let id = dict["id"] as? Int
                        {
                             person.idString = id
                        }
                       
                        person.mobileNumber = (dict.objectForKey("mobile_number") as? String)!
                        
                        
                         //person.ratingAverage = (dict.objectForKey("rating_average") as? [AnyObject])!
                        // person.reviewCount = (dict.objectForKey("review_count") as? [AnyObject])!
                        
                        if let  ratingAverage = deserializedResponse.objectForKey("ratingAverage") as? [NSDictionary]
                        {
                            for dict in ratingAverage
                            {
                                let average = RatingAverage()
                                average.average =   (dict.objectForKey("average") as? String)!
                                person.ratingAverage.append(average)
                                
                            }
                            
                        }
                        
                        if let  reviewCount = deserializedResponse.objectForKey("reviewCount") as? [NSDictionary]
                        {
                            for dict in reviewCount
                            {
                                let count = ReviewCount()
                                count.count =   (dict.objectForKey("count") as? String)!
                                person.reviewCount.append(count)
                                
                            }
                            
                        }

                        
                        
                        personArray.append(person)
                        
                    }
                    }
                    
                }
            }
            
            onFinish(response: response, deserializedResponse: personArray, errorMessage:errorMessage )
            
            
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    //MARK: CHAT LIST
    
    func getChatList(onFinish:(response:AnyObject,deserializedResponse:[ChatPerson])->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getChatList({ (response, deserializedResponse) in
            
            var dataArray = [ChatPerson]()
            if  deserializedResponse is [NSDictionary]
            {
                let arraydata = deserializedResponse as! [NSDictionary]
                for dict in arraydata
                {
                    let chatPerson = ChatPerson()
                    
                    chatPerson.idString = dict.objectForKey("id") as! Int
                    
                    if let name = dict.objectForKey("name") as? String
                    {
                        chatPerson.name = name
                    }
                    if let photo = dict.objectForKey("photo") as? String
                    {
                        chatPerson.photo = photo
                    }
                    
                    if let lastMessage = dict.objectForKey("last_message") as? String
                    {
                    
                        chatPerson.last_message = lastMessage
                    }
                    
                    if let lastMessageTime = dict.objectForKey("last_message_time") as? String
                    {
                        chatPerson.last_message_time = lastMessageTime
                    }
                    
                    if let unreadMessage = dict.objectForKey("last_message_time") as? Int
                    {
                        chatPerson.unread_message = unreadMessage
                    }
                    dataArray.append(chatPerson)
                }
                
            }
            onFinish(response: response, deserializedResponse: dataArray)
            
          }) { (error) in
            
            onError(error: error)
                
        }
    }
    
    func addRateReview(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        //by_user_id
        //for_user_id
        //review
        //rate
        
        let dataSession = DataSession()
        dataSession.addRateReview(dict, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                 onError(error: error)
        }
        
    }
    
    func getContactReviewList(dict:[String:String], onFinish:(response:AnyObject,reviewUser:ReviewUser)->(), onError:(error:AnyObject)->())
    {
         // GET
        /// for_user_id
        
        
    let dataSession = DataSession()
        dataSession.getContactReviewList(dict, onFinish: { (response, deserializedResponse) in
            let reviewUser:ReviewUser = ReviewUser()
            if deserializedResponse is NSDictionary
            {
                if let  review_user = deserializedResponse.objectForKey("review_user") as? [NSDictionary]
                {
                    if let name = review_user.first!.objectForKey("name") as? String
                    {
                        reviewUser.reviewPerson.name = name
                    }
                    
                }
                
                
                if let  rateReviewList = deserializedResponse.objectForKey("rateReviewList") as? [NSDictionary]
                {
                    
                    
                    for dict in rateReviewList
                    {
                        
                        let rateReviewr = RateReviewer()
                        rateReviewr.rate =   (dict.objectForKey("rate") as? String)!
                        rateReviewr.review =  (dict.objectForKey("review") as? String)!
                        rateReviewr.created_at =  (dict.objectForKey("created_at") as? String)!
                        
                        if let appuserDict =  dict.objectForKey("app_user") as? NSDictionary
                        {
                            
                            rateReviewr.appUser.idInt =   (appuserDict.objectForKey("id") as? Int)!
//                            rateReviewr.appUser.name =      (appuserDict.objectForKey("name") as? String)!
                            if let email = appuserDict.objectForKey("email") as? String
                            {
                                rateReviewr.appUser.email = email
                                
                            }
                            
                            if let mobile = appuserDict.objectForKey("mobile_number") as? String
                            {
                                rateReviewr.appUser.mobileNumber = mobile
                            }
                            
                            if let createdAt = appuserDict.objectForKey("created_at") as? String
                            {
                                rateReviewr.appUser.createdAt = createdAt
                            }
                            
                            if let updatedAt = appuserDict.objectForKey("updated_at") as? String
                            {
                                rateReviewr.appUser.updatedAt = updatedAt
                            }
                            if let dob = appuserDict.objectForKey("dob") as? String
                            {
                                rateReviewr.appUser.dob = dob
                            }
                            
                            if let address = appuserDict.objectForKey("address") as? String
                            {
                                rateReviewr.appUser.address = address
                            }
                            if let website = appuserDict.objectForKey("website") as? String
                            {
                                rateReviewr.appUser.website = website
                            }
                            if let photo = appuserDict.objectForKey("photo") as? String
                            {
                                rateReviewr.appUser.photo = photo
                            }
                            if let gcmToken = appuserDict.objectForKey("gcm_token") as? String
                            {
                                rateReviewr.appUser.gcmToken = gcmToken
                            }
                            
                            if let lastOnlineTime = appuserDict.objectForKey("last_online_time") as? String
                            {
                                rateReviewr.appUser.lastOnlineTime = lastOnlineTime
                            }
                            
                            
                            }
                        
                        reviewUser.rateReviewList.append(rateReviewr)
                        
                        
                    }
                    
                }
                
                if let  ratingAverage = deserializedResponse.objectForKey("ratingAverage") as? [NSDictionary]
                {
                    for dict in ratingAverage
                    {
                        let average = RatingAverage()
                        average.average =   (dict.objectForKey("average") as? String)!
                        reviewUser.ratingAverageArray.append(average)
                        
                    }
                    
                }
                
                if let  reviewCount = deserializedResponse.objectForKey("reviewCount") as? [NSDictionary]
                {
                    for dict in reviewCount
                    {
                        let count = ReviewCount()
                        count.count =   (dict.objectForKey("count") as? String)!
                        reviewUser.reviewCountArray.append(count)
                        
                    }
                    
                }
                
                if let  rateGraph = deserializedResponse.objectForKey("rateGraph") as? [NSDictionary]
                {
                    for dict in rateGraph
                    {
                        let ratGraph   = RateGraph()
                        ratGraph.rate  =   (dict.objectForKey("rate") as? String)!
                        ratGraph.count =   (dict.objectForKey("count") as? String)!
                        reviewUser.rateGraphArray.append(ratGraph)
                    }
                }
            }
            
            onFinish(response: response, reviewUser: reviewUser)
            
            
            }) { (error) in
                
                onError(error: error)
        }
       
    }
    
    func getChatConversionForContactID(dict:[String:String], onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        
        
    }
    
    
    func sendTextMessage(recipient_id:String, message:String,  onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
         let dataSession = DataSession()
        dataSession.sendTextMessage(recipient_id, message: message, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    
    
    func getContactListForPage(/*page:String,*/ onFinish:(response:AnyObject,contactPerson:ContactPerson)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getContactListForPage(/*page,*/ { (response, deserializedResponse) in
            
            let conatactPerson = ContactPerson()
            let  data = deserializedResponse as! NSArray
            /*
            if deserializedResponse is NSDictionary
            {*/
                /*
                if let  next_page_url = deserializedResponse.objectForKey("next_page_url") as? String
                {
                    conatactPerson.next_page_url = next_page_url
                    
                }
                conatactPerson.current_page = (deserializedResponse.objectForKey("current_page") as? Int)!
                conatactPerson.total = (deserializedResponse.objectForKey("total") as? Int)!
                conatactPerson.last_page = (deserializedResponse.objectForKey("last_page") as? Int)!*/
                
                if data is NSArray
                {
                    
                    for dict in data
                    {
                        
                        let searchPerson = SearchPerson()
                        
                        if let _ = dict.objectForKey("id") as? Int
                        {
                             searchPerson.idString = (dict.objectForKey("id") as? Int)!
                            
                        }
                        if let  idString = dict.objectForKey("id") as? String
                        {
                            searchPerson.idString =  Int(idString)!
                            
                        }
                        
                       
                        if let name = dict.objectForKey("name") as? String
                        {
                            searchPerson.name   = name
                        }
                        
                        searchPerson.email = dict.objectForKey("email") as? String
                        if let mobileNumber = dict.objectForKey("mobile_number") as? String
                        {
                            searchPerson.mobileNumber = mobileNumber
                        }
                        
                        searchPerson.app_user_token = dict.objectForKey("app_user_token") as? String
                         searchPerson.created_at = dict.objectForKey("created_at") as? String
                         searchPerson.updated_at = dict.objectForKey("updated_at") as? String
                         searchPerson.dob = dict.objectForKey("dob") as? String
                         searchPerson.address = dict.objectForKey("address") as? String
                         searchPerson.website = dict.objectForKey("website") as? String
                         searchPerson.photo = dict.objectForKey("photo") as? String
                         searchPerson.gcm_token = dict.objectForKey("gcm_token") as? String
                         searchPerson.last_online_time = dict.objectForKey("last_online_time") as? String
                        /*
                        if let ratingAverage =  dict.objectForKey("rating_average") as? [AnyObject]
                        {
                            searchPerson.ratingAverage = ratingAverage
                        }
                        
                        if let reviewcount = dict.objectForKey("review_count") as? [AnyObject]
                        {
                            searchPerson.reviewCount = reviewcount
                        }*/
                        
                        if let  ratingAverage = dict.objectForKey("rating_average") as? [NSDictionary]
                        {
                            for dict in ratingAverage
                            {
                                let average = RatingAverage()
                                if let avg = dict.objectForKey("average") as? String
                                {
                                    average.average =   avg
                                }
                                searchPerson.ratingAverage.append(average)
                                
                            }
                            
                        }
                        
                        if let  reviewCount = dict.objectForKey("review_count") as? [NSDictionary]
                        {
                            for dict in reviewCount
                            {
                                let count = ReviewCount()
                                count.count =   (dict.objectForKey("count") as? String)!
                                searchPerson.reviewCount.append(count)
                                
                            }
                            
                        }
                        conatactPerson.data.append(searchPerson)
                         
                    }
                    
                }
                
            //}*/
            onFinish(response: response, contactPerson: conatactPerson)
            
            }) { (error) in
                onError(error: error)
        }
        
        
    }
    
    
     //MARK: Get conversation
    func getChatConversationForID(contactID:String, page: String, onFinish:(response:AnyObject,chatConversation:ChatConversation)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getChatConversationForID(contactID, page: page, onFinish: { (response, deserializedResponse) in
            
            let chatConversation = ChatConversation()
            if deserializedResponse is NSDictionary
            {
                
                chatConversation.total = (deserializedResponse.objectForKey("total") as? Int)!
                chatConversation.per_page =  (deserializedResponse.objectForKey("per_page") as? Int)!
                chatConversation.current_page =    (deserializedResponse.objectForKey("current_page") as? Int)!
                chatConversation.last_page =  (deserializedResponse.objectForKey("last_page") as? Int)!
                
                
                if let data = deserializedResponse.objectForKey("data") as? NSArray
                {
                   for dict in data
                    {
                        let chattDetail = ChatDetail()
                         chattDetail.id = (dict.objectForKey("id") as? Int)!
                        
                        if let  senderId =   dict.objectForKey("sender_id") as? String
                        {
                           chattDetail.sender_id = senderId
                        }
                        if let recipient_id = dict.objectForKey("recipient_id") as? String
                        {
                            chattDetail.recipient_id = recipient_id
                        }
                        if let message_type =  dict.objectForKey("message_type") as? String
                        {
                            chattDetail.message_type = message_type
                        }
                        
                        if let text =
                            dict.objectForKey("text") as? String
                        {
                            chattDetail.text = text
                        }
                        
                        if let  image = dict.objectForKey("image") as? String
                        {
                            chattDetail.image = image
                        }
                        
                        if let  video = dict.objectForKey("video") as? String
                        {
                            chattDetail.video = video
                        }
                        
                        if let message_read =
                            dict.objectForKey("message_read") as? String
                        {
                            chattDetail.message_read = message_read
                        }
                        if let received_at =
                            dict.objectForKey("received_at") as? String
                        {
                            chattDetail.received_at =  received_at
                            
                        }
                        
                        if let created_at =
                            dict.objectForKey("created_at") as? String
                        {
                           chattDetail.created_at = created_at
                        }
                        
                        if let updated_at =
                            dict.objectForKey("updated_at") as? String
                        {
                            chattDetail.updated_at = updated_at
                        }
                        if let conversation_id =
                            dict.objectForKey("conversation_id") as? String
                        {
                            chattDetail.conversation_id = conversation_id
                        }
                        
                        chatConversation.data.append(chattDetail)
                        
                    }
                }
                
            }
            onFinish(response: response, chatConversation: chatConversation)
            
            
            
            }) { (error) in
                onError(error: error)
        }
        
    
    }
    
    //MARK: BLOCK
    func blockUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        let dataSession = DataSession()
        dataSession.blockUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
            }) { (error) in
                onError(error: error)
        }
        
    }
    
    func unblockUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.unblockUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    
    
    
    func getSearchPersonArray(deserializedResponse:NSArray)->[SearchPerson]
    {
        var lBlockUserArray = [SearchPerson]()
        
        if  deserializedResponse.isKindOfClass(NSArray)
        {
            
            for i in 0..<deserializedResponse.count
            {
                let lBlockUser = SearchPerson()
                let dict = deserializedResponse[i]
                if let _ = dict.objectForKey("id") as? Int
                {
                    lBlockUser.idString = (dict.objectForKey("id") as? Int)!
                }
                if let name = dict.objectForKey("name") as? String
                {
                    lBlockUser.name   = name
                }
                
                if let _ = dict.objectForKey("email") as? String
                {
                    
                    lBlockUser.email = (dict.objectForKey("email") as? String)!
                }
                if let mobileNumber = dict.objectForKey("mobile_number") as? String
                {
                    lBlockUser.mobileNumber = mobileNumber
                }
                
                lBlockUser.app_user_token = dict.objectForKey("app_user_token") as? String
                lBlockUser.created_at = dict.objectForKey("created_at") as? String
                lBlockUser.updated_at = dict.objectForKey("updated_at") as? String
                lBlockUser.dob = dict.objectForKey("dob") as? String
                lBlockUser.address = dict.objectForKey("address") as? String
                lBlockUser.website = dict.objectForKey("website") as? String
                lBlockUser.photo = dict.objectForKey("photo") as? String
                lBlockUser.gcm_token = dict.objectForKey("gcm_token") as? String
                lBlockUser.last_online_time = dict.objectForKey("last_online_time") as? String
                
                lBlockUserArray.append(lBlockUser)
                
            }
        }
        
        return lBlockUserArray
        
    }
    
    
    
    
    func getBlockUserList(onFinish:(response:AnyObject, blockUserArray:[SearchPerson])->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getBlockUsersList({ (response, deserializedResponse) in
            
            var lBlockUserArray = [SearchPerson]()
            
            if  deserializedResponse.isKindOfClass(NSArray)
            {
                
                for i in 0..<deserializedResponse.count
                {
                    let lBlockUser = SearchPerson()
                    let dict = deserializedResponse.objectAtIndex(i)
                    if let _ = dict.objectForKey("id") as? Int
                    {
                        lBlockUser.idString = (dict.objectForKey("id") as? Int)!
                    }
                    if let name = dict.objectForKey("name") as? String
                    {
                        lBlockUser.name   = name
                    }
                    
                    if let _ = dict.objectForKey("email") as? String
                    {
                    
                        lBlockUser.email = (dict.objectForKey("email") as? String)!
                    }
                    if let mobileNumber = dict.objectForKey("mobile_number") as? String
                    {
                        lBlockUser.mobileNumber = mobileNumber
                    }
                    
                    lBlockUser.app_user_token = dict.objectForKey("app_user_token") as? String
                    lBlockUser.created_at = dict.objectForKey("created_at") as? String
                    lBlockUser.updated_at = dict.objectForKey("updated_at") as? String
                    lBlockUser.dob = dict.objectForKey("dob") as? String
                    lBlockUser.address = dict.objectForKey("address") as? String
                    lBlockUser.website = dict.objectForKey("website") as? String
                    lBlockUser.photo = dict.objectForKey("photo") as? String
                    lBlockUser.gcm_token = dict.objectForKey("gcm_token") as? String
                    lBlockUser.last_online_time = dict.objectForKey("last_online_time") as? String
                    
                   lBlockUserArray.append(lBlockUser)
                    
                }
            }
            
             onFinish(response: response, blockUserArray: lBlockUserArray)
            
            }) { (error) in
            onError(error: error)
        }
        
        
        
        
        
        

    }
    //MARK: SPAM
    func spamUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.spamUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
     }
    
    //MARK: SPAM
    func unspamUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.unspamUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
    }
    
    func getUserSpamList(onFinish:(response:AnyObject,spamUserArray:[SearchPerson])->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getUserSpamList({ (response, deserializedResponse) in
            var lBlockUserArray = [SearchPerson]()
            lBlockUserArray =   self.getSearchPersonArray(deserializedResponse as! NSArray)
            onFinish(response: response, spamUserArray: lBlockUserArray)
            }) { (error) in
                onError(error: error)

        }

    }

    
    //MARK:FAVOURITE
    func favouriteUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.favouriteUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }

        
    }
    
    //MARK:FAVOURITE
    func unfavouriteUserID(userID:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.unfavouriteUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response: response, deserializedResponse: deserializedResponse)
        }) { (error) in
            onError(error: error)
        }
        
    }
    
    
    func getUserfavoriteList(onFinish:(response:AnyObject,favUserArray:[SearchPerson])->(), onError:(error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getUserfavoriteList({ (response, deserializedResponse) in
            var lBlockUserArray = [SearchPerson]()
            lBlockUserArray =   self.getSearchPersonArray(deserializedResponse as! NSArray)
            onFinish(response: response, favUserArray: lBlockUserArray)
            }) { (error) in
                onError(error: error)

        }
        
    }
    
    
    func updateStatus()
    {
    }
    
}

extension NSObject
{
    //MARK: get up user Token
    class func getAppUserIdAndToken()->[String:String]
    {
         let appUserId = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_id) as! Int
         let appUserToken = NSUserDefaults.standardUserDefaults().objectForKey(kapp_user_token) as! String
         return [kapp_user_id:String(appUserId), kapp_user_token :appUserToken]
    }
    
    class func resetAppUserIdAndToken()
    {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: kapp_user_id)
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: kapp_user_token)
        
    }
}

class ReviewPerson:NSObject
{
    var name = String()
}


class RateReviewer:NSObject
{
    var rate       = String()
    var review     = String()
    var created_at = String()
    var appUser:AppUser = AppUser()
    var likes_count =  [AnyObject]()
    var user_like = [AnyObject]()
    var dislikes_count = [AnyObject]()
    var user_dislike = [AnyObject]()
}


class AppUser:NSObject
{
    var idInt:Int = 12
    var name : String = String()
    var email : String = String()
    var mobileNumber: String = String()
    var createdAt: String = String()
    var updatedAt : String = String()
    var dob : String = String()
    var address: String = String()
    var website : String = String()
    var photo :String = String()
    var gcmToken : String = String()
    var lastOnlineTime : String = String()
}

class BlockUser:AppUser
{
    var ratingAverageArray = [RatingAverage]()
    var reviewCountArray   = [ReviewCount]()
}

class ReviewCount:NSObject
{
    var count = String()
}

class RatingAverage:NSObject
{
    var average:String = String()
}

class RateGraph:NSObject
{
    var rate  = String()
    var count = String()
}

class ReviewUser:NSObject
{
    var reviewPerson       =  ReviewPerson()/// dict 1
    var rateReviewList     = [RateReviewer]()
    var ratingAverageArray = [RatingAverage]()
    var reviewCountArray   = [ReviewCount]()
    var rateGraphArray     = [RateGraph]()
}


// Mohit


class commonModel:NSObject
{
    var id:Int = 12
    var name : String = String()
    var email : String = String()
    var mobile_number: String = String()
    var app_user_token: String = String()
    var created_at : String = String()
    var updated_at : String = String()
    var dob: String = String()
    var address : String = String()
    var website :String = String()
    var photo : String = String()
    var status : String = String()
    var gcm_token : String = String()
    var last_online_time : String = String()
}


class AlertCountCommonModel:NSObject
{
    var post_id = String()
    var likeDislikecount = String()
}


class postModel: NSObject {
    
    var id:Int = 12
    var action     = String()
    var action_val     = String()
    var review     = String()
    var recent_action     = String()
    var created_at     = String()
    var performed     = commonModel()
    var effected     = String()
    var likes_count     = [AlertCountCommonModel]()
    var dislikes_count     = [AlertCountCommonModel]()
    var likes_user     = [commonModel]()
    var dislikes_user     = [commonModel]()
    
}


class dataModel: NSObject {
    
    var id:Int = 12
    var action     = String()
    var created_at     = String()
    var action_by     = commonModel()
    var post     = postModel()
    
}


class AlertModel: NSObject {
    
    var total:Int = 12
    var per_page:Int = 12
    var current_page:Int = 12
    var last_page:Int = 12
    var next_page_url     = String()
    var prev_page_url     = String()
    var from:Int = 12
    var to:Int = 12
    var data = [dataModel]()
    
}



// Feed & MyFeed Model

class FeedMyfeed: NSObject {
    
    var total:Int = 12
    var per_page:Int = 12
    var current_page:Int = 12
    var last_page:Int = 12
    var next_page_url     = String()
    var prev_page_url     = String()
    var from:Int = 12
    var to:Int = 12
    var data = [dataFeedMyfeedModel]()
}


class dataFeedMyfeedModel: NSObject {
    
    var id:Int = 12
    var action     = String()
    var action_val     = String()
    var review     = String()
    var recent_action     = String()
    var created_at     = String()
    var performed     = commonModel()
    var effected      =  commonModel()
    var likes_count     = AlertCountCommonModel()
    var dislikes_count     = AlertCountCommonModel()
    var likes_user     = commonModel()
    var dislikes_user     = commonModel()
    
}
