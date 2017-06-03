
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

open class NetworkConnectivity
{
    
    class func isConnectedToNetwork() -> Bool
    {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
                 
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability as! SCNetworkReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable

        let needsConnection = flags == .connectionRequired
        
        //return isReachable && !needsConnection
        
        
        return getNetworkType()
    }
    
    
    
   class func getNetworkType()->Bool
    {
        do{
            let reachability:Reachability = try Reachability.forInternetConnection()
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
