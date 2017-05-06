
//
//  NetworkConnectivity.swift
//  ShoutAboutAppV
//
//  Created by VIRENDRA GUPTA on 05/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//


import Foundation
import SystemConfiguration
import Reachability
import CoreTelephony

public class NetworkConnectivity
{
    
    class func isConnectedToNetwork() -> Bool
    {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable

        let needsConnection = flags == .ConnectionRequired
        
        //return isReachable && !needsConnection
        
        
        return getNetworkType()
    }
    
    
    
   class func getNetworkType()->Bool
    {
        do{
            let reachability:Reachability = try Reachability.reachabilityForInternetConnection()
            do{
                try reachability.startNotifier()
                let status = reachability.currentReachabilityStatus()
                if(status == .NotReachable)
                {
                    return false
                }else if (status == .ReachableViaWiFi)
                {
                    return  true ///"Wifi"
                }else if (status == .ReachableViaWWAN)
                {
                    let networkInfo = CTTelephonyNetworkInfo()
                    let carrierType = networkInfo.currentRadioAccessTechnology
                    switch carrierType{
                    case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?: return true //"2G"
                    case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?: return  true//"3G"
                    case CTRadioAccessTechnologyLTE?: return true //"4G"
                    default: return false//""
                    }
                }else
                {
                    return false//""
                }
            }catch
            {
                return false//""
            }
            
        }catch
        {
            return false//""
        }
    }
}
