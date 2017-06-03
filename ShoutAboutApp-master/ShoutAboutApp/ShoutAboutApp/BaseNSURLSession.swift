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

import Foundation
import UIKit
import MobileCoreServices


//USE_PRODUCTION_SERVER

var doctorBaseURL = "http://oyapp.in/api/"
//var doctorBaseURL = "http://demo.varyavega.co.in/shoutaboutapp/api/"

//var doctorBaseURL = "http://dev-cerebellum.cloudapp.net/"
var doctorProd =  "https://cerebellum.medocity.com/"
var baseURL = doctorBaseURL

extension String
{
    /**
     A simple extension to the String object to encode it for web request.
     
     :returns: Encoded version of of string it was called as.
     */
    var escaped: String
    {
        return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,self as CFString!,"[]." as CFString!,":/?&=;+!@#$()',*" as CFString!,CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) as String
    }
    
    var lastPathComponent: String {
        
        get
        {
            return (self as NSString).lastPathComponent
        }
    }
    
    var pathExtension: String {
        
        get
        {
            
            return (self as NSString).pathExtension
        }
    }
    
    var stringByDeletingLastPathComponent: String {
        
        get
        {
            
            return (self as NSString).deletingLastPathComponent
        }
    }
    
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).deletingPathExtension
        }
    }
    
    var pathComponents: [String]
    {
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String
    {
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathExtension(ext)
    }
}

open class BaseNSURLSession: NSObject
{
    //Here prefix m represents Member variable;
    var mNSURLSessionConfiguration:URLSessionConfiguration
    var mNSURLSession: URLSession
    var mNSURLSessionDataTask: URLSessionDataTask?
    var mNSURLSessionDownloadTask:URLSessionDownloadTask?
    var mNSMutableRequest: URLRequest?
    var mNSMutableData: NSMutableData?
    var mNSError: NSError?
    var mIsDataAvailable: Bool = false
    let mStringURL: NSString
    //let mNSURLSessionDelegate:NSURLSessionDataDelegate
    var mConnectionHeaders:[String: String]?
    var mNSHTTPURLResponse: HTTPURLResponse?
    //let delegate: NSURLSessionDelegate?
    var  mPath: String = String()
    let  mCHWebServiceMethod = WebServicePath()
    
    var mStoreRequestDictionary: NSMutableDictionary
    var key:String
    
    // Basic initializers With Base URL This initializer may be change at later stage for concerting convence initializer
    
    init(stringURL:NSString,sessionConfiguration: URLSessionConfiguration  )
    {
        
        mNSURLSessionConfiguration = sessionConfiguration
        mNSURLSession              = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main) //NSURLSession.sharedSession()//Session Class
        
        print("\(stringURL)")
        mStringURL                 = stringURL //Base URL
        mNSMutableData             = NSMutableData()// To strore Data
        mConnectionHeaders         = [String: String]()// Dictionary to set Data
        mStoreRequestDictionary    = NSMutableDictionary()// To store request
        key                        = " "
    }
    
    // initializer with DefaultBase URL and DefaultSeession
    public convenience  override init()
    {
        
        var sessionConfig:URLSessionConfiguration
        sessionConfig = URLSessionConfiguration.default
        self.init(stringURL:baseURL as NSString,sessionConfiguration:sessionConfig)
    }
    deinit
    {
        mNSURLSession.invalidateAndCancel()
        
    }
    
    //Add Headers That is required
    func setSessionHeader(_ headerName:NSString, value: String?)
    {
        //        guard let _ = mConnectionHeaders else
        //        {
        //            return
        //        }
        mConnectionHeaders![headerName as String] = value
        
    }
    
    //This function  shows we have Interested  in JSON only
    func addDefaultJSONHeader()
    {
        mNSMutableRequest?.addValue("application/json", forHTTPHeaderField: "Accept")
        mNSMutableRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var session:NSString?
        var sessionKey:String?
        session    = UserDefaults.standard.value(forKey: "session") as? NSString
        sessionKey = "session"
        //isSessionTokenExpiredDoctor = false
        if let sessions = session
        {
            if((!self.mPath.isEqual("/login"))||(!self.mPath.isEqual("/v2/login")))
            {
                print("------------->sessionToken added")
                
                mNSMutableRequest?.setValue(sessions as String, forHTTPHeaderField: sessionKey!)
            }
        }
        
    }
    
    //Configure MutableRequest For GetRequest
    func configureGetMutableRequest(_ path:String,parameters : Dictionary<String, Any>?)
    {
        self.mPath = path
        var stringURL:String = String()
        if path.range(of: "http") != nil
        {
            print("exists")
            stringURL = path
        }
        else
        {
            stringURL  = (mStringURL as String)+path
        }
        
        
        stringURL =  stringURL.replacingOccurrences(of: "//", with: "/", options:NSString.CompareOptions.literal, range: nil)
        //Can do with Alternate way
        stringURL =  stringURL.replacingOccurrences(of: ":/", with: "://", options:NSString.CompareOptions.literal, range: nil)
        
        if((self.mPath.isEqual("/diary/url")))
        {
            if let param = parameters
            {
                for( key, value) in param
                {
                    setSessionHeader(key as NSString, value: value as? NSString as String?)
                }
                
            }
        }
        else
        {
            if let param = parameters
            {
                var array = Array<String>()
                for( key, val) in param
                {
                    let newVal = val as? String
                    array.append(key+"="+newVal!.escaped)
                    
                }
                let final = array.joined(separator: "&")
                //final = dropLast(final)
                
                if (final as NSString).length > 0
                {
                    if stringURL.range(of: "graph?start=") != nil
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
        stringURL =  stringURL.replacingOccurrences(of: " ", with: "%20", options:NSString.CompareOptions.literal, range: nil)
        if let lURL = URL(string: stringURL)// Need to check if does not nil
        {
            print("All urls goes Here \(stringURL)")
            mNSMutableRequest = NSMutableURLRequest(url:lURL ) as URLRequest// Apend Path to Hit
            mNSMutableRequest?.timeoutInterval = 180
            addDefaultJSONHeader()// Added Json Header Only
            if let tempData = mConnectionHeaders
            {
                mNSMutableRequest?.allHTTPHeaderFields = tempData
            }
        }
        else
        {
            
        }
        //println(" Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    //Configure MutableRequest For GetRequest
    func configureGetMutableRequestWithHeaders(_ path:String,headerParameters : Dictionary<String, String>?)
    {
        self.mPath = path
        var stringURL:String = (mStringURL as String)+path
        
        stringURL =  stringURL.replacingOccurrences(of: "//", with: "/", options:NSString.CompareOptions.literal, range: nil)
        //Can do with Alternate way
        stringURL =  stringURL.replacingOccurrences(of: ":/", with: "://", options:NSString.CompareOptions.literal, range: nil)
        let lURL = URL(string: stringURL)// Need to check if does not nil
        
        print("All urls goes Here \(stringURL)")
        mNSMutableRequest = NSMutableURLRequest(url:lURL! ) as URLRequest// Apend Path to Hit
        mNSMutableRequest?.timeoutInterval = 180
        addDefaultJSONHeader()// Added Json Header Only
        if let param = headerParameters
        {
            for( key, value) in param
            {
                setSessionHeader(key as NSString, value: value as String?)
            }
        }
        if let tempData = mConnectionHeaders
        {
            mNSMutableRequest?.allHTTPHeaderFields = tempData
        }
        
        //println(" Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    //Configure MutableRequest For GetRequest
    func configureDeleteMutableRequest(_ path:String,parameters : Dictionary<String, String>?)
    {
        configureGetMutableRequest(path, parameters: parameters as Dictionary<String, Any>?)
        mNSMutableRequest?.httpMethod = "DELETE"
    }
    
    //Configure MutableRequest For PostRequest
    
    final func configurePostMutableRequest(_ path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?)//->NSMutableURLRequest
    {
        configureGetMutableRequest(path, parameters: parameters)
        
        mNSMutableRequest?.httpMethod = "POST"
        if let _ = postBody
        {
            do {
                mNSMutableRequest?.httpBody   = try JSONSerialization.data(withJSONObject: postBody!, options: JSONSerialization.WritingOptions())
            }
            catch  {
                print("Error \(error)")
            }
            
        }
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    final func configurePostMutableRequestWithHeader(_ path:String,headerParameters : Dictionary<String, String>?, postBody:Dictionary<String, AnyObject>?)//->NSMutableURLRequest
    {
        configureGetMutableRequestWithHeaders(path, headerParameters: headerParameters)
        mNSMutableRequest?.httpMethod = "POST"
        if let _ = postBody
        {
            do {
                mNSMutableRequest?.httpBody = try JSONSerialization.data(withJSONObject: postBody!, options: JSONSerialization.WritingOptions())
            }
            catch   {
                print("Error \(error)")
            }
            
        }
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    final func configurePutMutableRequestWithHeader(_ path:String,headerParameters : Dictionary<String, String>?, putBody:Dictionary<String, String>?)//->NSMutableURLRequest
    {
        configureGetMutableRequestWithHeaders(path, headerParameters: headerParameters)
        mNSMutableRequest?.httpMethod = "PUT"
        if let putBody = putBody
        {
            do {
                mNSMutableRequest?.httpBody = try JSONSerialization.data(withJSONObject: putBody, options: JSONSerialization.WritingOptions())
            }
            catch   {
                print("Error \(error)")
            }
            
        }
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    final func configureRawPostMutableRequest(_ postType:String, urlString:String, postBody:String?)//->NSMutableURLRequest
    {
        self.mPath = urlString
        let stringURL:String = urlString
        let lURL = URL(string: stringURL)// Need to check if does not nil
        print("JSON Raw post URL \(stringURL)")
        mNSMutableRequest = NSMutableURLRequest(url:lURL! ) as URLRequest// Apend Path to Hit
        mNSMutableRequest?.timeoutInterval = 180
        addDefaultJSONHeader()// Added Json Header Only
        
        if let tempData = mConnectionHeaders
        {
            mNSMutableRequest?.allHTTPHeaderFields = tempData
        }
        
        mNSMutableRequest?.httpMethod = postType
        if let postbody = postBody
        {
            let requestData = (postbody as NSString).data(using: String.Encoding.utf8.rawValue)
            mNSMutableRequest?.httpBody   =  requestData
            //[request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            let lenght = NSString(format: "%d", requestData!.count)
            mNSMutableRequest?.addValue(lenght as String, forHTTPHeaderField: "Content-Length")
            
        }
    }
    
    // Configure MutableRequest For Put Request
    func configurePutMutableRequest(_ path:String,parameters : Dictionary<String, Any>?, postBody:Dictionary<String, AnyObject>?)//->NSMutableURLRequest
    {
        configureGetMutableRequest(path, parameters: parameters)
        
        mNSMutableRequest?.httpMethod = "PUT"
        if let _ = postBody
        {
            do {
                mNSMutableRequest?.httpBody =  try JSONSerialization.data(withJSONObject: postBody!, options: JSONSerialization.WritingOptions())
            }
            catch  {
                print("Error \(error)")
            }
        }
        //println(" Should be Data \(mNSMutableRequest?.HTTPBody?.description) Type  \(mNSMutableRequest?.HTTPMethod)")
    }
    
    //This function basically work Append Path and PassParameter
    /*
     func get( path : String, parameters : Dictionary<String, String>?,getDataWithDictionary:(dataInDictionary:NSDictionary?, stringMessage:String)->() )
     {
     if let param = parameters
     {
     configureGetMutableRequest(path, parameters: parameters!)
     
     }else
     {
     configureGetMutableRequest(path, parameters:nil)
     }
     
     startSessionDataTaskWithRequest(
     {(dataInDictionary, stringMessage)->() in
     
     println("Dictionary in base get  \(dataInDictionary)")
     if let dict = dataInDictionary
     {
     getDataWithDictionary(dataInDictionary: dataInDictionary!, stringMessage:stringMessage)
     }
     else
     {
     getDataWithDictionary(dataInDictionary: nil, stringMessage:stringMessage)
     
     }
     
     })
     }*/
    
    // MARK:  With on finish and with on
    
    //This function is GET plus takes parameter headers and appends to http headers
    final func getWithHeader( _ path : String, headerParameters : Dictionary<String, String>?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
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
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    // MARK:  With on finish and with on
    // This function will add parameters to query ie. append as get params in URL
    final public func getWithOnFinish( _ path : String, parameters : Dictionary<String, String>?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        print("get  path" + "\(path)")
        if let _ = parameters
        {
            configureGetMutableRequest(path, parameters: parameters! as Dictionary<String, Any>?)
        }
        else
        {
            configureGetMutableRequest(path, parameters:nil)
        }
        
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    open func getDownloadWithOnFinish( _ path : String, parameters : Dictionary<String, String>?,onFinish:@escaping (_ response:AnyObject,_ url:Bool )->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        print("get  path" + "\(path)")
        if let _ = parameters
        {
            configureGetMutableRequest(path, parameters: parameters! as Dictionary<String, Any>?)
        }
        else
        {
            configureGetMutableRequest(path, parameters:nil)
        }
        
        mNSMutableRequest?.addValue("application/pdf", forHTTPHeaderField: "Accept")
        mNSMutableRequest?.setValue("application/pdf", forHTTPHeaderField: "Content-Type")
        let fileType = mimeTypeForPath(path)
        mNSMutableRequest?.addValue(fileType, forHTTPHeaderField: "Accept")
        mNSMutableRequest?.setValue(fileType, forHTTPHeaderField: "Content-Type")
        downloadRequest({ (response, url) -> () in
            onFinish(response, url)
            
        }) { (error) -> () in
            onError(error)
            
        }
    }
    
    
    // MARK: post json function
    public final func postJSONRawDataWithOnFinish(_ urlString:String,postBody:String?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
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
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    // MARK: this function does a request outside the ICH servers.
    final public func getWithCustomURL(_ urlString:String,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        configureRawPostMutableRequest("GET", urlString:  urlString , postBody: nil)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    // MARK: post function
    public final  func postDataWithOnFinish(_ path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        
        if let postBody = postBody
        {
            configurePostMutableRequest(path , parameters: parameters, postBody: postBody)
        }else
        {
            configurePostMutableRequest(path , parameters: parameters, postBody: nil)
        }
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    final  func postDataWithHeaderOnFinish(_ path:String,headerParameters : Dictionary<String, String>?, postBody:Dictionary<String, AnyObject>?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        if let postBody = postBody
        {
            configurePostMutableRequestWithHeader(path, headerParameters: headerParameters, postBody: postBody)
        }
        else
        {
            configurePostMutableRequestWithHeader(path, headerParameters: headerParameters, postBody: nil)
        }
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    /* Post String To The Server */
    /*
     func postData(path:String,parameters : Dictionary<String, String>?, postBody:Dictionary<String, String>?,getDataWithDictionary:(dataInDictionary:NSDictionary?, stringMessage:String)->())
     {
     if let postBody = postBody
     {
     configurePostMutableRequest(path , parameters: parameters!, postBody: postBody)
     }else
     {
     configurePostMutableRequest(path , parameters: parameters!, postBody: nil)
     }
     
     startSessionDataTaskWithRequest(
     {(dataInDictionary, stringMessage)->() in
     
     println("Dictionary in base post \(dataInDictionary)")
     if let dict = dataInDictionary
     {
     getDataWithDictionary(dataInDictionary: dataInDictionary!, stringMessage:stringMessage)
     }
     else
     {
     getDataWithDictionary(dataInDictionary: nil, stringMessage:stringMessage)
     
     }
     
     })
     }*/
    
    /*Put string to the server*/
    /*
     func putData(path:String,parameters : Dictionary<String, String>, postBody:Dictionary<String, String>?,getDataWithDictionary:(dataInDictionary:NSDictionary?, stringMessage:String)->())
     {
     configurePutMutableRequest(path , parameters: parameters, postBody: postBody!)
     startSessionDataTaskWithRequest(
     {(dataInDictionary, stringMessage)->() in
     
     println("Dictionary in base put \(dataInDictionary)")
     if let dict = dataInDictionary
     {
     getDataWithDictionary(dataInDictionary: dataInDictionary!, stringMessage:stringMessage)
     }
     else
     {
     getDataWithDictionary(dataInDictionary: nil, stringMessage:stringMessage)
     
     }
     
     })
     }*/
    
    /* Put data with on finish and onError*/
    public final  func putDataOnFinish(_ path:String,parameters : Dictionary<String, AnyObject>?, postBody:Dictionary<String, AnyObject>?, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        if let postBody = postBody
        {
            configurePutMutableRequest(path, parameters: parameters, postBody: postBody)
        }
        else
        {
            configurePutMutableRequest(path, parameters: parameters, postBody: nil)
        }
        
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    final func putDataWithHeaderOnFinish(_ path:String,headerParameters : Dictionary<String, String>?, putBody:Dictionary<String, String>?,onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        if let putBody = putBody
        {
            configurePutMutableRequestWithHeader(path, headerParameters: headerParameters, putBody: putBody)
        }
        else
        {
            configurePutMutableRequestWithHeader(path, headerParameters: headerParameters, putBody: nil)
        }
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
        
    }
    
    /*Delete data from server with onFinish and On error*/
    final public func deleteDataOnFinish(_ path:String,parameters : Dictionary<String, String>?, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        configureDeleteMutableRequest(path , parameters: parameters)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
    }
    
    /*Delete data from the server*/
    /*
     func deleteData(path:String,parameters : Dictionary<String, String>?,getDataWithDictionary:(dataInDictionary:NSDictionary?, stringMessage:String)->())
     {
     configureDeleteMutableRequest(path , parameters: parameters)
     startSessionDataTaskWithRequest(
     {(dataInDictionary, stringMessage)->() in
     println("Dictionary in base Delete \(dataInDictionary)")
     
     if let dict = dataInDictionary
     {
     getDataWithDictionary(dataInDictionary: dataInDictionary!, stringMessage:stringMessage)
     }
     else
     {
     getDataWithDictionary(dataInDictionary: nil, stringMessage:stringMessage)
     
     }
     })
     }
     */
    
    //To start Session task
    /*
     final  func startSessionDataTaskWithRequest(getDataWithDictionary:(dataInDictionary:NSDictionary?, stringMessage:String)->())
     {
     
     mNSURLSessionDataTask = mNSURLSession.dataTaskWithRequest(mNSMutableRequest!/*lNSMutableURLRequest*/, completionHandler:
     {
     data, response, error -> Void in
     if error != nil
     {
     println("\(error.localizedFailureReason)")
     getDataWithDictionary(dataInDictionary:nil,stringMessage:error.localizedDescription)
     }
     
     println("Response: \(response)")
     self.mNSHTTPURLResponse = response as? NSHTTPURLResponse// Check Data is HTTPURl Response
     println("Status Code \(self.mNSHTTPURLResponse?.statusCode)")
     
     var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
     // println("Body: \(strData)")
     
     var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &self.mNSError) as? NSDictionary
     
     if(self.mNSError != nil)
     {
     println(self.mNSError!.localizedDescription)
     let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
     println("Error could not parse JSON: '\(jsonStr)'")
     }
     else
     {
     if let parseJSON = json
     {
     // Okay, the parsedJSON is here, let's get the value for 'success' out of it
     var success = parseJSON["success"] as? Int// Check wheater 0 or 1
     println("Succes: \(success)")
     if success == 1
     {
     getDataWithDictionary(dataInDictionary: parseJSON, stringMessage:strData! as String)
     }
     else
     {
     println("Unsuccess event")
     }
     
     }
     else
     {
     let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
     println("Error could not parse JSON: \(jsonStr)")
     }
     }
     })
     
     
     
     println("status of task \(mNSURLSessionDataTask?.state)")
     mNSURLSessionDataTask?.resume()
     }
     */
    // MARK: Session taskData
    // To match exact
    
    // Response is in form of Data and deserializedResponse in form of dictionary
    final  func startSessionTaskDataTaskWithRequest(_ onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        print(" URL path of request" + "\(mNSMutableRequest?.url)")
        
        let lAppDelegate = UIApplication.shared.delegate as AnyObject
        if let _ = mNSMutableRequest
        {
            
            mNSURLSessionDataTask = mNSURLSession.dataTask(with: mNSMutableRequest!, completionHandler:
                {
                    data, response, error -> Void in
                    //println("data: \(data)")
                    self.mNSHTTPURLResponse = response as? HTTPURLResponse// Check Data is HTTPURl Response
                    let HttpResponseStatusClass = HttpResponseStatus()
                    var responseMessage:String
                    print("Status Code::  \(self.mNSHTTPURLResponse?.statusCode) & URL : \(self.mNSHTTPURLResponse?.url)" )
                    
                    // First check for any error
                    if error != nil
                    {
                        //print("Error description: \(error!.localizedFailureReason)")
                        let errors = errorDescription(error! as AnyObject)
                        onError(errors as AnyObject)
                    }
                    else
                    {
                        var savePassword:NSString = ""
                        
                        // Here Check for status code if it is not null
                        if let statusCode = self.mNSHTTPURLResponse?.statusCode
                        {
                            // Get a corresponding Status code message
                            responseMessage = HttpResponseStatusClass.getResponseStatusMessage(statusCode)
                            print("Status code message" + responseMessage )
                            
                            if(self.mNSHTTPURLResponse?.statusCode  == 401  && ( self.mNSHTTPURLResponse?.url?.lastPathComponent == "login" || self.mNSHTTPURLResponse?.url?.lastPathComponent == "changepassword" || self.mNSHTTPURLResponse?.url?.lastPathComponent == "forgotpassword"))
                            {
                                
                                if let dataInAnyObject = data
                                {
                                    do  {
                                        let json = try JSONSerialization.jsonObject(with: dataInAnyObject, options: .mutableLeaves) as? NSDictionary
                                        // Check  if there is any error while converting the data
                                        if(self.mNSError != nil)
                                        {
                                            print(self.mNSError!.localizedDescription)
                                            let jsonStr = String(data: dataInAnyObject, encoding: String.Encoding.utf8)
                                            print("Error could not parse JSON with new block:  '\(jsonStr)'")
                                            let errors = errorDescription(self.mNSError!)
                                            // If there is any error while converting data to dict then through error block
                                            onError(errors as AnyObject)
                                        }
                                        else
                                        {
                                            //Here we check is there converted json dict or not
                                            if let parseJSON = json
                                            {
                                                let success = parseJSON["success"] as? Int
                                                if success == 1
                                                {
                                                    onError(parseJSON as AnyObject)
                                                }
                                                else
                                                {
                                                    onError(parseJSON as AnyObject)
                                                }
                                            }
                                        }
                                    }
                                    catch   {
                                        print("Error \(error)")
                                    }
                                }
                                
                            }
                            else  if(self.mNSHTTPURLResponse?.statusCode  == 401 &&  savePassword.length == 0)
                            {
                                // "isTokenExpired"
                                UserDefaults.standard.set(true, forKey: "isTokenExpired")
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "tokenexpirednotification"), object: self)
                                
                                let errors = "Session Expired."
                                onError(errors as AnyObject)
                                
                            }
                            else  if(self.mNSHTTPURLResponse?.statusCode  == 401  && (self.mNSHTTPURLResponse?.url?.lastPathComponent != "login" || self.mNSHTTPURLResponse?.url?.lastPathComponent != "changepassword" || self.mNSHTTPURLResponse?.url?.lastPathComponent != "forgotpassword"))
                            {
                                //                                print(self.mNSMutableRequest?.URL)
                                //                                 print(self.mNSMutableRequest?.HTTPMethod)
                                
                                if  ((self.mNSMutableRequest?.url != nil && self.mNSMutableRequest?.httpMethod != nil)  )
                                {
                                    if let urlString = self.mNSMutableRequest?.url?.lastPathComponent
                                    {
                                        self.key = urlString + (self.mNSMutableRequest?.httpMethod)!
                                    }
                                }
                                
                                
                                
                                let dicRequest : NSMutableDictionary = NSMutableDictionary()
                                dicRequest.setValue(self.mNSMutableRequest, forKey: self.key)
                                
                                
                                
                                
                                
                                                            }
                            else  if(self.mNSHTTPURLResponse?.statusCode  == 500 && self.mNSHTTPURLResponse?.url?.lastPathComponent == "account")
                            {
                                var errors = "500"
                                onError(errors as AnyObject)
                                
                            }
                                // Response code 200 means success
                            else if(self.mNSHTTPURLResponse?.statusCode  == 200)
                            {
                                
                                
                                
                                // here we check if there is any data
                                if let dataInAnyObject = data
                                {
                                    do  {
                                        let json = try JSONSerialization.jsonObject(with: dataInAnyObject, options: .mutableLeaves) as? NSDictionary
                                        // println("DeserilizedDict:"+"\(json)")
                                        
                                        // Check  if there is any error while converting the data
                                        if(self.mNSError != nil)
                                        {
                                            
                                            print(self.mNSError!.localizedDescription)
                                            let jsonStr = String(data: dataInAnyObject, encoding: String.Encoding.utf8)
                                            print("Error could not parse JSON with new block:  '\(String(describing: jsonStr))'")
                                            let errors = errorDescription(self.mNSError!)
                                            // If there is any error while converting data to dict then through error block
                                            onError(errors as AnyObject)
                                            
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
                                                    onFinish(data! as AnyObject,parseJSON)
                                                }
                                                else
                                                {
                                                    //There is no success Key
                                                    print("This shows there is no Success key")
                                                    onFinish(data! as AnyObject,parseJSON)
                                                    
                                                    //onError(error: "Unsuccess event")
                                                }
                                            }
                                                // No need to check this but for surity used this else
                                            else
                                            {
                                                let jsonStr = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                                                
                                                //let errors  = (errorDescription("Error could not parse JSON: \(jsonStr)")) as AnyObject as AnyObject
                                                //onError(errors as AnyObject )
                                            }
                                        }
                                    }
                                    catch   {
                                        print("Error \(error)")
                                    }
                                    
                                    
                                }
                            }else
                            {
                                let errors = errorDescription(responseMessage as AnyObject)
                                onError(errors as AnyObject )
                            }
                            
                        }
                        
                    }
            })
        }
        mNSURLSessionDataTask?.resume()
    }
    //-------------------------------
    
    // download Image with just URL
    func downloadImageWithURL(_ urlString:String, downloadedImageData:@escaping (_ imageData:Data?, _ message:String)->())
    {
        
        let lNSURLSessionDownloadTask: URLSessionDownloadTask = mNSURLSession.downloadTask(with: URL(string: urlString)! , completionHandler:
        {
            urlLocation, response, error -> Void in
            
            var lImageData:Data?
            if let url = urlLocation
            {
                print("we get error\(urlLocation!.path)")
                lImageData = try? Data(contentsOf: url)
            }
            
            if let err = error
            {
                // in case of error I have to pass nil data
                downloadedImageData(Data(), "\(err.localizedDescription)")
            }else
            {
                downloadedImageData(lImageData!, "Success")
            }
        })
        lNSURLSessionDownloadTask.resume()
        
    }
    
    //MARK: Download pdf
    
    func downloadRequest(_ onFinish:@escaping (_ response:AnyObject,_ url:Bool)->(), onError:@escaping (_ error:AnyObject)->())
    {
        print(" URL path of request" + "\(mNSMutableRequest?.url)")
        
        let lAppDelegate = UIApplication.shared.delegate as AnyObject
        if let _ = mNSMutableRequest
        {
            mNSURLSessionDownloadTask = mNSURLSession.downloadTask(with: mNSMutableRequest!, completionHandler:
                {
                    url, response, error -> Void in
                    
                    
                    //println("data: \(data)")
                    print("Response: \(response)")
                    print("error: \(error)")
                    self.mNSHTTPURLResponse = response as? HTTPURLResponse// Check Data is HTTPURl Response
                    let HttpResponseStatusClass = HttpResponseStatus()
                    var responseMessage:String
                    print("Status Code::  \(self.mNSHTTPURLResponse?.statusCode) & URL : \(self.mNSHTTPURLResponse?.url)" )
                    
                    // First check for any error
                    if error != nil
                    {
                        //print("Error description: \(error!.localizedFailureReason)")
                        let errors = errorDescription(error! as AnyObject)
                        onError(errors as AnyObject)
                    }
                    else
                    {
                        var savePassword:NSString = ""
                        
                        // Here Check for status code if it is not null
                        if let statusCode = self.mNSHTTPURLResponse?.statusCode
                        {
                            // Get a corresponding Status code message
                            responseMessage = HttpResponseStatusClass.getResponseStatusMessage(statusCode)
                            print("Status code message" + responseMessage )
                            
                            if(self.mNSHTTPURLResponse?.statusCode  == 401  && ( self.mNSHTTPURLResponse?.url?.lastPathComponent == "login" || self.mNSHTTPURLResponse?.url?.lastPathComponent == "changepassword" || self.mNSHTTPURLResponse?.url?.lastPathComponent == "forgotpassword"))
                            {
                                let errors = "Username or Password not correct"
                                onError(errors as AnyObject)
                                
                            }else  if(self.mNSHTTPURLResponse?.statusCode  == 401 &&  savePassword.length == 0)
                            {
                                // "isTokenExpired"
                                UserDefaults.standard.set(true, forKey: "isTokenExpired")
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "tokenexpirednotification"), object: self)
                                
                                let errors = "Session Expired."
                                onError(errors as AnyObject)
                                
                            }
                                
                                
                            else  if(self.mNSHTTPURLResponse?.statusCode  == 401  && (self.mNSHTTPURLResponse?.url?.lastPathComponent != "login" || self.mNSHTTPURLResponse?.url?.lastPathComponent != "changepassword" || self.mNSHTTPURLResponse?.url?.lastPathComponent != "forgotpassword"))
                            {
                                if  ((self.mNSMutableRequest?.url != nil && self.mNSMutableRequest?.httpMethod != nil)  )
                                {
                                    if let urlString = self.mNSMutableRequest?.url?.lastPathComponent
                                    {
                                        self.key = urlString + (self.mNSMutableRequest?.httpMethod)!
                                    }
                                }
                                
                                let dicRequest : NSMutableDictionary = NSMutableDictionary()
                                dicRequest.setValue(self.mNSMutableRequest, forKey: self.key)
                                //lAppDelegate.performSelector("setStoreRequestDict:", withObject: [self.key: self.mNSMutableRequest] as! AnyObject as! NSMutableDictionary)
                                //                                dictData.setObject(self.mNSMutableRequest!, forKey: self.key)
                                
                            }
                                
                                // Response code 200 means success
                            else if(self.mNSHTTPURLResponse?.statusCode  == 200 )
                            {
                                
                                
                                
                                
                                if (url != nil)
                                {
                                    let fileManager = FileManager.default
                                    let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                    let writePath = documents.stringByAppendingPathComponent((response?.suggestedFilename)!)
                                    let documentURL = URL(fileURLWithPath: writePath)
                                    
                                    
                                    if fileManager.fileExists(atPath: documentURL.path)
                                    {
                                        do
                                        {
                                            try  fileManager.replaceItem(at: documentURL, withItemAt: url!, backupItemName: nil, options: FileManager.ItemReplacementOptions.usingNewMetadataOnly, resultingItemURL: nil)
                                        }
                                        catch
                                        {
                                            onError("error" as AnyObject)
                                            
                                        }
                                    }else
                                    {
                                        do
                                        {
                                            try fileManager.moveItem(at: url!, to: documentURL)
                                        }
                                        catch
                                        {
                                            onError("error" as AnyObject)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                onFinish(response!, true)
                                
                                
                            }else
                            {
                                let errors = errorDescription(responseMessage as AnyObject)
                                onError(errors as AnyObject )
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

func errorDescription(_ error:AnyObject)->String
{
    let _:NSDictionary =  ["success":"0", "message":error.description]
    let errorinString = error.description
    
    return errorinString!;
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
    func getResponseStatusMessage(_ statusCode:Int)->String
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
    func configureMediaRequest(_ methodType:String, path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String )
    {
        let boundary = String.generateBoundaryString()//"---------------------------14737809831466499882746641449"
        
        configureGetMutableRequest(path, parameters:headerParam as Dictionary<String, Any>?)
        mNSMutableRequest!.httpMethod = methodType
        mNSMutableRequest!.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        mNSMutableRequest!.httpBody = createBodyWithParameters(name, mediaPaths: mediaPaths, boundary: boundary, bodyDict: bodyDict)
    }
    
    func configurePostMediaRequest(_ path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String)
    {
        configureMediaRequest("POST", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
    }
    
    func configurePutMediaRequest(_ path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String)
    {
        configureMediaRequest("PUT", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
    }
    
    fileprivate func createBodyWithParameters( _ name: String?, mediaPaths: [String]?, boundary: String, bodyDict:Dictionary<String, String>?) -> Data
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
                let data = try? Data(contentsOf: URL(fileURLWithPath: path))
                let mimetype = mimeTypeForPath(path)
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(name!)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.append(data!)
                body.appendString("\r\n")
            }
        }
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    fileprivate func mimeTypeForPath(_ path: String) -> String
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
    
    public final func postMediaWithOnFinish(_ path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        configurePostMediaRequest(path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
    }
    
    public final func putMediaWithOnFinish(_ path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, String>?, name:String, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        configurePutMediaRequest(path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
    }
    
    //MARK: Scrapbook Media Send
    
    public final func postSBMediaWithOnFinish(_ path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, AnyObject>?, name:[String]?, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        configureSBMediaRequest("POST", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
    }
    
    final func putSBMediaWithOnFinish(_ path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, AnyObject>?, name:[String]?, onFinish:@escaping (_ response:AnyObject,_ deserializedResponse:AnyObject)->(), onError:@escaping (_ error:AnyObject)->())
    {
        configureSBMediaRequest("PUT", path: path, headerParam: headerParam, mediaPaths: mediaPaths, bodyDict:bodyDict, name:name)
        startSessionTaskDataTaskWithRequest(
            {
                (response, deserializedResponse) -> () in
                onFinish(response, deserializedResponse)
        },
            onError: { (error) -> () in
                onError(error)
        })
    }
    
    func configureSBMediaRequest(_ methodType:String, path:String, headerParam:Dictionary<String, String>?, mediaPaths:[String]?, bodyDict:Dictionary<String, AnyObject>?, name:[String]? )
    {
        //Fixed Multipart Post
        //NSString.generateBoundary() not working in Swift 3
        let boundary = String.generateBoundaryString() // "---------------------------14737809831466499882746641449"
        /*"---------------------------14737809831466499882746641449"*///NSString.generateBoundary()
        configureGetMutableRequest(path, parameters:headerParam as Dictionary<String, Any>?)
        mNSMutableRequest!.httpMethod = methodType
        mNSMutableRequest!.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        mNSMutableRequest!.httpBody = createSBBodyWithParameters(name, mediaPaths: mediaPaths, boundary: boundary, bodyDict: bodyDict)
    }
    
    fileprivate func createSBBodyWithParameters( _ name: [String]?, mediaPaths: [String]?, boundary: String, bodyDict:Dictionary<String, AnyObject>?) -> Data
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
        
        if (mediaPaths?.count)! > 0
        {
            for i in 0..<(mediaPaths?.count)!
            {
                let index = name![i]
                let path = mediaPaths![i]
                let filename = path.lastPathComponent
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    let mimetype = mimeTypeForPath(path)
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(index)\"; filename=\"\(filename)\"\r\n")
                    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                    body.append(data)
                    body.appendString("\r\n")
                }
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
}

//Mark:Mutabledata
extension NSMutableData
{
    func appendString(_ string: String)
    {
        print(string)
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension String
{
    static func generateBoundaryString()->String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

