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
    func  getAlertCount(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.alert_count, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
    }
    
    
    
    //MARK: get post Detail
    func getPostDetail(_ post_id:String, alert_id:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        let dict = NSObject.getAppUserIdAndToken()
        var paramaDict = dict
        paramaDict["post_id"] = post_id
        paramaDict["alert_id"] = alert_id
        
        super.getWithOnFinish(mCHWebServiceMethod.post_detail, parameters: paramaDict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)

            
        }) { (error) in
            
            onError(error)
        }
    }
    
    
    // Mohit
    /*******************  Feed Screen ********************/
    //MARK: GET Feeds
    func getFeedsData(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()) {
        
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_feed_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    /*******************  MYFeed Screen ********************/
    //MARK: GET MYFeeds
    func getMyFeedsData(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()) {
        
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_myfeed_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    /*******************  Alert Screen ********************/
    //MARK: GET Alert
    func getAlertData(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()) {
        
        let dict = NSObject.getAppUserIdAndToken()
        
        super.getWithOnFinish(mCHWebServiceMethod.user_alerts_list, parameters: dict, onFinish: {(response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            
        }) {(error) in
            onError(error)
        }
        
    }
    
    
    
    
    /*******************  FEED Screen ********************/
    //MARK: Feed Like
    func feedLike(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.like_user, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
    }
    
    /*******************  Feed Screen ********************/
    //MARK: Feed Dislike
    func feedisLike(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.dislike_user, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
    }
    
    
    
    /*******************  Alert Screen ********************/
    //MARK: Report To Spam
    func reportTospam(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.user_report_spam_state, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
    }
    
    
    
    
    
    /*******************  LOGIN SCREEN ********************/
   //MARK: GET OTP
    func getOTPForMobileNumber(_ mobileNumber:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()) {
        
        let dict = ["mobile_number":mobileNumber]
        super.getWithOnFinish(mCHWebServiceMethod.add_app_user, parameters: dict, onFinish: { (response, deserializedResponse) in
            
               onFinish(response, deserializedResponse)
            
            }) { (error) in
                onError(error)
        }
        
    }
    
    /*******************  OTP SCREEN ********************/
    //MARK: GET OTP VALIDATION
    func getOTPValidateForMobileNumber(_ mobileNumber:String, otp:String,  onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = ["mobile_number":mobileNumber, "otp":otp]
        super.getWithOnFinish(mCHWebServiceMethod.match_otp, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    /*******************  SIGN UP ********************/
    //MARK: UPDATE PROFILE
    func updateProfile(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.update_profile, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
    }
    /*******************  SEARCH CONTACT ********************/
    
    //MARK:SEARCH CONTACT
    func searchContact(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        super.postDataWithOnFinish(mCHWebServiceMethod.search_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    /******************* PROFILE SCREEN ********************/
    
    //MARK: GET USER PROFILE DATA
    func getProfileData(_ contact_id:String?, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        if let _ = contact_id
        {
            dict["contact_id"] = contact_id
        }
        super.getWithOnFinish(mCHWebServiceMethod.app_user_profile, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
        
    }
    
    //MARK: POST PROFILE IMAGE
    
    func postProfileImage(_ mediaPath:[String]?, name:[String]?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        /*
         super.postSBMediaWithOnFinish(mCHWebServiceMethod.image_upload, headerParam: dict, mediaPaths: mediaPath, bodyDict: nil, name: name, onFinish: { (response, deserializedResponse) in
         onFinish(response, deserializedResponse)
         }) { (error) in
         onError(error)
         }*/
        
        super.postMediaWithOnFinish(mCHWebServiceMethod.image_upload, headerParam: dict, mediaPaths: mediaPath, bodyDict: nil, name: "photo", onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
    }
    
    
    
    //MARK: SYNC CONTACT
    func syncContactToTheServer(_ dict:[String:String], postDict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        super.postDataWithOnFinish(mCHWebServiceMethod.add_contact_list, parameters: dict as Dictionary<String, AnyObject>, postBody: postDict as Dictionary<String, AnyObject>, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
    }
    
    
    func getContactListForPage(/*page:String,*/ _ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
         let dict = NSObject.getAppUserIdAndToken()
         //dict["page"] = page
         super.getWithOnFinish(mCHWebServiceMethod.user_contact_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    
    
    //MARK: CHAT LIST
    func getChatList(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.chat_contact_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    //MARK: Get conversation
    func getChatConversationForID(_ contactID:String, page: String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var  dict = NSObject.getAppUserIdAndToken()
        dict["contact_id"] = contactID
        dict["page"] = page
        
        super.getWithOnFinish(mCHWebServiceMethod.chat_conversation, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    //MARK: ADD REVIEW LIST
    func addRateReview(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        super.postDataWithOnFinish(mCHWebServiceMethod.add_rate_review, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    //MARK: CONTACT LIST REVIEW
    func getContactReviewList(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        super.getWithOnFinish(mCHWebServiceMethod.contact_review_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    
    //MARK: CHAT CONVERSATION
    
    func getChatConversionForContactID(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        super.getWithOnFinish(mCHWebServiceMethod.chat_conversation, parameters: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }


    }
    
    // MARK: TEXT MESSAGE
    func sendTextMessage(_ recipient_id:String, message:String,  onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
         var  paramdict = NSObject.getAppUserIdAndToken()
         paramdict["recipient_id"] = recipient_id
         paramdict["message_type"] = "text"
        
         let  postDict = ["text":message]
        
        super.postDataWithOnFinish(mCHWebServiceMethod.send_message, parameters: paramdict as Dictionary<String, AnyObject>, postBody: postDict as Dictionary<String, AnyObject>, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)

            }) { (error) in
                onError(error)
        }
        
       
    }
    
    
    func sendVideoORImageMessage(_ recipentID:String, message_type: String, mediaPath:[String]?, name:[String]?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        var dict = NSObject.getAppUserIdAndToken()
        dict["recipient_id"] = recipentID
        dict["message_type"] = message_type
    
        super.postMediaWithOnFinish(mCHWebServiceMethod.send_message, headerParam: dict, mediaPaths: mediaPath, bodyDict: nil, name: message_type, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    func likeUserID(_ ratereviews_id:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["ratereviews_id"] = ratereviews_id
        super.getWithOnFinish(mCHWebServiceMethod.like_review, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    func dislikeUserID(_ ratereviews_id:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["ratereviews_id"] = ratereviews_id
        super.getWithOnFinish(mCHWebServiceMethod.dislike_review, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    //MARK: block user id
    
    func blockUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        
        dict["block_user_id"] = String(appUserId)
        dict ["for_user_id"]  = userID
        
        super.postDataWithOnFinish(mCHWebServiceMethod.block_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)

            }) { (error) in
                onError(error)

        }
        
    }
    
    func unblockUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        dict["block_user_id"] = String(appUserId)
        dict ["for_user_id"]  = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.unblock_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            
        }) { (error) in
            onError(error)
            
        }
        
    }

    
    
    func getBlockUsersList(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_block_list, parameters: dict, onFinish: { (response, deserializedResponse) in
             onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    
    //MARK SPAM
    func spamUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        //dict.removeValueForKey(kapp_user_id)
        let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        
        dict["by_user_id"] = String(appUserId)
        dict["spam_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.spam_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            
        }) { (error) in
            onError(error)
            
        }
        
    }
    
    //MARK SPAM
    func unspamUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
         let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
        dict["by_user_id"] = String(appUserId)
        dict["spam_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.unspam_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            
        }) { (error) in
            onError(error)
            
        }
        
    }
    
    func getUserSpamList(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_spam_list, parameters: dict, onFinish: { (response, deserializedResponse) in
        onFinish(response, deserializedResponse)
        }) { (error) in
        onError(error)
        }
        
    }

    
    
    //MARK:FAVOURITE
    func favouriteUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["fav_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.favourite_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            
        }) { (error) in
            onError(error)
            
        }
    }

    func unfavouriteUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        var dict = NSObject.getAppUserIdAndToken()
        dict["fav_user_id"] = userID
        super.postDataWithOnFinish(mCHWebServiceMethod.unfavourite_mobile_number, parameters: dict as Dictionary<String, AnyObject>, postBody: nil, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            
        }) { (error) in
            onError(error)
            
        }
        
    }
    
    func getUserfavoriteList(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dict = NSObject.getAppUserIdAndToken()
        super.getWithOnFinish(mCHWebServiceMethod.user_favourite_list, parameters: dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    
    
    
}

class DataSessionManger: NSObject
{
    static let sharedInstance = DataSessionManger()
    
    
    func downloadImageWithURL(_ urlString:String, downloadedImageData:@escaping (_ imageData:Data?, _ message:String)->())
    {
        let dataSession = DataSession()
        dataSession.downloadImageWithURL(urlString ) { (imageData, message) in
            downloadedImageData(imageData, message)
            dataSession.mNSURLSession.invalidateAndCancel()
        }
        
    }
    
    
    func sendVideoORImageMessage(_ recipentID:String, message_type: String, mediaPath:[String]?, name:[String]?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
         let dataSession = DataSession()
        dataSession.sendVideoORImageMessage(recipentID, message_type: message_type, mediaPath: mediaPath, name: name, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                 onError(error)
        }
    }
    
    
    func  getAlertCount(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getAlertCount({ (response, deserializedResponse) in
            onFinish(response, deserializedResponse)

            }) { (error) in
                onError(error)
        }
    }
    
    
    
    func dislikeUserID(_ ratereviews_id:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.dislikeUserID(ratereviews_id, onFinish: { (response, deserializedResponse) in
             onFinish(response, deserializedResponse)
            }) { (error) in
                 onError(error)
        }
        
        
    }
    
    
    
    func likeUserID(_ ratereviews_id:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.likeUserID(ratereviews_id, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)

            }) { (error) in
                onError(error)
        }
        
        
    }
    
    func postProfileImage(_ mediaPath:[String]?, name:[String]?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.postProfileImage(mediaPath, name: name, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    func getProfileData(_ contact_id:String?, onFinish:@escaping (_ response:AnyObject,_ personalProfile:SearchPerson)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.getProfileData(contact_id, onFinish: { (response, deserializedResponse) in
            let personalProfileData = SearchPerson()
            if deserializedResponse is NSDictionary
            {
                if let arrayDict = deserializedResponse.object(forKey: user_profile) as? [NSDictionary]
                {
                    
                    
                    let dataDict = arrayDict.first
                    
                    if let _ = dataDict?.object(forKey: "id") as? Int
                    {
                        personalProfileData.idString = (dataDict?.object(forKey: "id") as? Int)!
                    }
                    if let  name = dataDict?.object(forKey: name) as? String
                    {
                        personalProfileData.name = name
                    }
                    
                    if let _ = dataDict?.object(forKey: email)
                    {
                        personalProfileData.email = (dataDict?.object(forKey: email))! as? String
                    }
                    
                    if let _ = dataDict?.object(forKey: mobile_number) as? String
                    {
                        personalProfileData.mobileNumber = (dataDict?.object(forKey: mobile_number) as? String!)!
                    }
                    
                    if let createdAt = dataDict?.object(forKey: created_at) as? String
                    {
                        personalProfileData.created_at = createdAt
                    }
                   
                     
                    personalProfileData.updated_at = dataDict?.object(forKey: updated_at) as? String
                    personalProfileData.address = dataDict?.object(forKey: address) as? String
                    personalProfileData.website = dataDict?.object(forKey: website) as? String
                    personalProfileData.birthday = dataDict?.object(forKey: "dob") as? String
                    personalProfileData.gender = dataDict?.object(forKey: "gender") as? String
                    personalProfileData.status = dataDict?.object(forKey: "status") as? String
                    if let _ = dataDict?.object(forKey: photo) as? String
                    {
                        personalProfileData.photo = dataDict?.object(forKey: photo) as? String
                    }
                    
                    if let _ = dataDict?.object(forKey: gcm_token) as? String
                    {
                    
                        personalProfileData.gcm_token = (dataDict?.object(forKey: gcm_token) as? String)!
                    }
                    
                    
                    if let lastonlineTime = dataDict?.object(forKey: last_online_time) as? String
                    {
                         personalProfileData.last_online_time = lastonlineTime
                        
                    }
                    
                    
                    if let  ratingAverage = dataDict?.object(forKey: "rating_average") as? [NSDictionary]
                    {
                        for dict in ratingAverage
                        {
                            let average = RatingAverage()
                            if let avg = dict.object(forKey: "average") as? String
                            {
                                average.average =   avg
                            }
                            personalProfileData.ratingAverage.append(average)
                            
                        }
                        
                    }
                    
                    if let  reviewCount = dataDict?.object(forKey: "review_count") as? [NSDictionary]
                    {
                        for dict in reviewCount
                        {
                            let count = ReviewCount()
                            count.count =   String(dict.object(forKey: "count") as! Int)
                            personalProfileData.reviewCount.append(count)
                            
                        }
                    }
                }
            }
            
            onFinish(response, personalProfileData)
            
            
            }) { (error) in
                onError(error)
        }
        
    }
    
    
    
    func getOTPForMobileNumber(_ mobileNumber:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.getOTPForMobileNumber(mobileNumber, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    
    // Mohit
    
    
    
    //feed Like
    func feedLikeUser(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:dataFeedMyfeedModel)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        
        
        dataSession.feedLike(dict, onFinish: { (response, deserializedResponse) in
            let AlertUser:AlertCountCommonModel = AlertCountCommonModel()
            
            print(deserializedResponse)
           
                
                
//                AlertUser.post_id = (deserializedResponse.objectForKey("success") as? Int)!
           // AlertUser.likeDislikecount = NSNumber( ptr:(deserializedResponse.objectForKey("message") as? String)!)
                
            if let message = deserializedResponse.object(forKey: "message") as? String
            {
                if let _ = Int(message)
                {
                    AlertUser.likeDislikecount = NSNumber(value: Int(message)! as Int)
                }
            }
            
            let datavalue = dataFeedMyfeedModel()
            if let  dict = deserializedResponse.object(forKey: "post") as? NSDictionary
            {
                
                    datavalue.id =   (dict.object(forKey: "id") as? Int)!
                    
                    if let action = dict.object(forKey: "action") as? String
                    {
                        datavalue.action = action
                    }
                    
                    if dict.object(forKey: "action_val") != nil
                    {
                        
                        if let _ = dict.object(forKey: "action_val") as? String
                        {
                            datavalue.action_val = (dict.object(forKey: "action_val") as? String)!
                        }
                        
                    }
                    
                    if let review =  dict.object(forKey: "review") as? String
                    {
                        datavalue.review = review
                        
                    }
                    
                    if (dict.object(forKey: "recent_action") as? String) != nil
                    {
                        
                        datavalue.recent_action =   (dict.object(forKey: "recent_action") as? String)!
                    }
                    
                    datavalue.created_at =   (dict.object(forKey: "created_at") as? String)!
                    
                    if let innerDict = dict.object(forKey: "performed")
                    {
                        
                        let performedatavalue = SearchPerson()
                        performedatavalue.idString =   ((innerDict as AnyObject).object(forKey: "id") as? Int)!
                        
                        if (innerDict as AnyObject).object(forKey: "name") != nil
                        {
                            performedatavalue.name =   ((innerDict as AnyObject).object(forKey: "name") as? String)!
                        }
                        
                        performedatavalue.mobileNumber =  ((innerDict as AnyObject).object(forKey: "mobile_number") as? String)!
                        
                        if let photo = (innerDict as AnyObject).object(forKey: "photo") as? String
                        {
                            performedatavalue.photo =   photo
                        }
                        
                        datavalue.performed = performedatavalue
                    }
                    
                    
                    if (self.nullToNil(dict.object(forKey: "effected") as AnyObject) != nil)
                    {
                        if let effectedDict = dict.object(forKey: "effected")
                        {
                            
                            print(effectedDict)
                            print(dict.object(forKey: "effected") ?? "") 
                            let effectedatavalue = SearchPerson()
                            effectedatavalue.idString =   ((effectedDict as AnyObject).object(forKey: "id") as? Int)!
                            
                            
                            
                            if (effectedDict as AnyObject).object(forKey: "name") != nil
                            {
                                effectedatavalue.name =   ((effectedDict as AnyObject).object(forKey: "name") as? String)!
                            }
                            
                            effectedatavalue.mobileNumber =  ((effectedDict as AnyObject).object(forKey: "mobile_number") as? String)!
                            
                            if let photo = (effectedDict as AnyObject).object(forKey: "photo") as? String
                            {
                                effectedatavalue.photo =   photo
                            }
                            
                            datavalue.effected = effectedatavalue
                            
                            
                        }
                    }
                    
                    
                    if let  likesList = dict.object(forKey: "likes_count") as? [NSDictionary]
                    {
                        
                        for dict in likesList
                        {
                            
                            let LikeDislikevalue = AlertCountCommonModel()
                            if let _ = dict.object(forKey: "post_id") as? String
                            {
                                LikeDislikevalue.post_id = (dict.object(forKey: "post_id") as? NSNumber)!
                            }
                            
                            if let _ =  dict.object(forKey: "likes") as? NSNumber
                            {
                                
                                
                                LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "likes") as? NSNumber)!
                            }
                            
                            datavalue.likes_count = LikeDislikevalue
                        }
                        
                        print(likesList)
                    }
                    
                    if let  dislikesList = dict.object(forKey: "dislikes_count") as? [NSDictionary]
                    {
                        
                        for dict in dislikesList
                        {
                            
                            let LikeDislikevalue = AlertCountCommonModel()
                            
                            LikeDislikevalue.post_id =   (dict.object(forKey: "post_id") as? NSNumber)!
                            LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "dislikes") as? NSNumber)!
                            
                            datavalue.dislikes_count = LikeDislikevalue
                        }
                        print(dislikesList)
                    }
                    
                    
                    
                    if let  likesUserList = dict.object(forKey: "likes_user") as? [NSDictionary]{
                        
                        for dict in likesUserList
                        {
                            
                            let likesUserdatavalue = SearchPerson()
                            likesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                            if let name = dict.object(forKey: "name") as? String
                            {
                                likesUserdatavalue.name = name
                            }
                            likesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                            
                            if (dict.object(forKey: "photo") as? String) != nil
                            {
                                likesUserdatavalue.photo =   (dict.object(forKey: "photo") as? String)!
                            }
                            
                            datavalue.likes_user.append(likesUserdatavalue)
                        }
                    }
                    
                    
                    if let  dislikesUserList = dict.object(forKey: "dislikes_user") as? [NSDictionary]{
                        
                        for dict in dislikesUserList
                        {
                            
                            let dislikesUserdatavalue = SearchPerson()
                            dislikesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                            if let name = dict.object(forKey: "name") as? String
                            {
                                dislikesUserdatavalue.name = name
                            }
                            //                                    dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
                            //
                            dislikesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                            
                            if let photo = dict.object(forKey: "photo") as? String
                            {
                                dislikesUserdatavalue.photo =   photo
                            }
                            //
                            
                            datavalue.dislikes_user.append (dislikesUserdatavalue)
                            
                        }
                        
                        print(dislikesUserList)
                    }
                    // AlertUser.datavalue = datavalue
                
                    
                    //feedMyfeedUser.data.append(datavalue)
                
            }
            
            
            
            onFinish(response, datavalue)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    //feed DisLike
    func feedisLikeUser(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:dataFeedMyfeedModel)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.feedisLike(dict, onFinish: { (response, deserializedResponse) in
            let AlertUser:AlertCountCommonModel = AlertCountCommonModel()
            
            
            print(deserializedResponse)
            
            if let likedislikeCount = deserializedResponse.object(forKey: "message") as? String
            {
                if let _ = Int(likedislikeCount)
                {
                    AlertUser.likeDislikecount =  NSNumber(value: Int(likedislikeCount)! as Int)
                }
             }
            let datavalue = dataFeedMyfeedModel()
            if let  dict = deserializedResponse.object(forKey: "post") as? NSDictionary
            {
                
                datavalue.id =   (dict.object(forKey: "id") as? Int)!
                
                if let action = dict.object(forKey: "action") as? String
                {
                    datavalue.action = action
                }
                
                if dict.object(forKey: "action_val") != nil
                {
                    
                    if let _ = dict.object(forKey: "action_val") as? String
                    {
                        datavalue.action_val = (dict.object(forKey: "action_val") as? String)!
                    }
                    
                }
                
                if let review =  dict.object(forKey: "review") as? String
                {
                    datavalue.review = review
                    
                }
                
                if (dict.object(forKey: "recent_action") as? String) != nil
                {
                    
                    datavalue.recent_action =   (dict.object(forKey: "recent_action") as? String)!
                }
                
                datavalue.created_at =   (dict.object(forKey: "created_at") as? String)!
                
                if let innerDict = dict.object(forKey: "performed")
                {
                    
                    let performedatavalue = SearchPerson()
                    performedatavalue.idString =   ((innerDict as AnyObject).object(forKey: "id") as? Int)!
                    
                    if (innerDict as AnyObject).object(forKey: "name") != nil
                    {
                        performedatavalue.name =   ((innerDict as AnyObject).object(forKey: "name") as? String)!
                    }
                    
                    performedatavalue.mobileNumber =  ((innerDict as AnyObject).object(forKey: "mobile_number") as? String)!
                    
                    if let photo = (innerDict as AnyObject).object(forKey: "photo") as? String
                    {
                        performedatavalue.photo =   photo
                    }
                    
                    datavalue.performed = performedatavalue
                }
                
                
                if (self.nullToNil(dict.object(forKey: "effected") as AnyObject) != nil)
                {
                    if let effectedDict = dict.object(forKey: "effected")
                    {
                        
                         
                        let effectedatavalue = SearchPerson()
                        effectedatavalue.idString =   ((effectedDict as AnyObject).object(forKey: "id") as? Int)!
                        
                        
                        
                        if (effectedDict as AnyObject).object(forKey: "name") != nil
                        {
                            effectedatavalue.name =   ((effectedDict as AnyObject).object(forKey: "name") as? String)!
                        }
                        
                        effectedatavalue.mobileNumber =  ((effectedDict as AnyObject).object(forKey: "mobile_number") as? String)!
                        
                        if let photo = (effectedDict as AnyObject).object(forKey: "photo") as? String
                        {
                            effectedatavalue.photo =   photo
                        }
                        
                        datavalue.effected = effectedatavalue
                        
                        
                    }
                }
                
                
                if let  likesList = dict.object(forKey: "likes_count") as? [NSDictionary]
                {
                    
                    for dict in likesList
                    {
                        
                        let LikeDislikevalue = AlertCountCommonModel()
                        if let _ = dict.object(forKey: "post_id") as? String
                        {
                            LikeDislikevalue.post_id = (dict.object(forKey: "post_id") as? NSNumber)!
                        }
                        
                        if let _ =  dict.object(forKey: "likes") as? NSNumber
                        {
                            
                            
                            LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "likes") as? NSNumber)!
                        }
                        
                        datavalue.likes_count = LikeDislikevalue
                    }
                    
                    print(likesList)
                }
                
                if let  dislikesList = dict.object(forKey: "dislikes_count") as? [NSDictionary]
                {
                    
                    for dict in dislikesList
                    {
                        
                        let LikeDislikevalue = AlertCountCommonModel()
                        
                        LikeDislikevalue.post_id =   (dict.object(forKey: "post_id") as? NSNumber)!
                        LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "dislikes") as? NSNumber)!
                        
                        datavalue.dislikes_count = LikeDislikevalue
                    }
                    print(dislikesList)
                }
                
                
                
                if let  likesUserList = dict.object(forKey: "likes_user") as? [NSDictionary]{
                    
                    for dict in likesUserList
                    {
                        
                        let likesUserdatavalue = SearchPerson()
                        likesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                        if let name = dict.object(forKey: "name") as? String
                        {
                            likesUserdatavalue.name = name
                        }
                        likesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                        
                        if (dict.object(forKey: "photo") as? String) != nil
                        {
                            likesUserdatavalue.photo =   (dict.object(forKey: "photo") as? String)!
                        }
                        
                        datavalue.likes_user.append(likesUserdatavalue)
                    }
                }
                
                
                if let  dislikesUserList = dict.object(forKey: "dislikes_user") as? [NSDictionary]{
                    
                    for dict in dislikesUserList
                    {
                        
                        let dislikesUserdatavalue = SearchPerson()
                        dislikesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                        if let name = dict.object(forKey: "name") as? String
                        {
                            dislikesUserdatavalue.name = name
                        }
                        //                                    dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
                        //
                        dislikesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                        
                        if let photo = dict.object(forKey: "photo") as? String
                        {
                            dislikesUserdatavalue.photo =   photo
                        }
                        //
                        
                        datavalue.dislikes_user.append (dislikesUserdatavalue)
                        
                    }
                    
                    print(dislikesUserList)
                }
               // AlertUser.datavalue = datavalue
                
                //feedMyfeedUser.data.append(datavalue)
                
            }
            

            
            
            
            onFinish(response, datavalue)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    //Report To Spam
    func reportTospamUser(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.reportTospam(dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
    }
    
    func getPostDetail(_ post_id:String, alert_id:String, onFinish:@escaping (_ response:AnyObject,_ dataFeedsArray:[dataFeedMyfeedModel])->(), onError:(_ error:AnyObject)->())
    {
        
        let dataSession = DataSession()
        dataSession.getPostDetail(post_id, alert_id: alert_id, onFinish: { (response, deserializedResponse) in
        var dataFeedsArray:[dataFeedMyfeedModel] = [dataFeedMyfeedModel]()
            if let _ = deserializedResponse as? NSArray
            {
            
            for dict in (deserializedResponse as? NSArray)!
            {
                let datavalue = dataFeedMyfeedModel()
                datavalue.id =   ((dict as AnyObject).object(forKey: "id") as? Int)!
                
                if let action = (dict as AnyObject).object(forKey: "action") as? String
                {
                    datavalue.action = action
                }
                
                if (dict as AnyObject).object(forKey: "action_val") != nil
                {
                    
                    if let _ = (dict as AnyObject).object(forKey: "action_val") as? String
                    {
                        datavalue.action_val = ((dict as AnyObject).object(forKey: "action_val") as? String)!
                    }
                    
                }
                
                if let review =  (dict as AnyObject).object(forKey: "review") as? String
                {
                    datavalue.review = review
                    
                }
                
                if ((dict as AnyObject).object(forKey: "recent_action") as? String) != nil
                {
                    
                    datavalue.recent_action =   ((dict as AnyObject).object(forKey: "recent_action") as? String)!
                }
                
                datavalue.created_at =   ((dict as AnyObject).object(forKey: "created_at") as? String)!
                
                if let innerDict = (dict as AnyObject).object(forKey: "performed")
                {
                    
                    let performedatavalue = SearchPerson()
                    performedatavalue.idString =   ((innerDict as AnyObject).object(forKey: "id") as? Int)!
                    
                    if (innerDict as AnyObject).object(forKey: "name") != nil
                    {
                        performedatavalue.name =   ((innerDict as AnyObject).object(forKey: "name") as? String)!
                    }
                    
                    performedatavalue.mobileNumber =  ((innerDict as AnyObject).object(forKey: "mobile_number") as? String)!
                    
                    if let photo = (innerDict as AnyObject).object(forKey: "photo") as? String
                    {
                        performedatavalue.photo =   photo
                    }
                    
                    datavalue.performed = performedatavalue
                }
                
                
                if (self.nullToNil((dict as! NSDictionary).object(forKey: "effected") as AnyObject) != nil)
                {
                    if let effectedDict = (dict as AnyObject).object(forKey: "effected")
                    {
                        
                        print(effectedDict)
                       // print((dict as AnyObject).object(forKey: "effected") ?? <#default value#>)
                        let effectedatavalue = SearchPerson()
                        effectedatavalue.idString  =   ((effectedDict as AnyObject).object(forKey: "id") as? Int)!
                        
                        
                        
                        if (effectedDict as AnyObject).object(forKey: "name") != nil
                        {
                            effectedatavalue.name =   ((effectedDict as AnyObject).object(forKey: "name") as? String)!
                        }
                        
                        effectedatavalue.mobileNumber =  ((effectedDict as AnyObject).object(forKey: "mobile_number") as? String)!
                        
                        if let photo = (effectedDict as AnyObject).object(forKey: "photo") as? String
                        {
                            effectedatavalue.photo =   photo
                        }
                        
                        datavalue.effected = effectedatavalue
                        
                        
                    }
                }
                
                
                if let  likesList = (dict as AnyObject).object(forKey: "likes_count") as? [NSDictionary]
                {
                    
                    for dict in likesList
                    {
                        
                        let LikeDislikevalue = AlertCountCommonModel()
                        if let _ = dict.object(forKey: "post_id") as? String
                        {
                            LikeDislikevalue.post_id = (dict.object(forKey: "post_id") as? NSNumber)!
                        }
                        
                        if let _ =  dict.object(forKey: "likes") as? NSNumber
                        {
                            
                            
                            LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "likes") as? NSNumber)!
                        }
                        
                        datavalue.likes_count = LikeDislikevalue
                    }
                    
                    print(likesList)
                }
                
                if let  dislikesList = (dict as AnyObject).object(forKey: "dislikes_count") as? [NSDictionary]
                {
                    
                    for dict in dislikesList
                    {
                        
                        let LikeDislikevalue = AlertCountCommonModel()
                        
                        LikeDislikevalue.post_id =   (dict.object(forKey: "post_id") as? NSNumber)!
                        LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "dislikes") as? NSNumber)!
                        
                        datavalue.dislikes_count = LikeDislikevalue
                    }
                    print(dislikesList)
                }
                
                
                
                if let  likesUserList = (dict as AnyObject).object(forKey: "likes_user") as? [NSDictionary]{
                    
                    for dict in likesUserList
                    {
                        
                        let likesUserdatavalue = SearchPerson()
                        likesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                        if let name = dict.object(forKey: "name") as? String
                        {
                            likesUserdatavalue.name = name
                        }
                        likesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                        
                        if (dict.object(forKey: "photo") as? String) != nil
                        {
                            likesUserdatavalue.photo =   (dict.object(forKey: "photo") as? String)!
                        }
                        
                        datavalue.likes_user.append(likesUserdatavalue)
                    }
                }
                
                
                if let  dislikesUserList = (dict as AnyObject).object(forKey: "dislikes_user") as? [NSDictionary]{
                    
                    for dict in dislikesUserList
                    {
                        
                        let dislikesUserdatavalue = SearchPerson()
                        dislikesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                        if let name = dict.object(forKey: "name") as? String
                        {
                            dislikesUserdatavalue.name = name
                        }
                        //                                    dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
                        //
                        dislikesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                        
                        if let photo = dict.object(forKey: "photo") as? String
                        {
                            dislikesUserdatavalue.photo =   photo
                        }
                        //
                        
                        datavalue.dislikes_user.append (dislikesUserdatavalue)
                        
                    }
                    
                    print(dislikesUserList)
                }
                // AlertUser.datavalue = datavalue
                
                
                //feedMyfeedUser.data.append(datavalue)
                dataFeedsArray.append(datavalue)
                
            }
            }
            
            
            onFinish(response, dataFeedsArray)
            
            
            
            }) { (error) in
                
        }
    }
    
    
    
    
    
     //Feedslist
    func getfeedslist(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:FeedMyfeed)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        dataSession.getFeedsData({ (response, deserializedResponse) in
            
            let feedMyfeedUser:FeedMyfeed = FeedMyfeed()
            if deserializedResponse is NSDictionary
            {
                
                feedMyfeedUser.total = (deserializedResponse.object(forKey: "total") as? Int)!
                feedMyfeedUser.per_page = (deserializedResponse.object(forKey: "per_page") as? Int)!
                feedMyfeedUser.current_page = (deserializedResponse.object(forKey: "current_page") as? Int)!
                feedMyfeedUser.last_page = (deserializedResponse.object(forKey: "last_page") as? Int)!
                
                
                if let next_page_url = deserializedResponse.object(forKey: "next_page_url") as? String
                {
                    feedMyfeedUser.next_page_url = next_page_url
                }
                
                if let prev_page_url = deserializedResponse.object(forKey: "prev_page_url") as? String
                {
                    feedMyfeedUser.prev_page_url = prev_page_url
                }
                
                feedMyfeedUser.from = (deserializedResponse.object(forKey: "from") as? Int)!
                feedMyfeedUser.to = (deserializedResponse.object(forKey: "to") as? Int)!
                
                if let  dataList = deserializedResponse.object(forKey: "data") as? [NSDictionary]
                {
                    
                    for dict in dataList
                    {
                        
                        let datavalue = dataFeedMyfeedModel()
                        datavalue.id =   (dict.object(forKey: "id") as? Int)!
                        datavalue.action =   (dict.object(forKey: "action") as? String)!
                        if let review = dict.object(forKey: "review") as? String
                        {
                            datavalue.review = review
                        }
                        
                        if let action = dict.object(forKey: "action") as? String
                        {
                            datavalue.action = action
                        }
                        
                        if dict.object(forKey: "action_val") != nil
                        {
                            
                            if let _ = dict.object(forKey: "action_val") as? String
                            {
                                datavalue.action_val = (dict.object(forKey: "action_val") as? String)!
                            }
                            
                        }

                        
                        if let recent_action = dict.object(forKey: "recent_action") as? String
                        {
                            datavalue.recent_action =  recent_action
                        }
                        
                        if let created_at = dict.object(forKey: "created_at") as? String
                        {
                            datavalue.created_at =   created_at
                        }
                        
                        
                        
                        if let innerDict = dict.object(forKey: "performed")
                        {
                            
                            let performedatavalue = SearchPerson()
                            performedatavalue.idString =   ((innerDict as AnyObject).object(forKey: "id") as? Int)!
                            
                            if let  name = (innerDict as AnyObject).object(forKey: "name") as? String
                            {
                                performedatavalue.name = name
                            }
                           
                            
                            if let photo = (innerDict as AnyObject).object(forKey: "photo") as? String
                            {
                                performedatavalue.photo =   photo
                            }
                            
                            if let mobileNumber = (innerDict as AnyObject).object(forKey: "mobile_number") as? String
                            {
                                performedatavalue.mobileNumber =   mobileNumber
                            }
                           
                            
                            print(innerDict)
                            
                            datavalue.performed = performedatavalue
                            
                        }
                        
                        
                        
                        if (self.nullToNil(dict.object(forKey: "effected") as AnyObject) != nil)
                        {
                            if let effectedDict = dict.object(forKey: "effected")
                            {
                                
                                print(effectedDict)
                                print(dict.object(forKey: "effected"))
                                let effectedatavalue = SearchPerson()
                                effectedatavalue.idString =   ((effectedDict as AnyObject).object(forKey: "id") as? Int)!
                                
                                
                                
                                if (effectedDict as AnyObject).object(forKey: "name") != nil
                                {
                                    effectedatavalue.name =   ((effectedDict as AnyObject).object(forKey: "name") as? String)!
                                }
                                
                                effectedatavalue.mobileNumber =  ((effectedDict as AnyObject).object(forKey: "mobile_number") as? String)!
                                
                                if let photo = (effectedDict as AnyObject).object(forKey: "photo") as? String
                                {
                                    effectedatavalue.photo =   photo
                                }
                                
                                datavalue.effected = effectedatavalue
                                
                                
                            }
                        }

                        
//                        datavalue.effected =   (dict.objectForKey("effected") as? String)!
                        
                        
                        
                        if let  likesList = dict.object(forKey: "likes_count") as? [NSDictionary]
                        {
                            
                            for dict in likesList
                            {
                                
                                let LikeDislikevalue = AlertCountCommonModel()
                                if let _ = dict.object(forKey: "post_id") as? String
                                {
                                    LikeDislikevalue.post_id = (dict.object(forKey: "post_id") as? NSNumber)!
                                }
                                
                                if let _ =  dict.object(forKey: "likes") as? NSNumber
                                {
                                    LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "likes") as? NSNumber)!
                                }
                                
                                datavalue.likes_count = LikeDislikevalue
                            }
                            
                            print(likesList)
                        }
                        
                        if let  dislikesList = dict.object(forKey: "dislikes_count") as? [NSDictionary]{
                            
                            for dict in dislikesList
                            {
                                
                                let LikeDislikevalue = AlertCountCommonModel()
                                
                                LikeDislikevalue.post_id =   (dict.object(forKey: "post_id") as? NSNumber)!
                                LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "dislikes") as? NSNumber)!
                                
                                datavalue.dislikes_count = LikeDislikevalue
                            }
                            print(dislikesList)
                        }
                        
                        
                        
                        if let  likesUserList = dict.object(forKey: "likes_user") as? [NSDictionary]{
                            
                            for dict in likesUserList
                            {
                                
                                let likesUserdatavalue = SearchPerson()
                                likesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                                if let _ = dict.object(forKey: "name") as? String
                                {
                                    likesUserdatavalue.name =   (dict.object(forKey: "name") as? String)!
                                }
                                likesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                                
                                if let photo = dict.object(forKey: "photo") as? String
                                {
                                    likesUserdatavalue.photo =   photo
                                }
                                datavalue.likes_user.append(likesUserdatavalue)
                                
                            }
                        }
                        
                        
                        if let  dislikesUserList = dict.object(forKey: "dislikes_user") as? [NSDictionary]{
                            
                            for dict in dislikesUserList{
                                
                                let dislikesUserdatavalue = SearchPerson()
                                dislikesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                                if let name = dict.object(forKey: "name") as? String
                                {
                                    dislikesUserdatavalue.name =   name
                                }
                               
                                dislikesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                             
                                dislikesUserdatavalue.photo =   (dict.object(forKey: "photo") as? String)!
                                datavalue.dislikes_user.append(dislikesUserdatavalue)
                            }
                            
                            print(dislikesUserList)
                            
                            
                            
                        }
                        feedMyfeedUser.data.append(datavalue)
                    }
                }
                
                
                
                
            }
            
            
            
            onFinish(response, feedMyfeedUser)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    //MYFeedslist
    func getMyfeedslist(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:FeedMyfeed)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        let dataSession = DataSession()
        dataSession.getMyFeedsData({ (response, deserializedResponse) in
            let feedMyfeedUser:FeedMyfeed = FeedMyfeed()
            
            if deserializedResponse is NSDictionary
            {
                
                feedMyfeedUser.total = (deserializedResponse.object(forKey: "total") as? Int)!
                feedMyfeedUser.per_page = (deserializedResponse.object(forKey: "per_page") as? Int)!
                feedMyfeedUser.current_page = (deserializedResponse.object(forKey: "current_page") as? Int)!
                feedMyfeedUser.last_page = (deserializedResponse.object(forKey: "last_page") as? Int)!
                
                if let next_page_url = deserializedResponse.object(forKey: "next_page_url") as? String
                {
                    feedMyfeedUser.next_page_url = next_page_url
                }
                if let prev_page_url = deserializedResponse.object(forKey: "prev_page_url") as? String
                {
                
                        feedMyfeedUser.prev_page_url = prev_page_url
                }
                
                
                feedMyfeedUser.from = (deserializedResponse.object(forKey: "from") as? Int)!
                feedMyfeedUser.to = (deserializedResponse.object(forKey: "to") as? Int)!
                if let  dataList = deserializedResponse.object(forKey: "data") as? [NSDictionary]
                {
                    for dict in dataList
                    {
                        let datavalue = dataFeedMyfeedModel()
                        datavalue.id =   (dict.object(forKey: "id") as? Int)!
                        
                        if let action = dict.object(forKey: "action") as? String
                        {
                            datavalue.action = action
                        }
                        
                        if dict.object(forKey: "action_val") != nil
                        {
                            
                            if let _ = dict.object(forKey: "action_val") as? String
                            {
                                datavalue.action_val = (dict.object(forKey: "action_val") as? String)!
                            }
                            
                        }
                        
                        if let review =  dict.object(forKey: "review") as? String
                        {
                            datavalue.review = review
                        
                         }
                        
                        if (dict.object(forKey: "recent_action") as? String) != nil
                        {
                        
                            datavalue.recent_action =   (dict.object(forKey: "recent_action") as? String)!
                        }
                        
                        datavalue.created_at =   (dict.object(forKey: "created_at") as? String)!
                        
                        if let innerDict = dict.object(forKey: "performed")
                        {
                            
                            let performedatavalue = SearchPerson()
                            performedatavalue.idString =   ((innerDict as AnyObject).object(forKey: "id") as? Int)!
                            
                            if (innerDict as AnyObject).object(forKey: "name") != nil
                            {
                                performedatavalue.name =   ((innerDict as AnyObject).object(forKey: "name") as? String)!
                            }
                 
                            performedatavalue.mobileNumber =  ((innerDict as AnyObject).object(forKey: "mobile_number") as? String)!
                 
                            if let photo = (innerDict as AnyObject).object(forKey: "photo") as? String
                            {
                                performedatavalue.photo =   photo
                            }
                 
                            datavalue.performed = performedatavalue
                        }

                        
                        if (self.nullToNil(dict.object(forKey: "effected") as AnyObject) != nil)
                        {
                            if let effectedDict = dict.object(forKey: "effected")
                              {
                            
                                 print(effectedDict)
                                    print(dict.object(forKey: "effected"))
                                    let effectedatavalue = SearchPerson()
                                effectedatavalue.idString =   ((effectedDict as AnyObject).object(forKey: "id") as? Int)!
                                
                                
                                
                                if (effectedDict as AnyObject).object(forKey: "name") != nil
                                {
                                    effectedatavalue.name =   ((effectedDict as AnyObject).object(forKey: "name") as? String)!
                                }
                                
                                effectedatavalue.mobileNumber =  ((effectedDict as AnyObject).object(forKey: "mobile_number") as? String)!
                                
                                if let photo = (effectedDict as AnyObject).object(forKey: "photo") as? String
                                {
                                    effectedatavalue.photo =   photo
                                }

                                datavalue.effected = effectedatavalue
                                
                            
                            }
                        }
                            
                        
                            if let  likesList = dict.object(forKey: "likes_count") as? [NSDictionary]
                            {
                                
                                for dict in likesList
                                {
                                    
                                    let LikeDislikevalue = AlertCountCommonModel()
                                    if let _ = dict.object(forKey: "post_id") as? String
                                    {
                                            LikeDislikevalue.post_id = (dict.object(forKey: "post_id") as? NSNumber)!
                                    }
                                    
                                    if let _ =  dict.object(forKey: "likes") as? NSNumber
                                    {
                                    
                                    
                                        LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "likes") as? NSNumber)!
                                    }
                                    
                                    datavalue.likes_count = LikeDislikevalue
                                }
                                
                                print(likesList)
                            }
                            
                            if let  dislikesList = dict.object(forKey: "dislikes_count") as? [NSDictionary]
                            {
                                
                                for dict in dislikesList
                                {
                                    
                                    let LikeDislikevalue = AlertCountCommonModel()
                                    
                                    LikeDislikevalue.post_id =   (dict.object(forKey: "post_id") as? NSNumber)!
                                    LikeDislikevalue.likeDislikecount =   (dict.object(forKey: "dislikes") as? NSNumber)!
                                    
                                    datavalue.dislikes_count = LikeDislikevalue
                                }
                                print(dislikesList)
                            }
                            
                            
                            
                            if let  likesUserList = dict.object(forKey: "likes_user") as? [NSDictionary]{
                                
                                for dict in likesUserList
                                {
                                    
                                    let likesUserdatavalue = SearchPerson()
                                    likesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                                    if let name = dict.object(forKey: "name") as? String
                                    {
                                        likesUserdatavalue.name = name
                                    }
                                    likesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
                
                                    if (dict.object(forKey: "photo") as? String) != nil
                                    {
                                       likesUserdatavalue.photo =   (dict.object(forKey: "photo") as? String)!
                                    }
                 
                                    datavalue.likes_user.append(likesUserdatavalue)
                                }
                            }
                            
                            
                            if let  dislikesUserList = dict.object(forKey: "dislikes_user") as? [NSDictionary]{
                                
                                for dict in dislikesUserList
                                {
                                    
                                    let dislikesUserdatavalue = SearchPerson()
                                    dislikesUserdatavalue.idString =   (dict.object(forKey: "id") as? Int)!
                                    if let name = dict.object(forKey: "name") as? String
                                    {
                                        dislikesUserdatavalue.name = name
                                    }
//                                    dislikesUserdatavalue.name =   (dict.objectForKey("name") as? String)!
//
                                    dislikesUserdatavalue.mobileNumber =   (dict.object(forKey: "mobile_number") as? String)!
        
                                    if let photo = dict.object(forKey: "photo") as? String
                                    {
                                        dislikesUserdatavalue.photo =   photo
                                    }
//
                                    
                                    datavalue.dislikes_user.append (dislikesUserdatavalue)

                                }
                                
                                print(dislikesUserList)
                            }
                        
                            feedMyfeedUser.data.append(datavalue)
                        }
                    }
                

            }
            

            onFinish(response,  feedMyfeedUser)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    
    func nullToNil(_ value : AnyObject?) -> AnyObject?
    {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    
    
    
    
    
    //Alertlist
    func getAlertlist(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AlertModel)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        
        dataSession.getAlertData({(response, deserializedResponse) in
            
            let AlertUser:AlertModel = AlertModel()
            
            print(deserializedResponse)
            
            if deserializedResponse is NSDictionary
            {
                
                if let _ = deserializedResponse.object(forKey: "total") as? Int
                {
                    AlertUser.total = (deserializedResponse.object(forKey: "total") as? Int)!
                }
                
                if let _ = deserializedResponse.object(forKey: "per_page") as? Int
                {
                    AlertUser.per_page = (deserializedResponse.object(forKey: "per_page") as? Int)!
                }
                
                if let _ = deserializedResponse.object(forKey: "current_page") as? Int
                {
                    AlertUser.current_page = (deserializedResponse.object(forKey: "current_page") as? Int)!
                }
                
                if let _ = deserializedResponse.object(forKey: "last_page") as? Int
                {
                    AlertUser.last_page = (deserializedResponse.object(forKey: "last_page") as? Int)!
                }
                
                if let _ = deserializedResponse.object(forKey: "next_page_url") as? String
                {
                    AlertUser.next_page_url = (deserializedResponse.object(forKey: "next_page_url") as? String)!
                }
                
                if let _ = deserializedResponse.object(forKey: "prev_page_url") as? String
                {
                
                    AlertUser.prev_page_url = (deserializedResponse.object(forKey: "prev_page_url") as? String)!
                }
                
                
                
                
                
                if let _ = deserializedResponse.object(forKey: "from") as? Int
                {
                    AlertUser.from = (deserializedResponse.object(forKey: "from") as? Int)!
                }
                
                if let _ = deserializedResponse.object(forKey: "to") as? Int
                {
                    AlertUser.to = (deserializedResponse.object(forKey: "to") as? Int)!
                }
                
                if let  dataList = deserializedResponse.object(forKey: "data") as? [NSDictionary]
                {
                    
                    for dict in dataList
                    {
                        
                        let datavalue = dataModel()
                        
                        datavalue.id =   (dict.object(forKey: "id") as? Int)!
                        
                        datavalue.action =   (dict.object(forKey: "action") as? String)!
                        
                        if let _ = dict.object(forKey: "created_at") as? String
                        {
                            datavalue.created_at =   (dict.object(forKey: "created_at") as? String)!
                        }

                        if let innerDict = dict.object(forKey: "action_by")
                        {
                            
                            let action_bydatavalue = commonModel()
                            action_bydatavalue.id =   ((innerDict as AnyObject).object(forKey: "id") as? Int)!
                            
                            if ((innerDict as AnyObject).object(forKey: "name") as? String) != nil
                            {
                                action_bydatavalue.name =   ((innerDict as AnyObject).object(forKey: "name") as? String)!
                            }
                            
//
                            action_bydatavalue.mobile_number =   ((innerDict as AnyObject).object(forKey: "mobile_number") as? String)!
                        
                            if let _ = (innerDict as AnyObject).object(forKey: "photo") as? String
                            {
                                action_bydatavalue.photo =   ((innerDict as AnyObject).object(forKey: "photo") as? String)!
                            }
//

                        
                            datavalue.action_by = action_bydatavalue
                            
                        }
                        
                        if let postDict = dict.object(forKey: "post")
                        {
                            
                            let postdatavalue = postModel()
                            postdatavalue.id =   ((postDict as AnyObject).object(forKey: "id") as? Int)!
                            
                            postdatavalue.action =   ((postDict as AnyObject).object(forKey: "action") as? String)!
                            
                            if let _ = (postDict as AnyObject).object(forKey: "action_val") as? String
                            {
                                postdatavalue.action_val =   ((postDict as AnyObject).object(forKey: "action_val") as? String)!
                            }
                            if let _ = (postDict as AnyObject).object(forKey: "review") as? String
                            {
                                postdatavalue.review =   ((postDict as AnyObject).object(forKey: "review") as? String)!
                            }
                            if let _ = (postDict as AnyObject).object(forKey: "recent_action") as? String
                            {
                                postdatavalue.recent_action =   ((postDict as AnyObject).object(forKey: "recent_action") as? String)!
                            }
                            
                            postdatavalue.created_at =   ((postDict as AnyObject).object(forKey: "created_at") as? String)!
                           
                            
                           if let performedDict = (postDict as AnyObject).object(forKey: "performed")
                           {
                                
                                let performedatavalue = commonModel()
                                performedatavalue.id =   ((performedDict as AnyObject).object(forKey: "id") as? Int)!
                            
                            if ((performedDict as AnyObject).object(forKey: "name") as? String) != nil
                            {
                                performedatavalue.name =   ((performedDict as AnyObject).object(forKey: "name") as? String)!
                            }
                                performedatavalue.mobile_number =   ((performedDict as AnyObject).object(forKey: "mobile_number") as? String)!
    
                                performedatavalue.photo =   ((performedDict as AnyObject).object(forKey: "photo") as? String)!
                            
                                
                                 postdatavalue.performed = performedatavalue
                                 print(performedDict)
                            }
                            
                            
                            
                            
                            if (self.nullToNil(dict.object(forKey: "effected") as AnyObject) != nil)
                            {
                                if let effectedDict = dict.object(forKey: "effected")
                                {
                                    
                                    print(effectedDict)
                                    print(dict.object(forKey: "effected"))
                                    let effectedatavalue = commonModel()
                                    effectedatavalue.id =   ((effectedDict as AnyObject).object(forKey: "id") as? Int)!
                                    
                                    
                                    
                                    if (effectedDict as AnyObject).object(forKey: "name") != nil
                                    {
                                        effectedatavalue.name =   ((effectedDict as AnyObject).object(forKey: "name") as? String)!
                                    }
                                    
                                    effectedatavalue.mobile_number =  ((effectedDict as AnyObject).object(forKey: "mobile_number") as? String)!
                                    
                                    if let photo = (effectedDict as AnyObject).object(forKey: "photo") as? String
                                    {
                                        effectedatavalue.photo =   photo
                                    }
                                    
                                    postdatavalue.effected = effectedatavalue
                                    
                                    
                                }
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
            
            
            onFinish(response, AlertUser)
        }) { (error) in
            onError(error)
        }
        
    }
    
    
    //MARK:// GRET OTP
    func getOTPValidateForMobileNumber(_ mobileNumber:String, otp:String,  onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.getOTPValidateForMobileNumber(mobileNumber, otp: otp, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    //UPDATE PROFILE
    func updateProfile(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.updateProfile(dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    // SYNC CONTACT TO SERVER
    func syncContactToTheServer(_ dict:[String:String],postDict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.syncContactToTheServer(dict, postDict:postDict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }

    }
    
    //CONTACT
    func searchContact(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:[SearchPerson], _ errorMessage:String?)->(), onError:@escaping (_ error:AnyObject)->()){
        
        let dataSession = DataSession()
        dataSession.searchContact(dict, onFinish: { (response, deserializedResponse) in
            
            var personArray:[SearchPerson] = [SearchPerson]()
            var errorMessage:String?
            if deserializedResponse is NSDictionary
            {
                if deserializedResponse.object(forKey: "error") != nil
                {
                    errorMessage = deserializedResponse.object(forKey: "error") as?String
                }
                
                
                if deserializedResponse.object(forKey: search_mobile) != nil
                {
                    
                    let responseDictionary = deserializedResponse.object(forKey: search_mobile) as? NSDictionary
                    if let dataArray = responseDictionary?.object(forKey: "data") as? [NSDictionary]
                    {
                    for dataDict in dataArray
                    {
                        let personalProfileData = SearchPerson()
                        
                        
                        
                        if let _ = dataDict.object(forKey: "id") as? Int
                        {
                            personalProfileData.idString = (dataDict.object(forKey: "id") as? Int)!
                        }
                        if let  name = dataDict.object(forKey: name) as? String
                        {
                            personalProfileData.name = name
                        }
                        
                        if let _ = dataDict.object(forKey: email)
                        {
                            personalProfileData.email = (dataDict.object(forKey: email))! as? String
                        }
                        
                        if let _ = dataDict.object(forKey: mobile_number) as? String
                        {
                            personalProfileData.mobileNumber = (dataDict.object(forKey: mobile_number) as? String!)!
                        }
                        
                        if let createdAt = dataDict.object(forKey: created_at) as? String
                        {
                            personalProfileData.created_at = createdAt
                        }
                        
                        
                        personalProfileData.updated_at = dataDict.object(forKey: updated_at) as? String
                        personalProfileData.address = dataDict.object(forKey: address) as? String
                        personalProfileData.website = dataDict.object(forKey: website) as? String
                        personalProfileData.birthday = dataDict.object(forKey: "dob") as? String
                        personalProfileData.gender = dataDict.object(forKey: "gender") as? String
                        personalProfileData.status = dataDict.object(forKey: "status") as? String
                        if let _ = dataDict.object(forKey: photo) as? String
                        {
                            personalProfileData.photo = dataDict.object(forKey: photo) as? String
                        }
                        
                        if let _ = dataDict.object(forKey: gcm_token) as? String
                        {
                            
                            personalProfileData.gcm_token = (dataDict.object(forKey: gcm_token) as? String)!
                        }
                        
                        
                        if let lastonlineTime = dataDict.object(forKey: last_online_time) as? String
                        {
                            personalProfileData.last_online_time = lastonlineTime
                            
                        }
                        
                        
                        if let  ratingAverage = dataDict.object(forKey: "rating_average") as? [NSDictionary]
                        {
                            for dict in ratingAverage
                            {
                                let average = RatingAverage()
                                if let avg = dict.object(forKey: "average") as? String
                                {
                                    average.average =   avg
                                }
                                personalProfileData.ratingAverage.append(average)
                                
                            }
                            
                        }
                        
                        if let  reviewCount = dataDict.object(forKey: "review_count") as? [NSDictionary]
                        {
                            for dict in reviewCount
                            {
                                let count = ReviewCount()
                                count.count =   String(dict.object(forKey: "count") as! Int)
                                personalProfileData.reviewCount.append(count)
                                
                            }
                        }
                        personArray.append(personalProfileData)
                        
                    }
                }
            }
        }
            
            onFinish(response, personArray, errorMessage )
            
            
            }) { (error) in
                onError(error)
        }
        
    }
    
    //MARK: CHAT LIST
    
    func getChatList(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:[ChatPerson])->(), onError:@escaping (_ error:AnyObject)->())
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
                    
                    chatPerson.idString = dict.object(forKey: "id") as! Int
                    
                    if let name = dict.object(forKey: "name") as? String
                    {
                        chatPerson.name = name
                    }
                    if let photo = dict.object(forKey: "photo") as? String
                    {
                        chatPerson.photo = photo
                    }
                    
                    if let lastMessage = dict.object(forKey: "last_message") as? String
                    {
                    
                        chatPerson.last_message = lastMessage
                    }
                    
                    if let lastMessageTime = dict.object(forKey: "last_message_time") as? String
                    {
                        chatPerson.last_message_time = lastMessageTime
                    }
                    
                    if let unreadMessage = dict.object(forKey: "last_message_time") as? Int
                    {
                        chatPerson.unread_message = unreadMessage
                    }
                    dataArray.append(chatPerson)
                }
                
            }
            onFinish(response, dataArray)
            
          }) { (error) in
            
            onError(error)
                
        }
    }
    
    func addRateReview(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        //by_user_id
        //for_user_id
        //review
        //rate
        
        let dataSession = DataSession()
        dataSession.addRateReview(dict, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                 onError(error)
        }
        
    }
    
    func getContactReviewList(_ dict:[String:String], onFinish:@escaping (_ response:AnyObject,_ reviewUser:ReviewUser)->(), onError:@escaping (_ error:AnyObject)->())
    {
         // GET
        /// for_user_id
        
        
    let dataSession = DataSession()
        dataSession.getContactReviewList(dict, onFinish: { (response, deserializedResponse) in
            let reviewUser:ReviewUser = ReviewUser()
            if deserializedResponse is NSDictionary
            {
                if let  review_user = deserializedResponse.object(forKey: "review_user") as? [NSDictionary]
                {
                    if let name = review_user.first!.object(forKey: "name") as? String
                    {
                        reviewUser.reviewPerson.name = name
                    }
                    
                }
                
                
                if let  rateReviewList = deserializedResponse.object(forKey: "rateReviewList") as? [NSDictionary]
                {
                    
                    
                    for dict in rateReviewList
                    {
                        
                        let rateReviewr = RateReviewer()
                        rateReviewr.rate =   (dict.object(forKey: "rate") as? String)!
                        
                        if let _ = dict.object(forKey: "review") as? String
                        {
                            rateReviewr.review =  (dict.object(forKey: "review") as? String)!
                        }
                        rateReviewr.created_at =  (dict.object(forKey: "created_at") as? String)!
                        
                        if let appuserDict =  dict.object(forKey: "app_user") as? NSDictionary
                        {
                            
                            rateReviewr.appUser.idInt =   (appuserDict.object(forKey: "id") as? Int)!
                            
                            if let name = appuserDict.object(forKey: "name") as? String
                            {
                                rateReviewr.appUser.name =  name
                            }
                            if let email = appuserDict.object(forKey: "email") as? String
                            {
                                rateReviewr.appUser.email = email
                                
                            }
                            
                            if let mobile = appuserDict.object(forKey: "mobile_number") as? String
                            {
                                rateReviewr.appUser.mobileNumber = mobile
                            }
                            
                            if let createdAt = appuserDict.object(forKey: "created_at") as? String
                            {
                                rateReviewr.appUser.createdAt = createdAt
                            }
                            
                            if let updatedAt = appuserDict.object(forKey: "updated_at") as? String
                            {
                                rateReviewr.appUser.updatedAt = updatedAt
                            }
                            if let dob = appuserDict.object(forKey: "dob") as? String
                            {
                                rateReviewr.appUser.dob = dob
                            }
                            
                            if let address = appuserDict.object(forKey: "address") as? String
                            {
                                rateReviewr.appUser.address = address
                            }
                            if let website = appuserDict.object(forKey: "website") as? String
                            {
                                rateReviewr.appUser.website = website
                            }
                            if let photo = appuserDict.object(forKey: "photo") as? String
                            {
                                rateReviewr.appUser.photo = photo
                            }
                            if let gcmToken = appuserDict.object(forKey: "gcm_token") as? String
                            {
                                rateReviewr.appUser.gcmToken = gcmToken
                            }
                            
                            if let lastOnlineTime = appuserDict.object(forKey: "last_online_time") as? String
                            {
                                rateReviewr.appUser.lastOnlineTime = lastOnlineTime
                            }
                            
                            
                            }
                        
                        reviewUser.rateReviewList.append(rateReviewr)
                        
                        
                    }
                    
                }
                
                if let  ratingAverage = deserializedResponse.object(forKey: "ratingAverage") as? [NSDictionary]
                {
                    for dict in ratingAverage
                    {
                        let average = RatingAverage()
                        average.average =   (dict.object(forKey: "average") as? String)!
                        reviewUser.ratingAverageArray.append(average)
                        
                    }
                    
                }
                
                if let  reviewCount = deserializedResponse.object(forKey: "reviewCount") as? [NSDictionary]
                {
                    for dict in reviewCount
                    {
                        let count = ReviewCount()
                        if let countNumber = dict.object(forKey: "count") as? NSNumber
                        {
                            
                           count.count = countNumber.stringValue
                           reviewUser.reviewCountArray.append(count)
                        }
                        
                    }
                    
                }
                
                if let  rateGraph = deserializedResponse.object(forKey: "rateGraph") as? [NSDictionary]
                {
                    for dict in rateGraph
                    {
                        let ratGraph   = RateGraph()
                        ratGraph.rate  =   (dict.object(forKey: "rate") as? String)!
                        if let countNumber = dict.object(forKey: "count") as? NSNumber
                        {
                            ratGraph.count = countNumber.stringValue
                        }
                          
                        reviewUser.rateGraphArray.append(ratGraph)
                    }
                }
            }
            
            onFinish(response, reviewUser)
            
            
            }) { (error) in
                
                onError(error)
        }
       
    }
    
    func getChatConversionForContactID(_ dict:[String:String], onFinish:(_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:(_ error:AnyObject)->())
    {
        
        
        
    }
    
    
    func sendTextMessage(_ recipient_id:String, message:String,  onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
         let dataSession = DataSession()
        dataSession.sendTextMessage(recipient_id, message: message, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    
    
    func getContactListForPage(/*page:String,*/ _ onFinish:@escaping (_ response:AnyObject,_ contactPerson:ContactPerson)->(), onError:@escaping (_ error:AnyObject)->())
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
                        
                        if let _ = (dict as AnyObject).object(forKey: "id") as? Int
                        {
                             searchPerson.idString = ((dict as AnyObject).object(forKey: "id") as? Int)!
                            
                        }
                        if let  idString = (dict as AnyObject).object(forKey: "id") as? String
                        {
                            searchPerson.idString =  Int(idString)!
                            
                        }
                        
                       
                        if let name = (dict as AnyObject).object(forKey: "name") as? String
                        {
                            searchPerson.name   = name
                        }
                        
                        searchPerson.email = (dict as AnyObject).object(forKey: "email") as? String
                        if let mobileNumber = (dict as AnyObject).object(forKey: "mobile_number") as? String
                        {
                            searchPerson.mobileNumber = mobileNumber
                        }
                        
                        searchPerson.app_user_token = (dict as AnyObject).object(forKey: "app_user_token") as? String
                         searchPerson.created_at = (dict as AnyObject).object(forKey: "created_at") as? String
                         searchPerson.updated_at = (dict as AnyObject).object(forKey: "updated_at") as? String
                         searchPerson.dob = (dict as AnyObject).object(forKey: "dob") as? String
                         searchPerson.address = (dict as AnyObject).object(forKey: "address") as? String
                         searchPerson.website = (dict as AnyObject).object(forKey: "website") as? String
                         searchPerson.photo = (dict as AnyObject).object(forKey: "photo") as? String
                         searchPerson.gcm_token = (dict as AnyObject).object(forKey: "gcm_token") as? String
                         searchPerson.last_online_time = (dict as AnyObject).object(forKey: "last_online_time") as? String
                        /*
                        if let ratingAverage =  dict.objectForKey("rating_average") as? [AnyObject]
                        {
                            searchPerson.ratingAverage = ratingAverage
                        }
                        
                        if let reviewcount = dict.objectForKey("review_count") as? [AnyObject]
                        {
                            searchPerson.reviewCount = reviewcount
                        }*/
                        
                        if let  ratingAverage = (dict as AnyObject).object(forKey: "rating_average") as? [NSDictionary]
                        {
                            for dict in ratingAverage
                            {
                                let average = RatingAverage()
                                if let avg = dict.object(forKey: "average") as? String
                                {
                                    average.average =   avg
                                }
                                searchPerson.ratingAverage.append(average)
                                
                            }
                            
                        }
                        
                        if let  reviewCount = (dict as AnyObject).object(forKey: "review_count") as? [NSDictionary]
                        {
                            for dict in reviewCount
                            {
                                let count = ReviewCount()
                                if let _ = dict.object(forKey: "count") as? String
                                {
                                    count.count =   (dict.object(forKey: "count") as? String)!
                                }
                                searchPerson.reviewCount.append(count)
                                
                            }
                            
                        }
                        conatactPerson.data.append(searchPerson)
                         
                    }
                    
                }
                
            //}*/
            onFinish(response, conatactPerson)
            
            }) { (error) in
                onError(error)
        }
        
        
    }
    
    
     //MARK: Get conversation
    func getChatConversationForID(_ contactID:String, page: String, onFinish:@escaping (_ response:AnyObject,_ chatConversation:ChatConversation)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getChatConversationForID(contactID, page: page, onFinish: { (response, deserializedResponse) in
            
            let chatConversation = ChatConversation()
            if deserializedResponse is NSDictionary
            {
                
                chatConversation.total = (deserializedResponse.object(forKey: "total") as? Int)!
                chatConversation.per_page =  (deserializedResponse.object(forKey: "per_page") as? Int)!
                chatConversation.current_page =    (deserializedResponse.object(forKey: "current_page") as? Int)!
                chatConversation.last_page =  (deserializedResponse.object(forKey: "last_page") as? Int)!
                
                
                if let data = deserializedResponse.object(forKey: "data") as? NSArray
                {
                   for dict in data
                    {
                        let chattDetail = ChatDetail()
                         chattDetail.id = ((dict as AnyObject).object(forKey: "id") as? Int)!
                        
                        if let  senderId =   (dict as AnyObject).object(forKey: "sender_id") as? String
                        {
                           chattDetail.sender_id = senderId
                        }
                        if let recipient_id = (dict as AnyObject).object(forKey: "recipient_id") as? String
                        {
                            chattDetail.recipient_id = recipient_id
                        }
                        if let message_type =  (dict as AnyObject).object(forKey: "message_type") as? String
                        {
                            chattDetail.message_type = message_type
                        }
                        
                        if let text =
                            (dict as AnyObject).object(forKey: "text") as? String
                        {
                            chattDetail.text = text
                        }
                        
                        if let  image = (dict as AnyObject).object(forKey: "image") as? String
                        {
                            chattDetail.image = image
                        }
                        
                        if let  video = (dict as AnyObject).object(forKey: "video") as? String
                        {
                            chattDetail.video = video
                        }
                        
                        if let message_read =
                            (dict as AnyObject).object(forKey: "message_read") as? String
                        {
                            chattDetail.message_read = message_read
                        }
                        if let received_at =
                            (dict as AnyObject).object(forKey: "received_at") as? String
                        {
                            chattDetail.received_at =  received_at
                            
                        }
                        
                        if let created_at =
                            (dict as AnyObject).object(forKey: "created_at") as? String
                        {
                           chattDetail.created_at = created_at
                        }
                        
                        if let updated_at =
                            (dict as AnyObject).object(forKey: "updated_at") as? String
                        {
                            chattDetail.updated_at = updated_at
                        }
                        if let conversation_id =
                            (dict as AnyObject).object(forKey: "conversation_id") as? String
                        {
                            chattDetail.conversation_id = conversation_id
                        }
                        
                        chatConversation.data.append(chattDetail)
                        
                    }
                }
                
            }
            onFinish(response, chatConversation)
            
            
            
            }) { (error) in
                onError(error)
        }
        
    
    }
    
    //MARK: BLOCK
    func blockUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        let dataSession = DataSession()
        dataSession.blockUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
            }) { (error) in
                onError(error)
        }
        
    }
    
    func unblockUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        let dataSession = DataSession()
        dataSession.blockUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }

        
        /*
        let dataSession = DataSession()
        dataSession.unblockUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
   */
    
    
    
    }
    
    
    
    
    
    func getSearchPersonArray(_ deserializedResponse:NSArray)->[SearchPerson]
    {
        var lBlockUserArray = [SearchPerson]()
        
        if  deserializedResponse.isKind(of: NSArray.self)
        {
            
            for i in 0..<deserializedResponse.count
            {
                let lBlockUser = SearchPerson()
                let dict = deserializedResponse[i]
                if let _ = (dict as AnyObject).object(forKey: "id") as? Int
                {
                    lBlockUser.idString = ((dict as AnyObject).object(forKey: "id") as? Int)!
                }
                if let name = (dict as AnyObject).object(forKey: "name") as? String
                {
                    lBlockUser.name   = name
                }
                
                if let _ = (dict as AnyObject).object(forKey: "email") as? String
                {
                    
                    lBlockUser.email = ((dict as AnyObject).object(forKey: "email") as? String)!
                }
                if let mobileNumber = (dict as AnyObject).object(forKey: "mobile_number") as? String
                {
                    lBlockUser.mobileNumber = mobileNumber
                }
                
                lBlockUser.app_user_token = (dict as AnyObject).object(forKey: "app_user_token") as? String
                lBlockUser.created_at = (dict as AnyObject).object(forKey: "created_at") as? String
                lBlockUser.updated_at = (dict as AnyObject).object(forKey: "updated_at") as? String
                lBlockUser.dob = (dict as AnyObject).object(forKey: "dob") as? String
                lBlockUser.address = (dict as AnyObject).object(forKey: "address") as? String
                lBlockUser.website = (dict as AnyObject).object(forKey: "website") as? String
                lBlockUser.photo = (dict as AnyObject).object(forKey: "photo") as? String
                lBlockUser.gcm_token = (dict as AnyObject).object(forKey: "gcm_token") as? String
                lBlockUser.last_online_time = (dict as AnyObject).object(forKey: "last_online_time") as? String
                
                lBlockUserArray.append(lBlockUser)
                
            }
        }
        
        return lBlockUserArray
        
    }
    
    
    
    
    func getBlockUserList(_ onFinish:@escaping (_ response:AnyObject, _ blockUserArray:[SearchPerson])->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getBlockUsersList({ (response, deserializedResponse) in
            
            var lBlockUserArray = [SearchPerson]()
            
            if  deserializedResponse.isKind(of: NSArray.self)
            {
                
                for i in 0..<(deserializedResponse as! NSArray).count
                {
                    let lBlockUser = SearchPerson()
                    let dict = deserializedResponse.object(at: i)
                    if let _ = (dict as AnyObject).object(forKey: "id") as? Int
                    {
                        lBlockUser.idString = ((dict as AnyObject).object(forKey: "id") as? Int)!
                    }
                    if let name = (dict as AnyObject).object(forKey: "name") as? String
                    {
                        lBlockUser.name   = name
                    }
                    
                    if let _ = (dict as AnyObject).object(forKey: "email") as? String
                    {
                    
                        lBlockUser.email = ((dict as AnyObject).object(forKey: "email") as? String)!
                    }
                    if let mobileNumber = (dict as AnyObject).object(forKey: "mobile_number") as? String
                    {
                        lBlockUser.mobileNumber = mobileNumber
                    }
                    
                    lBlockUser.app_user_token = (dict as AnyObject).object(forKey: "app_user_token") as? String
                    lBlockUser.created_at = (dict as AnyObject).object(forKey: "created_at") as? String
                    lBlockUser.updated_at = (dict as AnyObject).object(forKey: "updated_at") as? String
                    lBlockUser.dob = (dict as AnyObject).object(forKey: "dob") as? String
                    lBlockUser.address = (dict as AnyObject).object(forKey: "address") as? String
                    lBlockUser.website = (dict as AnyObject).object(forKey: "website") as? String
                    lBlockUser.photo = (dict as AnyObject).object(forKey: "photo") as? String
                    lBlockUser.gcm_token = (dict as AnyObject).object(forKey: "gcm_token") as? String
                    lBlockUser.last_online_time = (dict as AnyObject).object(forKey: "last_online_time") as? String
                    
                   lBlockUserArray.append(lBlockUser)
                    
                }
            }
            
             onFinish(response, lBlockUserArray)
            
            }) { (error) in
            onError(error)
        }
        
        
        
        
        
        

    }
    //MARK: SPAM
    func spamUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.spamUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
     }
    
    //MARK: SPAM
    func unspamUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.spamUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }

        /*
        let dataSession = DataSession()
        dataSession.unspamUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        
        */
    }
    
    func getUserSpamList(_ onFinish:@escaping (_ response:AnyObject,_ spamUserArray:[SearchPerson])->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getUserSpamList({ (response, deserializedResponse) in
            var lBlockUserArray = [SearchPerson]()
            lBlockUserArray =   self.getSearchPersonArray(deserializedResponse as! NSArray)
            onFinish(response, lBlockUserArray)
            }) { (error) in
                onError(error)

        }

    }

    
    //MARK:FAVOURITE
    func favouriteUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.favouriteUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }

        
    }
    
    //MARK:FAVOURITE
    func unfavouriteUserID(_ userID:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.favouriteUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        /*
        let dataSession = DataSession()
        dataSession.unfavouriteUserID(userID, onFinish: { (response, deserializedResponse) in
            onFinish(response, deserializedResponse)
        }) { (error) in
            onError(error)
        }
        */
        
    }
    
    
    func getUserfavoriteList(_ onFinish:@escaping (_ response:AnyObject,_ favUserArray:[SearchPerson])->(), onError:@escaping (_ error:AnyObject)->())
    {
        let dataSession = DataSession()
        dataSession.getUserfavoriteList({ (response, deserializedResponse) in
            var lBlockUserArray = [SearchPerson]()
            lBlockUserArray =   self.getSearchPersonArray(deserializedResponse as! NSArray)
            onFinish(response, lBlockUserArray)
            }) { (error) in
                onError(error)

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
         let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
         let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
         return [kapp_user_id:String(appUserId), kapp_user_token :appUserToken]
    }
    
    class func resetAppUserIdAndToken()
    {
        UserDefaults.standard.set(nil, forKey: kapp_user_id)
        UserDefaults.standard.set(nil, forKey: kapp_user_token)
        
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

class ReviewCount:NSObject, NSCoding
{
    var count = String()
    
    required override init()
    {
        super.init()
    }
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        if let count = aDecoder.decodeObject(forKey: "count") as? String
        {
            self.count = count
        }
    }
    func encode(with aCoder: NSCoder)
    {
         aCoder.encode(count, forKey: "count")
        
    }
}

class RatingAverage:NSObject, NSCoding
{
    var average:String = String()
    required override init()
    {
        super.init()
    }
    required init?(coder aDecoder: NSCoder)
    {
        super.init()
        if let average = aDecoder.decodeObject(forKey: "average") as? String
        {
            self.average = average
        }
    }
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(average, forKey: "average")
    }
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
    var id:Int = 0
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
    var post_id:NSNumber = NSNumber()
    
    var likeDislikecount = NSNumber()
    //var datavalue = dataFeedMyfeedModel()
}


class postModel: NSObject {
    
    var id:Int = 12
    var action     = String()
    var action_val     = String()
    var review     = String()
    var recent_action     = String()
    var created_at     = String()
    var performed     = commonModel()
    //var effected     = String()
    var effected       = commonModel()
    var likes_count     = [AlertCountCommonModel]()
    var dislikes_count     = [AlertCountCommonModel]()
    var likes_user     = [commonModel]()
    var dislikes_user     = [commonModel]()
    
}


class dataModel: NSObject
{
    
    var id:Int = 0
    var action     = String()
    var created_at     = String()
    var action_by     = commonModel()
    var post     = postModel()
    
}


class AlertModel: NSObject
{
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

class FeedMyfeed: NSObject
{
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

class dataFeedMyfeedModel: NSObject
{
    var id:Int         = 12
    var action         = String()
    var action_val     = String()
    var review         = String()
    var recent_action  = String()
    var created_at     = String()
    var performed      = SearchPerson()
    var effected       = SearchPerson()
    var likes_count    = AlertCountCommonModel()
    var dislikes_count = AlertCountCommonModel()
    var likes_user     = [SearchPerson]()
    var dislikes_user  = [SearchPerson]()
}
