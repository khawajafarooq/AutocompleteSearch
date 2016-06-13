//
//  NetworkUtility.swift
//  VPCurrencyConverter
//
//  Created by GIB on 5/10/16.
//  Copyright © 2016 Veripark. All rights reserved.
//

import UIKit

public class SANetworkUtility: NSObject {

 
    // check the internet connectivity
    class func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability.reachabilityForInternetConnection()
            return (reachability.currentReachabilityStatus != Reachability.NetworkStatus.NotReachable)
        }
        catch{
            return false
        }
    }
    
    // encode readable value
    class func urlEncodeValue(var value:String?, encoding:NSStringEncoding) -> String
    {
        if let _ = value
        {
            // obj is a string. Do something with string
        }
        else
        {
            // obj is not a string
            value = value?.debugDescription
        }
        
        let customAllowedSet =  NSCharacterSet(charactersInString:"!*'();:@&=+$,/?%#[]").invertedSet
        let escapedString = value!.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        
        return escapedString!
    }

}