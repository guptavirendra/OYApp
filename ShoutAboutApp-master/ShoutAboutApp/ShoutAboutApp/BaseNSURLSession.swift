//
//  BaseNSURLSession.swift
//  MedocityNetWorkManager
//
//  Created by Virendra Kumar on 12/31/14.
//  Copyright (c) 2014 Virendra Kumar. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices


//var doctorBaseURL = "http://139.59.31.73/api/"
var doctorBaseURL = "http://demo.varyavega.co.in/shoutaboutapp/api/"
var baseURL = doctorBaseURL


extension String
{
    /**
     A simple extension to the String object to encode it for web request.
     
     :returns: Encoded version of of string it was called as.
     */
    var escaped: String
        {
            return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,self,"[].",":/?&=;+!@#$()',*",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) as String
    }
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        
        get {
            
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (self as NSString).stringByDeletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    var pathComponents: [String] {
        
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathExtension(ext)
    }
}

public class BaseNSURLSession: NSObject
{
    //Here prefix m represents Member variable;
    var mNSURLSessionConfiguration:NSURLSessionConfiguration
    var mNSURLSession: NSURLSession
    var mNSURLSessionDataTask: NSURLSessionDataTask?
    var mNSURLSessionDownloadTask:NSURLSessionDownloadTask?
    var mNSMutableRequest: NSMutableURLRequest?
    var mNSMutableData: NSMutableData?
    var mNSError: NSError?
    var mIsDataAvailable: Bool = false
    let mStringURL: NSString
    //let mNSURLSessionDelegate:NSURLSessionDataDelegate
    var mConnectionHeaders:Dictionary<String, AnyObject>?
    var mNSHTTPURLResponse: NSHTTPURLResponse?
    //let delegate: NSURLSessionDelegate?
    var  mPath: NSString = NSString()
    let  mCHWebServiceMethod = WebServicePath()
    
    var mStoreRequestDictionary: NSMutableDictionary
    var key:String
    
    // Basic initializers With Base URL This initializer may be change at later stage for concerting convence initializer
    
    init(stringURL:NSString,sessionConfiguration: NSURLSessionConfiguration  )
    {
        
        mNSURLSessionConfiguration = sessionConfiguration
        mNSURLSession              = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue()) //NSURLSession.sharedSession()//Session Class
        
        print("\(stringURL)")
        mStringURL                 = stringURL //Base URL
        mNSMutableData             = NSMutableData()// To strore Data
        mConnectionHeaders         = [String: AnyObject]()// Dictionary to set Data
        mStoreRequestDictionary    = NSMutableDictionary()// To store request
        key                        = " "
    }
    
    // initializer with DefaultBase URL and DefaultSeession
    public convenience  override init()
    {
        
        var sessionConfig:NSURLSessionConfiguration
        sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.init(stringURL:baseURL,sessionConfiguration:sessionConfig)
    }
    deinit
    {
        mNSURLSession.invalidateAndCancel()
       
    }
    
    //Add Headers That is required
    func setSessionHeader(headerName:NSString, value: NSString?)
    {
        guard let _ = mConnectionHeaders else  {
            return
        }
        
        guard let val = value as? String else    {
            return
        }
        
        mConnectionHeaders![headerName as String] = val
        // mNSMutableRequest?.setValue(value, forHTTPHeaderField: headerName)
        //        mConnectionHeaders.setValue(value, forKey: headerName as String)
        
    }
    
    //This function  shows we have Interested  in JSON only
    func addDefaultJSONHeader()
    {
        mNSMutableRequest?.addValue("application/json", forHTTPHeaderField: "Accept")
        mNSMutableRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var session:NSString?
        var sessionKey:String?
        session    = NSUserDefaults.standardUserDefaults().valueForKey("session") as? NSString
        sessionKey = "session"
        //isSessionTokenExpiredDoctor = false
        if let sessions = session
        {
            if((!self.mPath.isEqualToString("/login"))||(!self.mPath.isEqualToString("/v2/login")))
            {
                print("------------->sessionToken added")
               
                mNSMutableRequest?.setValue(sessions as String, forHTTPHeaderField: sessionKey!)
            }
        }
        
    }
    
    
    
    //Configure MutableRequest For GetRequest
    func configureGetMutableRequest(path:String,parameters : Dictionary<String, AnyObject>?)
    {
        self.mPath = path
        var stringURL:String = String()
        if path.rangeOfString("http") != nil
        {
            print("exists")
            stringURL = path
        }else
        {
            stringURL  = (mStringURL as String)+path
        }
        
        
        stringURL =  stringURL.stringByReplacingOccurrencesOfString("//", withString: "/", options:NSStringCompareOptions.LiteralSearch, range: nil)
        //Can do with Alternate way
        stringURL =  stringURL.stringByReplacingOccurrencesOfString(":/", withString: "://", options:NSStringCompareOptions.LiteralSearch, range: nil)
        
        if((self.mPath.isEqualToString("/diary/url")))
        {
            if let param = parameters
            {
                for( key, value) in param
                {
                    setSessionHeader(key, value: value as? NSString)
                }
                
            }
        }else
        {
            if let param = parameters
            {
                let array: NSMutableArray = NSMutableArray()
                for( key, val) in param
                {
                    let newVal = val as? String
                    array.addObject(key+"="+newVal!.escaped)
                    
                }
                let final = array.componentsJoinedByString("&")
                //final = dropLast(final)
                
                if (final as NSString).length > 0
                {
                    if stringURL.rangeOfString("graph?start=") != nil
                    {
                        stringURL = stringURL+final
                    }
                    else
                    {
                        stringURL = stringURL+"?"+final
                    }
                }
            }
        }
        stringURL =  stringURL.stringByReplacingOccurrencesOfString(" ", withString: "%20", options:NSStringCompareOptions.LiteralSearch, range: nil)
        if let lURL = NSURL(string: stringURL)// Need to check if does not nil
        {
            print("All urls goes Here \(stringURL)")
            mNSMutableRequest = NSMutableURLRequest(URL:lURL )// Apend Path to Hit
            mNSMutableRequest?.timeoutInterval = 300
            addDefaultJSONHeader()// Added Json Header Only
            if let tempData = mConnectionHeaders as? Dictionary<String, String>
            {
                mNSMutableRequest?.allHTTPHeaderFields = tempData
            }
            
        }else
        {
        }
        
        
        
        //println(" Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    //Configure MutableRequest For GetRequest
    func configureGetMutableRequestWithHeaders(path:String,headerParameters : Dictionary<String, String>?)
    {
        self.mPath = path
        var stringURL:String = (mStringURL as String)+path
        
        stringURL =  stringURL.stringByReplacingOccurrencesOfString("//", withString: "/", options:NSStringCompareOptions.LiteralSearch, range: nil)
        //Can do with Alternate way
        stringURL =  stringURL.stringByReplacingOccurrencesOfString(":/", withString: "://", options:NSStringCompareOptions.LiteralSearch, range: nil)
        let lURL = NSURL(string: stringURL)// Need to check if does not nil
        
        print("All urls goes Here \(stringURL)")
        mNSMutableRequest = NSMutableURLRequest(URL:lURL! )// Apend Path to Hit
        mNSMutableRequest?.timeoutInterval = 60
        addDefaultJSONHeader()// Added Json Header Only
        if let param = headerParameters
        {
            for( key, value) in param
            {
                setSessionHeader(key, value: value)
            }
        }
        if let tempData = mConnectionHeaders as? Dictionary<String, String>   {
            mNSMutableRequest?.allHTTPHeaderFields = tempData
        }
        
        //println(" Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    //Configure MutableRequest For GetRequest
    func configureDeleteMutableRequest(path:String,parameters : Dictionary<String, String>?)
    {
        configureGetMutableRequest(path, parameters: parameters)
        mNSMutableRequest?.HTTPMethod = "DELETE"
    }
    
    //Configure MutableRequest For PostRequest
    
    final func configurePostMutableRequest(path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?)//->NSMutableURLRequest
    {
        configureGetMutableRequest(path, parameters: parameters)
        
        mNSMutableRequest?.HTTPMethod = "POST"
        if let _ = postBody
        {
            do {
                mNSMutableRequest?.HTTPBody   = try NSJSONSerialization.dataWithJSONObject(postBody!, options: NSJSONWritingOptions())
            }
            catch  {
                print("Error \(error)")
            }
            
        }
        
        
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    final func configurePostMutableRequestWithHeader(path:String,headerParameters : Dictionary<String, String>?, postBody:Dictionary<String, AnyObject>?)//->NSMutableURLRequest
    {
        configureGetMutableRequestWithHeaders(path, headerParameters: headerParameters)
        mNSMutableRequest?.HTTPMethod = "POST"
        if let _ = postBody
        {
            do {
                mNSMutableRequest?.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postBody!, options: NSJSONWritingOptions())
            }
            catch   {
                print("Error \(error)")
            }
            
        }
        
        
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    final func configurePutMutableRequestWithHeader(path:String,headerParameters : Dictionary<String, String>?, putBody:Dictionary<String, String>?)//->NSMutableURLRequest
    {
        configureGetMutableRequestWithHeaders(path, headerParameters: headerParameters)
        mNSMutableRequest?.HTTPMethod = "PUT"
        if let putBody = putBody
        {
            do {
                mNSMutableRequest?.HTTPBody = try NSJSONSerialization.dataWithJSONObject(putBody, options: NSJSONWritingOptions())
            }
            catch   {
                print("Error \(error)")
            }
            
        }
        
        
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    final func configureRawPostMutableRequest(postType:String, urlString:String, postBody:String?)//->NSMutableURLRequest
    {
        self.mPath = urlString
        let stringURL:String = urlString
        let lURL = NSURL(string: stringURL)// Need to check if does not nil
        print("JSON Raw post URL \(stringURL)")
        mNSMutableRequest = NSMutableURLRequest(URL:lURL! )// Apend Path to Hit
        mNSMutableRequest?.timeoutInterval = 60
        addDefaultJSONHeader()// Added Json Header Only
        
        if let tempData = mConnectionHeaders as? [String : String]  {
            mNSMutableRequest?.allHTTPHeaderFields = tempData
        }
        
        mNSMutableRequest?.HTTPMethod = postType
        if let postbody = postBody
        {
            let requestData = (postbody as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            mNSMutableRequest?.HTTPBody   =  requestData
            //[request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            let lenght = NSString(format: "%d", requestData!.length)
            mNSMutableRequest?.addValue(lenght as String, forHTTPHeaderField: "Content-Length")
            
        }
    }
    // Configure MutableRequest For Put Request
    
    func configurePutMutableRequest(path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?)//->NSMutableURLRequest
    {
        configureGetMutableRequest(path, parameters: parameters)
        
        mNSMutableRequest?.HTTPMethod = "PUT"
        if let _ = postBody
        {
            do {
                mNSMutableRequest?.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(postBody!, options: NSJSONWritingOptions())
            }
            catch  {
                print("Error \(error)")
            }
        }
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    
    // MARK:  With on finish and with on
    
    //This function is GET plus takes parameter headers and appends to http headers
    final func getWithHeader( path : String, headerParameters : Dictionary<String, String>?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        print("get  path" + "\(path)")
        if let _ = headerParameters
        {
            configureGetMutableRequestWithHeaders(path, headerParameters: headerParameters!)
            
        }else
        {
            configureGetMutableRequestWithHeaders(path, headerParameters:nil)
        }
        
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        
    }
    
    // MARK:  With on finish and with on
    // This function will add parameters to query ie. append as get params in URL
    final public func getWithOnFinish( path : String, parameters : Dictionary<String, String>?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        print("get  path" + "\(path)")
        if let _ = parameters
        {
            configureGetMutableRequest(path, parameters: parameters!)
            
        }else
        {
            configureGetMutableRequest(path, parameters:nil)
        }
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0), { () -> Void in
        self.startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
            
        })
        
        
    }
    
    public func getDownloadWithOnFinish( path : String, parameters : Dictionary<String, String>?,onFinish:(response:AnyObject,url:Bool )->(), onError:(error:AnyObject)->())
    {
        
        print("get  path" + "\(path)")
        if let _ = parameters
        {
            configureGetMutableRequest(path, parameters: parameters!)
            
        }else
        {
            configureGetMutableRequest(path, parameters:nil)
        }
        
        mNSMutableRequest?.addValue("application/pdf", forHTTPHeaderField: "Accept")
        mNSMutableRequest?.setValue("application/pdf", forHTTPHeaderField: "Content-Type")
        let fileType = mimeTypeForPath(path)
        mNSMutableRequest?.addValue(fileType, forHTTPHeaderField: "Accept")
        mNSMutableRequest?.setValue(fileType, forHTTPHeaderField: "Content-Type")
        downloadRequest({ (response, url) -> () in
            onFinish(response: response, url: url)
            
            }) { (error) -> () in
                onError(error: error)
                
        }
        
        
        
    }
    
    
    // MARK: post json function
    public final func postJSONRawDataWithOnFinish(urlString:String,postBody:String?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        if let postBody = postBody
        {
            configureRawPostMutableRequest("POST", urlString: urlString ,  postBody: postBody)
        }else
        {
            configureRawPostMutableRequest("POST", urlString:  urlString , postBody: nil)
        }
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        
    }
    
    // MARK: this function does a request outside the ICH servers.
    final public func getWithCustomURL(urlString:String,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        configureRawPostMutableRequest("GET", urlString:  urlString , postBody: nil)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        
    }
    
    // MARK: post function
    public final  func postDataWithOnFinish(path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        if let postBody = postBody
        {
            configurePostMutableRequest(path , parameters: parameters, postBody: postBody)
        }else
        {
            configurePostMutableRequest(path , parameters: parameters, postBody: nil)
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0), { () -> Void in
        self.startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        })
        
    }
    final  func postDataWithHeaderOnFinish(path:String,headerParameters : Dictionary<String, String>?, postBody:Dictionary<String, AnyObject>?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        if let postBody = postBody
        {
            configurePostMutableRequestWithHeader(path, headerParameters: headerParameters, postBody: postBody)
        }else
        {
            configurePostMutableRequestWithHeader(path, headerParameters: headerParameters, postBody: nil)
        }
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        
    }
    
    /* Put data with on finish and onError*/
    public final  func putDataOnFinish(path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        if let postBody = postBody
        {
            configurePutMutableRequest(path, parameters: parameters, postBody: postBody)
        }else
        {
            configurePutMutableRequest(path, parameters: parameters, postBody: nil)
        }
        
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        
    }
    
    final  func putDataWithHeaderOnFinish(path:String,headerParameters : Dictionary<String, String>?, putBody:Dictionary<String, String>?,onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        if let putBody = putBody
        {
            configurePutMutableRequestWithHeader(path, headerParameters: headerParameters, putBody: putBody)
        }else
        {
            configurePutMutableRequestWithHeader(path, headerParameters: headerParameters, putBody: nil)
        }
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
        
    }
    
    /*Delete data from server with onFinish and On error*/
    final public func deleteDataOnFinish(path:String,parameters : Dictionary<String, String>?, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        configureDeleteMutableRequest(path , parameters: parameters)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
    }
    
    
    
    
    // MARK: Session taskData
    // To match exact
    
    // Response is in form of Data and deserializedResponse in form of dictionary
    final  func startSessionTaskDataTaskWithRequest(onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        
        print(" URL path of request" + "\(mNSMutableRequest?.URL)")
        
        
        if let _ = mNSMutableRequest
        {
            
            
            mNSURLSessionDataTask = mNSURLSession.dataTaskWithRequest(mNSMutableRequest!, completionHandler:
                {
                    data, response, error -> Void in
                    //println("data: \(data)")
                    print("Response: \(response)")
                    print("error: \(error)")
                    self.mNSHTTPURLResponse = response as? NSHTTPURLResponse// Check Data is HTTPURl Response
                    let HttpResponseStatusClass = HttpResponseStatus()
                    var responseMessage:String
                    print("Status Code::  \(self.mNSHTTPURLResponse?.statusCode) & URL : \(self.mNSHTTPURLResponse?.URL)" )
                    
                    // First check for any error
                    if error != nil
                    {
                        print("Error description: \(error!.localizedFailureReason)")
                        let errors = errorDescription(error!)
                        onError(error: errors)
                    }
                    else
                    {
                        
                        // Here Check for status code if it is not null
                        if let statusCode = self.mNSHTTPURLResponse?.statusCode
                        {
                            // Get a corresponding Status code message
                            responseMessage = HttpResponseStatusClass.getResponseStatusMessage(statusCode)
                            print("Status code message" + responseMessage )
                
                                // Response code 200 means success
                             if(self.mNSHTTPURLResponse?.statusCode  == 200 )
                            {
                                
                                // here we check if there is any data
                                if let dataInAnyObject = data
                                {
                                    do  {
                                        let json = try NSJSONSerialization.JSONObjectWithData(dataInAnyObject, options: .MutableLeaves) as? AnyObject
                                        // println("DeserilizedDict:"+"\(json)")
                                        
                                        // Check  if there is any error while converting the data
                                        if(self.mNSError != nil)
                                        {
                                            
                                            print(self.mNSError!.localizedDescription)
                                            let jsonStr = NSString(data: dataInAnyObject, encoding: NSUTF8StringEncoding)
                                            print("Error could not parse JSON with new block:  '\(jsonStr)'")
                                            let errors = errorDescription(self.mNSError!)
                                            // If there is any error while converting data to dict then through error block
                                            onError(error:errors)
                                            
                                        }
                                        else
                                        {
                                            //Here we check is there converted json dict or not
                                            if let parseJSON = json
                                            {
                                                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                                                let success = parseJSON["success"] as? Int// Check wheater 0 or 1
                                                print("Succes: \(success)")
                                                // Note Here we check success to 1 No need of if else here check success in some cases there is no message of success
                                                if success == 1
                                                {
                                                    onFinish(response: data!,deserializedResponse: parseJSON)
                                                }
                                                else
                                                {
                                                    //There is no success Key
                                                    print("This shows there is no Success key")
                                                    onFinish(response: data!,deserializedResponse: parseJSON)
                                                    
                                                    //onError(error: "Unsuccess event")
                                                }
                                            }
                                                // No need to check this but for surity used this else
                                            else
                                            {
                                                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                                print("Error could not parse JSON: \(jsonStr)")
                                                let errors = errorDescription("Error could not parse JSON: \(jsonStr)")
                                                onError(error:errors )
                                            }
                                        }
                                        
                                        
                                    }
                                    catch
                                    {
                                        
                                        do  {
                                            let json = try NSJSONSerialization.JSONObjectWithData(dataInAnyObject, options: .MutableLeaves) as? NSString
                                            onFinish(response: data!,deserializedResponse: json!)
                                        }
                                        catch
                                        {
                                            print("Error \(error)")
                                            onError(error:"\(error)")
                                        }
                                    }
                                    
                                    
                                }
                            }else
                            {
                                let errors = errorDescription(responseMessage)
                                onError(error:errors )
                            }
                            
                        }
                        
                    }
            })
        }
        mNSURLSessionDataTask?.resume()
    }
    //-------------------------------
    
    // download Image with just URL
    func downloadImageWithURL(urlString:String, downloadedImageData:(imageData:NSData?, message:String)->())
    {
        
        let lNSURLSessionDownloadTask: NSURLSessionDownloadTask = mNSURLSession.downloadTaskWithURL(NSURL(string: urlString)! , completionHandler:
            {
                urlLocation, response, error -> Void in
                
                var lImageData:NSData?
                if let url = urlLocation
                {
                    print("we get error\(urlLocation!.path)")
                    lImageData = NSData(contentsOfURL: url)
                }
                
                if let err = error
                {
                    // in case of error I have to pass nil data
                    downloadedImageData(imageData: NSData(), message:"\(err.localizedDescription)")
                }else
                {
                    downloadedImageData(imageData: lImageData!, message:"Success")
                }
                
                
        })
        lNSURLSessionDownloadTask.resume()
        
    }
    
    //MARK: Download pdf
    
    func downloadRequest(onFinish:(response:AnyObject,url:Bool)->(), onError:(error:AnyObject)->())
    {
        
        print(" URL path of request" + "\(mNSMutableRequest?.URL)")
        
        
        if let _ = mNSMutableRequest
        {
            
            
            mNSURLSessionDownloadTask = mNSURLSession.downloadTaskWithRequest(mNSMutableRequest!, completionHandler:
                {
                    url, response, error -> Void in
                    
                    
                    //println("data: \(data)")
                    print("Response: \(response)")
                    print("error: \(error)")
                    self.mNSHTTPURLResponse = response as? NSHTTPURLResponse// Check Data is HTTPURl Response
                    let HttpResponseStatusClass = HttpResponseStatus()
                    var responseMessage:String
                    print("Status Code::  \(self.mNSHTTPURLResponse?.statusCode) & URL : \(self.mNSHTTPURLResponse?.URL)" )
                    
                    // First check for any error
                    if error != nil
                    {
                        print("Error description: \(error!.localizedFailureReason)")
                        let errors = errorDescription(error!)
                        onError(error: errors)
                    }
                    else
                    {
                        
                        // Here Check for status code if it is not null
                        if let statusCode = self.mNSHTTPURLResponse?.statusCode
                        {
                            // Get a corresponding Status code message
                            responseMessage = HttpResponseStatusClass.getResponseStatusMessage(statusCode)
                            print("Status code message" + responseMessage )
                            
                            if(self.mNSHTTPURLResponse?.statusCode  == 401  && ( self.mNSHTTPURLResponse?.URL?.lastPathComponent == "login" || self.mNSHTTPURLResponse?.URL?.lastPathComponent == "changepassword" || self.mNSHTTPURLResponse?.URL?.lastPathComponent == "forgotpassword"))
                            {
                                let errors = "Username or Password not correct"
                                onError(error:errors)
                                
                            }

                                
                            else  if(self.mNSHTTPURLResponse?.statusCode  == 401  && (self.mNSHTTPURLResponse?.URL?.lastPathComponent != "login" || self.mNSHTTPURLResponse?.URL?.lastPathComponent != "changepassword" || self.mNSHTTPURLResponse?.URL?.lastPathComponent != "forgotpassword"))
                            {
                                if  ((self.mNSMutableRequest?.URL != nil && self.mNSMutableRequest?.HTTPMethod != nil)  )
                                {
                                    if let urlString = self.mNSMutableRequest?.URL?.lastPathComponent
                                    {
                                        self.key = urlString + (self.mNSMutableRequest?.HTTPMethod)!
                                    }
                                }
                                
                                let dicRequest : NSMutableDictionary = NSMutableDictionary()
                                dicRequest.setValue(self.mNSMutableRequest, forKey: self.key)
                                
                                
                            }
                                
                                // Response code 200 means success
                            else if(self.mNSHTTPURLResponse?.statusCode  == 200 )
                            {
                                
                                
                                // here we check if there is any data
                                
                               
                                
                                if (url != nil)
                                {
                                    let fileManager = NSFileManager.defaultManager()
                                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
                                    let writePath = documents.stringByAppendingPathComponent((response?.suggestedFilename)!)
                                    let documentURL = NSURL.fileURLWithPath(writePath)
                                    
                                    
                                    if fileManager.fileExistsAtPath(documentURL.path!)
                                    {
                                        do
                                        {
                                            try  fileManager.replaceItemAtURL(documentURL, withItemAtURL: url!, backupItemName: nil, options: NSFileManagerItemReplacementOptions.UsingNewMetadataOnly, resultingItemURL: nil)
                                        }
                                        catch
                                        {
                                            onError(error:"error")
                                            
                                        }
                                    }else
                                    {
                                        do
                                        {
                                            try fileManager.moveItemAtURL(url!, toURL: documentURL)
                                        }
                                        catch
                                        {
                                            onError(error:"error")
                                            
                                        }
                                        
                                    }
                                    

                                }
                                onFinish(response: response!, url: true)
                                
                                
                            }else
                            {
                                let errors = errorDescription(responseMessage)
                                onError(error:errors )
                            }
                            
                        }
                        
                    }
            })
        }
        mNSURLSessionDownloadTask?.resume()
    }
    
    
    
    
    func isDataAvailable()->Bool
    {
        return mIsDataAvailable
    }
    func cancelRequest()
    {
        mNSURLSessionDataTask?.cancel()
        
        
    }
    
        
    
}





func errorDescription(error:AnyObject)->NSString
{
    var errorinString = ""
    
    let errorDict:NSDictionary =  ["success":"0", "message":error.description]
    
    print("\(errorinString)")
    
    
    
    do
    {
        let data = try NSJSONSerialization.dataWithJSONObject(errorDict, options: NSJSONWritingOptions.PrettyPrinted)
        
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            if let json = json
            {
                errorinString = json as String
                print(json)
            }
        
    }
    catch
    {
        print(" in catch block")
        
    }
    
    return errorinString;
    
    
}

extension String
{
    // NSError *error;
    // NSData *objectData = [(NSString*)error dataUsingEncoding:NSUTF8StringEncoding];
    //  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    //    func stringToDict()->NSDictionary
    //    {
    //        var objectData:NSData =
    //
    //    }
    
}



class HttpResponseStatus:NSObject
{
    func getResponseStatusMessage(statusCode:Int)->String
    {
        switch statusCode
        {
        case 200:
            return "Success"
        case 401:
            return "Unauthorized"
        case 404:
            return "Not found"
        case 500:
            return "Internal Error"
        case 501:
            return "Not Implemented"
        case 502:
            return "Bad Gateway"
        case 503:
            return "Service Unavailable"
        case 504:
            return "Gateway Timeout"
        default:
            return "Unknown Status"
        }
    }
    
}

// MARK:Extension to base class to upload media files
extension BaseNSURLSession
{
    func configureMediaRequest(methodType:String, path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String )
    {
        let boundary = NSString.generateBoundaryString()
        configureGetMutableRequest(path, parameters:headerParam)
        mNSMutableRequest!.HTTPMethod = methodType
        mNSMutableRequest!.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        mNSMutableRequest!.HTTPBody = createBodyWithParameters(name, mediaPaths: mediaPaths, boundary: boundary, bodyDict: bodyDict)
    }
    
    func configurePostMediaRequest(path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String)
    {
        configureMediaRequest("POST", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
    }
    
    func configurePutMediaRequest(path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String)
    {
        configureMediaRequest("PUT", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
    }
    
    private func createBodyWithParameters( name: String?, mediaPaths: [String]?, boundary: String, bodyDict:Dictionary<String, String>?) -> NSData
    {
        let body = NSMutableData()
        if bodyDict != nil
        {
            for (key, value) in bodyDict!
            {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        /*else*/ if mediaPaths != nil
        {
            for path in mediaPaths!
            {
                let filename = path.lastPathComponent
                //let data = path.dataUsingEncoding(NSUTF8StringEncoding)
                let data = NSData(contentsOfFile: path)
                let mimetype = mimeTypeForPath(path)
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(name!)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.appendData(data!)
                body.appendString("\r\n")
            }
        }
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    private func mimeTypeForPath(path: String) -> String
    {
        let pathExtension = path.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue()
        {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
            {
                return mimetype as NSString as String
            }
        }
        return "application/octet-stream";
    }
    
    public final  func postMediaWithOnFinish(path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        configurePostMediaRequest(path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
    }
    
    public final  func putMediaWithOnFinish(path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        configurePutMediaRequest(path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
    }
    
    //MARK: Scrapbook Media Send
    
    public final func postSBMediaWithOnFinish(path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:[String]?, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        configureSBMediaRequest("POST", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
    }
    
    final  func putSBMediaWithOnFinish(path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:[String]?, onFinish:(response:AnyObject,deserializedResponse:AnyObject)->(), onError:(error:AnyObject)->())
    {
        configureSBMediaRequest("PUT", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response: response, deserializedResponse: deserializedResponse)
            },
            onError: { (error) -> () in
                onError(error: error)
        })
    }
    
    func configureSBMediaRequest(methodType:String, path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:[String]? )
    {
        let boundary = String.generateBoundaryString()
        configureGetMutableRequest(path, parameters:headerParam)
        mNSMutableRequest!.HTTPMethod = methodType
        mNSMutableRequest!.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        mNSMutableRequest!.HTTPBody = createSBBodyWithParameters(name, mediaPaths: mediaPaths, boundary: boundary, bodyDict: bodyDict)
    }
    
    private func createSBBodyWithParameters( name: [String]?, mediaPaths: [String]?, boundary: String, bodyDict:Dictionary<String, String>?) -> NSData
    {
        let body = NSMutableData()
        if bodyDict != nil
        {
            for (key, value) in bodyDict!
            {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        if mediaPaths?.count > 0
        {
            for i in 0..<(mediaPaths?.count)!
            {
                let index = name![i]
                let path = mediaPaths![i]
                let filename = path.lastPathComponent
                if let data = NSData(contentsOfFile: path) {
                    let mimetype = mimeTypeForPath(path)
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(index)\"; filename=\"\(filename)\"\r\n")
                    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                    body.appendData(data)
                    body.appendString("\r\n")
                }
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
}

//Mark:Mutabledata
extension NSMutableData
{
    func appendString(string: String)
    {
        print(string)
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

extension String
{
    
//    static func generateBoundaryString()->String
//    {
//        return ""
//    }
}

