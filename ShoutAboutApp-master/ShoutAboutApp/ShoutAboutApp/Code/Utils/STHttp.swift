//
//  SMHttp.swift
//  smalltalk
//
//  Created by Mikko Hämäläinen on 23/09/15.
//  Copyright (c) 2015 Mikko Hämäläinen. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import SDWebImage
import SwiftyJSON
import MobileCoreServices


extension String
{
    /**
     A simple extension to the String object to encode it for web request.
     
     :returns: Encoded version of of string it was called as.
     */
    
    
    /*
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
  */
    /* Small talk block*/
}

struct STHttp {
	static func get(url: String, auth: (String, String)? = nil) -> SignalProducer<Result<Any, NSError>, NSError> {
		NSLog("STHttp.get [%@]", url)
		let urlRequest = STHttp.urlRequest(url, contentType: "application/json", auth: auth)
		urlRequest.HTTPMethod = "GET"
		return STHttp.doRequest(urlRequest)
	}
	
	static func post(url: String, data: [NSObject: AnyObject], auth: (String, String)? = nil) -> SignalProducer<Result<Any, NSError>, NSError> {
		//NSLog("STHttp.post [%@] data %@", url, data)
		let urlRequest = STHttp.urlRequest(url, contentType: "application/json", auth: auth)
		urlRequest.HTTPMethod = "POST"
		do {
            
			let theJSONData =  try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
			urlRequest.HTTPBody = theJSONData
            
			return STHttp.doRequest(urlRequest)
		} catch {
			assert(false, "SJSONSerialization.dataWithJSONObject failed e")
			return SignalProducer<Result<Any, NSError>, NSError>.empty //TODO! Return an error!
		}
	}
    
    
    static func postImage(url: String, data: [NSObject: AnyObject], auth: (String, String)? = nil, image: UIImage, mediaPath:[String]) -> SignalProducer<String, NSError> {
        let boundary = String.generateBoundaryString()
        let urlRequest = STHttp.urlRequest(url, contentType: "multipart/form-data; boundary=\(boundary)", auth: nil)
        urlRequest.HTTPMethod = "POST"
        
        
        urlRequest.HTTPBody = createBodyWithParameters("image", mediaPaths: mediaPath, boundary: boundary, bodyDict: nil) //
        return STHttp.doRequest(urlRequest)
             .map {
                //Grab the fetched url
                (result: Result<Any, NSError>) -> String in
                if (result.value != nil) {
                    let dict = result.value as! JSON
                    let urls = dict["image"].stringValue
                    
                    let url = NSURL(string: urls)
                    
                    
                    //SDImageCache.sharedImageCache().storeImage(image, forKey: self.cacheKey(url!), completion: nil)
                  /*Small Talk */  SDImageCache.sharedImageCache().storeImage(image, forKey: self.cacheKey(url!))
                    return urls
                }
        return ""
        }
    }
	
    static func getFromS3(bucket: String, key: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
        return signGetIfNotInCache(bucket, key: key)
            .flatMap(FlattenStrategy.Merge, transform: {
                url in
                return STHttp.doImageGet(url).observeOn(QueueScheduler()).retryWithDelay(15, interval: 5, onScheduler: QueueScheduler())
            })
            .retry(2)
    }
	
	static func getImage(url: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
		if url == "" {
			return SignalProducer(error: NSError(domain: "smalltalk.getimage", code: -1, userInfo: [ NSLocalizedDescriptionKey: "empty url"]))
		}
		
		return STHttp.doImageGet(url).observeOn(QueueScheduler()).retryWithDelay(15, interval: 5, onScheduler: QueueScheduler())
	}
	
	static func getFromCache(bucket: String, key: String) -> UIImage? {
		let url = self.cacheKey(self.urlWithoutSigning(bucket, key:key))
		return SDImageCache.sharedImageCache().imageFromDiskCacheForKey(url)
	}
	
    static func putToS3(bucket: String, key: String, image: UIImage, filePath:[String]) -> SignalProducer<Result<Any, NSError>, NSError>
    {
        
        return STHttp.postImage("\(Configuration.mainApi)/send_message?app_user_id=31653&app_user_token=%242y%2410%246PRbH2TSZYMWqWuvQJcO%2FuW05ZnNXDYB4p7Bj8eogEJ9VVacfEJbK", data: [:], image: image, mediaPath:filePath ).flatMap(FlattenStrategy.Latest, transform: { (url: String) -> SignalProducer<Result<Any, NSError>, NSError> in
            return SignalProducer<Result<Any, NSError>, NSError>.empty

            
        })
        /*.flatMap(FlattenStrategy.Merge, transform:
            {
                (url: String) -> SignalProducer<Result<Any, NSError>, NSError> in
            //Cache the uploaded image
            let url = NSURL(string: url)
            SDImageCache.sharedImageCache().storeImage(image, forKey: self.cacheKey(url!))
                
             return   SignalProducer<Result<Any, NSError>, NSError>.empty
            
                
        })*/

        
        
		/*return STHttp.sign("POST", bucket: bucket, key: key)
			.flatMap(FlattenStrategy.Merge, transform:
                {
				(url: String) -> SignalProducer<Result<Any, NSError>, NSError> in
                    let boundary = String.generateBoundaryString()
				let urlRequest = STHttp.urlRequest(url, contentType: "multipart/form-data; boundary=\(boundary)", auth: nil)
				urlRequest.HTTPMethod = "POST"
                
                
				urlRequest.HTTPBody =  self.createBodyWithParameters("image", image: image, boundary: boundary, bodyDict: nil) //UIImageJPEGRepresentation(image, 0.75)
				return STHttp.doRequest(urlRequest)
					.on {
						_ in
						//Cache the uploaded image
						let url = NSURL(string: url)
						SDImageCache.sharedImageCache().storeImage(image, forKey: self.cacheKey(url!))
				}
			})*/
			//.retry(2)
	}
    
    
    
    static func createBodyWithParameters( name: String?, mediaPaths: [String]?, boundary: String, bodyDict:Dictionary<String, String>?) -> NSData
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
    
   static private func mimeTypeForPath(path: String) -> String
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


    

	
	//Private methods
	static private func signGetIfNotInCache(bucket: String, key: String) -> SignalProducer<String, NSError>
    {
		//If image is already in cache, there is no need to sign - we'll just pass through the cache key for doS3Get which will fetch it form cache
		let url = urlWithoutSigning(bucket, key: key)
		let cachedUrl = self.cacheKey(url)
		let imageInCache = SDImageCache.sharedImageCache().diskImageExistsWithKey(cachedUrl)
		if (imageInCache) {
			return SignalProducer(values: [cachedUrl])
		}
		
		//Not in cache, sign to get the actual s3 url
		return STHttp.sign("GET", bucket: bucket, key: key)
	}
	
	static private func urlWithoutSigning(bucket: String, key: String) -> NSURL {
		return NSURL(string: "http://demo.varyavega.co.in/shoutaboutapp/public/uploads/chat/images/\(key)")!
	}
	
	static private func AWSUrl(bucket: String, key: String) -> NSURL {
		return NSURL(string: "https://\(bucket).s3.amazonaws.com/\(key)")!
	}
	
	//Do AWS signing
	static private func sign(method: String, bucket: String, key: String) -> SignalProducer<String, NSError>
    {
        let data = [String:AnyObject
			//"method": method,
			//"bucket": bucket,
			//"image": key
		]()
		return STHttp.post("\(Configuration.mainApi)//send_message?app_user_id=31653&app_user_token=%242y%2410%246PRbH2TSZYMWqWuvQJcO%2FuW05ZnNXDYB4p7Bj8eogEJ9VVacfEJbK", data: data, auth:(User.username, User.token))
		.map {
			//Grab the fetched url
			(result: Result<Any, NSError>) -> String in
			if (result.value != nil) {
				let dict = result.value as! JSON
				return dict["url"].stringValue
			}
			
			return "http://demo.varyavega.co.in/shoutaboutapp/public/uploads/chat/images/1492280135.png"
		}
	}
	
	static private func cacheKey(url: NSURL) -> String {
		//Url without query parameters (since they keep changing for every query)
		let newUrl = NSURL(scheme: url.scheme, host: url.host!, path: url.path!)
		return newUrl!.absoluteString
	}
	
	static private func doImageGet(strUrl: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
		NSLog("doImageGet [%@]", strUrl)
		let url: NSURL = NSURL(string: strUrl)!
		let cachedUrl = self.cacheKey(url)
       //let imageInCache =  SDImageCache.sharedImageCache().diskImageExistsWithKey(cachedUrl, completion: nil)
        
		let imageInCache = SDImageCache.sharedImageCache().diskImageExistsWithKey(cachedUrl)
		if (imageInCache) {
			let image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(strUrl)
			let retResult = Result<(UIImage, String), NSError>(value: (image!, strUrl))

			return SignalProducer(values: [retResult])
		}
		
		let urlRequest = STHttp.urlRequest(strUrl, contentType: nil, auth: nil)
		urlRequest.HTTPMethod = "GET"
		return STHttp.doRequest(urlRequest, deserializeJSON: false).map {
			result in
			if result.value != nil
            {
                if let data = result.value as? NSData
                {
                    if let image = UIImage(data: data)
                    {
				
                        SDImageCache.sharedImageCache().storeImage(image, forKey: self.cacheKey(url))
                        let retResult = Result<(UIImage, String), NSError>(value: (image, strUrl))
                        return retResult
                    }
                }
			}
			
			return Result<(UIImage, String), NSError>(error: result.error!)
		}
	}
	
	static private func urlRequest(url: String, contentType: String?, auth: (String, String)?) -> NSMutableURLRequest {
		let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        if contentType != nil {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
		if auth != nil
        {
            
            
			let (username, password) = auth!
			let loginString = "\(username):\(password)"
			let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
			_ = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
			
			//urlRequest.setValue(username, forHTTPHeaderField: "app_user_id")
           // urlRequest.setValue(password, forHTTPHeaderField: "app_user_token")
		}
		return urlRequest
	}
	
	static private func doRequest(urlRequest: NSURLRequest, deserializeJSON: Bool = true) -> SignalProducer<Result<Any, NSError>, NSError> {
		return STHttp.networkProducer(urlRequest)
			.flatMap(FlattenStrategy.Merge, transform: {
				(incomingData: NSData, response: NSURLResponse) in
				return SignalProducer<(NSData, NSURLResponse), NSError> { observer, disposable in
					//NSLog("Response %@ %@", response, NSThread.isMainThread())
					let statusCode = (response as! NSHTTPURLResponse).statusCode
					if  statusCode >= 200 && statusCode < 299
                    {
                        do {
                        let json = try NSJSONSerialization.JSONObjectWithData(incomingData, options: NSJSONReadingOptions(rawValue: 0))
                        print(json)
                        }catch {}
						observer.sendNext((incomingData, response))
					} else {
						var errorSent = false
						if incomingData.length > 0 {
							if deserializeJSON {
								do {
									let json = try NSJSONSerialization.JSONObjectWithData(incomingData, options: NSJSONReadingOptions(rawValue: 0))
									observer.sendFailed(
											NSError(domain: "smalltalk.http",
												code: statusCode,
												userInfo: [ NSLocalizedDescriptionKey: "\(NSHTTPURLResponse.localizedStringForStatusCode(statusCode)) + \(json)"]
										)
									)
									errorSent = true
								} catch {}
							}
						}
						if !errorSent {
							//If no incomingData was sent in error
							observer.sendFailed(
								NSError(domain: "smalltalk.http",
									code: statusCode,
									userInfo: [ NSLocalizedDescriptionKey: "\(NSHTTPURLResponse.localizedStringForStatusCode(statusCode))"]
								)
							)
						}
					}
					
					observer.sendCompleted()
				}
			})
			.map {
				(incomingData: NSData, response: NSURLResponse) -> Result<Any, NSError> in
				if incomingData.length > 0 {
					if deserializeJSON {
						let json = JSON(data: incomingData)
						return Result.Success(json) //Result<JSON, NSError>(value: json)
					} else {
						return Result.Success(incomingData)
					}
				}
				
				return Result.Success("")
		}
	}
	
	static func networkProducer(urlRequest: NSURLRequest) -> SignalProducer<(NSData, NSURLResponse), NSError>
	{
		return NSURLSession.sharedSession().rac_dataWithRequestBackgroundSupport(urlRequest)
			.retry(2)
	}
}
/*
 Small Talk comment
 */
/*
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
    static func generateBoundaryString()->String
    {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}
 
 */