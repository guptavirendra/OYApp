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
	static func get(_ url: String, auth: (String, String)? = nil) -> SignalProducer<Result<Any, NSError>, NSError> {
		NSLog("STHttp.get [%@]", url)
		let urlRequest = STHttp.urlRequest(url, contentType: "application/json", auth: auth)
		urlRequest.httpMethod = "GET"
		return STHttp.doRequest(urlRequest)
	}
	
	static func post(_ url: String, data: [AnyHashable: Any], auth: (String, String)? = nil) -> SignalProducer<Result<Any, NSError>, NSError> {
		//NSLog("STHttp.post [%@] data %@", url, data)
		let urlRequest = STHttp.urlRequest(url, contentType: "application/json", auth: auth)
		urlRequest.httpMethod = "POST"
		do {
            
			let theJSONData =  try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 0))
			urlRequest.httpBody = theJSONData
            
			return STHttp.doRequest(urlRequest)
		} catch {
			assert(false, "SJSONSerialization.dataWithJSONObject failed e")
			return SignalProducer<Result<Any, NSError>, NSError>.empty //TODO! Return an error!
		}
	}
    
    
    static func postImage(_ url: String, data: [AnyHashable: Any], auth: (String, String)? = nil, image: UIImage, mediaPath:[String]) -> SignalProducer<String, NSError> {
        let boundary = String.generateBoundary()
        let urlRequest = STHttp.urlRequest(url, contentType: "multipart/form-data; boundary=\(boundary)", auth: nil)
        urlRequest.httpMethod = "POST"
        
        
        urlRequest.httpBody = createBodyWithParameters("image", mediaPaths: mediaPath, boundary: boundary, bodyDict: nil) //
        return STHttp.doRequest(urlRequest)
             .map {
                //Grab the fetched url
                (result: Result<Any, NSError>) -> String in
                if (result.value != nil) {
                    let dict = result.value as! JSON
                    let urls = dict["image"].stringValue
                    
                    let url = URL(string: urls)
                    
                    
                    //SDImageCache.sharedImageCache().storeImage(image, forKey: self.cacheKey(url!), completion: nil)
                  /*Small Talk */  SDImageCache.shared().store(image, forKey: self.cacheKey(url!))
                    return urls
                }
        return ""
        }
    }
	
    static func getFromS3(_ bucket: String, key: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
        return signGetIfNotInCache(bucket, key: key)
            .flatMap(FlattenStrategy.merge, transform: {
                url in
                return STHttp.doImageGet(url).observeOn(QueueScheduler()).retryWithDelay(15, interval: 5, onScheduler: QueueScheduler())
            })
            .retry(2)
    }
	
	static func getImage(_ url: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
		if url == "" {
			return SignalProducer(error: NSError(domain: "smalltalk.getimage", code: -1, userInfo: [ NSLocalizedDescriptionKey: "empty url"]))
		}
		
		return STHttp.doImageGet(url).observeOn(QueueScheduler()).retryWithDelay(15, interval: 5, onScheduler: QueueScheduler())
	}
	
	static func getFromCache(_ bucket: String, key: String) -> UIImage? {
		let url = self.cacheKey(self.urlWithoutSigning(bucket, key:key))
		return SDImageCache.shared().imageFromDiskCache(forKey: url)
	}
	
    static func putToS3(_ bucket: String, key: String, image: UIImage, filePath:[String]) -> SignalProducer<Result<Any, NSError>, NSError>
    {
        
        return STHttp.postImage("\(Configuration.mainApi)/send_message?app_user_id=31653&app_user_token=%242y%2410%246PRbH2TSZYMWqWuvQJcO%2FuW05ZnNXDYB4p7Bj8eogEJ9VVacfEJbK", data: [:], image: image, mediaPath:filePath ).flatMap(FlattenStrategy.latest, transform: { (url: String) -> SignalProducer<Result<Any, NSError>, NSError> in
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
    
    
    
    static func createBodyWithParameters( _ name: String?, mediaPaths: [String]?, boundary: String, bodyDict:Dictionary<String, String>?) -> Data
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
        return body
    }
    
   static fileprivate func mimeTypeForPath(_ path: String) -> String
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
	static fileprivate func signGetIfNotInCache(_ bucket: String, key: String) -> SignalProducer<String, NSError>
    {
		//If image is already in cache, there is no need to sign - we'll just pass through the cache key for doS3Get which will fetch it form cache
		let url = urlWithoutSigning(bucket, key: key)
		let cachedUrl = self.cacheKey(url)
		let imageInCache = SDImageCache.shared().diskImageExists(withKey: cachedUrl)
		if (imageInCache) {
			return SignalProducer(values: [cachedUrl])
		}
		
		//Not in cache, sign to get the actual s3 url
		return STHttp.sign("GET", bucket: bucket, key: key)
	}
	
	static fileprivate func urlWithoutSigning(_ bucket: String, key: String) -> URL {
		return URL(string: "http://demo.varyavega.co.in/shoutaboutapp/public/uploads/chat/images/\(key)")!
	}
	
	static fileprivate func AWSUrl(_ bucket: String, key: String) -> URL {
		return URL(string: "https://\(bucket).s3.amazonaws.com/\(key)")!
	}
	
	//Do AWS signing
	static fileprivate func sign(_ method: String, bucket: String, key: String) -> SignalProducer<String, NSError>
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
	
	static fileprivate func cacheKey(_ url: URL) -> String {
		//Url without query parameters (since they keep changing for every query)
		let newUrl = NSURL(scheme: url.scheme, host: url.host!, path: url.path!) as? URL
		return newUrl!.absoluteString
	}
	
	static fileprivate func doImageGet(_ strUrl: String) -> SignalProducer<Result<(UIImage, String), NSError>, NSError> {
		NSLog("doImageGet [%@]", strUrl)
		let url: URL = URL(string: strUrl)!
		let cachedUrl = self.cacheKey(url)
       //let imageInCache =  SDImageCache.sharedImageCache().diskImageExistsWithKey(cachedUrl, completion: nil)
        
		let imageInCache = SDImageCache.shared().diskImageExists(withKey: cachedUrl)
		if (imageInCache) {
			let image = SDImageCache.shared().imageFromDiskCache(forKey: strUrl)
			let retResult = Result<(UIImage, String), NSError>(value: (image!, strUrl))

			return SignalProducer(values: [retResult])
		}
		
		let urlRequest = STHttp.urlRequest(strUrl, contentType: nil, auth: nil)
		urlRequest.httpMethod = "GET"
		return STHttp.doRequest(urlRequest, deserializeJSON: false).map {
			result in
			if result.value != nil
            {
                if let data = result.value as? Data
                {
                    if let image = UIImage(data: data)
                    {
				
                        SDImageCache.shared().store(image, forKey: self.cacheKey(url))
                        let retResult = Result<(UIImage, String), NSError>(value: (image, strUrl))
                        return retResult
                    }
                }
			}
			
			return Result<(UIImage, String), NSError>(error: result.error!)
		}
	}
	
	static fileprivate func urlRequest(_ url: String, contentType: String?, auth: (String, String)?) -> NSMutableURLRequest {
		let urlRequest = NSMutableURLRequest(url: URL(string: url)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        if contentType != nil {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
		if auth != nil
        {
            
            
			let (username, password) = auth!
			let loginString = "\(username):\(password)"
			let loginData: Data = loginString.data(using: String.Encoding.utf8)!
			_ = loginData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
			
			//urlRequest.setValue(username, forHTTPHeaderField: "app_user_id")
           // urlRequest.setValue(password, forHTTPHeaderField: "app_user_token")
		}
		return urlRequest
	}
	
	static fileprivate func doRequest(_ urlRequest: URLRequest, deserializeJSON: Bool = true) -> SignalProducer<Result<Any, NSError>, NSError> {
		return STHttp.networkProducer(urlRequest)
			.flatMap(FlattenStrategy.merge, transform: {
				(incomingData: Data, response: URLResponse) in
				return SignalProducer<(Data, URLResponse), NSError> { observer, disposable in
					//NSLog("Response %@ %@", response, NSThread.isMainThread())
					let statusCode = (response as! HTTPURLResponse).statusCode
					if  statusCode >= 200 && statusCode < 299
                    {
                        do {
                        let json = try JSONSerialization.jsonObject(with: incomingData, options: JSONSerialization.ReadingOptions(rawValue: 0))
                        print(json)
                        }catch {}
						observer.sendNext((incomingData, response))
					} else {
						var errorSent = false
						if incomingData.count > 0 {
							if deserializeJSON {
								do {
									let json = try JSONSerialization.jsonObject(with: incomingData, options: JSONSerialization.ReadingOptions(rawValue: 0))
									observer.sendFailed(
											NSError(domain: "smalltalk.http",
												code: statusCode,
												userInfo: [ NSLocalizedDescriptionKey: "\(HTTPURLResponse.localizedString(forStatusCode: statusCode)) + \(json)"]
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
									userInfo: [ NSLocalizedDescriptionKey: "\(HTTPURLResponse.localizedString(forStatusCode: statusCode))"]
								)
							)
						}
					}
					
					observer.sendCompleted()
				}
			})
			.map {
				(incomingData: Data, response: URLResponse) -> Result<Any, NSError> in
				if incomingData.count > 0 {
					if deserializeJSON {
						let json = JSON(data: incomingData)
						return Result.success(json) //Result<JSON, NSError>(value: json)
					} else {
						return Result.success(incomingData)
					}
				}
				
				return Result.success("")
		}
	}
	
	static func networkProducer(_ urlRequest: URLRequest) -> SignalProducer<(Data, URLResponse), NSError>
	{
		return URLSession.shared.rac_dataWithRequestBackgroundSupport(urlRequest)
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
